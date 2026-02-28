import Foundation

enum NavigationItem: String, CaseIterable, Identifiable {
    case download = "Download"
    case recents = "Recents"
    case settings = "Settings"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .download: return "arrow.down.circle"
        case .recents: return "clock"
        case .settings: return "gearshape"
        }
    }
}
