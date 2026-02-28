import Foundation

struct Repository: Decodable, Sendable, Identifiable, Hashable {
    var id: String { name }
    let name: String
    let description: String?
    let defaultBranch: String
    let fork: Bool
    let language: String?

    enum CodingKeys: String, CodingKey {
        case name
        case description
        case defaultBranch = "default_branch"
        case fork
        case language
    }
}
