//
//  ShareViewController.swift
//  ReactShareExtension
//
//  Created by Yannick Juarez on 27/04/2026.
//

import UIKit
import UniformTypeIdentifiers

/// Plain UIViewController — no native compose sheet, processes image immediately.
final class ShareViewController: UIViewController {

    private let appGroupIdentifier = "group.com.yannickjuarez.React"
    private let appURLScheme = "reactdemo://shared-image"

    private let inboxFolderName = "SharedReactInbox"
    private let manifestFileName = "latest.json"

    struct Manifest: Codable {
        let imageFileName: String
        let createdAt: Date
    }

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
        do {
            guard let imageData = try await loadFirstImageData() else {
                complete(withError: "Aucune image détectée dans le partage.")
                return
            }
            try persistImageToAppGroup(imageData)
            openMainApp()
            extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
        } catch {
            complete(withError: "Impossible de partager cette image.")
        }
    }

    private func loadFirstImageData() async throws -> Data? {
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
              let providers = extensionItem.attachments
        else { return nil }

        for provider in providers where provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
            if let data = try await loadImageData(from: provider) { return data }
        }
        return nil
    }

    private func loadImageData(from provider: NSItemProvider) async throws -> Data? {
        try await withCheckedThrowingContinuation { continuation in
            provider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { data, error in
                if let error { continuation.resume(throwing: error); return }
                continuation.resume(returning: data)
            }
        }
    }

    private func persistImageToAppGroup(_ imageData: Data) throws {
        guard let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupIdentifier
        ) else { throw ShareError.appGroupNotFound }

        let inboxURL = containerURL.appendingPathComponent(inboxFolderName, isDirectory: true)
        try FileManager.default.createDirectory(at: inboxURL, withIntermediateDirectories: true)

        let imageFileName = "incoming-\(UUID().uuidString).jpg"
        try imageData.write(to: inboxURL.appendingPathComponent(imageFileName), options: .atomic)

        let manifest = Manifest(imageFileName: imageFileName, createdAt: Date())
        let manifestData = try JSONEncoder().encode(manifest)
        try manifestData.write(to: inboxURL.appendingPathComponent(manifestFileName), options: .atomic)
    }

    private func openMainApp() {
        guard let url = URL(string: appURLScheme) else { return }
        extensionContext?.open(url, completionHandler: nil)
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
