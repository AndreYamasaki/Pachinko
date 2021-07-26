//
//  GameScene.swift
//  Project11
//
//  Created by user on 26/07/21.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //MARK: - Attributes
    
    var scoreLabel: SKLabelNode!
    var numberOfBallsLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    var editingLabel: SKLabelNode!
    var editingMode: Bool = false {
        didSet{
            if editingMode {
                editingLabel.text = "Done"
            } else {
                editingLabel.text = "Edit"
            }
        }
    }
    var numberOfBalls = 5 {
        didSet {
            numberOfBallsLabel.text = "Balls: \(numberOfBalls)"
            if numberOfBalls == 0 {
                numberOfBallsLabel.text = "Game Over"
                resetGame()
            }
        }
    }
    
    //MARK: - didMove
    override func didMove(to view: SKView) {
        
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 980, y: 700)
        addChild(scoreLabel)
        
        numberOfBallsLabel = SKLabelNode(fontNamed: "Chalkduster")
        numberOfBallsLabel.text = "Balls: 5"
        numberOfBallsLabel.horizontalAlignmentMode = .right
        numberOfBallsLabel.position = CGPoint(x: 980, y: 650)
        addChild(numberOfBallsLabel)
        
        editingLabel = SKLabelNode(fontNamed: "Chalkduster")
        editingLabel.text = "Edit"
//        editingLabel.horizontalAlignmentMode = .left
        editingLabel.position = CGPoint(x: 80, y: 700)
        addChild(editingLabel)
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self
        
        makeSlot(at: CGPoint(x: 128, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 384, y: 0), isGood: false)
        makeSlot(at: CGPoint(x: 640, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 896, y: 0), isGood: false)
        
        makeBouncer(at: CGPoint(x: 0, y: 0))
        makeBouncer(at: CGPoint(x: 256, y: 0))
        makeBouncer(at: CGPoint(x: 512, y: 0))
        makeBouncer(at: CGPoint(x: 768, y: 0))
        makeBouncer(at: CGPoint(x: 1024, y: 0))
    }
    
    //MARK: - Methods
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let objects = nodes(at: location)
        
        if objects.contains(editingLabel) {
            editingMode.toggle()
        } else {
            if editingMode {
                
                let size = CGSize(width: Int.random(in: 16...128), height: 16)
                let box = SKSpriteNode(color: UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1), size: size)
                box.zRotation = CGFloat.random(in: 0...3)
                box.position = location
                
                box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
                box.physicsBody?.isDynamic = false
                box.name = "box"
                addChild(box)
            } else {
                
//Challenge 1: Try writing code to use a random ball color each time they tap the screen.
                let arrayBall = [
                "ballBlue", "ballCyan", "ballGreen", "ballGrey", "ballPurple", "ballRed", "ballYellow"
                ]
                let ball = SKSpriteNode(imageNamed: arrayBall[Int.random(in: 0...6)])
                ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
                ball.physicsBody?.restitution = 0.4
                ball.physicsBody?.contactTestBitMask = ball.physicsBody?.collisionBitMask ?? 0
//Challenge 2: Try to force the Y value of new balls so they are near the top of the screen.
                ball.position = CGPoint(x: location.x, y: 680)
                ball.name = "ball"
                addChild(ball)
            }
        }
    }
    
    func makeBouncer(at position: CGPoint) {
        
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2)
        bouncer.physicsBody?.isDynamic = false
        addChild(bouncer)
    }
    
    func makeSlot(at position: CGPoint, isGood: Bool) {
        
        var slotBase: SKSpriteNode
        var slotGlow: SKSpriteNode
        
        if isGood {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slotBase.name = "good"
        } else {
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slotBase.name = "bad"
        }
        
        slotBase.position = position
        slotGlow.position = position
        
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody?.isDynamic = false
        
        addChild(slotBase)
        addChild(slotGlow)
        
        let spin = SKAction.rotate(byAngle: .pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
    }
    
    func collision(between ball: SKNode, object: SKNode) {
        if object.name == "good" {
            destroy(ball: ball)
            score += 1
            numberOfBalls += 1
        } else if object.name == "bad" {
            destroy(ball: ball)
            score -= 1
            numberOfBalls -= 1
        }
        
        if object.name == "box" {
             destroy(ball: object)
         }
    }
    
    func destroy(ball: SKNode) {
        
        if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
            fireParticles.position = ball.position
            addChild(fireParticles)
        }
        ball.removeFromParent()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if contact.bodyA.node?.name == "ball" {
            collision(between: nodeA, object: nodeB)
        } else if contact.bodyB.node?.name == "ball" {
            collision(between: nodeB, object: nodeA)
        }
        
//Challenge 3: Give players a limit of five balls, then remove obstacle boxes when they are hit.
        if contact.bodyA.node?.name == "box" {
            collision(between: nodeA, object: nodeB)
        } else if contact.bodyB.node?.name == "box" {
            collision(between: nodeB, object: nodeA)
        }
    }
    
    func resetGame() {
        let gameScene:GameScene = GameScene(size: self.view!.bounds.size) // create your new scene
        let transition = SKTransition.fade(withDuration: 1.0) // create type of transition (you can check in documentation for more transtions)
        gameScene.scaleMode = SKSceneScaleMode.fill
        self.view!.presentScene(gameScene, transition: transition)
        }
}
