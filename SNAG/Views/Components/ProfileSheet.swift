import SwiftUI
import WebKit

struct ProfileSheet: View {
    let username: String
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = true

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(username)
                    .font(.headline)
                Spacer()
                Button("Done") { dismiss() }
                    .keyboardShortcut(.cancelAction)
            }
            .padding()

            Divider()

            WebView(url: URL(string: "https://github.com/\(username)")!, isLoading: $isLoading)
                .overlay(alignment: .top) {
                    if isLoading {
                        ProfileSkeleton()
                            .transition(.opacity)
                    }
                }
                .clipped()
                .animation(.easeOut(duration: 0.2), value: isLoading)
        }
        .frame(idealWidth: 700, idealHeight: 500)
        .fixedSize()
    }
}

struct WebView: NSViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {}

    final class Coordinator: NSObject, WKNavigationDelegate {
        let parent: WebView
        init(_ parent: WebView) { self.parent = parent }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
        }
    }
}

private struct ProfileSkeleton: View {
    @State private var shimmer = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Pill(width: 22, height: 16)
                Spacer()
                Circle().frame(width: 32, height: 32)
                Spacer()
                Pill(width: 62, height: 30)
                    .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(.quaternary))
                Circle().frame(width: 30, height: 30)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color(nsColor: .controlBackgroundColor))

            Divider()

            VStack(alignment: .leading, spacing: 20) {
                HStack(alignment: .center, spacing: 16) {
                    Circle().frame(width: 100, height: 100)
                    Pill(width: 180, height: 18)
                }
                .padding(.top, 12)

                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Pill(width: 18, height: 18)
                        Pill(width: 220, height: 13)
                    }
                    Pill(width: .infinity, height: 13)
                }

                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 6) {
                        Pill(width: 14, height: 14)
                        Pill(width: 160, height: 12)
                    }
                    HStack(spacing: 6) {
                        Pill(width: 14, height: 14)
                        Pill(width: 130, height: 12)
                    }
                }

                HStack(spacing: 6) {
                    Pill(width: 90, height: 12)
                    Pill(width: 90, height: 12)
                }

                RoundedRectangle(cornerRadius: 6)
                    .frame(maxWidth: .infinity)
                    .frame(height: 34)

                Divider()

                HStack(spacing: 14) {
                    ForEach(0..<6) { _ in
                        Circle().frame(width: 52, height: 52)
                    }
                }

                Divider()

                HStack(spacing: 18) {
                    ForEach(0..<5) { _ in
                        Pill(width: 64, height: 13)
                    }
                }

                ForEach(0..<2) { _ in
                    RoundedRectangle(cornerRadius: 8)
                        .frame(maxWidth: .infinity)
                        .frame(height: 90)
                }
            }
            .padding(24)

            Spacer()
        }
        .foregroundStyle(.quaternary)
        .opacity(shimmer ? 0.6 : 1.0)
        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: shimmer)
        .onAppear { shimmer = true }
        .background(.background)
    }
}

private struct Pill: View {
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: height / 3)
            .frame(maxWidth: width == .infinity ? .infinity : nil, minHeight: height, maxHeight: height)
            .frame(width: width == .infinity ? nil : width)
    }
}
