import Foundation

enum ArchiveService {
    static func fetch(
        user: String,
        repo: Repository,
        to outDir: URL,
        method: String,
        groupByLang: Bool,
        overwrite: Bool
    ) async throws {
        var target = outDir
        
        if groupByLang {
            let lang = (repo.language ?? "Unknown").replacingOccurrences(of: "/", with: "-")
            target.appendPathComponent(lang)
            try? FileManager.default.createDirectory(at: target, withIntermediateDirectories: true)
        }
        
        let path = target.appendingPathComponent(repo.name)
        
        if FileManager.default.fileExists(atPath: path.path) {
            guard overwrite else { return }
            try? FileManager.default.removeItem(at: path)
        }
        
        if method == "ZIP Download" {
            try await fetchZip(user: user, repo: repo, to: target)
        } else {
            try await cloneViaGit(user: user, repo: repo, to: path, method: method)
        }
    }
    
    private static func fetchZip(user: String, repo: Repository, to dir: URL) async throws {
        let urlStr = "https://github.com/\(user)/\(repo.name)/archive/refs/heads/\(repo.defaultBranch).zip"
        guard let url = URL(string: urlStr) else { throw AppError.extractionFailed }
        
        let tempUrl: URL
        let res: URLResponse
        
        do {
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = 45.0
            let session = URLSession(configuration: config)
            (tempUrl, res) = try await session.download(from: url)
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
        
        guard let http = res as? HTTPURLResponse else { throw AppError.extractionFailed }
        if (500...599).contains(http.statusCode) { throw AppError.serverError(http.statusCode) }
        guard http.statusCode == 200 else { throw AppError.apiError(http.statusCode) }
        
        try await Task.detached {
            let p = Process()
            p.executableURL = URL(fileURLWithPath: "/usr/bin/ditto")
            p.arguments = ["-x", "-k", tempUrl.path, dir.path]
            p.standardOutput = FileHandle.nullDevice
            p.standardError = FileHandle.nullDevice
            
            try p.run()
            p.waitUntilExit()

            guard p.terminationStatus == 0 else { throw AppError.extractionFailed }
        }.value
        
        try? FileManager.default.removeItem(at: tempUrl)
        
        let extracted = "\(repo.name)-\(repo.defaultBranch)"
        let extractedUrl = dir.appendingPathComponent(extracted)
        let finalUrl = dir.appendingPathComponent(repo.name)
        
        if FileManager.default.fileExists(atPath: extractedUrl.path) {
            try? FileManager.default.moveItem(at: extractedUrl, to: finalUrl)
        }
    }
    
    private static func cloneViaGit(user: String, repo: Repository, to dir: URL, method: String) async throws {
        let cloneUrl = method == "SSH Clone"
            ? "git@github.com:\(user)/\(repo.name).git"
            : "https://github.com/\(user)/\(repo.name).git"
        
        try await Task.detached {
            let p = Process()
            p.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
            p.arguments = ["git", "clone", cloneUrl, dir.path]
            
            var env = ProcessInfo.processInfo.environment
            env["PATH"] = "/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin"
            p.environment = env
            
            let errorPipe = Pipe()
            p.standardOutput = FileHandle.nullDevice
            p.standardError = errorPipe
            
            try p.run()
            p.waitUntilExit()

            guard p.terminationStatus == 0 else {
                let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                let errorMessage = String(data: errorData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Unknown git error"
                throw AppError.gitCloneFailed(errorMessage)
            }
        }.value
    }
}
