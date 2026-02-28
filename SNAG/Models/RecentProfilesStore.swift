import Foundation
import Observation

struct RecentProfile: Codable, Identifiable, Hashable {
    let username: String
    let timestamp: Date
    var repositoryCount: Int

    var id: String { username }
}

@MainActor
@Observable
final class RecentProfilesStore {
    private static let storageKey = "recentProfiles"

    private(set) var profiles: [RecentProfile] = []
    private let limit: Int

    init(limit: Int = 20) {
        self.limit = limit
        load()
    }

    func insert(_ username: String, repositoryCount: Int = 0) {
        guard !username.isEmpty else { return }
        profiles.removeAll { $0.username.lowercased() == username.lowercased() }
        profiles.insert(
            RecentProfile(username: username, timestamp: .now, repositoryCount: repositoryCount),
            at: 0
        )
        if profiles.count > limit {
            profiles.removeLast()
        }
        save()
    }

    func remove(_ profile: RecentProfile) {
        profiles.removeAll { $0.id == profile.id }
        save()
    }

    func clear() {
        profiles.removeAll()
        save()
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: Self.storageKey),
              let decoded = try? JSONDecoder().decode([RecentProfile].self, from: data) else { return }
        profiles = decoded
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(profiles) else { return }
        UserDefaults.standard.set(data, forKey: Self.storageKey)
    }
}
