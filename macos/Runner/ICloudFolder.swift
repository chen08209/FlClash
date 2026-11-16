import Cocoa
import FlutterMacOS

final class ICloudFolder {
    private let queue = DispatchQueue(label: "com.follow.clash.icloud")
    private let bookmarkKey = "icloudYamlFolder"
    private let maxBytes = 16 * 1024 * 1024

    func register(with messenger: FlutterBinaryMessenger) {
        let channel = FlutterMethodChannel(name: "flclash/icloud", binaryMessenger: messenger)
        channel.setMethodCallHandler { [self] call, result in
            if call.method == "select" {
                let panel = NSOpenPanel()
                panel.canChooseDirectories = true
                panel.canChooseFiles = false
                panel.allowsMultipleSelection = false
                panel.canCreateDirectories = true
                panel.directoryURL = FileManager.default.homeDirectoryForCurrentUser
                    .appendingPathComponent("Library/Mobile Documents/com~apple~CloudDocs")
                panel.begin { response in
                    guard response == .OK, let url = panel.url else { result(nil); return }
                    self.queue.async {
                        self.complete(result) {
                            let root = FileManager.default.homeDirectoryForCurrentUser
                                .appendingPathComponent("Library/Mobile Documents/com~apple~CloudDocs")
                                .resolvingSymlinksInPath().path + "/"
                            guard (url.resolvingSymlinksInPath().path + "/").hasPrefix(root) else {
                                throw self.failure("Select a folder inside iCloud Drive.")
                            }
                            let bookmark = try url.bookmarkData(options: .withSecurityScope,
                                                               includingResourceValuesForKeys: nil,
                                                               relativeTo: nil)
                            UserDefaults.standard.set(bookmark, forKey: self.bookmarkKey)
                            return url.path
                        }
                    }
                }
                return
            }
            queue.async {
                self.complete(result) {
                    if call.method == "disable" {
                        UserDefaults.standard.removeObject(forKey: self.bookmarkKey)
                        return nil
                    }
                    guard let data = UserDefaults.standard.data(forKey: self.bookmarkKey) else { return nil }
                    var stale = false
                    let folder = try URL(resolvingBookmarkData: data, options: .withSecurityScope,
                                         relativeTo: nil, bookmarkDataIsStale: &stale)
                    let accessed = folder.startAccessingSecurityScopedResource()
                    defer { if accessed { folder.stopAccessingSecurityScopedResource() } }
                    if stale {
                        UserDefaults.standard.set(try folder.bookmarkData(options: .withSecurityScope,
                            includingResourceValuesForKeys: nil, relativeTo: nil), forKey: self.bookmarkKey)
                    }
                    switch call.method {
                    case "folder": return folder.path
                    case "list":
                        let urls = try FileManager.default.contentsOfDirectory(at: folder,
                            includingPropertiesForKeys: nil, options: [])
                        return Array(Set(urls.compactMap { url -> String? in
                            var name = url.lastPathComponent
                            if name.hasPrefix(".") && name.hasSuffix(".icloud") {
                                name = String(name.dropFirst().dropLast(".icloud".count))
                            }
                            return self.isYamlName(name) ? name : nil
                        }))
                    case "read", "write":
                        guard let args = call.arguments as? [String: Any], let name = args["name"] as? String,
                              self.isYamlName(name) else {
                            throw self.failure("Invalid YAML file name.")
                        }
                        let url = folder.appendingPathComponent(name)
                        if call.method == "read" {
                            var bytes: Data?
                            try self.coordinate(url, writing: false) { target in bytes = try self.read(target) }
                            return bytes.map { FlutterStandardTypedData(bytes: $0) }
                        }
                        guard let bytes = args["bytes"] as? FlutterStandardTypedData,
                              bytes.data.count <= self.maxBytes else { throw self.failure("YAML file is too large.") }
                        let expected = (args["expected"] as? FlutterStandardTypedData)?.data
                        try self.coordinate(url, writing: true) { target in
                            guard try self.read(target) == expected else {
                                throw self.failure("The cloud file changed. Sync again before resolving it.")
                            }
                            try bytes.data.write(to: target, options: .atomic)
                        }
                        return nil
                    default: return FlutterMethodNotImplemented
                    }
                }
            }
        }
    }

    private func isYamlName(_ name: String) -> Bool {
        !name.contains("/") && !name.contains("\\") && !name.hasPrefix(".") &&
            ["yaml", "yml"].contains((name as NSString).pathExtension.lowercased())
    }

    private func read(_ url: URL) throws -> Data? {
        let fm = FileManager.default
        let placeholder = url.deletingLastPathComponent().appendingPathComponent(".\(url.lastPathComponent).icloud")
        if fm.fileExists(atPath: placeholder.path) {
            try fm.startDownloadingUbiquitousItem(at: url)
            throw failure("iCloud is downloading this file. Sync will retry automatically.")
        }
        guard fm.fileExists(atPath: url.path) else { return nil }
        if !(NSFileVersion.unresolvedConflictVersionsOfItem(at: url) ?? []).isEmpty {
            throw failure("Resolve the iCloud file versions in Finder before syncing this file.")
        }
        let values = try url.resourceValues(forKeys: [.isSymbolicLinkKey, .fileSizeKey,
            .isUbiquitousItemKey, .ubiquitousItemDownloadingStatusKey])
        guard values.isSymbolicLink != true else { throw failure("Symbolic links are not synced.") }
        if values.isUbiquitousItem == true && values.ubiquitousItemDownloadingStatus != .current {
            try fm.startDownloadingUbiquitousItem(at: url)
            throw failure("iCloud is downloading this file. Sync will retry automatically.")
        }
        guard (values.fileSize ?? 0) <= maxBytes else { throw failure("YAML file is too large.") }
        return try Data(contentsOf: url)
    }

    private func coordinate(_ url: URL, writing: Bool, body: @escaping (URL) throws -> Void) throws {
        var coordinationError: NSError?
        var operationError: Error?
        let accessor: (URL) -> Void = { target in
            do { try body(target) } catch { operationError = error }
        }
        let coordinator = NSFileCoordinator(filePresenter: nil)
        if writing {
            coordinator.coordinate(writingItemAt: url, options: .forReplacing,
                                   error: &coordinationError, byAccessor: accessor)
        } else {
            coordinator.coordinate(readingItemAt: url, options: [],
                                   error: &coordinationError, byAccessor: accessor)
        }
        if let error = coordinationError { throw error }
        if let error = operationError { throw error }
    }

    private func failure(_ message: String) -> NSError {
        NSError(domain: "FlClash.iCloud", code: 1, userInfo: [NSLocalizedDescriptionKey: message])
    }

    private func complete(_ result: @escaping FlutterResult, operation: () throws -> Any?) {
        do {
            let value = try operation()
            DispatchQueue.main.async { result(value) }
        } catch {
            let message = error.localizedDescription
            DispatchQueue.main.async { result(FlutterError(code: "icloud", message: message, details: nil)) }
        }
    }
}
