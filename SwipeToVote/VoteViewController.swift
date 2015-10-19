//
//  VoteViewController.swift
//  SwipeToVote
//
//  Created by Jackson Doherty on 10/3/15.
//  Copyright © 2015 Jackson Doherty. All rights reserved.
//

// todo:    - make sure I manage memory apropriately
//              - once block.center is beyond certain point, stop/delete it?
//              - look at Stanford lecture
//              - perhaps stop velocity on segue back to VoteViewController
//          - make sure I treat attachment behaviors safely
//          - figure out why blocks are all distorted after a couple of resets
//          - figure out why I need to undo attach behavior

import UIKit

class VoteViewController: UIViewController {
    
    // container for childVoteViewController
    @IBOutlet weak var containerView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // container views seem to be on seperate threads
        print("this is the main view")
    }
    
}
