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

class ColorSwatch {
  var name:String! = ""
  var colors:[ColorPaletteItem] = []
  var productID:String! = ""
  var description:String! = ""
  var filename:String! = ""
  
  init(fromPList plist:[String:Any]){
    self.name = plist["name"] as! String
    self.description = plist["description"] as! String
    self.productID = plist["productID"] as! String
    self.filename = plist["filename"] as! String
  }
  
  func load(completion: @escaping () -> ()){
    
    if self.colors.count > 0 {
      completion()
      return
    }
    
    PListParser<[[String:String]]>().parse(filename: self.filename) { (result) in
      result.forEach({ (color) in
        self.colors.append(ColorPaletteItem(hexString: color["hex"]!, label: color["label"]!))
      })
      completion()
    }
  }
  
  public static func ==(lhs: ColorSwatch, rhs: ColorSwatch) -> Bool {
    return lhs.productID == rhs.productID
  }
}

class ColorSwatchesManager {
  
  static let shared = ColorSwatchesManager()
  
  var swatches:[ColorSwatch] = []
  
  func fetchActiveColorSwatches(completion: @escaping ([ColorSwatch]) -> ()){
    // todo filter according to existing IAPurchases
    self.fetchAvailableColorSwatches(completion: completion)
  }
  
  func fetchAvailableColorSwatches(completion: @escaping ([ColorSwatch]) -> ()){
    if swatches.count == 0 {
      PListParser<[[String:String]]>().parse(filename: "ColorSwatches") { (result) in
        result.forEach({ (colorSwatchPListDict) in
          self.swatches.append(ColorSwatch(fromPList: colorSwatchPListDict))
        })
        completion(self.swatches)
      }
    } else {
      completion(self.swatches)
    }
  }

}
