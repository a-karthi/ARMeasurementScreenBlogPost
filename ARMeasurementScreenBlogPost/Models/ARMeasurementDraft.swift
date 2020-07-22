//
//  MeasurementDraft.swift
//  ARMeasurementScreenBlogPost
//
//  Created by Eray Diler on 8.06.2020.
//  Copyright © 2020 Hippo Foundry. All rights reserved.
//

import SceneKit

class ARMeasurementDraft {
    
    // MARK: - Properties

    var startDotNode: DotNode?
    var endDotNode: DotNode?
    var lines = [Line()]
    
    private(set) var measurement = ARMeasurement()

    // MARK: - Computed properties
    
    private var allNodes: [SCNNode] {
        var nodes = [SCNNode]()
        
        if let startDotNode = startDotNode {
            nodes.append(startDotNode)
        }
        
        if !lines.isEmpty {
            for aLine in lines {
                nodes.append(contentsOf: aLine.nodes)
            }
        }
        
        if let endDotNode = endDotNode {
            nodes.append(endDotNode)
        }
        
        return nodes
    }
}

// MARK: - Public

extension ARMeasurementDraft {
//    var info: String {
//        return measurement.info(forLength: distances.first)
//    }

    func reset() {
        allNodes.forEach { $0.removeFromParentNode() }
        startDotNode = nil
        endDotNode = nil
        lines = [Line(), Line()]
        measurement.currentStep = .first
    }

    func goNextStep(fromStarting dotNode: DotNode) {
        switch measurement.currentStep {
        case .first:
            startDotNode = dotNode
        case .second:
            endDotNode = dotNode
        case .last:
            break
        }

        measurement.goNextStep()
    }

    func goPreviousStep() {
        switch measurement.currentStep {
        case .first:
            break
        case .second:
            startDotNode?.removeFromParentNode()
            startDotNode = nil
            if !lines.isEmpty {
                lines[0].removeFromParentNode()
                lines[0] = Line()
            }
        case .last:
            endDotNode?.removeFromParentNode()
            endDotNode = nil
            if !lines.isEmpty {
                lines[0].removeFromParentNode()
                lines[0] = Line()
            }
        }

        measurement.goPreviousStep()
    }
    
    func setDistance(_ distance: Double?) {
        guard let distance = distance else { return }
        
        var measurement = Measurement(value: distance, unit: UnitLength.centimeters)
        
        if !Locale.current.usesMetricSystem {
            measurement = measurement.converted(to: UnitLength.inches)
        }
        
        let distanceText = ARMeasurementFormatter().string(from: measurement)
        
        switch self.measurement.currentStep {
        case .first:
            break
        case .second:
            lines[0].textString = distanceText
        case .last:
            break
        }
    }
}