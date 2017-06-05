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
      dataController.deleteAllEvents()
      dataController.deleteAllEventTypes()
      dataController.bootstrapEventTypes()
//      self.performSegue(withIdentifier: "onboardingSegue", sender: self)
    }
  }
  
  func isFirstLaunch() -> Bool{
    return true
    
    /*
    
    let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
    if launchedBefore  {
      return false
    }
    UserDefaults.standard.set(false, forKey: "launchedBefore")
    return true
     */
  }
}
