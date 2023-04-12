//
//  GameViewController.swift
//  Plane
//
//  Created by Ibram Uppal on 11/7/15.
//  Copyright (c) 2015 Ibram Uppal. All rights reserved.
//

import SceneKit

class GameViewController: UIViewController {
    let sceneRendererDelegate = VMSceneRendererDelegate()
    
    weak private var sceneView : VMPlaneView? {
        return viewIfLoaded as? VMPlaneView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = view as? VMPlaneView {
            view.delegate = sceneRendererDelegate
        }
        
    }

    @IBAction func onTapGestureRecognizer(_ sender: UITapGestureRecognizer) {
        sceneView?.removeObstacle(sender.location(in: view))
    }
}
