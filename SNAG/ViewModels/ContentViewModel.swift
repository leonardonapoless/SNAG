import SwiftUI

@Observable @MainActor
final class ContentViewModel {
    private let recentStore = RecentProfilesStore()
    private let downloadService = DownloadService()

    var githubProfile = "" {
        didSet {
            if githubProfile != oldValue {
                fetchedRepositories.removeAll()
                selectedRepositoryIDs.removeAll()
                isFinished = false
                outputLog = ""
            }
        }
    }
    var customFolderName = ""
    var downloadPath = FileManager.default.homeDirectoryForCurrentUser.appending(path: "Downloads").path
    
    var outputLog = ""
    var downloadProgress = 0.0
    var isDownloading = false
    var isFinished = false
    
    var isFetching = false
    var fetchedRepositories: [Repository] = []
    var selectedRepositoryIDs: Set<String> = []
    
    var totalRepositories = 0
    var completedRepositories = 0

    var isPaused = false
    var recentProfiles: [String] { recentStore.profiles }
    private var downloadTask: Task<Void, Never>?

    var isReadyToFetch: Bool {
        !isFetching && !isDownloading && !githubProfile.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var isReadyToDownload: Bool {
        !isDownloading && !fetchedRepositories.isEmpty && !selectedRepositoryIDs.isEmpty
    }

    func fetchRepositories() {
        Task {
            guard let username = GitHubAPI.extractUsername(from: githubProfile) else {
                logMessage("Invalid URL or username provided.\n")
                return
            }
            
            isFetching = true
            outputLog = "Looking up \(username) on GitHub...\n"
            fetchedRepositories.removeAll()
            selectedRepositoryIDs.removeAll()
            
            defer { isFetching = false }
            
            do {
                let repos = try await GitHubAPI.fetchRepositories(for: username)
                if repos.isEmpty {
                    logMessage("No public repositories found.\n")
                } else {
                    fetchedRepositories = repos
                    selectedRepositoryIDs = Set(repos.map(\.id))
                    logMessage("Found \(repos.count) repositories.\n")
                    
                    if let username = GitHubAPI.extractUsername(from: githubProfile) {
                        recentStore.insert(username)
                    }
                }
            } catch {
                logMessage("Error fetching repositories: \(error.localizedDescription)\n")
            }
        }
    }
    
    func toggleSelection(for repositoryID: String) {
        if selectedRepositoryIDs.contains(repositoryID) {
            selectedRepositoryIDs.remove(repositoryID)
        } else {
            selectedRepositoryIDs.insert(repositoryID)
        }
    }
    
    func selectAll() {
        selectedRepositoryIDs = Set(fetchedRepositories.map(\.id))
    }
    
    func deselectAll() {
        selectedRepositoryIDs.removeAll()
    }

    func startDownload(downloadAll: Bool = false) {
        downloadTask = Task { [weak self] in
            guard let self else { return }
            guard let username = GitHubAPI.extractUsername(from: githubProfile) else { return }

            isDownloading = true
            isPaused = false
            isFinished = false
            outputLog = ""
            downloadProgress = 0
            completedRepositories = 0

            defer {
                isDownloading = false
                isPaused = false
            }

            let reposToDownload = fetchedRepositories.filter {
                downloadAll || self.selectedRepositoryIDs.contains($0.id)
            }

            guard !reposToDownload.isEmpty else { return }

            totalRepositories = reposToDownload.count
            logMessage("Starting download of \(reposToDownload.count) repositories.\n\n")

            let folderName = customFolderName.isEmpty ? username : customFolderName
            let destinationDirectory = URL(fileURLWithPath: downloadPath).appending(path: folderName)
            try? FileManager.default.createDirectory(at: destinationDirectory, withIntermediateDirectories: true)

            await downloadService.download(
                username: username,
                repositories: reposToDownload,
                destinationDirectory: destinationDirectory,
                isPaused: { [weak self] in 
                    let safeSelf = self
                    return await MainActor.run { safeSelf?.isPaused ?? false } 
                },
                onStart: { _ in },
                onEach: { [weak self] index, repository in
                    let safeSelf = self
                    Task { @MainActor in
                        guard let self = safeSelf else { return }
                        if Task.isCancelled { return }
                        self.logMessage("\(repository.name)...")
                    }
                },
                onSuccess: { [weak self] index in
                    let safeSelf = self
                    Task { @MainActor in
                        guard let self = safeSelf else { return }
                        if Task.isCancelled { return }
                        self.logMessage(" ✓\n")
                        self.completedRepositories = index + 1
                        withAnimation(.spring(duration: 0.5, bounce: 0.15)) {
                            self.downloadProgress = Double(index + 1) / Double(self.totalRepositories)
                        }
                    }
                },
                onFailure: { [weak self] index, _ in
                    let safeSelf = self
                    Task { @MainActor in
                        guard let self = safeSelf else { return }
                        if Task.isCancelled { return }
                        self.logMessage(" ✗\n")
                        self.completedRepositories = index + 1
                        withAnimation(.spring(duration: 0.5, bounce: 0.15)) {
                            self.downloadProgress = Double(index + 1) / Double(self.totalRepositories)
                        }
                    }
                },
                onComplete: { [weak self] successCount in
                    let safeSelf = self
                    Task { @MainActor in
                        guard let self = safeSelf else { return }
                        let displayPath = destinationDirectory.path.replacingOccurrences(
                            of: FileManager.default.homeDirectoryForCurrentUser.path,
                            with: "~"
                        )
                        self.logMessage("\n\(successCount)/\(self.totalRepositories) repositories downloaded to \(displayPath)\n")
                        withAnimation(.spring(duration: 0.6, bounce: 0.2)) {
                            self.isFinished = true
                        }
                    }
                }
            )
        }
    }

    func pauseDownload() {
        withAnimation { isPaused = true }
    }

    func resumeDownload() {
        withAnimation { isPaused = false }
    }

    func cancelDownload() {
        downloadTask?.cancel()
        withAnimation(.spring(duration: 0.3)) {
            isDownloading = false
            isPaused = false
            downloadProgress = 0
            if !outputLog.isEmpty && !outputLog.hasSuffix("\n") {
                outputLog += "\n"
            }
            outputLog += "Operation completely cancelled.\n"
        }
    }

    func resetSession() {
        withAnimation(.spring(duration: 0.3)) {
            isFinished = false
            downloadProgress = 0
            outputLog = ""
            completedRepositories = 0
            fetchedRepositories.removeAll()
            selectedRepositoryIDs.removeAll()
        }
    }

    private func logMessage(_ message: String) { 
        outputLog += message 
    }
}

