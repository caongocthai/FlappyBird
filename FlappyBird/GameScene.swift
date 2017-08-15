//
//  GameScene.swift
//  FlappyBird
//
//  Created by Harry Cao on 10/6/17.
//  Copyright © 2017 Harry Cao. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
  enum ColliderType: UInt32 {
    case Bird = 1
    case Ground = 2
    case Pipe = 4
    case Gap = 8
  }
  
  var isGameOver = false
  
  
//  var bgs = [SKSpriteNode]()
  var bg = SKSpriteNode()
  let ground = SKNode()
  var bird = SKSpriteNode()
  
  override func didMove(to view: SKView) {
    super.didMove(to: view)
    
    self.physicsWorld.contactDelegate = self
    
    setupBackground()
    setupGround()
    _ = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(setupPipes), userInfo: nil, repeats: true)
    
    setupBird()
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    if isGameOver == false {
      // Define isDynamic true will make the bird fall down
      // Do this only when users click for the 1st time
      bird.physicsBody?.isDynamic = true
      
      // Set bird velocity
      bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
      
      // As users click, apply an impulse to the bird
      bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 90))
    }
  }

  
  override func update(_ currentTime: TimeInterval) {
      // Called before each frame is rendered
  }
  
  func didBegin(_ contact: SKPhysicsContact) {
    let contactCategory = ColliderType.Ground.rawValue
    if isGameOver == false {
      bird.physicsBody?.applyImpulse(CGVector(dx: 10, dy: 20))
    } else {
      bird.physicsBody?.velocity.dx = 0
    }
    
    if contact.bodyA.categoryBitMask ==  contactCategory || contact.bodyA.categoryBitMask == contactCategory {
      bird.physicsBody?.isDynamic = false
    }
    
    isGameOver = true
    self.speed = 0
  }
}

extension GameScene {
  fileprivate func setupBackground() {
    let bgTexture = SKTexture(image: #imageLiteral(resourceName: "bg"))
    
    let movingAnimation = SKAction.move(by: CGVector(dx: -bgTexture.size().width, dy: 0) , duration: 6)
    let shiftingBack = SKAction.move(by: CGVector(dx: bgTexture.size().width, dy: 0), duration: 0)
    let moveBg = SKAction.repeatForever(SKAction.sequence([movingAnimation, shiftingBack]))
    
    for i in 0...2 {
      // Define bg and add it to scene
      bg = SKSpriteNode(texture: bgTexture)
      bg.position = CGPoint(x: bgTexture.size().width*CGFloat(i), y: self.frame.midY)
      bg.size.height = self.frame.height
      self.addChild(bg)
      //      bgs.append(SKSpriteNode(texture: bgTexture))
      //      bgs[i].position = CGPoint(x: bgTexture.size().width*CGFloat(i), y: self.frame.midY)
      //      bgs[i].size.height = self.frame.height
      //      bgs[i].zPosition = -1
      //      self.addChild(bgs[i])
      
      // Make background moving to the left
      bg.run(moveBg)
      //      bgs[i].run(moveBg)
    }
  }
  
  fileprivate func setupGround() {
    // Set position and size of the ground
    ground.position = CGPoint(x: -self.frame.midX, y: -self.frame.height/2)
    ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: 1))
    
    // Make the ground not falling like other physic
    ground.physicsBody?.isDynamic = false
    
    ground.physicsBody?.categoryBitMask = ColliderType.Ground.rawValue
    ground.physicsBody?.contactTestBitMask = ColliderType.Bird.rawValue
    ground.physicsBody?.collisionBitMask = ColliderType.Bird.rawValue
    
    self.addChild(ground)
  }
  
  fileprivate func setupBird() {
    let birdTexture1 = SKTexture(image: #imageLiteral(resourceName: "flappy1"))
    let birdTexture2 = SKTexture(image: #imageLiteral(resourceName: "flappy2"))
    let birdTextures = [birdTexture1, birdTexture2]
    
    // Define bird node and add it to scene
    bird = SKSpriteNode(texture: birdTexture1)
    bird.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
    bird.zPosition = 2
    
    bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height/2)
    // Not a physic body at first
    bird.physicsBody?.isDynamic = false
    
    bird.physicsBody?.categoryBitMask = ColliderType.Bird.rawValue
    bird.physicsBody?.contactTestBitMask = ColliderType.Ground.rawValue | ColliderType.Pipe.rawValue
    bird.physicsBody?.collisionBitMask = ColliderType.Ground.rawValue
    
    self.addChild(bird)
    
    // Make bird flap
    let animation = SKAction.animate(with: birdTextures, timePerFrame: 0.2)
    let makeBirdFlap = SKAction.repeatForever(animation)
    bird.run(makeBirdFlap)
  }
  
  @objc
  fileprivate func setupPipes() {
    let gapHeight = bird.size.height * 5
    
    // Randomize the position of the gap
    let randomOffset = CGFloat(arc4random()%UInt32(self.frame.height/2)) - self.frame.height/4
    
    // Action to move the pipe
    let movingAnimation = SKAction.move(by: CGVector(dx: -2*self.frame.width ,dy: 0), duration: TimeInterval(self.frame.width/100))
    
    // Ceil pipe
    let ceilPipeTexture = SKTexture(image: #imageLiteral(resourceName: "pipe1"))
    let ceilPipe = SKSpriteNode(texture: ceilPipeTexture)
    ceilPipe.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY + ceilPipeTexture.size().height/2 + gapHeight/2 + randomOffset)
    ceilPipe.zPosition = 1
    
    ceilPipe.physicsBody = SKPhysicsBody(rectangleOf: ceilPipe.size)
    ceilPipe.physicsBody?.isDynamic = false
    ceilPipe.physicsBody?.categoryBitMask = ColliderType.Pipe.rawValue
    ceilPipe.physicsBody?.contactTestBitMask = ColliderType.Bird.rawValue
    
    self.addChild(ceilPipe)
    ceilPipe.run(movingAnimation) { 
      ceilPipe.removeFromParent()
    }
    
    // Floor pipe
    let floorPipeTexture = SKTexture(image: #imageLiteral(resourceName: "pipe2"))
    let floorPipe = SKSpriteNode(texture: floorPipeTexture)
    floorPipe.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY - floorPipeTexture.size().height/2 - gapHeight/2 + randomOffset)
    floorPipe.zPosition = 1
    
    floorPipe.physicsBody = SKPhysicsBody(rectangleOf: ceilPipe.size)
    floorPipe.physicsBody?.isDynamic = false
    floorPipe.physicsBody?.categoryBitMask = ColliderType.Pipe.rawValue
    floorPipe.physicsBody?.contactTestBitMask = ColliderType.Bird.rawValue
    
    self.addChild(floorPipe)
    floorPipe.run(movingAnimation) {
      floorPipe.removeFromParent()
    }
  }
}
