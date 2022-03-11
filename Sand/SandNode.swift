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
        let sand = SCNSphere(radius: properties.radius)
        sand.firstMaterial?.diffuse.contents = properties.color
        geometry = sand
        physicsBody = SCNPhysicsBody.dynamic()
        physicsBody?.restitution = 0  // no bounciness
        physicsBody?.friction = properties.friction
        physicsBody?.damping = 0.9  // bigger falls slower
        physicsBody?.mass = properties.mass
        physicsBody?.categoryBitMask = PhysicsCategory.sand
    }
}
