import SwiftUI

struct HeaderView: View {
    let viewModel: ContentViewModel

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .bottom, spacing: 12) {
                Text("SNAG")
                    .font(.system(size: 150, weight: .black, design: .default).width(.compressed))
                    .tracking(-3.5)
                    .lineLimit(1)
                    .allowsTightening(true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .offset(x: -8)
                
                if viewModel.isDownloading {
                    HStack(spacing: 6) {
                        Text("\(viewModel.completedRepositories)/\(viewModel.totalRepositories)")
                            .font(.system(size: 11, weight: .heavy, design: .monospaced))
                            .foregroundStyle(.secondary)
                            .contentTransition(.numericText())
                        
                        ProgressView()
                            .controlSize(.mini)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.quaternary.opacity(0.8), in: Capsule())
                    .transition(.asymmetric(
                        insertion: .push(from: .trailing).combined(with: .opacity),
                        removal: .scale.combined(with: .opacity)
                    ))
                }
            }
            .padding(.horizontal, 32)
            
            Text("Download all repositories from a GitHub profile")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 30)
                .padding(.bottom, 24)
                .offset(y: -8)
        }
        .overlay(alignment: .bottom) {
            Divider().opacity(0.4)
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: viewModel.isDownloading)
    }
}
