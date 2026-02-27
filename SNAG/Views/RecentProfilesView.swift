import SwiftUI

struct RecentProfilesView: View {
    var viewModel: ContentViewModel
    
    var body: some View {
        VStack {
            if viewModel.recentProfiles.isEmpty {
                ContentUnavailableView {
                    Label("No Recent Profiles", systemImage: "clock.badge.questionmark")
                } description: {
                    Text("Your recently fetched profiles will appear here for quick access.")
                }
            } else {
                List {
                    Section("Recently Fetched") {
                        ForEach(viewModel.recentProfiles, id: \.self) { profile in
                            Button(action: {
                                viewModel.githubProfile = profile
                                viewModel.fetchRepositories()
                            }) {
                                HStack {
                                    Image(systemName: "person.circle.fill")
                                        .foregroundStyle(.secondary)
                                    Text(profile)
                                        .font(.system(size: 14, weight: .medium))
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(.tertiary)
                                }
                                .padding(.vertical, 4)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }
}
