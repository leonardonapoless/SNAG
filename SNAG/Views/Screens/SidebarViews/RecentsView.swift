import SwiftUI

struct RecentsView: View {
    @Bindable var viewModel: ContentViewModel
    @Binding var selection: NavigationItem?

    var body: some View {
        Group {
            if viewModel.recentProfiles.isEmpty {
                ContentUnavailableView {
                    Label("No Recent Profiles", systemImage: "clock.arrow.circlepath")
                } description: {
                    Text("Profiles you fetch or download will appear here.")
                }
            } else {
                List {
                    ForEach(viewModel.recentProfiles) { profile in
                        RecentProfileRow(profile: profile)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewModel.githubProfile = profile.username
                                selection = .download
                            }
                            .contextMenu {
                                Button("Fetch Repositories") {
                                    viewModel.githubProfile = profile.username
                                    selection = .download
                                    viewModel.fetchRepos()
                                }

                                Divider()

                                Button("Copy Username") {
                                    NSPasteboard.general.clearContents()
                                    NSPasteboard.general.setString(profile.username, forType: .string)
                                }

                                Button("Open on GitHub") {
                                    if let url = URL(string: "https://github.com/\(profile.username)") {
                                        NSWorkspace.shared.open(url)
                                    }
                                }

                                Divider()

                                Button("Remove", role: .destructive) {
                                    withAnimation { viewModel.removeRecentProfile(profile) }
                                }
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    withAnimation { viewModel.removeRecentProfile(profile) }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
                .listStyle(.inset(alternatesRowBackgrounds: true))
                .toolbar {
                    ToolbarItem(placement: .destructiveAction) {
                        Button("Clear All") {
                            withAnimation { viewModel.clearRecentProfiles() }
                        }
                        .disabled(viewModel.recentProfiles.isEmpty)
                    }
                }
            }
        }
        .navigationTitle("Recent Profiles")
    }
}

private struct RecentProfileRow: View {
    let profile: RecentProfile
    @State private var showingProfile = false

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: "https://github.com/\(profile.username).png?size=56")) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.quaternary)
            }
            .frame(width: 32, height: 32)
            .clipShape(Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(profile.username)
                    .font(.system(size: 13, weight: .semibold))

                HStack(spacing: 8) {
                    if profile.repositoryCount > 0 {
                        Label(
                            "\(profile.repositoryCount) repos",
                            systemImage: "square.stack.3d.up"
                        )
                    }

                    Label(profile.timestamp.formatted(.relative(presentation: .named)), systemImage: "clock")
                }
                .font(.system(size: 11))
                .foregroundStyle(.tertiary)
                .labelStyle(CompactLabelStyle())
            }

            Spacer()

            Button {
                showingProfile = true
            } label: {
                Image(systemName: "info.circle")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
        .sheet(isPresented: $showingProfile) {
            ProfileSheet(username: profile.username)
        }
    }
}

