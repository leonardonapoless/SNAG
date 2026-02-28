import SwiftUI

struct RepoSelectionView: View {
    var viewModel: ContentViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Select Repositories (\(viewModel.selectedRepositoryIDs.count)/\(viewModel.fetchedRepositories.count))")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Button("Select All") {
                    viewModel.selectAll()
                }
                .buttonStyle(.plain)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.primary)
                
                Text("•")
                    .foregroundStyle(.secondary.opacity(0.5))
                
                Button("Deselect All") {
                    viewModel.deselectAll()
                }
                .buttonStyle(.plain)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.primary)
            }
            .padding(.horizontal, 16)
            
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.fetchedRepositories) { repo in
                        let isSelected = viewModel.selectedRepositoryIDs.contains(repo.id)
                        
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                viewModel.toggleSelection(for: repo.id)
                            }
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(isSelected ? Color.primary : Color.secondary.opacity(0.4))
                                    .font(.system(size: 16))
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(repo.name)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundStyle(isSelected ? .primary : .secondary)
                                    
                                    if let description = repo.description, !description.isEmpty {
                                        Text(description)
                                            .font(.system(size: 12, weight: .regular))
                                            .foregroundStyle(.secondary.opacity(0.8))
                                            .lineLimit(2)
                                    }
                                }
                                
                                Spacer()
                                
                                Text(repo.defaultBranch)
                                    .font(.system(size: 12, weight: .regular, design: .monospaced))
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(.quaternary.opacity(0.5), in: .rect(cornerRadius: 4))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        
                        if repo != viewModel.fetchedRepositories.last {
                            Divider()
                                .padding(.leading, 44)
                                .opacity(0.5)
                        }
                    }
                }
                .padding(.vertical, 8)
            }
            .frame(height: 220)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(NSColor.textBackgroundColor).opacity(0.5))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(Color(NSColor.separatorColor).opacity(0.5), lineWidth: 1)
            )
        }
    }
}
