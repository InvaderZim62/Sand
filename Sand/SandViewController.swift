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
    static let sandCount = 300
    static let sandRadius: CGFloat = 0.1
    static let sandReleaseInterval = 0.1  // seconds between releasing grains of sand
    static let sandColor = #colorLiteral(red: 0.9994240403, green: 0.9855536819, blue: 0, alpha: 1)
    static let paneColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.2)
    static let paneSize: CGFloat = 10
    static let paneThickness: CGFloat = 0.1
    static let paneSeparation: CGFloat = 0.6  // distance between front and rear pane centers
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
        addFrameNode()
    }

    // create square frame in center of screen
    // origin (center of rotation) is center of frame
    // x: right, y: up, z: out of screen
    private func addFrameNode() {
        let frameNode = FrameNode()
        frameNode.position = SCNVector3(0, 0, 0)
        scnScene.rootNode.addChildNode(frameNode)
    }

    private func addSandNode() {  // called from renderer, below
        let sandNode = SandNode()
        let offset = CGFloat.random(in: -Constants.sandRadius...Constants.sandRadius)
        sandNode.position = SCNVector3(offset, Constants.paneSize / 2, 0)
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
        scnView.scene = scnScene
    }
    
    private func setupCamera() {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        let cameraDistance = max(9.7 * scnView.frame.height / scnView.frame.width, 15)  // pws: work on this
        cameraNode.position = SCNVector3(0, 0, cameraDistance)
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
        cleanScene()
    }
}
