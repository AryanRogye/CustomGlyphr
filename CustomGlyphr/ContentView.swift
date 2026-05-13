//
//  ContentView.swift
//  CustomGlyphr
//
//  Created by Aryan Rogye on 5/13/26.
//

import SwiftUI

struct ContentView: View {
    
    @State private var editor = ShapeEditor()

    var body: some View {
        NavigationSplitView {
            /// Sidebar
            CommandListSidebar(editor: editor)
                .navigationSplitViewColumnWidth(min: 220, ideal: 260, max: 320)
        } content: {
            /// Main Content
            ShapeCanvas(editor: editor)
                .frame(minWidth: 520, minHeight: 520)
                .toolbar {
                    CustomToolbar(editor: editor)
                }
        } detail: {
            /// Inspector
            InspectorView(editor: editor)
                .navigationSplitViewColumnWidth(min: 300, ideal: 360, max: 440)
        }
        .navigationTitle("CustomGlyphr")
    }
}

#Preview {
    ContentView()
}
