#!/usr/bin/env python3
"""
Adds `public` access modifiers and package imports to all SPM package Swift files.
Run from the project root directory.
"""

import re
import os

BASE = "/Users/yannickjuarez/Developer/BeReal/ios-react-demo-app"
PKG  = f"{BASE}/Packages"

# ─────────────────────────────────────────────────────────────────────────────
# Helpers
# ─────────────────────────────────────────────────────────────────────────────

def prepend_imports(source: str, extra_imports: list[str]) -> str:
    """Insert extra import statements right after the last existing import line."""
    lines = source.splitlines(keepends=True)
    last_import_idx = -1
    for i, line in enumerate(lines):
        if re.match(r'^import\s+\w', line):
            last_import_idx = i
    new_imports = "".join(f"import {m}\n" for m in extra_imports)
    if last_import_idx >= 0:
        lines.insert(last_import_idx + 1, new_imports)
    else:
        lines.insert(0, new_imports)
    return "".join(lines)


def make_public(source: str, patterns: list[tuple[str, str]]) -> str:
    for old, new in patterns:
        source = source.replace(old, new, 1)
    return source


def write(path: str, content: str):
    with open(path, "w") as f:
        f.write(content)
    print(f"  ✓ {os.path.relpath(path, BASE)}")


def read(path: str) -> str:
    with open(path) as f:
        return f.read()


# ─────────────────────────────────────────────────────────────────────────────
# CoreDomain
# ─────────────────────────────────────────────────────────────────────────────
print("\n── CoreDomain ──")

# React.swift
p = f"{PKG}/CoreDomain/Sources/CoreDomain/React.swift"
s = read(p)
s = s.replace(
    "struct React: Codable {\n\n    var id: UUID = UUID()\n\n    var content: URL\n    var hint: String\n    var sender: User\n    var response: URL?",
    "public struct React: Codable, Sendable {\n\n    public var id: UUID\n    public var content: URL\n    public var hint: String\n    public var sender: User\n    public var response: URL?\n\n    public init(id: UUID = UUID(), content: URL, hint: String, sender: User, response: URL? = nil) {\n        self.id = id\n        self.content = content\n        self.hint = hint\n        self.sender = sender\n        self.response = response\n    }",
)
write(p, s)

# User.swift
p = f"{PKG}/CoreDomain/Sources/CoreDomain/User.swift"
s = read(p)
s = s.replace(
    "struct User: Codable {\n\n    var id: UUID = UUID()\n\n    var username: String\n    var displayName: String\n    var profilePictureURL: URL?",
    "public struct User: Codable, Sendable {\n\n    public var id: UUID\n    public var username: String\n    public var displayName: String\n    public var profilePictureURL: URL?\n\n    public init(id: UUID = UUID(), username: String, displayName: String, profilePictureURL: URL? = nil) {\n        self.id = id\n        self.username = username\n        self.displayName = displayName\n        self.profilePictureURL = profilePictureURL\n    }",
)
write(p, s)

# ReactContent.swift
p = f"{PKG}/CoreDomain/Sources/CoreDomain/ReactContent.swift"
s = read(p)
s = s.replace(
    "struct ReactContent: Codable {\n    var mediaURL: URL\n}",
    "public struct ReactContent: Codable, Sendable {\n    public var mediaURL: URL\n    public init(mediaURL: URL) { self.mediaURL = mediaURL }\n}",
)
write(p, s)

# Reaction.swift
p = f"{PKG}/CoreDomain/Sources/CoreDomain/Reaction.swift"
s = read(p)
s = s.replace(
    "struct Reaction: Codable {\n    var id: UUID = UUID()\n    var reactId: UUID\n    var videoURL: URL\n    var createdAt: Date = Date()\n}",
    "public struct Reaction: Codable, Sendable {\n    public var id: UUID\n    public var reactId: UUID\n    public var videoURL: URL\n    public var createdAt: Date\n    public init(id: UUID = UUID(), reactId: UUID, videoURL: URL, createdAt: Date = Date()) {\n        self.id = id\n        self.reactId = reactId\n        self.videoURL = videoURL\n        self.createdAt = createdAt\n    }\n}",
)
write(p, s)

