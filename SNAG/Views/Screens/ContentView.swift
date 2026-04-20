import SwiftUI

struct ContentView: View {
    @State private var viewModel = ContentViewModel()
    @State private var isHoveringDownloadButton = false
    @State private var selection: NavigationItem? = .download

    var body: some View {
        NavigationSplitView {
            List(NavigationItem.allCases, selection: $selection) { item in
                Label(item.rawValue, systemImage: item.icon)
                    .tag(item)
            }
            .listStyle(.sidebar)
            .navigationSplitViewColumnWidth(min: 160, ideal: 200, max: 240)
        } detail: {
            switch selection {
            case .download, .none:
                DownloadView(
                    viewModel: viewModel,
                    isHoveringDownloadButton: $isHoveringDownloadButton
                )
            case .recents:
                RecentsView(viewModel: viewModel, selection: $selection)
            case .settings:
                SettingsView(viewModel: viewModel)
            }
        }
        .navigationSplitViewStyle(.balanced)
        .frame(minWidth: 800, minHeight: 740)
    }
}
