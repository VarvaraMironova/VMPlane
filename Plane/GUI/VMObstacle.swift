//
//  VMObstacles.swift
//  Plane
//
//  Created by Varvara Myronova on 04.04.2023.
//  Copyright © 2023 Ibram Uppal. All rights reserved.
//

import SceneKit

class VMObstacle {
    //var object : SCNNode?
    
    var objectNames = ["Purple", "Orange", "Red"]
    let moveAction = SCNAction.move(by      : SCNVector3(0.0, 0.0, 60.0),
                                    duration: 3.0)
    static let zConst = -50.0
    
    private var position : SCNVector3 = {
        var x = Double(arc4random_uniform(5)) * -2.0 + 2.0
        x = x == 0.0 ? 2.0 : x
        let y = Double(arc4random_uniform(4)) * -1 + 2.0
        
        return SCNVector3(x, y, zConst)
    }()
    
    //call always in main thread!
    public func spawn(_ name: String) -> SCNNode? {
        if let geometryNode = SCNScene(named: "art.scnassets/Geometry.dae")?.rootNode {
            let index = Int(arc4random_uniform(3))
            let objectName = objectNames[index]
            
            if let object = geometryNode.childNode(withName: objectName, recursively: true) {
                object.position = position
                object.opacity = 0.0
                object.name = name
                
                move(object: object)
                
                return object
            }
        }
        
        return nil
    }
    
    public func move(object: SCNNode) {
        let removeMoveAction = SCNAction.removeFromParentNode()
        let opacityAction = SCNAction.fadeOpacity(to: 1.0, duration: 0.5)
        let firstGroupAction = SCNAction.group([moveAction, opacityAction])
        let moveSequence = SCNAction.sequence([firstGroupAction, removeMoveAction])
        object.runAction(moveSequence)
    }
}
