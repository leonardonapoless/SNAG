import SwiftUI

extension View {
    fileprivate func consoleCardStyle() -> some View {
        self.modifier(ConsoleCardStyle())
    }
}

struct ConsoleSection: View {
    let viewModel: ContentViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if viewModel.isDownloading || viewModel.isFinished || viewModel.isCancelledState {
                progressHeader
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .top).combined(with: .opacity),
                            removal: .move(edge: .bottom).combined(with: .opacity)
                        )
                    )
            }

            if viewModel.isDownloading || viewModel.isFinished || viewModel.isCancelledState {
                Divider()
                    .padding(.horizontal, 20)
                    .transition(.opacity)
            }

            logArea
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.isDownloading)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.isFinished)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.isCancelledState)
        .consoleCardStyle()
    }

    private var progressHeader: some View {
        VStack(spacing: 10) {
            HStack(alignment: .lastTextBaseline) {
                Text(viewModel.isCancelledState ? "Download Cancelled" : (viewModel.isFinished ? "Download Complete" : "Downloading repositories..."))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(viewModel.isCancelledState ? .red : (viewModel.isFinished ? .primary : .secondary))
                
                Spacer()
                
                Text(viewModel.downloadProgress, format: .percent.precision(.fractionLength(0)))
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(viewModel.isCancelledState ? Color.red : (viewModel.isFinished ? Color.green : Color.primary))
                    .contentTransition(.numericText())
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule(style: .continuous)
                        .fill(Color(NSColor.separatorColor).opacity(0.4))
                        .frame(height: 6)
                    
                    Capsule(style: .continuous)
                        .fill(
                            viewModel.isCancelledState
                            ? AnyShapeStyle(Color.red.gradient)
                            : (viewModel.isFinished
                                ? AnyShapeStyle(Color.primary.gradient)
                                : AnyShapeStyle(Color.primary.gradient))
                        )
                        .frame(width: geometry.size.width * viewModel.downloadProgress, height: 6)
                }
            }
            .frame(height: 6)
        }
        .padding(20)
    }

    private var logArea: some View {
        ScrollViewReader { scrollProxy in
            ScrollView {
                VStack(spacing: 4) {
                    Text(viewModel.outputLog.isEmpty ? "Ready to download." : viewModel.outputLog)
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundStyle(viewModel.outputLog.isEmpty ? .tertiary : .secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                        .lineSpacing(4)
                    
                    Color.clear.frame(height: 1).id("LogBottom")
                }
                .padding(20)
            }
            .frame(minHeight: 180)
            .onChange(of: viewModel.outputLog) {
                withAnimation(.easeOut(duration: 0.15)) {
                    scrollProxy.scrollTo("LogBottom", anchor: .bottom)
                }
            }
        }
    }
}

