import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    /// Called when a single .md file is opened (double-click in Finder, `open` CLI, etc.)
    func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        return load(filename)
    }

    /// Called when multiple files are opened at once
    func application(_ sender: NSApplication, openFiles filenames: [String]) {
        if let last = filenames.last { _ = load(last) }
    }

    private func load(_ filename: String) -> Bool {
        guard let content = try? String(contentsOfFile: filename, encoding: .utf8) else {
            return false
        }
        DispatchQueue.main.async {
            AppState.shared.markdownText = content
        }
        return true
    }
}
