import SwiftUI

struct ContentView: View {
    @State private var viewModel = ContentViewModel()
    @State private var isHoveringDownloadButton = false
    @State private var selection: NavigationItem? = .download
    @State private var columnVisibility: NavigationSplitViewVisibility = .all

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            List(NavigationItem.allCases, selection: $selection) { item in
                Label(item.rawValue, systemImage: item.icon)
                    .tag(item)
            }
            .listStyle(.sidebar)
            .navigationSplitViewColumnWidth(min: 200, ideal: 220, max: 280)
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
        .navigationSplitViewStyle(.prominentDetail)
        .frame(minWidth: 800, minHeight: 740)
    }
}

