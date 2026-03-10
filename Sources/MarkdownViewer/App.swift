import SwiftUI

@main
struct MarkdownViewerApp: App {
    var body: some Scene {
        WindowGroup("Markdown Viewer") {
            ContentView()
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified(showsTitle: true))
        .commands {
            CommandGroup(replacing: .newItem) {}
        }
    }
}
