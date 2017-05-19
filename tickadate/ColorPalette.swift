//
//  ColorPalette.swift
//  tickadate
//
//  Created by Romain Bessuges-Meusy on 16/05/2017.
//  Copyright © 2017 Agilitation. All rights reserved.
//

import UIKit
import DynamicColor
class ColorPaletteItem : Equatable {
  var color:UIColor! = UIColor.black
  var label:String! = ""
  
  init(color:UIColor, label:String) {
    self.color = color;
    self.label = label;
  }
  
  convenience init(hexString:String, label:String) {
    self.init(color: DynamicColor(hexString: hexString), label: label)
  }
 
  public static func ==(lhs: ColorPaletteItem, rhs: ColorPaletteItem) -> Bool {
    return lhs.color == rhs.color
  }

}
