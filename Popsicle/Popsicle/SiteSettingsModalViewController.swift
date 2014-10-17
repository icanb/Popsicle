//
//  SiteSettingsModalViewController.swift
//  Popsicle
//
//  Created by Ilter Canberk on 10/16/14.
//  Copyright (c) 2014 hax. All rights reserved.
//

import UIKit

class SiteSettingsModalViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!)  {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.commonInit()
    }

    func commonInit() {
        self.modalPresentationStyle = .Custom
        self.transitioningDelegate = self
    }
    
    // ---- UIViewControllerTransitioningDelegate methods
    
    func presentationControllerForPresentedViewController(presented: UIViewController!, presentingViewController presenting: UIViewController!, sourceViewController source: UIViewController!) -> UIPresentationController! {
        
        if presented == self {
            return FlyFromTopController(presentedViewController: presented, presentingViewController: presenting)
        }
        
        return nil
    }
    
    func animationControllerForPresentedController(presented: UIViewController!, presentingController presenting: UIViewController!, sourceController source: UIViewController!) -> UIViewControllerAnimatedTransitioning! {
        
        if presented == self {
            return FlyFromTopAnimationController(isPresenting: true)
        }
        else {
            return nil
        }
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController!) -> UIViewControllerAnimatedTransitioning! {
        
        if dismissed == self {
            return FlyFromTopAnimationController(isPresenting: false)
        }
        else {
            return nil
        }
    }
    
}
