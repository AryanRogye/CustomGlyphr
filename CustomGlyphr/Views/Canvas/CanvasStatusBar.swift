//
//  CanvasStatusBar.swift
//  CustomGlyphr
//
//  Created by Aryan Rogye on 5/13/26.
//

import SwiftUI

struct CanvasStatusBar: View {
    @Bindable var editor: ShapeEditor

    var body: some View {
        HStack(spacing: 14) {
            StatusItem(
                systemImage: editor.activeTool.systemImage,
                text: editor.activeTool.rawValue
            )
            StatusItem(
                systemImage: "point.3.connected.trianglepath.dotted",
                text: "\(editor.commands.count) commands"
            )
            StatusItem(
                systemImage: "grid", 
                text: "\(Int(editor.gridDivisions)) divisions"
            )

            Spacer(minLength: 12)

            Text(selectionText)
                .lineLimit(1)
                .foregroundStyle(.secondary)
        }
        .font(.caption)
        .padding(.horizontal, 12)
        .frame(height: 30)
        .frame(maxWidth: 560)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(.secondary.opacity(0.18), lineWidth: 1)
        }
    }

    private var selectionText: String {
        guard let selectedPoint = editor.selectedPoint,
              let point = editor.point(for: selectedPoint) else {
            return "No selection"
        }

        return "\(selectedPoint.pointKind.label)  x \(point.formattedX)  y \(point.formattedY)"
    }
}


private struct StatusItem: View {
    var systemImage: String
    var text: String
    
    var body: some View {
        Label(text, systemImage: systemImage)
            .foregroundStyle(.secondary)
    }
}
