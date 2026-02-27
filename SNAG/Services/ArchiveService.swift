import Foundation

enum ArchiveService {
    static func downloadAndExtract(username: String, repository: Repository, destination: URL) async throws {
        let zipURL = URL(string: "https://github.com/\(username)/\(repository.name)/archive/refs/heads/\(repository.defaultBranch).zip")!

        let (temporaryURL, response) = try await URLSession.shared.download(from: zipURL)

        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw AppError.apiError((response as? HTTPURLResponse)?.statusCode ?? 0)
        }

        try await extractArchive(at: temporaryURL, to: destination)
        try? FileManager.default.removeItem(at: temporaryURL)
    }

    private static func extractArchive(at sourceURL: URL, to destinationURL: URL) async throws {
        try await Task.detached {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/ditto")
            process.arguments = ["-x", "-k", sourceURL.path, destinationURL.path]
            process.standardOutput = FileHandle.nullDevice
            process.standardError = FileHandle.nullDevice
            
            try process.run()
            process.waitUntilExit()

            guard process.terminationStatus == 0 else {
                throw AppError.extractionFailed
            }
        }.value
    }
}
