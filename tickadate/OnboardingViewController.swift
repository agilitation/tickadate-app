//
//  OnboardingViewController.swift
//  tickadate
//
//  Created by Romain Bessuges-Meusy on 05/06/2017.
//  Copyright © 2017 Agilitation. All rights reserved.
//

import UIKit

open class OnboardingViewController: UIViewController {
  
  var alreadySetup:Bool! = false
  
  @IBAction func nextPage(_ sender: Any) {
    let op = self.parent as! OnboardingPager
    op.nextPage(fromViewController: self)
  }
  open override func prepareForInterfaceBuilder() {
    setup()
  }
  
  open override func viewDidLoad() {
    if !alreadySetup {
      setup()
      alreadySetup = true
    }
  }
 
  open func setup() {
    
  }
}
