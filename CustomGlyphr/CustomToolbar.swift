//
//  CustomToolbar.swift
//  CustomGlyphr
//
//  Created by Aryan Rogye on 5/13/26.
//

import SwiftUI

struct CustomToolbar: ToolbarContent {
    
    @Bindable var editor: ShapeEditor
    
    var body: some ToolbarContent {
        ToolbarItemGroup {
            Picker("Tool", selection: $editor.activeTool) {
                ForEach(SegmentTool.allCases) { tool in
                    Label(tool.rawValue, systemImage: tool.systemImage)
                        .tag(tool)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 300)
            
            Divider()
            
            Toggle(isOn: $editor.snapToGrid) {
                Label("Snap", systemImage: "grid")
            }
            .toggleStyle(.button)
            
            Toggle(isOn: $editor.showHandles) {
                Label("Handles", systemImage: "point.3.connected.trianglepath.dotted")
            }
            .toggleStyle(.button)
        }
    }
}
