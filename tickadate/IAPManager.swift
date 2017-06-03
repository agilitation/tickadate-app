//
//  IAPManager.swift
//  tickadate
//
//  Created by Romain Bessuges-Meusy on 02/06/2017.
//  Copyright © 2017 Agilitation. All rights reserved.
//

import UIKit


//github "bizz84/SwiftyStoreKit"

class IAPManager: NSObject {

  var activeColorSwatches:[ColorSwatch] = []
  var eventTypesCount:Int = 3
  
  func purchase(colorSwatch: ColorSwatch){
    activeColorSwatches.append(colorSwatch)
  }
  
  func purchase(additionalEventTypes:Int){
    
  }
  
}
