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
    static let sandCount = 20
    static let sandRadius: CGFloat = 0.2
    static let sandReleaseInterval = 0.2  // seconds between releasing grains of sand
}

class SandViewController: UIViewController {
    
    private var scnView: SCNView!
    private var scnScene: SCNScene!
    private var cameraNode: SCNNode!

    private var sandNodes = [SandNode]()
    private var sandSpawnTime: TimeInterval = 3
    private var firstReleaseInterval = true

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupScene()
        setupCamera()
    }

    private func addSandNode() {
        let sandNode = SandNode()
        sandNode.position = SCNVector3(x: 0, y: 7, z: 0)
        sandNodes.append(sandNode)
        scnScene.rootNode.addChildNode(sandNode)
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
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 30)
        scnScene.rootNode.addChildNode(cameraNode)
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
    }
}
