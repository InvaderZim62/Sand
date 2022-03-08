//
//  BeachNode.swift
//  Sand
//
//  Created by Phil Stern on 3/7/22.
//

import UIKit
import SceneKit

class BeachNode: SCNNode {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override init() {
        super.init()
        name = "Beach"
        //                    front  right  back   left          top            bottom
        let colors = [UIColor.gray, .gray, .gray, .gray, Constants.beachColor, .gray]
        let beachMaterials = colors.map { color -> SCNMaterial in
            let material = SCNMaterial()
            material.diffuse.contents = color
            return material
        }
        let beach = SCNBox(width: Constants.beachSize,
                           height: Constants.beachThickness,
                           length: Constants.beachSize,
                           chamferRadius: 0.1 * Constants.beachSize)
        beach.materials = beachMaterials
        geometry = beach
        physicsBody = SCNPhysicsBody(type: .static, shape: nil)
    }
}
