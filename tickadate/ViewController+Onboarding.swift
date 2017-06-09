//
//  Onboarding.swift
//  tickadate
//
//  Created by Romain Bessuges-Meusy on 05/06/2017.
//  Copyright © 2017 Agilitation. All rights reserved.
//

import UIKit


extension ViewController {
  
    func onboarding() {
    if isFirstLaunch() {
      let op = storyboard?.instantiateViewController(withIdentifier: "onboardingPageViewController") as! OnboardingPager
      op.view.frame = CGRect(x:0, y:0, width:self.view.frame.size.width, height: self.view.frame.size.height)
      self.addChildViewController(op)
      self.view.addSubview(op.view)
      op.didMove(toParentViewController: self)
      
      self.onboardingPager = op
    }
  }
  
  func leaveUnboarding(){
    if let op = onboardingPager {
      UIView.animate(withDuration: 1, animations: {
        op.view.frame.origin.y = -2000
      }, completion: { (completed) in
        op.view.removeFromSuperview()
        op.removeFromParentViewController()
      })
    }
  }
  
  func isFirstLaunch() -> Bool{
    
//    UserDefaults.standard.set(false, forKey: "launchedBefore")
    
    if UserDefaults.standard.bool(forKey: "launchedBefore") {
      return false
    }
    
    UserDefaults.standard.set(true, forKey: "launchedBefore")
    
    IAPManager.shared.reset()
    dataController.deleteAllEvents()
    dataController.deleteAllEventTypes()
    dataController.bootstrapEventTypes()
    return true
    
  }
}
