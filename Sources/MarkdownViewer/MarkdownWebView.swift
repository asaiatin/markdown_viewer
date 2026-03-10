import SwiftUI
import WebKit

struct MarkdownWebView: NSViewRepresentable {
    let markdownText: String

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        // Allow loading CDN scripts
        config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.loadHTMLString(htmlTemplate, baseURL: URL(string: "https://localhost"))
        context.coordinator.pendingText = markdownText
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        if context.coordinator.isReady {
            context.coordinator.update(webView: webView, text: markdownText)
        } else {
            context.coordinator.pendingText = markdownText
        }
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var isReady = false
        var pendingText: String?

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            isReady = true
            if let text = pendingText {
                update(webView: webView, text: text)
                pendingText = nil
            }
        }

        func update(webView: WKWebView, text: String) {
            // Use base64 to safely pass any markdown (avoids JS escaping issues)
            let base64 = Data(text.utf8).base64EncodedString()
            webView.evaluateJavaScript("updateContentBase64('\(base64)')", completionHandler: nil)
        }
    }
}

// MARK: - HTML Template

private let htmlTemplate = """
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="color-scheme" content="light dark">

<!-- marked.js v4 — stable markdown parser with GFM tables -->
<script src="https://cdn.jsdelivr.net/npm/marked@4.3.0/marked.min.js"></script>

<!-- mermaid v10 — flowcharts, sequence diagrams, etc. -->
<script src="https://cdn.jsdelivr.net/npm/mermaid@10.6.1/dist/mermaid.min.js"></script>

<!-- highlight.js v11 — syntax highlighting -->
<link id="hljs-light" rel="stylesheet" href="https://cdn.jsdelivr.net/npm/highlight.js@11.9.0/styles/github.min.css">
<link id="hljs-dark"  rel="stylesheet" href="https://cdn.jsdelivr.net/npm/highlight.js@11.9.0/styles/github-dark.min.css" disabled>
<script src="https://cdn.jsdelivr.net/npm/highlight.js@11.9.0/lib/highlight.min.js"></script>

<style>
:root {
  --bg:         #ffffff;
  --fg:         #1a1a1a;
  --code-bg:    #f6f8fa;
  --border:     #d0d7de;
  --link:       #0969da;
  --th-bg:      #f6f8fa;
  --tr-alt:     #f6f8fa;
  --bq-border:  #d0d7de;
  --bq-color:   #57606a;
  --muted:      #6e7781;
  --radius:     8px;
}
@media (prefers-color-scheme: dark) {
  :root {
    --bg:        #0d1117;
    --fg:        #e6edf3;
    --code-bg:   #161b22;
    --border:    #30363d;
    --link:      #58a6ff;
    --th-bg:     #161b22;
    --tr-alt:    #1c2128;
    --bq-border: #3d444d;
    --bq-color:  #8d96a0;
    --muted:     #848d97;
  }
}

* { box-sizing: border-box; margin: 0; padding: 0; }

html { font-size: 16px; }

body {
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif;
  font-size: 1rem;
  line-height: 1.7;
  color: var(--fg);
  background: var(--bg);
  padding: 36px 48px;
  max-width: 860px;
  margin: 0 auto;
}

/* ── Headings ── */
h1, h2, h3, h4, h5, h6 {
  margin: 1.5em 0 0.6em;
  font-weight: 600;
  line-height: 1.25;
}
h1 { font-size: 2em;   border-bottom: 1px solid var(--border); padding-bottom: 0.3em; }
h2 { font-size: 1.5em; border-bottom: 1px solid var(--border); padding-bottom: 0.3em; }
h3 { font-size: 1.25em; }
h4 { font-size: 1em;   }
h5, h6 { font-size: 0.875em; }

/* ── Paragraphs & Inline ── */
p   { margin: 0 0 1em; }
strong { font-weight: 600; }
em     { font-style: italic; }
del    { text-decoration: line-through; color: var(--muted); }

a { color: var(--link); text-decoration: none; }
a:hover { text-decoration: underline; }

/* ── Inline code ── */
code {
  font-family: "SF Mono", SFMono-Regular, Consolas, "Liberation Mono", Menlo, monospace;
  font-size: 0.85em;
  background: var(--code-bg);
  padding: 0.15em 0.4em;
  border-radius: 4px;
  border: 1px solid var(--border);
}

/* ── Code blocks ── */
pre {
  background: var(--code-bg);
  border: 1px solid var(--border);
  border-radius: var(--radius);
  padding: 16px 20px;
  overflow-x: auto;
  margin: 0 0 1em;
  line-height: 1.5;
}
pre code {
  background: transparent;
  border: none;
  padding: 0;
  font-size: 0.875em;
  white-space: pre;
}

/* ── Tables ── */
.table-wrap {
  overflow-x: auto;
  margin: 0 0 1em;
}
table {
  border-collapse: collapse;
  width: 100%;
  border: 1px solid var(--border);
  border-radius: var(--radius);
  overflow: hidden;
  font-size: 0.9em;
}
th, td {
  padding: 8px 16px;
  border: 1px solid var(--border);
  text-align: left;
}
th {
  background: var(--th-bg);
  font-weight: 600;
}
tbody tr:nth-child(even) td { background: var(--tr-alt); }

/* ── Blockquotes ── */
blockquote {
  border-left: 4px solid var(--bq-border);
  padding: 0 1em;
  color: var(--bq-color);
  margin: 0 0 1em;
}
blockquote > *:last-child { margin-bottom: 0; }

/* ── Lists ── */
ul, ol { padding-left: 2em; margin: 0 0 1em; }
li      { margin: 3px 0; }
li > p  { margin: 0; }

/* ── HR ── */
hr {
  border: none;
  border-top: 1px solid var(--border);
  margin: 1.5em 0;
}

/* ── Images ── */
img { max-width: 100%; height: auto; border-radius: 4px; }

/* ── Mermaid diagrams ── */
.mermaid-wrap {
  display: flex;
  justify-content: center;
  background: var(--code-bg);
  border: 1px solid var(--border);
  border-radius: var(--radius);
  padding: 20px;
  margin: 0 0 1em;
  overflow-x: auto;
}

/* ── Welcome screen ── */
#welcome {
  text-align: center;
  padding: 100px 40px;
  color: var(--muted);
}
#welcome svg { margin-bottom: 20px; opacity: 0.35; }
#welcome h2  { font-size: 1.4em; border: none; color: var(--muted); margin: 0 0 8px; }
#welcome p   { font-size: 0.95em; }

/* ── Scrollbar ── */
::-webkit-scrollbar { width: 6px; height: 6px; }
::-webkit-scrollbar-track { background: transparent; }
::-webkit-scrollbar-thumb { background: var(--border); border-radius: 3px; }

/* ── Dark-mode tweak for hljs ── */
.hljs { background: transparent !important; }
</style>
</head>
<body>
<div id="content">
  <div id="welcome">
    <svg width="64" height="64" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
      <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
      <polyline points="14 2 14 8 20 8"/>
      <line x1="16" y1="13" x2="8" y2="13"/>
      <line x1="16" y1="17" x2="8" y2="17"/>
      <polyline points="10 9 9 9 8 9"/>
    </svg>
    <h2>Paste Markdown to Preview</h2>
    <p>Start typing or paste markdown in the editor on the left</p>
  </div>
</div>

<script>
// ── Dark mode sync for hljs stylesheets ──────────────────────────────────────
const isDark = window.matchMedia('(prefers-color-scheme: dark)');
function syncTheme(dark) {
  document.getElementById('hljs-light').disabled = dark.matches;
  document.getElementById('hljs-dark').disabled  = !dark.matches;
}
syncTheme(isDark);
isDark.addEventListener('change', syncTheme);

// ── Mermaid init ─────────────────────────────────────────────────────────────
mermaid.initialize({
  startOnLoad: false,
  theme: isDark.matches ? 'dark' : 'default',
  securityLevel: 'loose'
});
isDark.addEventListener('change', e => {
  mermaid.initialize({ startOnLoad: false, theme: e.matches ? 'dark' : 'default', securityLevel: 'loose' });
});

// ── marked: custom renderer ──────────────────────────────────────────────────
const renderer = {
  // Wrap tables for horizontal scroll
  table(header, body) {
    return '<div class="table-wrap"><table><thead>' + header + '</thead><tbody>' + body + '</tbody></table></div>';
  },
  // Handle mermaid + syntax highlighting
  code(code, lang) {
    if (lang === 'mermaid') {
      return '<div class="mermaid-wrap"><div class="mermaid">' + escHtml(code) + '</div></div>';
    }
    if (lang && typeof hljs !== 'undefined' && hljs.getLanguage(lang)) {
      try {
        const hl = hljs.highlight(code, { language: lang, ignoreIllegals: true }).value;
        return '<pre><code class="hljs language-' + lang + '">' + hl + '</code></pre>';
      } catch(_) {}
    }
    if (typeof hljs !== 'undefined') {
      const hl = hljs.highlightAuto(code).value;
      return '<pre><code class="hljs">' + hl + '</code></pre>';
    }
    return '<pre><code>' + escHtml(code) + '</code></pre>';
  }
};

marked.use({ renderer, gfm: true, breaks: false });

function escHtml(s) {
  return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
}

// ── Main update function (called from Swift via evaluateJavaScript) ───────────
function updateContentBase64(base64) {
  // Safely decode UTF-8 content encoded as base64
  let markdown;
  try {
    const bytes = Uint8Array.from(atob(base64), c => c.charCodeAt(0));
    markdown = new TextDecoder('utf-8').decode(bytes);
  } catch(e) {
    markdown = atob(base64);
  }

  const content = document.getElementById('content');

  if (!markdown.trim()) {
    content.innerHTML = '<div id="welcome"><h2>Paste Markdown to Preview</h2><p>Start typing or paste markdown in the editor on the left</p></div>';
    return;
  }

  content.innerHTML = marked.parse(markdown);

  // Run mermaid on any diagram blocks
  const diagrams = content.querySelectorAll('.mermaid:not([data-processed])');
  if (diagrams.length > 0) {
    mermaid.run({ nodes: diagrams }).catch(() => {});
  }
}
</script>
</body>
</html>
"""
