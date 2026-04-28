//
//  ReactShareViewController.swift
//  React
//
//  Created by Yannick Juarez on 27/04/2026.
//

import UIKit
import SwiftUI
import UniformTypeIdentifiers
import UserNotifications
import os
import CoreDomain
import CorePersistence
import DesignSystem
import AnalyticsKit

/// Shared extension controller logic hosted in React module.
open class ReactShareViewController: UIViewController {

    private let logger = Logger(subsystem: "com.yannickjuarez.React.ShareExtension", category: "Share")

    struct Manifest: Codable {
        let shareID: String
        let imageFileName: String
        let hint: String
        let createdAt: Date
    }

    private struct SharedImagePayload {
        let data: Data
        let fileExtension: String
    }

    private static let reactNotificationIdentifier = "com.react.demo.incomingReact"

    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        self.showSpinner()
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsService.shared.track(
            ReactAnalyticsEvents.shareExtensionOpened,
            properties: [
                "source_app": "unknown",
                "content_type": "image",
                "os_version": UIDevice.current.systemVersion,
                "app_version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown",
            ]
        )
        Task { await self.handleShare() }
    }

    private func handleShare() async {
        guard let payload = await self.loadFirstImagePayload() else {
            self.complete(withError: "Aucune image detectee dans le partage.")
            return
        }

        guard let image = UIImage(data: payload.data) else {
            self.complete(withError: "Impossible de lire cette image.")
            return
        }

        await MainActor.run { self.showPreview(image: image, payload: payload) }
    }

    @MainActor
    private func showPreview(image: UIImage, payload: SharedImagePayload) {
        let previewView = ReactRequestView(
            sharedImage: image,
            onCancel: { [weak self] in
                self?.complete(withError: "Partage annule.")
            },
            onContinue: { [weak self] hint in
                guard let self else { return }
                do {
                    let shareID = try self.persistImageToAppGroup(payload, hint: hint)
                    AnalyticsService.shared.track(
                        ReactAnalyticsEvents.shareTargetSelected,
                        properties: [
                            "share_id": shareID,
                            "sender_id": "current_user",
                            "receiver_id": "sample_user",
                            "source_app": "unknown",
                            "content_type": "image",
                            "candidate_count": "1",
                        ]
                    )
                    AnalyticsService.shared.track(
                        ReactAnalyticsEvents.shareSent,
                        properties: [
                            "share_id": shareID,
                            "sender_id": "current_user",
                            "receiver_id": "sample_user",
                            "source_app": "unknown",
                            "content_type": "image",
                            "payload_size_bucket": ReactAnalyticsEvents.payloadSizeBucket(bytes: payload.data.count),
                            "sent_at": ISO8601DateFormatter().string(from: Date()),
                        ]
                    )
                    self.scheduleIncomingReactNotification(shareID: shareID)
                    self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
                } catch {
                    self.complete(withError: "Impossible de sauvegarder cette image.")
                }
            }
        )

        let host = UIHostingController(rootView: previewView.preferredColorScheme(.dark))
        self.addChild(host)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        host.view.backgroundColor = .black
        self.view.addSubview(host.view)
        NSLayoutConstraint.activate([
            host.view.topAnchor.constraint(equalTo: self.view.topAnchor),
            host.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            host.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ])
        host.didMove(toParent: self)
    }

    private func loadFirstImagePayload() async -> SharedImagePayload? {
        let extensionItems = self.extensionContext?.inputItems.compactMap { $0 as? NSExtensionItem } ?? []
        let providers = extensionItems.flatMap { $0.attachments ?? [] }

        self.logger.debug("Share input items: \(extensionItems.count), providers: \(providers.count)")

        for provider in providers where provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
            self.logger.debug("Provider registered types: \(provider.registeredTypeIdentifiers.joined(separator: ", "))")
            if let payload = await self.loadImagePayload(from: provider) {
                return payload
            }
        }

        self.logger.error("No image payload could be loaded from any provider")
        return nil
    }

    private func loadImagePayload(from provider: NSItemProvider) async -> SharedImagePayload? {
        let concreteTypes = self.preferredConcreteImageTypes(from: provider)

        for imageType in concreteTypes {
            if let dataPayload = await self.tryLoadDataRepresentation(from: provider, typeIdentifier: imageType.identifier) {
                return dataPayload
            }

            if let filePayload = await self.tryLoadFileRepresentation(from: provider, typeIdentifier: imageType.identifier) {
                return filePayload
            }
        }

        if provider.canLoadObject(ofClass: UIImage.self),
           let image = await self.tryLoadUIImage(from: provider),
           let payload = self.imagePayload(from: image, preferredType: self.preferredImageType(from: provider)) {
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
            return try await self.loadDataRepresentation(from: provider, typeIdentifier: typeIdentifier)
        } catch {
            self.logger.debug("loadDataRepresentation failed for \(typeIdentifier): \(String(describing: error))")
            return nil
        }
    }

    private func loadFileRepresentation(
        from provider: NSItemProvider,
        typeIdentifier: String
    ) async throws -> SharedImagePayload? {
        try await withCheckedThrowingContinuation { continuation in
            provider.loadFileRepresentation(forTypeIdentifier: typeIdentifier) { url, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

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
            return try await self.loadFileRepresentation(from: provider, typeIdentifier: typeIdentifier)
        } catch {
            self.logger.debug("loadFileRepresentation failed for \(typeIdentifier): \(String(describing: error))")
            return nil
        }
    }

    private func loadUIImage(from provider: NSItemProvider) async throws -> UIImage? {
        try await withCheckedThrowingContinuation { continuation in
            provider.loadObject(ofClass: UIImage.self) { object, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume(returning: object as? UIImage)
            }
        }
    }

    private func tryLoadUIImage(from provider: NSItemProvider) async -> UIImage? {
        do {
            return try await self.loadUIImage(from: provider)
        } catch {
            self.logger.debug("loadObject(UIImage.self) failed: \(String(describing: error))")
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

    private func persistImageToAppGroup(_ payload: SharedImagePayload, hint: String) throws -> String {
        try AppGroupReactInboxStore.saveIncomingImageAndReturnShareID(
            payload.data,
            hint: hint,
            preferredFileExtension: payload.fileExtension.isEmpty ? "jpg" : payload.fileExtension
        )
    }

    private func scheduleIncomingReactNotification(shareID: String) {
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

        AnalyticsService.shared.track(
            ReactAnalyticsEvents.shareNotificationSent,
            properties: [
                "share_id": shareID,
                "receiver_id": "sample_user",
                "send_channel": "push",
                "delivery_status": "sent",
            ]
        )
    }

    private func complete(withError description: String) {
        let error = NSError(domain: "ReactShareExtension", code: 1,
                            userInfo: [NSLocalizedDescriptionKey: description])
        self.extensionContext?.cancelRequest(withError: error)
    }

    private func showSpinner() {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.color = .white
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        self.view.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
        ])
    }

    enum ShareError: Error {
        case appGroupNotFound
    }
}
