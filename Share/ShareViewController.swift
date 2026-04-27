//
//  ShareViewController.swift
//  ShareExtension
//
//  Created by Yannick Juarez on 27/04/2026.
//

import UIKit
import SwiftUI
import UniformTypeIdentifiers
import UserNotifications
import os

/// Plain UIViewController — no native compose sheet, processes image immediately.
final class ShareViewController: UIViewController {

    private let logger = Logger(subsystem: "com.yannickjuarez.React.ShareExtension", category: "Share")

    private let appGroupIdentifier = "group.com.yannickjuarez.React"

    private let inboxFolderName = "SharedReactInbox"
    private let manifestFileName = "latest.json"

    struct Manifest: Codable {
        let imageFileName: String
        let hint: String
        let createdAt: Date
    }

    private struct SharedImagePayload {
        let data: Data
        let fileExtension: String
    }

    private static let reactNotificationIdentifier = "com.react.demo.incomingReact"

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        showSpinner()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Task { await handleShare() }
    }

    // MARK: - Share handling

    private func handleShare() async {
        guard let payload = await loadFirstImagePayload() else {
            complete(withError: "Aucune image détectée dans le partage.")
            return
        }
        guard let image = UIImage(data: payload.data) else {
            complete(withError: "Impossible de lire cette image.")
            return
        }
        await MainActor.run { showPreview(image: image, payload: payload) }
    }

    @MainActor
    private func showPreview(image: UIImage, payload: SharedImagePayload) {
        let previewView = RequestReactView(
            sharedImage: image,
            onCancel: { [weak self] in
                self?.complete(withError: "Partage annulé.")
            },
            onContinue: { [weak self] hint in
                guard let self else { return }
                do {
                    try self.persistImageToAppGroup(payload, hint: hint)
                    self.scheduleIncomingReactNotification()
                    self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
                } catch {
                    self.complete(withError: "Impossible de sauvegarder cette image.")
                }
            }
        )

        let host = UIHostingController(rootView: previewView.preferredColorScheme(ColorScheme.dark))
        addChild(host)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        host.view.backgroundColor = UIColor.black
        view.addSubview(host.view)
        NSLayoutConstraint.activate([
            host.view.topAnchor.constraint(equalTo: view.topAnchor),
            host.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            host.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        host.didMove(toParent: self)
    }

    private func loadFirstImagePayload() async -> SharedImagePayload? {
        let extensionItems = extensionContext?.inputItems.compactMap { $0 as? NSExtensionItem } ?? []
        let providers = extensionItems.flatMap { $0.attachments ?? [] }

        logger.debug("Share input items: \(extensionItems.count), providers: \(providers.count)")

        for provider in providers where provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
            logger.debug("Provider registered types: \(provider.registeredTypeIdentifiers.joined(separator: ", "))")
            if let payload = await loadImagePayload(from: provider) {
                return payload
            }
        }

        logger.error("No image payload could be loaded from any provider")
        return nil
    }

    private func loadImagePayload(from provider: NSItemProvider) async -> SharedImagePayload? {
        let concreteTypes = preferredConcreteImageTypes(from: provider)

        for imageType in concreteTypes {
            if let dataPayload = await tryLoadDataRepresentation(from: provider, typeIdentifier: imageType.identifier) {
                return dataPayload
            }

            if let filePayload = await tryLoadFileRepresentation(from: provider, typeIdentifier: imageType.identifier) {
                return filePayload
            }
        }

        if provider.canLoadObject(ofClass: UIImage.self),
           let image = await tryLoadUIImage(from: provider),
           let payload = imagePayload(from: image, preferredType: preferredImageType(from: provider)) {
            return payload
        }

        return nil
    }

    private func preferredImageType(from provider: NSItemProvider) -> UTType? {
        provider.registeredTypeIdentifiers
            .compactMap(UTType.init)
            .first(where: { $0.conforms(to: .image) })
    }

    private func preferredConcreteImageTypes(from provider: NSItemProvider) -> [UTType] {
        let rankedIdentifiers = [
            UTType.heic.identifier,
            UTType.heif.identifier,
            UTType.jpeg.identifier,
            UTType.png.identifier,
            UTType.tiff.identifier,
            UTType.bmp.identifier,
            UTType.webP.identifier,
            UTType.gif.identifier,
        ]

        var selected: [UTType] = []

        for identifier in rankedIdentifiers where provider.hasItemConformingToTypeIdentifier(identifier) {
            if let type = UTType(identifier), !selected.contains(type) {
                selected.append(type)
            }
        }

        for type in provider.registeredTypeIdentifiers.compactMap(UTType.init)
        where type.conforms(to: .image) && type.identifier != UTType.image.identifier && !selected.contains(type) {
            selected.append(type)
        }

        return selected
    }

    private func loadDataRepresentation(
        from provider: NSItemProvider,
        typeIdentifier: String
    ) async throws -> SharedImagePayload? {
        try await withCheckedThrowingContinuation { continuation in
            provider.loadDataRepresentation(forTypeIdentifier: typeIdentifier) { data, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let data else {
                    continuation.resume(returning: nil)
                    return
                }

                let fileExtension = UTType(typeIdentifier)?.preferredFilenameExtension ?? "jpg"
                continuation.resume(returning: SharedImagePayload(data: data, fileExtension: fileExtension))
            }
        }
    }

    private func tryLoadDataRepresentation(
        from provider: NSItemProvider,
        typeIdentifier: String
    ) async -> SharedImagePayload? {
        do {
            return try await loadDataRepresentation(from: provider, typeIdentifier: typeIdentifier)
        } catch {
            logger.debug("loadDataRepresentation failed for \(typeIdentifier): \(String(describing: error))")
            return nil
        }
    }

    private func loadFileRepresentation(
        from provider: NSItemProvider,
        typeIdentifier: String
    ) async throws -> SharedImagePayload? {
        try await withCheckedThrowingContinuation { continuation in
            provider.loadFileRepresentation(forTypeIdentifier: typeIdentifier) { url, error in
                if let error { continuation.resume(throwing: error); return }
                guard let url else {
                    continuation.resume(returning: nil)
                    return
                }

                do {
                    let data = try Data(contentsOf: url)
                    let fileExtension = url.pathExtension.isEmpty
                        ? (UTType(typeIdentifier)?.preferredFilenameExtension ?? "jpg")
                        : url.pathExtension
                    continuation.resume(returning: SharedImagePayload(data: data, fileExtension: fileExtension))
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    private func tryLoadFileRepresentation(
        from provider: NSItemProvider,
        typeIdentifier: String
    ) async -> SharedImagePayload? {
        do {
            return try await loadFileRepresentation(from: provider, typeIdentifier: typeIdentifier)
        } catch {
            logger.debug("loadFileRepresentation failed for \(typeIdentifier): \(String(describing: error))")
            return nil
        }
    }

    private func loadUIImage(from provider: NSItemProvider) async throws -> UIImage? {
        try await withCheckedThrowingContinuation { continuation in
            provider.loadObject(ofClass: UIImage.self) { object, error in
                if let error { continuation.resume(throwing: error); return }
                continuation.resume(returning: object as? UIImage)
            }
        }
    }

    private func tryLoadUIImage(from provider: NSItemProvider) async -> UIImage? {
        do {
            return try await loadUIImage(from: provider)
        } catch {
            logger.debug("loadObject(UIImage.self) failed: \(String(describing: error))")
            return nil
        }
    }

    private func imagePayload(from image: UIImage, preferredType: UTType?) -> SharedImagePayload? {
        if let preferredType, preferredType.conforms(to: .png),
           let data = image.pngData() {
            return SharedImagePayload(data: data, fileExtension: preferredType.preferredFilenameExtension ?? "png")
        }

        if let data = image.jpegData(compressionQuality: 0.95) {
            return SharedImagePayload(data: data, fileExtension: preferredType?.preferredFilenameExtension ?? "jpg")
        }

        if let data = image.pngData() {
            return SharedImagePayload(data: data, fileExtension: "png")
        }

        return nil
    }

    private func persistImageToAppGroup(_ payload: SharedImagePayload, hint: String) throws {
        guard let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupIdentifier
        ) else { throw ShareError.appGroupNotFound }

        let inboxURL = containerURL.appendingPathComponent(inboxFolderName, isDirectory: true)
        try FileManager.default.createDirectory(at: inboxURL, withIntermediateDirectories: true)

        let sanitizedExtension = payload.fileExtension.isEmpty ? "jpg" : payload.fileExtension
        let imageFileName = "incoming-\(UUID().uuidString).\(sanitizedExtension)"
        try payload.data.write(to: inboxURL.appendingPathComponent(imageFileName), options: .atomic)

        let normalizedHint = hint.trimmingCharacters(in: .whitespacesAndNewlines)
        let manifest = Manifest(
            imageFileName: imageFileName,
            hint: normalizedHint.isEmpty ? "No hint" : normalizedHint,
            createdAt: Date()
        )
        let manifestData = try JSONEncoder().encode(manifest)
        try manifestData.write(to: inboxURL.appendingPathComponent(manifestFileName), options: .atomic)
    }

    private func scheduleIncomingReactNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Yaya"
        content.body = "Yaya vous a envoye un React Content"
        content.sound = .default
        content.userInfo = ["action": "openReact"]

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(
            identifier: Self.reactNotificationIdentifier,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [Self.reactNotificationIdentifier]
        )
        UNUserNotificationCenter.current().add(request)
    }

    private func complete(withError description: String) {
        let error = NSError(domain: "ReactShareExtension", code: 1,
                            userInfo: [NSLocalizedDescriptionKey: description])
        extensionContext?.cancelRequest(withError: error)
    }

    // MARK: - UI helpers

    private func showSpinner() {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.color = .white
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        view.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    enum ShareError: Error { case appGroupNotFound }
}
