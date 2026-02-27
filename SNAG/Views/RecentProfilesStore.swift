import Foundation

@MainActor
final class RecentProfilesStore {
    private(set) var profiles: [String] = []
    private let limit: Int

    init(limit: Int = 10) {
        self.limit = limit
    }

    func insert(_ username: String) {
        guard !username.isEmpty else { return }
        if let index = profiles.firstIndex(of: username) {
            profiles.remove(at: index)
        }
        profiles.insert(username, at: 0)
        if profiles.count > limit {
            profiles.removeLast()
        }
    }
}
