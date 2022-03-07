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
        let sand = SCNSphere(radius: Constants.sandRadius)
        sand.firstMaterial?.diffuse.contents = UIColor.yellow
        geometry = sand
        physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        physicsBody?.restitution = 0  // no bounciness
//        physicsBody?.categoryBitMask = ContactCategory.sand
//        physicsBody?.contactTestBitMask = ContactCategory.beach
    }
}
