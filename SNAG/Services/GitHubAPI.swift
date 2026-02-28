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

    static func fetchRepos(for username: String) async throws -> [Repository] {
        var allRepos: [Repository] = []
        var page = 1

        while true {
            var components = URLComponents(string: "https://api.github.com/users/\(username)/repos")!
            components.queryItems = [
                URLQueryItem(name: "per_page", value: "100"),
                URLQueryItem(name: "page", value: "\(page)")
            ]

            let data: Data
            let response: URLResponse
            
            do {
                let config = URLSessionConfiguration.default
                config.timeoutIntervalForRequest = 15.0
                let session = URLSession(configuration: config)
                
                (data, response) = try await session.data(from: components.url!)
            } catch let error as URLError {
                switch error.code {
                case .notConnectedToInternet, .cannotFindHost, .networkConnectionLost:
                    throw AppError.offline
                case .timedOut:
                    throw AppError.timeout
                default:
                    throw error
                }
            }

            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0

            if statusCode == 403 { throw AppError.rateLimited }
            if (500...599).contains(statusCode) { throw AppError.serverError(statusCode) }
            guard statusCode == 200 else { throw AppError.apiError(statusCode) }

            let batch = try JSONDecoder().decode([Repository].self, from: data)
            if batch.isEmpty { break }

            allRepos.append(contentsOf: batch)
            page += 1
        }

        return allRepos
    }
}
