//
//  GameViewController.swift
//  flappy_bird_clone_swift iOS
//
//  Created by Kevin Lu on 4/14/25.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Convert this view to an SKView so we can present SpriteKit scenes
        if let skView = self.view as? SKView {
            
            // Create an instance of MyScene (from MyScene.swift)
            let scene = GameScene(size: skView.bounds.size)
            
            // Configure how the scene is scaled
            scene.scaleMode = .aspectFill
            
            // Show some debug info (optional)
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            // Present the scene
            skView.presentScene(scene)
        }
    }
    
    // For iPhone/iPad orientation support (optional depending on your game)
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        // You can adjust for phone vs. tablet here if desired
        return .allButUpsideDown
    }
    
    // Usually games hide the status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
