import SwiftUI

struct ErrorModalView: View {
    @Environment(\.dismiss) private var dismiss
    let error: AppError
    let onSwitchToHTTPS: (() -> Void)?
    let onSwitchToZIP: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.yellow.gradient)
                .symbolEffect(.pulse)
            
            VStack(spacing: 8) {
                Text(error.localizedDescription)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                
                if let suggestion = error.recoverySuggestion {
                    Text(suggestion)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            
            HStack(spacing: 12) {
                Button("Dismiss", role: .cancel) {
                    dismiss()
                }
                .keyboardShortcut(.escape, modifiers: [])
                
                if case .sshKeyMissing = error {
                    if let onSwitchToZIP {
                        Button("Use ZIP") {
                            onSwitchToZIP()
                            dismiss()
                        }
                    }
                    if let onSwitchToHTTPS {
                        Button("Use HTTPS") {
                            onSwitchToHTTPS()
                            dismiss()
                        }
                        .keyboardShortcut(.defaultAction)
                    }
                } else {
                    Button("OK") {
                        dismiss()
                    }
                    .keyboardShortcut(.defaultAction)
                }
            }
        }
        .padding(32)
        .frame(width: 450)
    }
}
