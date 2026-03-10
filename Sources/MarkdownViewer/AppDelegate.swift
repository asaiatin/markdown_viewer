import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    /// Modern API — called by macOS when files are opened via Finder, `open` CLI, etc.
    func application(_ application: NSApplication, open urls: [URL]) {
        guard let url = urls.first else { return }
        load(url)
    }

    /// Legacy API fallback
    func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        load(URL(fileURLWithPath: filename))
        return true
    }

    func application(_ sender: NSApplication, openFiles filenames: [String]) {
        if let last = filenames.last {
            load(URL(fileURLWithPath: last))
        }
    }

    private func load(_ url: URL) {
        guard let content = try? String(contentsOf: url, encoding: .utf8) else { return }
        // Slight delay ensures SwiftUI views are subscribed before we push the update
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            AppState.shared.markdownText = content
        }
    }
}
