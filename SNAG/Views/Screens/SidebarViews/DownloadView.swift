import SwiftUI

struct DownloadView: View {
    let viewModel: ContentViewModel
    @Binding var isHoveringDownloadButton: Bool

    var body: some View {
        VStack(spacing: 0) {
                HeaderView(viewModel: viewModel)

                ScrollView {
                    VStack(spacing: 24) {
                        InputSection(viewModel: viewModel)

                        if !viewModel.fetchedRepositories.isEmpty {
                            RepoSelectionView(viewModel: viewModel)
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
            .padding(.top, -20)
            .sheet(isPresented: Bindable(viewModel).showErrorModal) {
                if let error = viewModel.currentError {
                    ErrorModalView(
                        error: error,
                        onSwitchToHTTPS: {
                            UserDefaults.standard.set("HTTPS Clone", forKey: "downloadMethod")
                        },
                        onSwitchToZIP: {
                            UserDefaults.standard.set("ZIP Download", forKey: "downloadMethod")
                        }
                    )
                }
            }
        }
    }
