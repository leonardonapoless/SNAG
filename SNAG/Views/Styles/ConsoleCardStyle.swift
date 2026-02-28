//
//  ConsoleCardStyle.swift
//  SNAG
//
//  Created by Leonardo Nápoles on 2/27/26.
//

import SwiftUI

struct ConsoleCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(NSColor.controlBackgroundColor))
                    .shadow(color: .black.opacity(0.04), radius: 8, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Color(NSColor.separatorColor).opacity(0.5), lineWidth: 1)
            )
    }
}
