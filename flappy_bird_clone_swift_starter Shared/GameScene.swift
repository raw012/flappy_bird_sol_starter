import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    // MARK: - Properties
    private var bird: SKSpriteNode!
    private let skyColor = SKColor(red: 113.0 / 255.0, green: 197.0 / 255.0, blue: 207.0 / 255.0, alpha: 1.0)
    static let kVerticalPipeGap = 150
    
    private var pipeTexture1: SKTexture!
    private var pipeTexture2: SKTexture!
    private var moveAndRemovePipes: SKAction!
    private var pipes = SKNode()
    private var moving = SKNode()
    private var canRestart = false
    private var score: NSInteger = 0
    private var scoreLabelNode: SKLabelNode!
    
    // Physics collision categories
    private let birdCategory: UInt32  = 1 << 0
    private let worldCategory: UInt32 = 1 << 1
    private let pipeCategory: UInt32  = 1 << 2
    private let scoreCategory: UInt32 = 1 << 3

    // MARK: - Initializer
    override init(size: CGSize) {
        super.init(size: size)
        
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -5.0)
        physicsWorld.contactDelegate = self
        
        // Initialize game elements
        setupBird()
        setupScoreLabel()
        
        addChild(moving)
        
        setupGround()
        setupSkyline()
        setupDummyNode()
        
        setupPipes()
        startSpawningPipes()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Setup Methods
    /*
     ACTIVITY 1: Setup basic scene properties
     We are going to use 2 bird sprites: name them birdTexture1 and birdTexture2
     They're of type SKTexture, and when initializing, use the imageNamed property equal to
     Bird1 and Bird2, respectively.
     */
    private func setupBird() {
        // Load bird textures here:
        // let birdTexture1 =
        // let birdTexture2 =
        birdTexture1.filteringMode = .nearest
        birdTexture2.filteringMode = .nearest
        
        // Create a flap animation using both textures
        let flap = SKAction.repeatForever(SKAction.animate(with: [birdTexture1, birdTexture2], timePerFrame: 0.2))
        
        bird = SKSpriteNode(texture: birdTexture1)
        bird.setScale(3.0)
        bird.position = CGPoint(x: self.frame.size.width / 4, y: self.frame.midY)
        bird.run(flap)
        
        
        /*
         ACTIVITY 2: Setup bird physics.
         Our bird has a built in property called physicsBody.
         Initialize it to a SKPhysicsBody, with a property circleOfRadius: bird.size.height / 2.
         This way, our physics body covers our whole bird sprite and nothing more.
         We've set the gravity for you already. Does your bird do anything different?
         */
        
        addChild(bird)
    }
    
    private func setupScoreLabel() {
        // Create and position the score label at the top of the screen
        scoreLabelNode = SKLabelNode(fontNamed: "MarkerFelt-Wide")
        scoreLabelNode.position = CGPoint(x: frame.midX, y: 3 * frame.size.height / 4)
        scoreLabelNode.zPosition = 100  // Ensures label is in front
        scoreLabelNode.text = "\(score)"
        addChild(scoreLabelNode)
    }
    
    private func setupGround() {
        // Load ground texture
        let groundTexture = SKTexture(imageNamed: "Ground")
        groundTexture.filteringMode = .nearest
        
        // Create actions to move the ground left and reset its position
        let moveGroundSprite = SKAction.moveBy(x: -groundTexture.size().width * 2,
                                               y: 0,
                                               duration: 0.02 * Double(groundTexture.size().width * 2))
        let resetGroundSprite = SKAction.moveBy(x: groundTexture.size().width * 2,
                                                y: 0,
                                                duration: 0)
        let moveGroundSpritesForever = SKAction.repeatForever(SKAction.sequence([moveGroundSprite, resetGroundSprite]))
        
        // Determine the number of sprites needed to fill the screen and add them to the moving container
        let groundSpriteCount = Int(2 + self.frame.size.width / (groundTexture.size().width * 2))
        for i in 0..<groundSpriteCount {
            let sprite = SKSpriteNode(texture: groundTexture)
            sprite.setScale(2.0)
            sprite.position = CGPoint(x: CGFloat(i) * sprite.size.width,
                                      y: sprite.size.height / 2)
            sprite.run(moveGroundSpritesForever)
            moving.addChild(sprite)
        }
    }
    
    
    /*
     ACTIVITY 1: Setup basic scene properties
     The scene has a built in property called "backgroundColor", which you can access through self.
     Set it up here, and set it equal to skyColor.
     Then, load in the skyline texture for our background image. It'll be of type SKTexture,
     with property of imageNamed: "Skyline"
     Finally, uncomment the rest of the function.
     */
    private func setupSkyline() {
        // Load the skyline texture and create its scrolling action
        
        
//        skylineTexture.filteringMode = .nearest
//        
//        let moveSkylineSprite = SKAction.moveBy(x: -skylineTexture.size().width * 2,
//                                                y: 0,
//                                                duration: 0.1 * skylineTexture.size().width * 2)
//        let resetSkylineSprite = SKAction.moveBy(x: skylineTexture.size().width * 2,
//                                                 y: 0,
//                                                 duration: 0)
//        let moveSkylineSpritesForever = SKAction.repeatForever(SKAction.sequence([moveSkylineSprite, resetSkylineSprite]))
//        
//        // Calculate the number of skyline sprites required and add them behind other objects
//        let skylineSpriteCount = Int(2 + self.frame.size.width / (skylineTexture.size().width * 2))
//        for i in 0..<skylineSpriteCount {
//            let sprite = SKSpriteNode(texture: skylineTexture)
//            sprite.setScale(2.0)
//            sprite.zPosition = -20
//            sprite.position = CGPoint(
//                x: CGFloat(i) * sprite.size.width,
//                y: sprite.size.height / 2 + SKTexture(imageNamed: "Ground").size().height * 2
//            )
//            sprite.run(moveSkylineSpritesForever)
//            moving.addChild(sprite)
//        }
    }
    
    private func setupDummyNode() {
        // Create an invisible node to serve as a collision boundary for the ground
        let groundTexture = SKTexture(imageNamed: "Ground")
        let dummy = SKNode()
        dummy.position = CGPoint(x: 0, y: groundTexture.size().height)
        dummy.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.size.width,
                                                                height: groundTexture.size().height * 2))
        dummy.physicsBody?.isDynamic = false
        dummy.physicsBody?.categoryBitMask = worldCategory
        
        addChild(dummy)
    }
    
    private func setupPipes() {
        addChild(pipes)
        
        // Load and configure pipe textures
        pipeTexture1 = SKTexture(imageNamed: "Pipe1")
        pipeTexture1.filteringMode = .nearest
        pipeTexture2 = SKTexture(imageNamed: "Pipe2")
        pipeTexture2.filteringMode = .nearest
        
        // Create an action to move pipes left offscreen, then remove them
        let distanceToMove = self.frame.width + 2 * pipeTexture1.size().width
        let movePipes = SKAction.moveBy(x: -distanceToMove, y: 0, duration: 0.01 * Double(distanceToMove))
        let removePipes = SKAction.removeFromParent()
        moveAndRemovePipes = SKAction.sequence([movePipes, removePipes])
    }
    
    private func startSpawningPipes() {
        // Create an action to spawn pipes repeatedly with a delay,
        // and run it with a key so it can be removed on game over
        
        /*
         ACTIVITY 3: Setup pipe spawning.
         We've set up the nitty gritty of spawnPipes() for you, but the function is actually never called.
         Set up an SKAction and call .run() on it, passing in spawnPipes() as the parameter.
         Then, define a delay (also SKAction) and call .wait() for a duration of 2-3 seconds.
         Then, call repeatForever(), and run it.
         */
    }
    
    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /*
         ACTIVITY 2: Setup touch functionality.
         Let's play ahead. Our touch began function needs to handle two cases:
         1. The game is not over. That means our bird is moving (the moving.speed variable is nonzero).
         2. The game is over. Our bird is not moving. (else block is sufficient)
         
         In the first block, we want the following logic in order to simulate a bird's flap from a touch.
         First, set the bird's physicsbody's velocity to be zero.
         Then, call the applyImpulse() function on the physics body and pass in CGVector(dx: 0, dy: 14).
         */