# ReactRequest.swift
p = f"{PKG}/CoreDomain/Sources/CoreDomain/ReactRequest.swift"
s = read(p)
s = s.replace(
    "struct ReactRequest: Codable {\n    var id: UUID = UUID()\n    var content: ReactContent\n    var hint: String\n    var sender: User\n    var createdAt: Date = Date()\n}",
    "public struct ReactRequest: Codable, Sendable {\n    public var id: UUID\n    public var content: ReactContent\n    public var hint: String\n    public var sender: User\n    public var createdAt: Date\n    public init(id: UUID = UUID(), content: ReactContent, hint: String, sender: User, createdAt: Date = Date()) {\n        self.id = id\n        self.content = content\n        self.hint = hint\n        self.sender = sender\n        self.createdAt = createdAt\n    }\n}",
)
write(p, s)

# React+Samples.swift
p = f"{PKG}/CoreDomain/Sources/CoreDomain/React+Samples.swift"
s = read(p)
s = s.replace("extension React {", "public extension React {")
write(p, s)

# User+Samples.swift
p = f"{PKG}/CoreDomain/Sources/CoreDomain/User+Samples.swift"
s = read(p)
s = s.replace("extension User {", "public extension User {")
write(p, s)

# ReactRepository.swift
p = f"{PKG}/CoreDomain/Sources/CoreDomain/ReactRepository.swift"
s = read(p)
s = s.replace("protocol ReactRepository {", "public protocol ReactRepository {")
write(p, s)

# UseCaseProtocols.swift
p = f"{PKG}/CoreDomain/Sources/CoreDomain/UseCaseProtocols.swift"
s = read(p)
s = s.replace("protocol SendReactRequestUseCaseProtocol {", "public protocol SendReactRequestUseCaseProtocol {")
s = s.replace("protocol LoadInboxUseCaseProtocol {", "public protocol LoadInboxUseCaseProtocol {")
s = s.replace("extension LoadInboxUseCaseProtocol {", "public extension LoadInboxUseCaseProtocol {")
s = s.replace("protocol RecordReactionUseCaseProtocol {", "public protocol RecordReactionUseCaseProtocol {")
s = s.replace("protocol MarkReactAsUnlockedUseCaseProtocol {", "public protocol MarkReactAsUnlockedUseCaseProtocol {")
write(p, s)

# ─────────────────────────────────────────────────────────────────────────────
# CorePersistence
# ─────────────────────────────────────────────────────────────────────────────
print("\n── CorePersistence ──")

# StoredReactDTO.swift — internal only, no public needed for external consumers
p = f"{PKG}/CorePersistence/Sources/CorePersistence/StoredReactDTO.swift"
s = read(p)
# Add CoreDomain import (needed for… actually not — DTO only uses Foundation types)
write(p, s)

# StoredReactMapper.swift
p = f"{PKG}/CorePersistence/Sources/CorePersistence/StoredReactMapper.swift"
s = read(p)
s = prepend_imports(s, ["CoreDomain"])
write(p, s)

# LocalDemoReactStore.swift
p = f"{PKG}/CorePersistence/Sources/CorePersistence/LocalDemoReactStore.swift"
s = read(p)
s = prepend_imports(s, ["CoreDomain"])
s = s.replace("struct LocalDemoReactStore {", "public struct LocalDemoReactStore {")
s = s.replace("    static func save(", "    public static func save(")
s = s.replace("    static func loadLatest()", "    public static func loadLatest()")
s = s.replace("    static func saveResponseVideo(", "    public static func saveResponseVideo(")
s = s.replace("    enum LocalDemoReactStoreError: Error {", "    public enum LocalDemoReactStoreError: Error {")
s = s.replace("        case invalidImage", "        public case invalidImage")
write(p, s)

