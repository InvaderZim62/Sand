//
//  SandNode.swift
//  Sand
//
//  Created by Phil Stern on 3/7/22.
//

import UIKit
import SceneKit

class SandNode: SCNNode {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override init() {
        super.init()
        name = "Sand"
        let sand = SCNSphere(radius: Constants.sandRadius)
        sand.firstMaterial?.diffuse.contents = Constants.sandColor
        geometry = sand
        physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        physicsBody?.restitution = 0  // no bounciness
        physicsBody?.friction = 1
        physicsBody?.damping = 0.9
    }
}
