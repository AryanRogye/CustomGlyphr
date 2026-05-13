//
//  ShapeEditor.swift
//  CustomGlyphr
//
//  Created by Aryan Rogye on 5/13/26.
//

import SwiftUI

@Observable
@MainActor
final class ShapeEditor {
    var commands: [PathCommand] = []
    var selectedCommandID: PathCommand.ID?
    var selectedPoint: PointSelection?
    
    var activeTool: SegmentTool = .select
    
    /// Controls if we can see the grid or not
    var showGrid = true
    
    var gridDivisions = 16.0
    
    var showHandles = true
    
    var snapToGrid = true
    
    var shapeName = "CustomShape"
    
    var exportCode: String {
        SwiftUIShapeExporter.export(shapeName: shapeName, commands: commands)
    }
    
    /// if we can close a path or not
    var canClosePath: Bool {
        commands.contains { $0.kind == .move } && commands.last?.kind != .close
    }
    private var currentPoint: NormalizedPoint? {
        commands.last(where: { $0.kind != .close })?.point
    }
    
    func commandBinding(id: PathCommand.ID) -> Binding<PathCommand>? {
        guard let index = commands.firstIndex(where: { $0.id == id }) else { return nil }
        return Binding(
            get: { self.commands[index] },
            set: { self.commands[index] = $0 }
        )
    }

}

// MARK: - Gesture
extension ShapeEditor {
    func hitTest(point: CGPoint, in rect: CGRect, tolerance: CGFloat = 11) -> PointSelection? {
        var candidates: [(PointSelection, CGFloat)] = []
        
        for command in commands {
            let anchor = GeometryMapper.canvasPoint(from: command.point, in: rect)
            candidates.append((PointSelection(commandID: command.id, pointKind: .anchor), anchor.distance(to: point)))
            
            if let control1 = command.control1 {
                let p = GeometryMapper.canvasPoint(from: control1, in: rect)
                candidates.append((PointSelection(commandID: command.id, pointKind: .control1), p.distance(to: point)))
            }
            
            if let control2 = command.control2 {
                let p = GeometryMapper.canvasPoint(from: control2, in: rect)
                candidates.append((PointSelection(commandID: command.id, pointKind: .control2), p.distance(to: point)))
            }
        }
        
        return candidates
            .filter { $0.1 <= tolerance }
            .sorted { $0.1 < $1.1 }
            .first?
            .0
    }
    
    func addSegment(to rawPoint: NormalizedPoint) {
        let point = snapped(rawPoint).clamped()
        
        if commands.isEmpty || commands.last?.kind == .close {
            let command = PathCommand(kind: .move, point: point)
            commands.append(command)
            select(command.id, .anchor)
            return
        }
        
        let previous = currentPoint ?? point
        let command: PathCommand
        switch activeTool {
        case .select:
            return
        case .line:
            command = PathCommand(kind: .line, point: point)
        case .quad:
            let control = NormalizedPoint(
                x: (previous.x + point.x) / 2,
                y: min(previous.y, point.y) - 0.16
            ).clamped()
            command = PathCommand(kind: .quad, point: point, control1: snapped(control).clamped())
        case .cubic:
            let dx = point.x - previous.x
            let commandControl1 = NormalizedPoint(x: previous.x + dx * 0.35, y: previous.y - 0.16).clamped()
            let commandControl2 = NormalizedPoint(x: previous.x + dx * 0.65, y: point.y + 0.16).clamped()
            command = PathCommand(
                kind: .cubic,
                point: point,
                control1: snapped(commandControl1).clamped(),
                control2: snapped(commandControl2).clamped()
            )
        }
        
        commands.append(command)
        select(command.id, .anchor)
    }
    
    func updatePoint(selection: PointSelection, point rawPoint: NormalizedPoint) {
        guard let index = commands.firstIndex(where: { $0.id == selection.commandID }) else { return }
        let point = snapped(rawPoint).clamped()
        
        switch selection.pointKind {
        case .anchor:
            commands[index].point = point
        case .control1:
            commands[index].control1 = point
        case .control2:
            commands[index].control2 = point
        }
    }
}

// MARK: - Addition
extension ShapeEditor {
    
    /// Function Adds a Move
    func addMove() {
        let command = PathCommand(
            kind: .move,
            point: NormalizedPoint(
                x: 0.2, y: 0.8
            )
        )
        commands.append(command)
        select(command.id, .anchor)
    }
    
    /// Function Closes the path if we can
    func closePath() {
        guard canClosePath, let first = commands.first(where: { $0.kind == .move }) else { return }
        let command = PathCommand(kind: .close, point: first.point)
        commands.append(command)
        select(command.id, .anchor)
    }
}

// MARK: - Selection
extension ShapeEditor {
    /// This is used for the sidebar
    /// when we select something
    func select(
        _ commandID: PathCommand.ID,
        _ pointKind: EditablePointKind = .anchor
    ) {
        selectedCommandID = commandID
        selectedPoint = PointSelection(commandID: commandID, pointKind: pointKind)
    }
}

// MARK: - Deletion
extension ShapeEditor {
    func reset() {
        commands = [
            PathCommand(kind: .move, point: NormalizedPoint(x: 0.2, y: 0.78))
        ]
        selectedCommandID = commands.first?.id
        selectedPoint = commands.first.map { PointSelection(commandID: $0.id, pointKind: .anchor) }
    }

    func deleteSelection(id: PathCommand.ID) {
        commands.removeAll { $0.id == id }
        /// Set last
        self.selectedCommandID = commands.last?.id
        selectedPoint = self.selectedCommandID.map {
            PointSelection(commandID: $0, pointKind: .anchor)
        }
    }
    
    func deleteSelection() {
        guard let selectedCommandID else { return }
        commands.removeAll { $0.id == selectedCommandID }
        /// Set Last
        self.selectedCommandID = commands.last?.id
        /// set the selectedPoint to be the new selectedID
        selectedPoint = self.selectedCommandID.map {
            PointSelection(commandID: $0, pointKind: .anchor)
        }
    }
}

// MARK: - Helpers
extension ShapeEditor {
    func point(for selection: PointSelection) -> NormalizedPoint? {
        guard let command = commands.first(where: { $0.id == selection.commandID }) else { return nil }
        switch selection.pointKind {
        case .anchor: return command.point
        case .control1: return command.control1
        case .control2: return command.control2
        }
    }
    private func snapped(_ point: NormalizedPoint) -> NormalizedPoint {
        guard snapToGrid else { return point }
        let divisions = max(gridDivisions, 2)
        return NormalizedPoint(
            x: (point.x * divisions).rounded() / divisions,
            y: (point.y * divisions).rounded() / divisions
        )
    }
}
