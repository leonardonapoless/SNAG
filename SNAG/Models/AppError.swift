import Foundation

enum AppError: LocalizedError {
    case rateLimited
    case apiError(Int)
    case extractionFailed

    var errorDescription: String? {
        switch self {
        case .rateLimited: return "GitHub rate limit exceeded. Try again later."
        case .apiError(let code): return "GitHub API returned status \(code)."
        case .extractionFailed: return "Failed to extract the downloaded repository."
        }
    }
}
