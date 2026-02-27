import Foundation

enum GitHubAPI {
    static func extractUsername(from input: String) -> String? {
        let text = input.trimmingCharacters(in: .whitespacesAndNewlines)

        if let url = URL(string: text),
           url.host()?.contains("github.com") == true,
           let user = url.pathComponents.dropFirst().first,
           !user.isEmpty {
            return user
        }

        if !text.contains("/"), !text.contains(" "), !text.isEmpty {
            return text
        }

        return nil
    }

    static func fetchRepositories(for username: String) async throws -> [Repository] {
        var allRepositories: [Repository] = []
        var page = 1

        while true {
            var components = URLComponents(string: "https://api.github.com/users/\(username)/repos")!
            components.queryItems = [
                URLQueryItem(name: "per_page", value: "100"),
                URLQueryItem(name: "page", value: "\(page)")
            ]

            let (data, response) = try await URLSession.shared.data(from: components.url!)
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0

            if statusCode == 403 { throw AppError.rateLimited }
            guard statusCode == 200 else { throw AppError.apiError(statusCode) }

            let batch = try JSONDecoder().decode([Repository].self, from: data)
            if batch.isEmpty { break }

            allRepositories.append(contentsOf: batch)
            page += 1
        }

        return allRepositories
    }
}
