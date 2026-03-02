import SwiftUI

struct InputSection: View {
    @Bindable var viewModel: ContentViewModel
    @State private var showingProfile = false

    private var profileUsername: String {
        viewModel.githubProfile.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                InputRow(
                    label: "GitHub Profile",
                    icon: "person.crop.circle",
                    text: $viewModel.githubProfile,
                    prompt: "johnappleseed",
                    prefix: "https://github.com/"
                )

                if !profileUsername.isEmpty {
                    Button {
                        showingProfile = true
                    } label: {
                        Image(systemName: "info.circle")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, 16)
                }
            }
            .sheet(isPresented: $showingProfile) {
                ProfileSheet(username: profileUsername)
            }

            Divider()
                .padding(.leading, 32)
                .opacity(0.4)

            InputRow(
                label: "Destination Folder",
                icon: "folder",
                text: $viewModel.customFolderName,
                prompt: "Leave blank to use username"
            )

            Divider()
                .padding(.leading, 32)
                .opacity(0.4)

            HStack(spacing: 12) {
                Image(systemName: "externaldrive")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 24, alignment: .center)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Save Location")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.secondary)
                    
                    Text(PathFormatter.displayPath(viewModel.downloadPath))
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .padding(.vertical, 3)
                        .padding(.horizontal, 8)
                        .background(.quaternary.opacity(0.5), in: .rect(cornerRadius: 6, style: .continuous))
                }

                Spacer()

                Button("Browse...") {
                    presentFolderPicker()
                }
                .controlSize(.regular)
                .buttonStyle(.bordered)
            }
            .padding(16)
        }
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(NSColor.controlBackgroundColor))
                .shadow(color: .black.opacity(0.04), radius: 8, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color(NSColor.separatorColor).opacity(0.5), lineWidth: 1)
        )
    }

    private func presentFolderPicker() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.message = "Choose a destination folder for downloaded repositories"
        
        if panel.runModal() == .OK, let url = panel.url {
            let desktopPath = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Desktop").path
            
            if url.path == desktopPath {
                viewModel.downloadPath = url.appendingPathComponent("SNAG").path
            } else {
                viewModel.downloadPath = url.path
            }
        }
    }
}

private struct InputRow: View {
    let label: String
    let icon: String
    @Binding var text: String
    let prompt: String
    var prefix: String? = nil

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.primary)
                .frame(width: 24, alignment: .center)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.secondary)
                
                HStack(spacing: 0) {
                    if let prefix {
                        Text(prefix)
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(.secondary.opacity(0.7))
                    }
                    
                    TextField(prompt, text: $text)
                        .textFieldStyle(.plain)
                        .font(.system(size: 15, weight: .regular))
                        .lineLimit(1)
                }
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 2)
            }
        }
        .padding(16)
    }
}

enum PathFormatter {
    static func displayPath(_ path: String) -> String {
        var display = path.replacingOccurrences(of: NSHomeDirectory(), with: "~")
        display = display.replacingOccurrences(of: "/Users/\(NSUserName())", with: "~")
        return display
    }
}
