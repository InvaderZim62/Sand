//
//  SandViewController.swift
//  Sand
//
//  Created by Phil Stern on 3/7/22.
//
//  Initial setup: File | New | Project | Game (Game Technology: SceneKit)
//  Delete art.scnassets (move to Trash)
//
//  Device orientations:
//    In addition to the Device Orientations properties under Targets | General, there may be
//    left-over/redundant settings in: Targets | Build Settings | Info.plist Values.  I had to
//    delete the settings labeled: "Supported Interface Orientations (iPhone)", so that the
//    iPhone would use the settings labeled: "Supported Interface Orientations"
//

import UIKit
import QuartzCore
import SceneKit

struct SandProperties {
    let color: UIColor
    let radius: CGFloat
    let mass: CGFloat
    let friction: CGFloat
}

struct Constants {
    static let sandProperties = [SandProperties(color: #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1), radius: 0.14, mass: 0.1, friction: 0.3),
                                 SandProperties(color: #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1), radius: 0.13, mass: 0.5, friction: 0.6),
                                 SandProperties(color: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), radius: 0.12, mass: 1.0, friction: 0.9)]
    static let sandCount = 400
    static let sandReleaseInterval = 0.08  // seconds between releasing grains of sand
    static let paneColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.2)
    static let paneWidth: CGFloat = 20
    static let paneHeight: CGFloat = 10
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
        let offset = CGFloat.random(in: -0.5...0.5)
        let largestRadius = Constants.sandProperties[0].radius
        sandNode.position = SCNVector3(offset, Constants.paneHeight / 2 - 2 * largestRadius, 0)
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
