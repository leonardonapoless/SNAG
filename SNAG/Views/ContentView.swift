import SwiftUI

struct ContentView: View {
    @State private var viewModel = ContentViewModel()
    @State private var isHoveringDownloadButton = false

    var body: some View {
        DownloadView(
            viewModel: viewModel,
            isHoveringDownloadButton: $isHoveringDownloadButton
        )
        .containerBackground(.windowBackground, for: .window)
        .frame(minWidth: 800, minHeight: 600)
    }

    private struct DownloadView: View {
        let viewModel: ContentViewModel
        @Binding var isHoveringDownloadButton: Bool

        var body: some View {
            VStack(spacing: 0) {
                HeaderView(viewModel: viewModel)

                ScrollView {
                    VStack(spacing: 24) {
                        InputSection(viewModel: viewModel)

                        if !viewModel.fetchedRepositories.isEmpty {
                            RepositorySelectionView(viewModel: viewModel)
                                .transition(.move(edge: .top).combined(with: .opacity))
                        }

                        ActionSection(viewModel: viewModel, isHovering: $isHoveringDownloadButton)
                            .zIndex(1)

                        ConsoleSection(viewModel: viewModel)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 32)
                }
            }
        }
    }
}
