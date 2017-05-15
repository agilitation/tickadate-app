//
//  DebugViewController.swift
//  tickadate
//
//  Created by Romain Bessuges-Meusy on 15/05/2017.
//  Copyright © 2017 Agilitation. All rights reserved.
//

import UIKit

class DebugViewController: UIViewController {

  let dc:DataController = DataController()
  
  @IBAction func removeEvents(_ sender: Any) {
    dc.deleteAllEvents()
  }
  @IBAction func removeEventTypes(_ sender: Any) {
    dc.deleteAllEvents()
    dc.deleteAllEventTypes()
  }
  @IBAction func createDefaultEventTypes(_ sender: Any) {
    dc.bootstrapEventTypes()
  }
}
