import SwiftUI

enum ActionButtonRole {
    case primary
    case secondary
    case destructive
    case warning
    case success
}

struct ActionButtonStyle: ButtonStyle {
    let role: ActionButtonRole
    
    @Environment(\.isEnabled) private var isEnabled
    @State private var isHovered = false

    func makeBody(configuration: Configuration) -> some View {
        ActionButtonView(
            configuration: configuration,
            role: role,
            isEnabled: isEnabled,
            isHovered: $isHovered
        )
    }
}

private struct ActionButtonView: View {
    let configuration: ButtonStyle.Configuration
    let role: ActionButtonRole
    let isEnabled: Bool
    @Binding var isHovered: Bool
    
    var body: some View {
        configuration.label
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            .background(backgroundView)
            .foregroundStyle(foregroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(borderGradient, lineWidth: 1)
                    .blendMode(.overlay)
            )
            .shadow(color: shadowColor, radius: isHovered ? 4 : 2, y: isHovered ? 2 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : (isHovered && isEnabled ? 1.005 : 1.0))
            .animation(.interactiveSpring(response: 0.25, dampingFraction: 0.65), value: configuration.isPressed)
            .animation(.easeOut(duration: 0.15), value: isHovered)
            .onHover { isHovered = $0 && isEnabled }
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        if !isEnabled {
            Color(NSColor.controlBackgroundColor).opacity(0.5)
        } else {
            ZStack {
                Rectangle()
                    .fill(.ultraThinMaterial)
                
                tintColor
                    .opacity(configuration.isPressed ? 0.6 : (isHovered ? 0.9 : 0.75))
            }
        }
    }
    
    private var tintColor: Color {
        switch role {
        case .primary: return Color.primary
        case .secondary: return Color.primary.opacity(0.05)
        case .destructive: return .red
        case .warning: return .orange
        case .success: return .green
        }
    }
    
    private var foregroundColor: Color {
        if !isEnabled {
            return .secondary.opacity(0.5)
        }
        switch role {
        case .primary:
            return Color(NSColor.controlBackgroundColor)
        case .destructive, .warning, .success:
            return .white
        case .secondary:
            return .primary
        }
    }
    
    private var borderGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.primary.opacity(0.15),
                Color.primary.opacity(0.05),
                Color.primary.opacity(0.0),
                Color.primary.opacity(0.1)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var shadowColor: Color {
        if !isEnabled || configuration.isPressed { return .clear }
        
        let baseColor: Color
        switch role {
        case .primary: baseColor = .accentColor
        case .secondary: baseColor = .black
        case .destructive: baseColor = .red
        case .warning: baseColor = .orange
        case .success: baseColor = .green
        }
        
        return baseColor.opacity(role == .secondary ? 0.05 : 0.2)
    }
}

extension View {
    func actionButtonStyle(_ role: ActionButtonRole = .primary) -> some View {
        buttonStyle(ActionButtonStyle(role: role))
    }
}
