import Foundation

struct DownloadProgress {
    var total: Int
    var completed: Int
    var fraction: Double { total == 0 ? 0 : Double(completed) / Double(total) }
}

actor DownloadService {
    func start(
        user: String,
        repos: [Repository],
        outDir: URL,
        isPaused: @Sendable () async -> Bool,
        onStart: @Sendable (_ total: Int) -> Void,
        onEach: @Sendable (_ index: Int, _ repo: Repository) -> Void,
        onSuccess: @Sendable (_ index: Int) -> Void,
        onFailure: @Sendable (_ index: Int, _ error: Error) -> Void,
        onComplete: @Sendable (_ count: Int) -> Void
    ) async {
        onStart(repos.count)

        let limit = max(1, UserDefaults.standard.integer(forKey: "concurrency"))
        let method = UserDefaults.standard.string(forKey: "cloneMethod") ?? "ZIP Download"
        let groupByLang = UserDefaults.standard.bool(forKey: "groupByLang")
        let overwrite = UserDefaults.standard.bool(forKey: "overwrite")
        
        var completed = 0
        
        await withTaskGroup(of: (Int, Result<Void, Error>).self) { group in
            var active = 0
            var i = 0
            
            while i < repos.count {
                var wasPaused = false
                while await isPaused() {
                    if !wasPaused { wasPaused = true }
                    try? await Task.sleep(for: .milliseconds(250))
                }
                
                if active >= limit {
                    if let res = await group.next() {
                        active -= 1
                        switch res.1 {
                        case .success:
                            completed += 1
                            onSuccess(res.0)
                        case .failure(let err):
                            onFailure(res.0, err)
                        }
                    }
                }
                
                let idx = i
                let repo = repos[idx]
                i += 1
                active += 1
                
                onEach(idx, repo)
                
                group.addTask {
                    do {
                        try await ArchiveService.fetch(
                            user: user,
                            repo: repo,
                            to: outDir,
                            method: method,
                            groupByLang: groupByLang,
                            overwrite: overwrite
                        )
                        return (idx, .success(()))
                    } catch {
                        return (idx, .failure(error))
                    }
                }
            }
            
            for await res in group {
                switch res.1 {
                case .success:
                    completed += 1
                    onSuccess(res.0)
                case .failure(let err):
                    onFailure(res.0, err)
                }
            }
        }

        onComplete(completed)
    }
}
