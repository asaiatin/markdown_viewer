import Foundation

/// Shared app state — holds the markdown text and persists it to UserDefaults.
class AppState: ObservableObject {
    static let shared = AppState()

    @Published var markdownText: String {
        didSet {
            UserDefaults.standard.set(markdownText, forKey: "markdownContent")
        }
    }

    private init() {
        markdownText = UserDefaults.standard.string(forKey: "markdownContent") ?? sampleMarkdown
    }
}
