//
//  HandleMarker.swift
//  CustomGlyphr
//
//  Created by Aryan Rogye on 5/13/26.
//

import SwiftUI


struct HandleMarker: View {
    var isControl: Bool
    var isSelected: Bool

    var body: some View {
        Circle()
            .fill(isControl ? Color.orange : Color.accentColor)
            .overlay {
                Circle()
                    .stroke(.background, lineWidth: 2)
            }
            .shadow(radius: isSelected ? 4 : 0)
            .frame(width: isSelected ? 13 : 9, height: isSelected ? 13 : 9)
    }
}