//        if {
//            // On touch, reset vertical velocity and apply an upward impulse to the bird
//            bird.physicsBody?.velocity = .zero
//            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 14))
//        } else {
//            // Restart the game if allowed
//            resetScene()
//        }
    }
    
    // MARK: - Helper Method
    func clamp(_ lower: CGFloat, _ upper: CGFloat, value: CGFloat) -> CGFloat {
        // Ensure value stays within the lower and upper bounds
        return min(max(value, lower), upper)
    }
    
    // MARK: - Pipe Spawning
    func spawnPipes() {
        let pipePair = SKNode()
        pipePair.name = "pipePair"
        // Start pipes off-screen to the right
        pipePair.position = CGPoint(x: self.frame.width + pipeTexture1.size().width, y: 0)
        pipePair.zPosition = -10
        
        // Randomize vertical position (within lower third) for variability
        let yPosition = CGFloat.random(in: 0 ..< (self.frame.height / 3))
        
        // Lower pipe configuration
        let pipe1 = SKSpriteNode(texture: pipeTexture1)
        pipe1.setScale(3)
        pipe1.position = CGPoint(x: 0, y: yPosition)
        pipe1.physicsBody = SKPhysicsBody(rectangleOf: pipe1.size)
        pipe1.physicsBody?.isDynamic = false
        pipe1.physicsBody?.categoryBitMask = pipeCategory
        pipe1.physicsBody?.contactTestBitMask = birdCategory
        pipePair.addChild(pipe1)
        
        // Upper pipe: positioned above the lower pipe using the fixed vertical gap
        let pipe2 = SKSpriteNode(texture: pipeTexture2)
        pipe2.setScale(3)
        pipe2.position = CGPoint(x: 0, y: Int(yPosition + pipe1.size.height) + GameScene.kVerticalPipeGap)
        pipe2.physicsBody = SKPhysicsBody(rectangleOf: pipe2.size)
        pipe2.physicsBody?.isDynamic = false
        pipe2.physicsBody?.categoryBitMask = pipeCategory
        pipe2.physicsBody?.contactTestBitMask = birdCategory
        pipePair.addChild(pipe2)
        
        // Invisible contact node to trigger scoring when the bird passes the pipes
        let contactNode = SKNode()
        contactNode.position = CGPoint(x: pipe1.size.width + bird.size.width / 2, y: self.frame.midY)
        contactNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: pipe2.size.width, height: self.frame.height))
        contactNode.physicsBody?.isDynamic = false
        contactNode.physicsBody?.categoryBitMask = scoreCategory
        contactNode.physicsBody?.contactTestBitMask = birdCategory
        pipePair.addChild(contactNode)
        
        // Run the move-and-remove action and add the pair to the moving container
        pipePair.run(moveAndRemovePipes)
        moving.addChild(pipePair)
    }
    
    // MARK: - Collision Handling
    func didBegin(_ contact: SKPhysicsContact) {
        if moving.speed > 0 {
            // Check if contact is with the scoring node
            if (contact.bodyA.categoryBitMask & scoreCategory) == scoreCategory ||
               (contact.bodyB.categoryBitMask & scoreCategory) == scoreCategory {
                /*
                ACTIVITY 4: Set score.
                When contact is made with our invisible scoring entity, increment score by 1,
                and set our score label node to display this new value.
                */
                
                // Briefly scale the score label to indicate a score increase
                let scaleUp = SKAction.scale(to: 1.5, duration: 0.1)
                let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
                let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
                scoreLabelNode.run(scaleSequence)
            } else {
                // Game over: collision with a pipe or the ground
                moving.speed = 0
                // Prevent further collisions from affecting the bird
                bird.physicsBody?.collisionBitMask = worldCategory
                
                // Remove the pipe-spawning action to stop creating new pipes
                removeAction(forKey: "pipeSpawning")
                
                // Rotate the bird to simulate falling
                let angle = CGFloat.pi * bird.position.y * 0.01
                let duration = TimeInterval(bird.position.y * 0.003)
                let rotateAction = SKAction.rotate(byAngle: angle, duration: duration)
                bird.run(rotateAction) { [weak self] in
                    self?.bird.speed = 0
                }
                
                // Flash the background red as feedback and then allow game restart
                removeAction(forKey: "flash")
                let flashSequence = SKAction.sequence([
                    SKAction.repeat(
                        SKAction.sequence([
                            SKAction.run { self.backgroundColor = .red },
                            SKAction.wait(forDuration: 0.05),
                            SKAction.run { self.backgroundColor = self.skyColor },
                            SKAction.wait(forDuration: 0.05)
                        ]),
                        count: 4
                    ),
                    SKAction.run { self.canRestart = true }
                ])
                run(flashSequence, withKey: "flash")
            }
        }
    }
    
    // MARK: - Scene Reset
    func resetScene() {
        // Reset bird properties
        bird.position = CGPoint(x: frame.size.width / 4, y: frame.midY)
        bird.physicsBody?.velocity = .zero
        bird.physicsBody?.collisionBitMask = worldCategory | pipeCategory
        bird.speed = 1.0
        bird.zRotation = 0.0
        
        // Remove all active pipe pairs
        moving.enumerateChildNodes(withName: "pipePair") { node, _ in
            node.removeFromParent()
        }
        
        // Reset game state flags and resume movement
        canRestart = false
        moving.speed = 1
        
        // Restart the pipe spawning cycle
        startSpawningPipes()
        
        // ACTIVITY 4 CONTINUED: Reset the score here

    }
    
    // MARK: - Update Loop
    override func update(_ currentTime: TimeInterval) {
        // Ensure the bird's physics body is valid
        guard let physicsBody = bird.physicsBody else { return }
        
        // Adjust the bird's rotation based on its vertical velocity
        let multiplier: CGFloat = physicsBody.velocity.dy < 0 ? 0.003 : 0.001
        bird.zRotation = clamp(-1, 0.5, value: physicsBody.velocity.dy * multiplier)
    }
}