# AppGroupReactInboxStore.swift
p = f"{PKG}/CorePersistence/Sources/CorePersistence/AppGroupReactInboxStore.swift"
s = read(p)
s = prepend_imports(s, ["CoreDomain"])
s = s.replace("struct AppGroupReactInboxStore {", "public struct AppGroupReactInboxStore {")
s = s.replace("    static let appGroupIdentifier", "    public static let appGroupIdentifier")
s = s.replace("    static let urlScheme", "    public static let urlScheme")
s = s.replace("    struct Manifest: Codable {", "    public struct Manifest: Codable {")
s = s.replace("        let imageFileName: String", "        public let imageFileName: String")
s = s.replace("        let hint: String", "        public let hint: String")
s = s.replace("        let createdAt: Date", "        public let createdAt: Date")
s = s.replace("    struct IncomingReactDraft {", "    public struct IncomingReactDraft {")
s = s.replace("        let image: UIImage", "        public let image: UIImage")
s = s.replace("    static func hasPendingDraft()", "    public static func hasPendingDraft()")
s = s.replace("    static func consumeLatestDraft()", "    public static func consumeLatestDraft()")
s = s.replace("    static func consumeLatestImage()", "    public static func consumeLatestImage()")
s = s.replace("    static func saveIncomingImageData(", "    public static func saveIncomingImageData(")
s = s.replace("    enum SharedInboxError: Error {", "    public enum SharedInboxError: Error {")
s = s.replace("        case appGroupNotFound", "        public case appGroupNotFound")
# SharedReactInbox compat struct
s = s.replace("struct SharedReactInbox {", "public struct SharedReactInbox {")
s = s.replace("    static let appGroupIdentifier = AppGroupReactInboxStore.appGroupIdentifier",
              "    public static let appGroupIdentifier = AppGroupReactInboxStore.appGroupIdentifier")
s = s.replace("    static let urlScheme = AppGroupReactInboxStore.urlScheme",
              "    public static let urlScheme = AppGroupReactInboxStore.urlScheme")
# SharedReactInbox.IncomingReactDraft
s = s.replace("    struct IncomingReactDraft {\n        let image: UIImage\n        let hint: String",
              "    public struct IncomingReactDraft {\n        public let image: UIImage\n        public let hint: String")
s = s.replace("    static func hasPendingDraft() -> Bool {\n        AppGroupReactInboxStore.hasPendingDraft()",
              "    public static func hasPendingDraft() -> Bool {\n        AppGroupReactInboxStore.hasPendingDraft()")
s = s.replace("    static func consumeLatestDraft() -> IncomingReactDraft?",
              "    public static func consumeLatestDraft() -> IncomingReactDraft?")
s = s.replace("    static func consumeLatestImage() -> UIImage? {",
              "    public static func consumeLatestImage() -> UIImage? {")
s = s.replace("    static func saveIncomingImageData(\n        _ data: Data",
              "    public static func saveIncomingImageData(\n        _ data: Data")
write(p, s)

# ─────────────────────────────────────────────────────────────────────────────
# CoreInfrastructure
# ─────────────────────────────────────────────────────────────────────────────
print("\n── CoreInfrastructure ──")

for name in ["LoadInboxUseCase", "MarkReactAsUnlockedUseCase", "RecordReactionUseCase", "SendReactRequestUseCase"]:
    p = f"{PKG}/CoreInfrastructure/Sources/CoreInfrastructure/{name}.swift"
    s = read(p)
    s = prepend_imports(s, ["CoreDomain"])
    struct_name = name
    s = s.replace(f"struct {struct_name}:", f"public struct {struct_name}:")
    s = s.replace("    init(repository: any ReactRepository)", "    public init(repository: any ReactRepository)")
    s = s.replace("    func execute(", "    public func execute(")
    s = s.replace("    func loadLatest()", "    public func loadLatest()")
    s = s.replace("    func hasPendingDraft()", "    public func hasPendingDraft()")
    write(p, s)

# LocalReactRepository.swift
p = f"{PKG}/CoreInfrastructure/Sources/CoreInfrastructure/LocalReactRepository.swift"
s = read(p)
s = prepend_imports(s, ["CoreDomain", "CorePersistence"])
s = s.replace("struct LocalReactRepository: ReactRepository {", "public struct LocalReactRepository: ReactRepository {\n\n    public init() {}")
s = s.replace("    func hasPendingInbox()", "    public func hasPendingInbox()")
s = s.replace("    func loadInboxReact(", "    public func loadInboxReact(")
s = s.replace("    func loadLatestReact()", "    public func loadLatestReact()")
s = s.replace("    func saveIncomingReact(", "    public func saveIncomingReact(")
s = s.replace("    func saveResponseVideo(", "    public func saveResponseVideo(")
s = s.replace("    func markAsUnlocked(", "    public func markAsUnlocked(")
write(p, s)

