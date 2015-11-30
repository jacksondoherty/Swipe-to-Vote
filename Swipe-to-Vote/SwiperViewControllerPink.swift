//
//  SwiperViewController2.swift
//  Swipe-to-Vote
//
//  Created by Jackson Doherty on 11/16/15.
//  Copyright © 2015 Jackson Doherty. All rights reserved.
//

import UIKit

class SwiperViewControllerPink: UIViewController {
    
    // block
    
    var block = UIView()
    
    let blockHeight = 50
    
    var blockSize : CGSize {
        let width = self.view.frame.size.width
        let height = CGFloat(blockHeight)
        return CGSize(width: width, height: height)
    }
    
    var blockStartPosition : CGPoint {
        let x = CGFloat(0)
        let y = self.view.frame.size.height - CGFloat(blockHeight)
        return CGPoint(x: x, y: y)
    }
    
    let blockColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
    
    // fade
    
    var fade = UIView()
    
    var fadeSize : CGSize {
        let width = blockSize.width
        let height = self.view.frame.size.height
        return CGSize(width: width, height: height)
    }
    
    var fadeStartPosition : CGPoint {
        let x = blockStartPosition.x
        let y = self.view.frame.size.height
        return CGPoint(x: x, y: y)
    }
    
    var fadeGradient : CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.frame = fade.bounds
        gradient.colors = [UIColor.magentaColor().CGColor, UIColor.whiteColor().CGColor]
        return gradient
    }
    
    // physics
    
    lazy var animator: UIDynamicAnimator = {
        return UIDynamicAnimator(referenceView: self.view)
    }()
    
    lazy var push: UIPushBehavior = {
        let lazyPush = UIPushBehavior()
        lazyPush.pushDirection = CGVectorMake(0, -1.0)
        lazyPush.action = {
            
            let multiplier = CGFloat(-3)
            
            // once block reaches 3 superviews above superview
            if (self.block.center.y < multiplier * self.view.superview!.frame.height) {
                self.animator.removeAllBehaviors()
            }
        }
        return lazyPush
    }()
    
    var attach: UIAttachmentBehavior?
    
    lazy var swipe : UIPanGestureRecognizer = {
        return UIPanGestureRecognizer(target: self, action: Selector("swipe:"))
    }()
    
    // must use this method
    // viewDidLoad will cause errors in dimensions of subviews
    override func viewWillLayoutSubviews() {
        createBlock()
        createFade()
        addPhysics()
    }
    
    func createBlock() {
        block.frame = CGRect(origin: blockStartPosition, size: blockSize)
        block.backgroundColor = blockColor
        self.view.addSubview(block)
    }
    
    func createFade() {
        fade.frame = CGRect(origin: fadeStartPosition, size: fadeSize)
        fade.layer.insertSublayer(fadeGradient, atIndex: 0)
        self.view.addSubview(fade)
    }
    
    func addPhysics() {
        animator.addBehavior(push)
        block.addGestureRecognizer(swipe)
        block.userInteractionEnabled = true
    }
    
    func swipe(gesture: UIPanGestureRecognizer) {
        
        // ** disable user interaction of other block **
        
        let translation = gesture.translationInView(self.view)
        
        // note: coordinates here are calculated by center of views
        let blockYStartPosition = self.view.frame.size.height - blockSize.height/2
        let fadeYStartPosition = self.view.frame.size.height + fadeSize.height/2
        
        // move block by translation
        block.center = CGPoint(x: block.center.x, y: blockYStartPosition + translation.y)
        
        // move fade by translation
        fade.center = CGPoint(x: fade.center.x, y: fadeYStartPosition + translation.y)
        
        if gesture.state == UIGestureRecognizerState.Ended {
            
            // if past certain point, push behavior kicks in
            if translation.y < -100 {
                
                // ** register user vote **
                
                // attach fade to block
                attach = UIAttachmentBehavior(item: fade, attachedToItem: block)
                animator.addBehavior(attach!)
                
                // configure push behavior to have velocity of swipe
                let velocity = gesture.velocityInView(self.view)
                let magnitude = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y))
                push.magnitude = magnitude
                
                // add block to push behavior
                push.addItem(block)
                
                // else, block and fade snap back to original position
            } else {
                
                block.center = CGPoint(x: block.center.x, y: blockYStartPosition)
                fade.center = CGPoint(x: fade.center.x, y: fadeYStartPosition)
                
                // ** enable user interaction of other block **
            }
        }
    }
}