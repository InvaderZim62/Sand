//
//  SandViewController.swift
//  Sand
//
//  Created by Phil Stern on 3/7/22.
//
//  Initial setup: File | New | Project | Game (Game Technology: SceneKit)
//  Delete art.scnassets (move to Trash)
//

import UIKit
import QuartzCore
import SceneKit

struct Constants {
    static let sandCount = 30
    static let sandRadius: CGFloat = 0.1
    static let sandReleaseInterval = 0.2  // seconds between releasing grains of sand
    static let beachSize: CGFloat = 10.0
    static let beachThickness: CGFloat = 0.2
    static let beachColor = #colorLiteral(red: 0.6679978967, green: 0.4751212597, blue: 0.2586010993, alpha: 1)
    static let sandColor = #colorLiteral(red: 0.9994240403, green: 0.9855536819, blue: 0, alpha: 1)
}

class SandViewController: UIViewController {
    
    private var scnView: SCNView!
    private var scnScene: SCNScene!
    private var cameraNode: SCNNode!

    private var sandNodes = [SandNode]()
    private var sandSpawnTime: TimeInterval = 0
    private var firstReleaseInterval = true

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupScene()
        setupCamera()
        addBeachNode()
    }

    // create square beach in center of screen (edgewise view)
    // origin (center of rotation) is center of beach
    // x: to right side of beach, y: out of beach, z: to bottom of beach
    private func addBeachNode() {
        let beachNode = BeachNode()
        beachNode.position = SCNVector3(0, 0, 0)
        scnScene.rootNode.addChildNode(beachNode)
    }

    private func addSandNode() {  // called in renderer, below
        let sandNode = SandNode()
        sandNode.position = SCNVector3(x: 0, y: 7, z: 0)
        sandNodes.append(sandNode)
        scnScene.rootNode.addChildNode(sandNode)
    }
    
    private func cleanScene() {
        for node in scnScene.rootNode.childNodes {
            if node.presentation.position.y < -10 {  // delete node if below screen
                node.removeFromParentNode()
            }
        }
    }

    // MARK: - Setup
    
    private func setupView() {
        scnView = self.view as? SCNView
        scnView.allowsCameraControl = true  // use standard camera controls with swiping
        scnView.showsStatistics = true
        scnView.autoenablesDefaultLighting = true
        scnView.isPlaying = true  // prevent SceneKit from entering a "paused" state, if there isn't anything to animate
        scnView.delegate = self  // needed for renderer, below
    }
    
    private func setupScene() {
        scnScene = SCNScene()
        scnScene.background.contents = "Background_Diffuse.png"
//        scnScene.physicsWorld.contactDelegate = self  // requires SCNPhysicsContactDelegate (extension, below)
        scnView.scene = scnScene
    }
    
    private func setupCamera() {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        rotateCameraAroundBeachCenter(deltaAngle: -.pi/4)  // move up 45 deg (looking into beach)
        scnScene.rootNode.addChildNode(cameraNode)
    }

    // rotate camera around beach x-axis, while continuing to point at beach center
    private func rotateCameraAroundBeachCenter(deltaAngle: CGFloat) {
        cameraNode.transform = SCNMatrix4Rotate(cameraNode.transform, Float(deltaAngle), 1, 0, 0)
        let cameraAngle = CGFloat(cameraNode.eulerAngles.x)
        let cameraDistance = max(9.7 * scnView.frame.height / scnView.frame.width, 15)
        cameraNode.position = SCNVector3(0, -cameraDistance * sin(cameraAngle), cameraDistance * cos(cameraAngle))
    }
}

// spawn grains of sand
extension SandViewController: SCNSceneRendererDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if time > sandSpawnTime && sandNodes.count < Constants.sandCount {
            if !firstReleaseInterval { addSandNode() }
            firstReleaseInterval = false
            sandSpawnTime = time + TimeInterval(Constants.sandReleaseInterval)
        }
        cleanScene()
    }
}