# ReactNotificationScheduler.swift
p = f"{PKG}/CoreInfrastructure/Sources/CoreInfrastructure/ReactNotificationScheduler.swift"
s = read(p)
s = s.replace("final class ReactNotificationScheduler:", "public final class ReactNotificationScheduler:")
s = s.replace("    enum Route: Equatable {", "    public enum Route: Equatable {")
s = s.replace("        case incomingReact\n        case playback",
              "        public case incomingReact\n        public case playback")
s = s.replace("    nonisolated static let incomingReactNotificationIdentifier",
              "    public nonisolated static let incomingReactNotificationIdentifier")
s = s.replace("    nonisolated static let playbackNotificationIdentifier",
              "    public nonisolated static let playbackNotificationIdentifier")
s = s.replace("    @Published private(set) var authorizationStatus:",
              "    @Published public private(set) var authorizationStatus:")
s = s.replace("    @Published private(set) var pendingRoute:",
              "    @Published public private(set) var pendingRoute:")
s = s.replace("    override init() {", "    public override init() {")
s = s.replace("    var isAuthorized: Bool {", "    public var isAuthorized: Bool {")
s = s.replace("    var isDenied: Bool {", "    public var isDenied: Bool {")
s = s.replace("    func refreshStatus()", "    public func refreshStatus()")
s = s.replace("    func requestAuthorization()", "    public func requestAuthorization()")
s = s.replace("    func scheduleIncomingReactNotification(", "    public func scheduleIncomingReactNotification(")
s = s.replace("    func schedulePlaybackNotification(", "    public func schedulePlaybackNotification(")
s = s.replace("    func consumePendingRoute()", "    public func consumePendingRoute()")
s = s.replace("    func openSettingsForNotifications()", "    public func openSettingsForNotifications()")
write(p, s)

# ─────────────────────────────────────────────────────────────────────────────
# DesignSystem
# ─────────────────────────────────────────────────────────────────────────────
print("\n── DesignSystem ──")

# React+PresentationUI.swift
p = f"{PKG}/DesignSystem/Sources/DesignSystem/React+PresentationUI.swift"
s = read(p)
s = prepend_imports(s, ["CoreDomain"])
s = s.replace("extension React {", "public extension React {")
write(p, s)

# User+PresentationUI.swift
p = f"{PKG}/DesignSystem/Sources/DesignSystem/User+PresentationUI.swift"
s = read(p)
s = prepend_imports(s, ["CoreDomain"])
s = s.replace("extension User {", "public extension User {")
write(p, s)

# ReactUserCapsule.swift
p = f"{PKG}/DesignSystem/Sources/DesignSystem/ReactUserCapsule.swift"
s = read(p)
s = prepend_imports(s, ["CoreDomain"])
s = s.replace("struct ReactSenderCapsule2: View {", "public struct ReactSenderCapsule2: View {")
s = s.replace("    @State var user: User", "    public var user: User")
s = s.replace("    var body: some View {", "    public var body: some View {")
write(p, s)

# ─────────────────────────────────────────────────────────────────────────────
# CameraFeature
# ─────────────────────────────────────────────────────────────────────────────
print("\n── CameraFeature ──")

# ReactCaptureButton.swift
p = f"{PKG}/CameraFeature/Sources/CameraFeature/ReactCaptureButton.swift"
s = read(p)
s = prepend_imports(s, ["CoreDomain", "DesignSystem"])
s = s.replace("struct ReactCaptureButton: View {", "public struct ReactCaptureButton: View {")
s = s.replace("    @Binding var isPressed: Bool", "    @Binding public var isPressed: Bool")
s = s.replace("    @State var radius:", "    @State public var radius:")
s = s.replace("    @State var strokeWidth:", "    @State public var strokeWidth:")
s = s.replace("    @State var padding:", "    @State public var padding:")
s = s.replace("    var body: some View {", "    public var body: some View {")
write(p, s)

