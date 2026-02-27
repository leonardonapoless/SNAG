import SwiftUI

enum NavigationItem: String, CaseIterable, Identifiable {
    case download
    case recent
    case settings
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .download: return "Download"
        case .recent: return "Recent"
        case .settings: return "Settings"
        }
    }
    
    var icon: String {
        switch self {
        case .download: return "square.and.arrow.down"
        case .recent: return "clock"
        case .settings: return "gearshape"
        }
    }
}
