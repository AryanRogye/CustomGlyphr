import SwiftUI

struct CommandListSidebar: View {
    
    @Bindable var editor: ShapeEditor
    
    var body: some View {
        VStack(spacing: 0) {
            listView
            
            Divider()
            
            HStack(spacing: 8) {
                moveButton
                
                closeButton
                
                Spacer()
                
                deleteButton
            }
            .buttonStyle(.borderless)
            .labelStyle(.iconOnly)
            .padding(10)
        }
    }
    
    private var listView: some View {
        List(selection: $editor.selectedCommandID) {
            Section("Path") {
                ForEach(editor.commands) { command in
                    CommandRow(command: command)
                        .tag(command.id)
                        .contextMenu {
                            Button("Delete", role: .destructive) {
                                editor.deleteSelection(id: command.id)
                            }
                        }
                }
            }
        }
        .listStyle(.sidebar)
        .onChange(of: editor.selectedCommandID) { _, newValue in
            guard let newValue else { return }
            editor.select(newValue, .anchor)
        }
    }
    
    // MARK: - Delete Button
    private var deleteButton: some View {
        Button(role: .destructive) {
            editor.deleteSelection()
        } label: {
            Image(systemName: "trash")
        }
        .disabled(editor.selectedCommandID == nil)
    }
    
    // MARK: - Move Button
    private var moveButton: some View {
        Button {
            editor.addMove()
        } label: {
            Label("Move", systemImage: "plus")
        }
    }
    
    // MARK: - Close Button
    private var closeButton: some View {
        Button {
            editor.closePath()
        } label: {
            Label("Close", systemImage: "seal")
        }
        .disabled(!editor.canClosePath)
    }
}

private struct CommandRow: View {
    let command: PathCommand

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: command.kind.systemImage)
                .foregroundStyle(.secondary)
                .frame(width: 18)

            VStack(alignment: .leading, spacing: 2) {
                Text(command.title)
                    .lineLimit(1)
                Text(command.summary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 2)
    }
}
