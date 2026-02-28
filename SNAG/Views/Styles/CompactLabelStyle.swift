//
//  CompactLabelStyle.swift
//  SNAG
//
//  Created by Leonardo Nápoles on 2/27/26.
//

import SwiftUI

struct CompactLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 3) {
            configuration.icon
            configuration.title
        }
    }
}