# ReactFrontCameraPreview.swift
p = f"{PKG}/CameraFeature/Sources/CameraFeature/ReactFrontCameraPreview.swift"
s = read(p)
s = prepend_imports(s, ["CoreDomain", "DesignSystem"])
s = s.replace("final class ReactFrontCameraSession:", "public final class ReactFrontCameraSession:")
s = s.replace("    let session = AVCaptureSession()", "    public let session = AVCaptureSession()")
s = s.replace("    func configure()", "    public func configure()")
s = s.replace("    func startRecording(", "    public func startRecording(")
s = s.replace("    func stopRecording()", "    public func stopRecording()")
# Find and make the SwiftUI view public
s = re.sub(r'\bstruct ReactFrontCameraPreview\b', "public struct ReactFrontCameraPreview", s)
s = re.sub(r'(    )(var body: some View \{)', r'\1public \2', s)
write(p, s)

# ReactConfirmView.swift (named ConfirmView inside)
p = f"{PKG}/CameraFeature/Sources/CameraFeature/ReactConfirmView.swift"
s = read(p)
s = prepend_imports(s, ["CoreDomain", "DesignSystem"])
s = s.replace("struct ConfirmView: View {", "public struct ConfirmView: View {")
s = s.replace("    var react: React", "    public var react: React")
s = s.replace("    let onSend: () -> Void", "    public let onSend: () -> Void")
s = s.replace("    let onCancel: () -> Void", "    public let onCancel: () -> Void")
s = s.replace("    var body: some View {", "    public var body: some View {")
write(p, s)

# ─────────────────────────────────────────────────────────────────────────────
# ReactionFeature
# ─────────────────────────────────────────────────────────────────────────────
print("\n── ReactionFeature ──")

# CameraPermissionClient.swift
p = f"{PKG}/ReactionFeature/Sources/ReactionFeature/CameraPermissionClient.swift"
s = read(p)
s = s.replace("struct CameraPermissionClient {", "public struct CameraPermissionClient {")
s = s.replace("    let cameraStatus:", "    public let cameraStatus:")
s = s.replace("    let microphoneStatus:", "    public let microphoneStatus:")
s = s.replace("    let requestCameraAccess:", "    public let requestCameraAccess:")
s = s.replace("    let requestMicrophoneAccess:", "    public let requestMicrophoneAccess:")
s = s.replace("    let openAppSettings:", "    public let openAppSettings:")
s = s.replace("    static let live = CameraPermissionClient(", "    public static let live = CameraPermissionClient(")
write(p, s)

# PermissionsManager.swift
p = f"{PKG}/ReactionFeature/Sources/ReactionFeature/PermissionsManager.swift"
s = read(p)
s = s.replace("final class PermissionsManager: ObservableObject {", "public final class PermissionsManager: ObservableObject {")
s = s.replace("    @Published private(set) var cameraStatus:",
              "    @Published public private(set) var cameraStatus:")
s = s.replace("    @Published private(set) var microphoneStatus:",
              "    @Published public private(set) var microphoneStatus:")
s = s.replace("    init(permissionClient: CameraPermissionClient = .live) {",
              "    public init(permissionClient: CameraPermissionClient = .live) {")
# Make public vars/funcs
s = re.sub(r'(?m)^    var (protectionMessage|actionTitle|isCameraBlocked|isMicBlocked|isFullyReady)\b',
           lambda m: f"    public var {m.group(1)}", s)
s = re.sub(r'(?m)^    func (requestPermissions|refreshStatuses)\b',
           lambda m: f"    public func {m.group(1)}", s)
write(p, s)

# ReactPermissionsView.swift
p = f"{PKG}/ReactionFeature/Sources/ReactionFeature/ReactPermissionsView.swift"
s = read(p)
s = s.replace("struct ReactPermissionsView: View {", "public struct ReactPermissionsView: View {")
s = s.replace("    var body: some View {", "    public var body: some View {")
write(p, s)

