//
//  SandNode.swift
//  Sand
//
//  Created by Phil Stern on 3/7/22.
//

import UIKit
import SceneKit

class SandNode: SCNNode {
    
    let properties: SandProperties
    
    required init?(coder: NSCoder) {
        properties = Constants.sandProperties.randomElement()!
        super.init(coder: coder)
    }

    override init() {
        properties = Constants.sandProperties.randomElement()!
        super.init()
        name = "Sand"
        let sand = SCNSphere(radius: Constants.sandRadius)
        sand.firstMaterial?.diffuse.contents = properties.color
        geometry = sand
        physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        physicsBody?.restitution = 0  // no bounciness
        physicsBody?.friction = 0.5
        physicsBody?.damping = 0.9  // bigger falls slower
        physicsBody?.mass = properties.mass
    }
}
