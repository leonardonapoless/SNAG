import Foundation

enum AppError: LocalizedError {
    case rateLimited
    case apiError(Int)
    case extractionFailed
    case offline
    case timeout
    case serverError(Int)
    case gitCloneFailed(String)
    case sshKeyMissing(repository: String)

    var errorDescription: String? {
        switch self {
        case .rateLimited: 
            return "GitHub rate limit exceeded. Please wait a moment and try again."
        case .apiError(let code): 
            return "GitHub API responded with an unexpected status code: \(code)."
        case .extractionFailed: 
            return "Failed to extract the downloaded ZIP archive."
        case .offline:
            return "You are currently offline. Please check your internet connection."
        case .timeout:
            return "The request to GitHub timed out. Please try again later."
        case .serverError(let code):
            return "GitHub servers appear to be offline (HTTP \(code))."
        case .gitCloneFailed(let message):
            return "Git Clone aborted:\n\(message)"
        case .sshKeyMissing(let repo):
            return "Failed to clone '\(repo)' using SSH."
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .rateLimited: 
            return "Please wait a moment and try again later."
        case .apiError, .extractionFailed, .serverError, .gitCloneFailed:
            return "Check the repository URL or permissions and try again."
        case .offline, .timeout:
            return "Ensure your Mac is connected to the network and try again."
        case .sshKeyMissing:
            return "macOS cannot find an SSH key associated with your GitHub account. You can either switch the download method to HTTPS, or generate and link a new SSH key to your account."
        }
    }
}
