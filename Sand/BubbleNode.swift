//
//  BubbleNode.swift
//  Sand
//
//  Created by Phil Stern on 3/11/22.
//

import UIKit
import SceneKit

class BubbleNode: SCNNode {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override init() {
        super.init()
        name = "Sand"
        let bubble = SCNSphere(radius: Constants.bubbleRadius)
        bubble.firstMaterial?.diffuse.contents = Constants.bubbleColor
        geometry = bubble
        physicsBody = SCNPhysicsBody.dynamic()
        physicsBody?.restitution = 0  // no bounciness
        physicsBody?.friction = 0.7
        physicsBody?.isAffectedByGravity = false  // replace with custom gravity field
        physicsBody?.categoryBitMask = PhysicsCategory.bubble
    }
}
