//
//  VMPlaneView.swift
//  Plane
//
//  Created by Varvara Myronova on 06.03.2023.
//  Copyright © 2023 Ibram Uppal. All rights reserved.
//

import SceneKit

class VMSceneRendererDelegate: NSObject, SCNSceneRendererDelegate {
    var timeLast        : Double?
    var locationRotation: Double = 0.0
    
    let speedConstant = 1.5
    
    
    func renderer(_ renderer        : SCNSceneRenderer,
                  updateAtTime time : TimeInterval)
    {
        var delta: Double
        if let timeLast = timeLast {
            delta = time - timeLast
        } else {
            delta = 0
        }
        
        timeLast = time
        locationRotation += speedConstant * delta
        let y = sin(locationRotation) / 4.0
        let planeRotation = cos(locationRotation) / 4.0
        
        if let renderer = renderer as? VMPlaneView {
            renderer.updatePlanePosition(SCNVector3(0.0, y, 0.0))
            renderer.updatePlaneRotation(SCNVector4(1.0, 0.0, 0.0, planeRotation))
        }
        
        if locationRotation > .pi * 2 {
            locationRotation -= .pi * 2
        }
    }
}

class VMPlaneView: SCNView {
    
    let planeNode     = SCNNode()
    let obstaclesNode = SCNNode()
    
    let waitDuration              = 0.6
    let propellerRotationDuration = 0.2
    let obstacleName              = "Obstacle"

    override func awakeFromNib() {
        super.awakeFromNib()
        
        scene = SCNScene()
        backgroundColor = UIColor(red   : 0x8b/255.0,
                                  green : 0xf0/255.0,
                                  blue  : 0xff/255.0,
                                  alpha : 1)
        isPlaying = true
        
        setupScene()
    }
    
    //MARK: - Helpers
    private func setupScene() {
        setupCamera()
        setupLights()
        setupClouds()
        setupPlane()
        setupObstacles()
    }
    
    private func setupCamera() {
        let cameraNode = SCNNode()
        let camera = SCNCamera()
        camera.usesOrthographicProjection = false
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 0)
        cameraNode.pivot = SCNMatrix4MakeTranslation(0, 0, -5)
        cameraNode.camera = camera
        
        if let rootNode = scene?.rootNode {
            rootNode.addChildNode(cameraNode)
        }
    }
    
    private func setupLights() {
        let lightNodeSpot = SCNNode()
        let light = SCNLight()
        light.type = .spot
        lightNodeSpot.position = SCNVector3(x: 30, y: 30, z: 30)
        lightNodeSpot.light = light
        
        let empty = SCNNode()
        empty.position = SCNVector3Zero
        lightNodeSpot.constraints = [SCNLookAtConstraint(target: empty)]
        
        if let rootNode = scene?.rootNode {
            rootNode.addChildNode(empty)
            rootNode.addChildNode(lightNodeSpot)
        }
    }
    
    private func setupClouds() {
        if let clouds = SCNParticleSystem(named        : "Clouds.scnp",
                                          inDirectory  : "")
        {
            let cloudsEmitter = SCNNode()
            cloudsEmitter.position = SCNVector3(x: 0, y: -4, z: -3)
            cloudsEmitter.addParticleSystem(clouds)
            
            if let rootNode = scene?.rootNode {
                rootNode.addChildNode(cloudsEmitter)
            }
        }
    }
    
    private func setupPlane() {
        if let planeScene = SCNScene(named: "art.scnassets/SimplePlane.dae") {
            if let plane = planeScene.rootNode.childNode(withName: "Plane", recursively: true) {
                planeNode.addChildNode(plane)
            }
            
            if let propeller = planeScene.rootNode.childNode(withName: "Propeller", recursively: true) {
                planeNode.addChildNode(propeller)
                let propellerRotation = SCNAction.rotate(by         : .pi * 2.0,
                                                         around     : SCNVector3(0.0, 0.0, 1.0),
                                                         duration   : propellerRotationDuration)
                let repeatedRotation = SCNAction.repeatForever(propellerRotation)
                propeller.runAction(repeatedRotation)
            }
            
            scene?.rootNode.addChildNode(planeNode)
        }
    }
    
    private func setupObstacles() {
        let obstacleSpawnAction = SCNAction.run { node in
            DispatchQueue.main.async {[unowned self] in
                if let obstacle = VMObstacle().spawn(self.obstacleName) {
                    self.obstaclesNode.addChildNode(obstacle)
                }
            }
        }
        
        let waitAction = SCNAction.wait(duration: waitDuration)
        let actionSequence = SCNAction.sequence([obstacleSpawnAction, waitAction])
        let repeatSequence = SCNAction.repeatForever(actionSequence)
        obstaclesNode.runAction(repeatSequence)
        
        scene?.rootNode.addChildNode(obstaclesNode)
    }
    
    //MARK: - Public
    public func updatePlanePosition(_ position: SCNVector3) {
        planeNode.position = position
    }
    
    public func updatePlaneRotation(_ rotation: SCNVector4) {
        planeNode.rotation = rotation
    }
    
    public func removeObstacle(_ atLocation: CGPoint) {
        let hitResults = hitTest(atLocation, options: nil)
        
        if let node = hitResults.first?.node {
            if node.name == obstacleName {
                let scale = SCNAction.scale(by: 2.0, duration: 0.5)
                scale.timingMode = .easeInEaseOut
                let reverseScale = scale.reversed()
                let scaleSequence = SCNAction.sequence([reverseScale, scale])
                node.runAction(scaleSequence)
            }
        }
    }

}
