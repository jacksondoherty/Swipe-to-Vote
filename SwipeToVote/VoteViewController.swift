//
//  VoteViewController.swift
//  SwipeToVote
//
//  Created by Jackson Doherty on 10/3/15.
//  Copyright © 2015 Jackson Doherty. All rights reserved.
//

// todo:    - make sure I manage memory apropriately -> once block.center is beyond certain point, stop/delete it?
//              look at Stanford lecture
//          - make sure I treat attachment behaviors safely
//          - figure out why blocks are all distorted after a couple of resets
//          - figure out why I need to undo attach behavior

import UIKit
import EXTView

class VoteViewController: UIViewController {
    
    // background view
    @IBOutlet weak var backgroundView: UIView!
    
    // bounds to get screen size
    var screen = UIScreen.mainScreen().bounds
    
    // dynamic animator
    lazy var animator: UIDynamicAnimator = {
        return UIDynamicAnimator(referenceView: self.backgroundView)
    }()
    
    // push behavior
    let push = UIPushBehavior()
    
    // attachment behaviors (attaches fades to blocks)
    var attach1: UIAttachmentBehavior! // is this okay?
    var attach2: UIAttachmentBehavior!
    
    // swipe gestures
    lazy var gesture1: UIPanGestureRecognizer = {
        return UIPanGestureRecognizer(target: self, action: Selector("drag1:"))
    }()
    lazy var gesture2: UIPanGestureRecognizer = {
        return UIPanGestureRecognizer(target: self, action: Selector("drag2:"))
    }()
    
    // blocks
    var blockView1 = UIView()
    var blockView2 = UIView()
    
    // fades (below blocks)
    var fadeView1 = EXTView() // cocoapod
    var fadeView2 = EXTView()
    
    // block size
    let blockHeight = 50
    var blockSize: CGSize {
        let width = (screen.size.width / 2)
        let height = CGFloat(blockHeight)
        return CGSize(width: width, height: height)
    }
    
    // fade size
    var fadeSize: CGSize {
        let width = blockSize.width
        let height = screen.size.height
        return CGSize(width: width, height: height)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        // add push behavior to animator and configure settings
        animator.addBehavior(push)
        push.pushDirection = CGVectorMake(0, -1.0)
        
        createBlocks()
        
        createFades()
        
        // add swipe gesture1 to blockView1 and enable user interaction
        blockView1.addGestureRecognizer(gesture1)
        blockView1.userInteractionEnabled = true
        
        // add swipe gesture2 to blockView2 and enable user interaction
        blockView2.addGestureRecognizer(gesture2)
        blockView2.userInteractionEnabled = true
    }
    
    func createBlocks() {
        
        // both blocks start in same y position
        let blockStartYPosition = screen.size.height - CGFloat(blockHeight)
        
        // create block1 and add to backgoundView
        let position1 = CGPoint(x: 0, y: blockStartYPosition)
        let frame1 = CGRect(origin: position1, size: blockSize)
        blockView1.frame = frame1
        blockView1.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
        backgroundView.addSubview(blockView1)
        
        // create block2 and add to backgroundView
        let position2 = CGPoint(x: (screen.size.width / 2), y: blockStartYPosition)
        let frame2 = CGRect(origin: position2, size: blockSize)
        blockView2.frame = frame2
        blockView2.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
        backgroundView.addSubview(blockView2)
    }
    
    func createFades() {
        
        // create fade1 and add to backgroundView
        let fadePosition1 = CGPoint(x: 0, y: screen.size.height)
        let fadeFrame1 = CGRect(origin: fadePosition1, size: fadeSize)
        fadeView1.frame = fadeFrame1
        fadeView1.bgStartColor = UIColor.purpleColor()
        fadeView1.bgEndColor = UIColor.clearColor()
        backgroundView.addSubview(fadeView1)
        
        // create fade2 and add to backgroundView
        let fadePosition2 = CGPoint(x: (screen.size.width / 2), y: screen.size.height)
        let fadeFrame2 = CGRect(origin: fadePosition2, size: fadeSize)
        fadeView2.frame = fadeFrame2
        fadeView2.bgStartColor = UIColor.purpleColor()
        fadeView2.bgEndColor = UIColor.clearColor()
        backgroundView.addSubview(fadeView2)
    }
    