# ReactMainViewModel.swift
p = f"{PKG}/ReactionFeature/Sources/ReactionFeature/ReactMainViewModel.swift"
s = read(p)
s = s.replace("final class ReactMainViewModel: ObservableObject {",
              "public final class ReactMainViewModel: ObservableObject {")
s = s.replace("        @Published var isRecording: Bool = false",
              "        @Published public var isRecording: Bool = false")
s = s.replace("        @Published private(set) var isRevealed: Bool = false",
              "        @Published public private(set) var isRevealed: Bool = false")
s = s.replace("        @Published private(set) var countdownValue: Int? = nil",
              "        @Published public private(set) var countdownValue: Int? = nil")
s = s.replace("        func handleRecordingChanged(_ isRecording: Bool) {",
              "        public func handleRecordingChanged(_ isRecording: Bool) {")
write(p, s)

# ReactMainView.swift
p = f"{PKG}/ReactionFeature/Sources/ReactionFeature/ReactMainView.swift"
s = read(p)
s = prepend_imports(s, ["CoreDomain", "CoreInfrastructure", "DesignSystem", "CameraFeature"])
s = s.replace("struct ReactMainView: View {", "public struct ReactMainView: View {")
s = s.replace("    var body: some View {", "    public var body: some View {")
# Make init public — find the init line
s = re.sub(r'(?m)^    init\(', "    public init(", s)
write(p, s)

# ReactContentPreview.swift (struct named ContentPreview)
p = f"{PKG}/ReactionFeature/Sources/ReactionFeature/ReactContentPreview.swift"
s = read(p)
s = prepend_imports(s, ["CoreDomain", "DesignSystem"])
s = s.replace("struct ContentPreview: View {", "public struct ContentPreview: View {")
s = s.replace("    let react: React", "    public let react: React")
s = s.replace("    let isBlurred: Bool", "    public let isBlurred: Bool")
s = s.replace("    let countdownValue: Int?", "    public let countdownValue: Int?")
s = s.replace("    var body: some View {", "    public var body: some View {")
write(p, s)

# ReactPlaybackView.swift
p = f"{PKG}/ReactionFeature/Sources/ReactionFeature/ReactPlaybackView.swift"
s = read(p)
s = prepend_imports(s, ["CoreDomain"])
# Make top-level struct public (LoopingPlayerUIView stays private/internal)
s = re.sub(r'\bstruct ReactPlaybackView\b', "public struct ReactPlaybackView", s)
s = re.sub(r'(?m)^    var body: some View \{', "    public var body: some View {", s)
s = re.sub(r'(?m)^    init\(', "    public init(", s)
write(p, s)

# ─────────────────────────────────────────────────────────────────────────────
# ShareImportFeature
# ─────────────────────────────────────────────────────────────────────────────
print("\n── ShareImportFeature ──")

# ReactRequestView.swift
p = f"{PKG}/ShareImportFeature/Sources/ShareImportFeature/ReactRequestView.swift"
s = read(p)
s = prepend_imports(s, ["CoreDomain", "DesignSystem"])
s = s.replace("struct ReactRequestView: View {", "public struct ReactRequestView: View {")
s = s.replace("    let sharedImage: UIImage", "    public let sharedImage: UIImage")
s = s.replace("    let onCancel: () -> Void", "    public let onCancel: () -> Void")
s = s.replace("    let onContinue: (String) -> Void", "    public let onContinue: (String) -> Void")
s = s.replace("    var cornerRadius: CGFloat = 8", "    public var cornerRadius: CGFloat = 8")
s = s.replace("    var body: some View {", "    public var body: some View {")
write(p, s)

# ReactShareViewController.swift
p = f"{PKG}/ShareImportFeature/Sources/ShareImportFeature/ReactShareViewController.swift"
s = read(p)
s = prepend_imports(s, ["CoreDomain", "CoreInfrastructure", "DesignSystem"])
s = s.replace("class ReactShareViewController: UIViewController {",
              "open class ReactShareViewController: UIViewController {")
write(p, s)

print("\n✅ All public modifiers applied successfully.")
