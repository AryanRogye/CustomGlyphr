//
//  ShapeCanvas.swift
//  CustomGlyphr
//
//  Created by Aryan Rogye on 5/13/26.
//

import SwiftUI

struct ShapeCanvas: View {
    
    @Bindable var editor: ShapeEditor
    @State private var activeDrag: PointSelection?

    var body: some View {
        GeometryReader { proxy in
            let drawingRect = GeometryMapper.drawingRect(in: proxy.size)
            
            ZStack {
                Canvas { context, size in
                    drawGrid(context: context, rect: drawingRect)
                    drawBounds(context: context, rect: drawingRect)
                    drawShape(context: context, rect: drawingRect)
                    
                    if editor.showHandles {
                        drawHandles(context: context, rect: drawingRect)
                    }
                }
                
                ForEach(handleMarkers(in: drawingRect), id: \.selection) { marker in
                    HandleMarker(
                        isControl: marker.selection.pointKind != .anchor,
                        isSelected: marker.selection == editor.selectedPoint
                    )
                    .position(marker.point)
                    .help(marker.selection.pointKind.label)
                }
            }
            .background(.background)
            .contentShape(Rectangle())
            .gesture(canvasGesture(in: drawingRect))
            .overlay(alignment: .bottom) {
                CanvasStatusBar(editor: editor)
                    .padding(.horizontal, 14)
                    .padding(.bottom, 12)
            }
        }
    }
    
    
    private struct HandleMarkerModel: Hashable {
        var selection: PointSelection
        var point: CGPoint
    }
}

// MARK: - Gesture
extension ShapeCanvas {
    private func canvasGesture(in rect: CGRect) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                if activeDrag == nil, let hit = editor.hitTest(point: value.startLocation, in: rect) {
                    activeDrag = hit
                    editor.select(hit.commandID, hit.pointKind)
                }
                
                guard let activeDrag else { return }
                let normalized = GeometryMapper.normalizedPoint(from: value.location, in: rect)
                editor.updatePoint(selection: activeDrag, point: normalized)
            }
            .onEnded { value in
                defer { activeDrag = nil }
                
                if let activeDrag {
                    let normalized = GeometryMapper.normalizedPoint(from: value.location, in: rect)
                    editor.updatePoint(selection: activeDrag, point: normalized)
                    return
                }
                
                guard rect.contains(value.location) else { return }
                
                if editor.activeTool == .select {
                    if let hit = editor.hitTest(point: value.location, in: rect) {
                        editor.select(hit.commandID, hit.pointKind)
                    }
                } else {
                    let normalized = GeometryMapper.normalizedPoint(from: value.location, in: rect)
                    editor.addSegment(to: normalized)
                }
            }
    }

}

// MARK: - Handles
extension ShapeCanvas {
    private func handleMarkers(in rect: CGRect) -> [HandleMarkerModel] {
        var markers: [HandleMarkerModel] = []
        
        for command in editor.commands {
            markers.append(
                HandleMarkerModel(
                    selection: PointSelection(commandID: command.id, pointKind: .anchor),
                    point: GeometryMapper.canvasPoint(from: command.point, in: rect)
                )
            )
            
            if let control1 = command.control1 {
                markers.append(
                    HandleMarkerModel(
                        selection: PointSelection(commandID: command.id, pointKind: .control1),
                        point: GeometryMapper.canvasPoint(from: control1, in: rect)
                    )
                )
            }
            
            if let control2 = command.control2 {
                markers.append(
                    HandleMarkerModel(
                        selection: PointSelection(commandID: command.id, pointKind: .control2),
                        point: GeometryMapper.canvasPoint(from: control2, in: rect)
                    )
                )
            }
        }
        
        return markers
    }
}

// MARK: - Canvas Helpers
extension ShapeCanvas {
    private func drawGrid(context: GraphicsContext, rect: CGRect) {
        guard editor.showGrid else { return }
        
        let divisions = max(Int(editor.gridDivisions), 2)
        var path = Path()
        
        for index in 0...divisions {
            let progress = CGFloat(index) / CGFloat(divisions)
            let x = rect.minX + rect.width * progress
            let y = rect.minY + rect.height * progress
            
            path.move(to: CGPoint(x: x, y: rect.minY))
            path.addLine(to: CGPoint(x: x, y: rect.maxY))
            path.move(to: CGPoint(x: rect.minX, y: y))
            path.addLine(to: CGPoint(x: rect.maxX, y: y))
        }
        
        context.stroke(path, with: .color(.secondary.opacity(0.16)), lineWidth: 1)
    }
    
    private func drawBounds(context: GraphicsContext, rect: CGRect) {
        let path = Path(roundedRect: rect, cornerRadius: 8)
        context.stroke(path, with: .color(.secondary.opacity(0.35)), lineWidth: 1.2)
    }
    
    private func drawShape(context: GraphicsContext, rect: CGRect) {
        let path = makePath(in: rect)
        context.fill(path, with: .color(.accentColor.opacity(0.16)))
        context.stroke(path, with: .color(.accentColor), style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
    }
    
    private func drawHandles(context: GraphicsContext, rect: CGRect) {
        var handlePath = Path()
        var previousAnchor: CGPoint?
        
        for command in editor.commands {
            let anchor = GeometryMapper.canvasPoint(from: command.point, in: rect)
            
            if let control1 = command.control1 {
                let controlPoint = GeometryMapper.canvasPoint(from: control1, in: rect)
                handlePath.move(to: previousAnchor ?? anchor)
                handlePath.addLine(to: controlPoint)
                handlePath.move(to: controlPoint)
                handlePath.addLine(to: anchor)
            }
            
            if let control2 = command.control2 {
                let controlPoint = GeometryMapper.canvasPoint(from: control2, in: rect)
                handlePath.move(to: anchor)
                handlePath.addLine(to: controlPoint)
            }
            
            if command.kind != .close {
                previousAnchor = anchor
            }
        }
        
        context.stroke(handlePath, with: .color(.secondary.opacity(0.42)), style: StrokeStyle(lineWidth: 1.2, dash: [5, 4]))
    }

    
    /// Main Function that makes paths based on the commands
    private func makePath(in rect: CGRect) -> Path {
        Path { path in
            for command in editor.commands {
                let point = GeometryMapper.canvasPoint(from: command.point, in: rect)
                
                switch command.kind {
                case .move:
                    path.move(to: point)
                case .line:
                    path.addLine(to: point)
                case .quad:
                    let control = GeometryMapper.canvasPoint(from: command.control1 ?? command.point, in: rect)
                    path.addQuadCurve(to: point, control: control)
                case .cubic:
                    let control1 = GeometryMapper.canvasPoint(from: command.control1 ?? command.point, in: rect)
                    let control2 = GeometryMapper.canvasPoint(from: command.control2 ?? command.point, in: rect)
                    path.addCurve(to: point, control1: control1, control2: control2)
                case .close:
                    path.closeSubpath()
                }
            }
        }
    }

}
