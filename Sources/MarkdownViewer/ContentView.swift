import SwiftUI

let sampleMarkdown = """
# Markdown Viewer

Paste your markdown in the editor on the left!

## Tables

| Language | Stars | Trend |
|----------|-------|-------|
| Rust     | 89k   | 🔥 Hot |
| Swift    | 65k   | ↑ Up  |
| Go       | 120k  | → Steady |

## Code Blocks

```python
def greet(name: str) -> str:
    return f"Hello, {name}!"

print(greet("World"))
```

## Diagrams

```mermaid
graph LR
    A[Paste Markdown] --> B[See Preview]
    B --> C{Happy?}
    C -- Yes --> D[Done!]
    C -- No --> A
```

## ASCII Charts

```
CPU Usage (%)
100 ┤
 90 ┤  ╭─╮
 80 ┤  │ │     ╭──╮
 70 ┤──╯ ╰─────╯  ╰──
 60 ┤
    └──────────────────
    10s  20s  30s  40s
```

## Blockquote

> Terminal output, tables, and diagrams all render beautifully here.
"""

struct ContentView: View {
    @EnvironmentObject private var appState: AppState
    @State private var showEditor: Bool = true

    var body: some View {
        HSplitView {
            if showEditor {
                EditorPane(text: $appState.markdownText)
                    .frame(minWidth: 280, idealWidth: 420)
            }
            PreviewPane(markdownText: appState.markdownText)
                .frame(minWidth: 400, maxWidth: .infinity)
        }
        .frame(minWidth: showEditor ? 800 : 500, minHeight: 550)
        .toolbar {
            ToolbarItemGroup(placement: .automatic) {
                Button {
                    showEditor.toggle()
                } label: {
                    Image(systemName: showEditor ? "sidebar.left" : "sidebar.left")
                        .symbolVariant(showEditor ? .fill : .none)
                }
                .help(showEditor ? "Hide Editor" : "Show Editor")

                Divider()

                Button("Clear") {
                    appState.markdownText = ""
                }
                .help("Clear the editor")

                Button("Sample") {
                    appState.markdownText = sampleMarkdown
                }
                .help("Load sample markdown")
            }
        }
    }
}

struct EditorPane: View {
    @Binding var text: String

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("EDITOR")
                    .font(.system(size: 10, weight: .semibold, design: .default))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                Spacer()
                Text("\(text.count) chars")
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
                    .padding(.trailing, 12)
            }
            .background(.bar)

            Divider()

            MonospaceTextEditor(text: $text)
        }
    }
}

struct PreviewPane: View {
    let markdownText: String

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("PREVIEW")
                    .font(.system(size: 10, weight: .semibold, design: .default))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                Spacer()
            }
            .background(.bar)

            Divider()

            MarkdownWebView(markdownText: markdownText)
        }
    }
}
