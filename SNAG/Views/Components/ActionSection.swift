import SwiftUI

struct ActionSection: View {
    let viewModel: ContentViewModel
    @Binding var isHovering: Bool

    var body: some View {
        Group {
            if viewModel.isFinished {
                HStack(spacing: 12) {
                    Button(action: { viewModel.resetSession() }) {
                        Label("Start New Download", systemImage: "arrow.counterclockwise")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .frame(maxWidth: .infinity)
                    }
                    .actionButtonStyle(.secondary)
                    
                    if let dir = viewModel.currentDestinationDirectory {
                        Button(action: {
                            NSWorkspace.shared.open(dir)
                        }) {
                            Label("Open in Finder", systemImage: "folder")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .frame(maxWidth: .infinity)
                        }
                        .actionButtonStyle(.primary)
                    }
                }
                .transition(.asymmetric(
                    insertion: .push(from: .bottom).combined(with: .opacity),
                    removal: .push(from: .top).combined(with: .opacity)
                ))
            } else if viewModel.isDownloading {
                HStack(spacing: 12) {
                    Button(action: {
                        if viewModel.isPaused {
                            viewModel.resumeDownload()
                        } else {
                            viewModel.pauseDownload()
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: viewModel.isPaused ? "play.fill" : "pause.fill")
                                .font(.system(size: 14, weight: .bold))
                            Text(viewModel.isPaused ? "Resume" : "Pause")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .actionButtonStyle(viewModel.isPaused ? .success : .warning)

                    Button(action: {
                        viewModel.cancelDownload()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .bold))
                            Text("Cancel")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .actionButtonStyle(.destructive)
                }
                .transition(.asymmetric(
                    insertion: .push(from: .top).combined(with: .opacity),
                    removal: .push(from: .bottom).combined(with: .opacity)
                ))
            } else if !viewModel.fetchedRepositories.isEmpty {
                HStack(spacing: 12) {
                    Button(action: {
                        viewModel.startDownload(downloadAll: false)
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.down.circle")
                                .font(.system(size: 15, weight: .bold))
                            
                            Text("Download Selected (\(viewModel.selectedRepositoryIDs.count))")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .actionButtonStyle(.primary)
                    .disabled(!viewModel.isReadyToDownload)
                    
                    Button(action: {
                        viewModel.startDownload(downloadAll: true)
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.down.doc")
                                .font(.system(size: 15, weight: .bold))
                            
                            Text("Download All")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .actionButtonStyle(.secondary)
                    .disabled(viewModel.isDownloading)
                }
                .transition(.asymmetric(
                    insertion: .push(from: .top).combined(with: .opacity),
                    removal: .push(from: .bottom).combined(with: .opacity)
                ))
            } else {
                Button(action: {
                    viewModel.fetchRepos()
                }) {
                    HStack(spacing: 8) {
                        if viewModel.isFetching {
                            ProgressView()
                                .controlSize(.small)
                            
                            Text("Fetching...")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                        } else {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 15, weight: .bold))
                            
                            Text("Fetch Repositories")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .actionButtonStyle(.primary)
                .disabled(!viewModel.isReadyToFetch)
                .transition(.asymmetric(
                    insertion: .push(from: .top).combined(with: .opacity),
                    removal: .push(from: .bottom).combined(with: .opacity)
                ))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: actionState)
    }

    private var actionState: String {
        if viewModel.isFinished { return "finished" }
        if viewModel.isDownloading { return "downloading-\(viewModel.isPaused)" }
        if viewModel.isFetching { return "fetching" }
        if !viewModel.fetchedRepositories.isEmpty { return "ready" }
        return "idle"
    }
}
