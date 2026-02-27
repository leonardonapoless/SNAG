import Foundation

struct DownloadProgress {
    var total: Int
    var completed: Int
    var fraction: Double { total == 0 ? 0 : Double(completed) / Double(total) }
}

actor DownloadService {
    func download(
        username: String,
        repositories: [Repository],
        destinationDirectory: URL,
        isPaused: @Sendable () async -> Bool,
        onStart: @Sendable (_ total: Int) -> Void,
        onEach: @Sendable (_ index: Int, _ repo: Repository) -> Void,
        onSuccess: @Sendable (_ index: Int) -> Void,
        onFailure: @Sendable (_ index: Int, _ error: Error) -> Void,
        onComplete: @Sendable (_ successCount: Int) -> Void
    ) async {
        onStart(repositories.count)

        var successCount = 0
        for (index, repository) in repositories.enumerated() {
            var printedPaused = false
            while await isPaused() {
                if !printedPaused {
                    printedPaused = true
                }
                try? await Task.sleep(for: .milliseconds(250))
            }

            onEach(index, repository)

            do {
                try await ArchiveService.downloadAndExtract(username: username, repository: repository, destination: destinationDirectory)
                successCount += 1
                onSuccess(index)
            } catch {
                onFailure(index, error)
            }
        }

        onComplete(successCount)
    }
}
