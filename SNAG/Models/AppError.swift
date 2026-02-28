import Foundation

enum AppError: LocalizedError {
    case rateLimited
    case apiError(Int)
    case extractionFailed
    case offline
    case timeout
    case serverError(Int)
    case gitCloneFailed(String)

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
            return "GitHub servers appear to be down (HTTP \(code))."
        case .gitCloneFailed(let message):
            return "Git Clone aborted:\n\(message)"
        }
    }
}
