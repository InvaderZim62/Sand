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
import CoreMotion  // needed for accelerometers

struct SandProperties {
    let color: UIColor
    let radius: CGFloat
    let mass: CGFloat
    let friction: CGFloat
}

struct PhysicsCategory {
    static let bubble = 1 << 0
    static let sand = 1 << 2  // 1 << 1 doesn't work, for some reason (sand falls through frame)
}

struct Constants {
    static let sandProperties = [SandProperties(color: #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1), radius: 0.14, mass: 0.1, friction: 0.3),
                                 SandProperties(color: #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1), radius: 0.13, mass: 0.5, friction: 0.6),
                                 SandProperties(color: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), radius: 0.12, mass: 1.0, friction: 0.9)]
    static let sandCount = 600
    static let sandReleaseInterval = 0.08  // seconds between releasing grains of sand
    static let bubbleCount = 40
    static let bubbleRadius = 0.2
    static let bubbleColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.4)  // semi-transparent
    static let paneColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.2)  // semi-transparent
    static let paneWidth: CGFloat = 20
    static let paneHeight: CGFloat = 10
    static let paneThickness: CGFloat = 0.1
    static let paneSeparation: CGFloat = 0.6  // distance between front and rear pane centers
    static let gravity = 9.81  // m/s^2
}

class SandViewController: UIViewController {
    
    private var scnView: SCNView!
    private var scnScene: SCNScene!
    private var cameraNode: SCNNode!
    private let motionManager = CMMotionManager()  // needed for accelerometers

    private var sandNodes = [SandNode]()
    private var bubbleNodes = [BubbleNode]()
    private var buoyancyField = SCNPhysicsField()
    private var sandSpawnTime: TimeInterval = 0
    private var firstReleaseInterval = true

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupScene()
        setupCamera()
        addFrameNode()
        addBuoyancyField()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // use accelerometers to determine direction of gravity
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.1
            motionManager.startAccelerometerUpdates(to: .main) { (data, error) in
                if let nx = data?.acceleration.x, let ny = data?.acceleration.y, let nz = data?.acceleration.z {
                    self.scnScene.physicsWorld.gravity = SCNVector3(Constants.gravity * ny, -Constants.gravity * nx, Constants.gravity * nz)
                    self.buoyancyField.direction = SCNVector3(-ny, nx, -nz)
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        motionManager.stopAccelerometerUpdates()
    }
    
    // MARK: - Start of code

    // create square frame in center of screen
    // origin (center of rotation) is center of frame
    // x: right, y: up, z: out of screen
    private func addFrameNode() {
        let frameNode = FrameNode()
        frameNode.position = SCNVector3(0, 0, 0)
        scnScene.rootNode.addChildNode(frameNode)
    }
        
    private func addBuoyancyField() {
        // add custom gravity field that only affects balloon
        buoyancyField = SCNPhysicsField.linearGravity()
        buoyancyField.strength = 3  // m/s^2
        buoyancyField.direction = SCNVector3(x: 0, y: 1, z: 0)  // start with gravity up (change direction above)
        buoyancyField.categoryBitMask = PhysicsCategory.bubble  // if mask not specified, field affects everything (sand and bubbles)
        let buoyancyNode = SCNNode()
        buoyancyNode.physicsField = buoyancyField
        scnScene.rootNode.addChildNode(buoyancyNode)
    }

    private func addSandNode() {  // called from renderer, below
        let sandNode = SandNode()
        let offset = CGFloat.random(in: -0.4...0.4)
        sandNode.position = SCNVector3(offset, 0, 0)
        sandNodes.append(sandNode)
        scnScene.rootNode.addChildNode(sandNode)
    }
    
    private func addBubbleNode() {  // called from renderer, below
        let bubbleNode = BubbleNode()
        let offset = CGFloat.random(in: -Constants.paneWidth/2...Constants.paneWidth/2)
        bubbleNode.position = SCNVector3(offset, 0, 0)
        bubbleNodes.append(bubbleNode)
        scnScene.rootNode.addChildNode(bubbleNode)
    }

    private func cleanScene() {
        for node in scnScene.rootNode.childNodes {
            if node.presentation.position.z < -10 {  // delete node if falling into screen
                node.removeFromParentNode()
            }
        }
    }

    // MARK: - Setup functions
    
    private func setupView() {
        scnView = self.view as? SCNView
        scnView.allowsCameraControl = true  // disable standard camera controls with swiping
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

// MARK: - Extensions

// spawn grains of sand every sandReleaseInterval
extension SandViewController: SCNSceneRendererDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if time > sandSpawnTime {
            if sandNodes.count < Constants.sandCount {
                if !firstReleaseInterval { addSandNode() }
                firstReleaseInterval = false
                sandSpawnTime = time + TimeInterval(Constants.sandReleaseInterval)
            }
            if bubbleNodes.count < Constants.bubbleCount {
                addBubbleNode()
            }
        }
        cleanScene()
    }
}