    func drag1(gesture: UIPanGestureRecognizer) {
        
        // disable user interaction of other block
        blockView2.userInteractionEnabled = false
        
        // get translation of gesture
        let translation = gesture.translationInView(backgroundView)
        
        // note: coordinates here are calculated by center of views
        
        // move block by translation
        blockView1.center = CGPoint(x: blockView1.center.x, y: screen.size.height - blockSize.height/2 + translation.y)
        
        // move fade by translation
        fadeView1.center = CGPoint(x: fadeView1.center.x, y: screen.size.height + fadeSize.height/2 + translation.y)
        
        if gesture.state == UIGestureRecognizerState.Ended {
            
            // if past certain point, push kicks in
            // if not, gravity kicks in and enable other button
            if translation.y < -100 {
            
                // attach fade to block
                attach1 = UIAttachmentBehavior(item: fadeView1, attachedToItem: blockView1)
                animator.addBehavior(attach1)
            
                // configure push behavior to have velocity of swipe
                let velocity = gesture.velocityInView(backgroundView)
                let magnitude = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y))
                push.magnitude = magnitude
                
                // add push to block behavior
                push.addItem(blockView1)
                
            } else {
                
                blockView1.center = CGPoint(x: blockView1.center.x, y: screen.size.height - blockSize.height/2)
                fadeView1.center = CGPoint(x: fadeView1.center.x, y: screen.size.height + fadeSize.height/2)
                blockView2.userInteractionEnabled = true
            }
        }
    }
    
    func drag2(gesture: UIPanGestureRecognizer) {
        
        blockView1.userInteractionEnabled = false
        
        //get translation
        let translation = gesture.translationInView(backgroundView)
        
        // move block by translation
        blockView2.center = CGPoint(x: blockView2.center.x, y: screen.size.height - blockSize.height/2 + translation.y)
        
        // move fade by translation
        fadeView2.center = CGPoint(x: fadeView2.center.x, y: screen.size.height + fadeSize.height/2 + translation.y)
        
        // let go of block
        if gesture.state == UIGestureRecognizerState.Ended {
            
            // if past certain point, push kicks in
            // if not, gravity kicks in and enable other button
            if translation.y < -100 {
            
                // attach fade to block
                attach2 = UIAttachmentBehavior(item: fadeView2, attachedToItem: blockView2)
                animator.addBehavior(attach2)
            
                // configure push behavior to have velocity of swipe
                let velocity = gesture.velocityInView(backgroundView)
                let magnitude = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y))
                push.magnitude = magnitude
                
                // block to push behavior
                push.addItem(blockView2)
            
            } else {
            
                blockView2.center = CGPoint(x: blockView2.center.x, y: screen.size.height - blockSize.height/2)
                fadeView2.center = CGPoint(x: fadeView2.center.x, y: screen.size.height + fadeSize.height/2)
                blockView1.userInteractionEnabled = true
            }
        }
    }
    
    // won't be a function in the scooper app
    @IBAction func reset(sender: AnyObject) {
        
        // undo attachments - not sure why but seems necessary
        if let attachment1 = attach1 {
            animator.removeBehavior(attachment1)
        }
        if let attachment2 = attach2 {
            animator.removeBehavior(attachment2)
        }
        
        // remove velocity
        push.removeItem(blockView1)
        push.removeItem(blockView2)
        
        // put blocks and fades back into their original positions
        blockView1.center = CGPoint(x: blockView1.center.x, y: screen.size.height - blockSize.height/2)
        blockView1.userInteractionEnabled = true
        fadeView1.center = CGPoint(x: fadeView1.center.x, y: screen.size.height + fadeSize.height/2)
        blockView2.center = CGPoint(x: blockView2.center.x, y: screen.size.height - blockSize.height/2)
        blockView2.userInteractionEnabled = true
        fadeView2.center = CGPoint(x: fadeView2.center.x, y: screen.size.height + fadeSize.height/2)
    }
}
