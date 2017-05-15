//
//  EventTypeNavigationController.swift
//  tickadate
//
//  Created by Romain Bessuges-Meusy on 15/05/2017.
//  Copyright © 2017 Agilitation. All rights reserved.
//

import UIKit

class EventTypeNavigationController: UINavigationController, UINavigationControllerDelegate {
  
  override init(rootViewController: UIViewController) {
    super.init(rootViewController: rootViewController)
    print ("EventTypeNavigationController.init", "rootViewController", rootViewController)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    print ("EventTypeNavigationController.init(coder)")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    print ("EventTypeNavigationController.viewDidLoad")
    
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    print("EventTypeNavigationController.prepare for segue", segue)
    super.prepare(for: segue, sender: sender)
  }
  
  override func unwind(for unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
    print("unwind", unwindSegue, subsequentVC)
    super.unwind(for: unwindSegue, towardsViewController: subsequentVC)
  }
  
  
  func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
    print("EventTypeNavigationController.preparedelegateWillShow", viewController)
  }
  
  func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
    print("EventTypeNavigationController.preparedelegateWillShow", viewController)
  }
}
