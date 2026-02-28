import SwiftUI

enum CloneMethod: String, CaseIterable, Identifiable {
    case zip = "ZIP Download"
    case https = "HTTPS Clone"
    case ssh = "SSH Clone"
    
    var id: String { rawValue }
}

struct SettingsView: View {
    @Bindable var viewModel: ContentViewModel
    
    @AppStorage("cloneMethod") private var cloneMethod: CloneMethod = .zip
    @AppStorage("concurrency") private var concurrency: Int = 3
    @AppStorage("skipForks") private var skipForks: Bool = false
    @AppStorage("overwrite") private var overwrite: Bool = false
    @AppStorage("groupByLang") private var groupByLang: Bool = false

    var body: some View {
        Form {
            Section("Download Location") {
                LabeledContent("Directory") {
                    HStack(spacing: 8) {
                        Text(PathFormatter.displayPath(viewModel.downloadPath))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                        
                        Button("Choose...") {
                            selectDownloadDirectory()
                        }
                        .fixedSize()
                    }
                }
                
                TextField("Custom Folder Name", text: $viewModel.customFolderName, prompt: Text("Leave blank to use username"))
            }
            
            Section("Download Options") {
                Picker("Protocol", selection: $cloneMethod) {
                    ForEach(CloneMethod.allCases) { method in
                        Text(method.rawValue).tag(method)
                    }
                }
                .pickerStyle(.menu)
                
                LabeledContent("Concurrent Downloads") {
                    HStack(spacing: 12) {
                        Text("\(concurrency)")
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                            .frame(width: 24, alignment: .trailing)
                            
                        Stepper("", value: $concurrency, in: 1...10)
                            .labelsHidden()
                    }
                }
            }
            
            Section("Repository Filters") {
                Toggle("Skip Forked Repositories", isOn: $skipForks)
                Toggle("Overwrite Existing Folders", isOn: $overwrite)
                Toggle("Organize into Language Folders", isOn: $groupByLang)
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Settings")
    }
    
    private func selectDownloadDirectory() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = true
        panel.title = "Select Download Directory"
        
        if panel.runModal() == .OK, let url = panel.url {
            viewModel.downloadPath = url.path(percentEncoded: false)
        }
    }
}