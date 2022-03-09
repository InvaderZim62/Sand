//
//  FrameNode.swift
//  Sand
//
//  Created by Phil Stern on 3/8/22.
//

import UIKit
import SceneKit

class FrameNode: SCNNode {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override init() {
        super.init()
        name = "Frame"
        
        let frontPane = SCNBox(width: Constants.paneSize,
                               height: Constants.paneSize,
                               length: Constants.paneThickness,
                               chamferRadius: 0)
        frontPane.firstMaterial?.diffuse.contents = Constants.paneColor
        let frontNode = SCNNode(geometry: frontPane)
        frontNode.position = SCNVector3(x: 0, y: 0, z: Float(Constants.paneSeparation / 2))
        addChildNode(frontNode)
        
        let rearPane = SCNBox(width: Constants.paneSize,
                              height: Constants.paneSize,
                              length: Constants.paneThickness,
                              chamferRadius: 0)
        rearPane.firstMaterial?.diffuse.contents = Constants.paneColor
        let rearNode = SCNNode(geometry: rearPane)
        rearNode.position = SCNVector3(x: 0, y: 0, z: -Float(Constants.paneSeparation / 2))
        addChildNode(rearNode)
        
        //----------------------------------------------------------------------
        // caps sit outside panes with top and bottom caps overlapping side caps
        //----------------------------------------------------------------------
        let topCap = SCNBox(width: Constants.paneSize + 2 * Constants.paneThickness,
                            height: Constants.paneThickness,
                            length: Constants.paneSeparation + Constants.paneThickness,
                            chamferRadius: 0)
        topCap.firstMaterial?.diffuse.contents = Constants.paneColor
        let topNode = SCNNode(geometry: topCap)
        topNode.position = SCNVector3(x: 0, y: Float(Constants.paneSize / 2 + Constants.paneThickness / 2), z: 0)
        addChildNode(topNode)

        let bottomCap = SCNBox(width: Constants.paneSize + 2 * Constants.paneThickness,
                               height: Constants.paneThickness,
                               length: Constants.paneSeparation + Constants.paneThickness,
                               chamferRadius: 0)
        bottomCap.firstMaterial?.diffuse.contents = Constants.paneColor
        let bottomNode = SCNNode(geometry: bottomCap)
        bottomNode.position = SCNVector3(x: 0, y: -Float(Constants.paneSize / 2 + Constants.paneThickness / 2), z: 0)
        addChildNode(bottomNode)

        let rightCap = SCNBox(width: Constants.paneThickness,
                              height: Constants.paneSize,
                              length: Constants.paneSeparation + Constants.paneThickness,
                              chamferRadius: 0)
        rightCap.firstMaterial?.diffuse.contents = Constants.paneColor
        let rightNode = SCNNode(geometry: rightCap)
        rightNode.position = SCNVector3(x: Float(Constants.paneSize / 2 + Constants.paneThickness / 2), y: 0, z: 0)
        addChildNode(rightNode)

        let leftCap = SCNBox(width: Constants.paneThickness,
                             height: Constants.paneSize,
                             length: Constants.paneSeparation + Constants.paneThickness,
                             chamferRadius: 0)
        leftCap.firstMaterial?.diffuse.contents = Constants.paneColor
        let leftNode = SCNNode(geometry: leftCap)
        leftNode.position = SCNVector3(x: -Float(Constants.paneSize / 2 + Constants.paneThickness / 2), y: 0, z: 0)
        addChildNode(leftNode)

        physicsBody = SCNPhysicsBody(type: .static, shape: nil)
    }
}
