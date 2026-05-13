import AppKit
import SwiftUI

struct InspectorView: View {
    @Bindable var editor: ShapeEditor

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                shapeControls
                selectedCommandEditor
                exportSection
            }
            .padding(16)
        }
    }

    private var shapeControls: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Shape")
                .font(.headline)

            TextField("Shape name", text: $editor.shapeName)

            Toggle("Show grid", isOn: $editor.showGrid)
            Toggle("Snap to grid", isOn: $editor.snapToGrid)
            Toggle("Show handles", isOn: $editor.showHandles)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Grid divisions")
                    Spacer()
                    Text("\(Int(editor.gridDivisions))")
                        .foregroundStyle(.secondary)
                }
                Slider(value: $editor.gridDivisions, in: 4...32, step: 1)
            }

            HStack {
                Button {
                    editor.reset()
                } label: {
                    Label("New", systemImage: "doc")
                }
            }
        }
    }

    @ViewBuilder
    private var selectedCommandEditor: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Inspector")
                .font(.headline)

            if let selectedCommandID = editor.selectedCommandID,
               let binding = editor.commandBinding(id: selectedCommandID) {
                CommandInspector(command: binding, editor: editor)
            } else {
                Text("Select an anchor or handle on the canvas.")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var exportSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("SwiftUI Export")
                    .font(.headline)

                Spacer()

                Button {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(editor.exportCode, forType: .string)
                } label: {
                    Label("Copy", systemImage: "doc.on.doc")
                }
            }

            ScrollView([.horizontal, .vertical]) {
                Text(editor.exportCode)
                    .font(.system(.caption, design: .monospaced))
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
            }
            .frame(minHeight: 260)
            .background(.quaternary.opacity(0.45), in: RoundedRectangle(cornerRadius: 8))
        }
    }
}

private struct CommandInspector: View {
    @Binding var command: PathCommand
    @Bindable var editor: ShapeEditor

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(command.title, systemImage: command.kind.systemImage)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text(command.kind.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if command.kind != .close {
                PointFields(
                    title: "Anchor",
                    point: Binding(
                        get: { command.point },
                        set: {
                            command.point = $0.clamped()
                            editor.select(command.id, .anchor)
                        }
                    )
                )
            }

            if command.kind == .quad || command.kind == .cubic {
                PointFields(
                    title: command.kind == .quad ? "Control" : "Control 1",
                    point: Binding(
                        get: { command.control1 ?? command.point },
                        set: {
                            command.control1 = $0.clamped()
                            editor.select(command.id, .control1)
                        }
                    )
                )
            }

            if command.kind == .cubic {
                PointFields(
                    title: "Control 2",
                    point: Binding(
                        get: { command.control2 ?? command.point },
                        set: {
                            command.control2 = $0.clamped()
                            editor.select(command.id, .control2)
                        }
                    )
                )
            }
        }
    }
}

private struct PointFields: View {
    var title: String
    @Binding var point: NormalizedPoint

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 10) {
                AxisField(label: "X", value: Binding(get: { point.x }, set: { point.x = min(max($0, 0), 1) }))
                AxisField(label: "Y", value: Binding(get: { point.y }, set: { point.y = min(max($0, 0), 1) }))
            }
        }
    }
}

private struct AxisField: View {
    var label: String
    @Binding var value: Double

    var body: some View {
        HStack(spacing: 6) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 12)
            TextField(label, value: $value, format: .number.precision(.fractionLength(3)))
                .textFieldStyle(.roundedBorder)
                .frame(minWidth: 72)
            Stepper(label, value: $value, in: 0...1, step: 0.01)
                .labelsHidden()
        }
    }
}
