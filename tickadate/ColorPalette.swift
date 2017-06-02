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
  var label:String! = ""
  var colors:[ColorPaletteItem] = []
  
  init(label:String, colors:[ColorPaletteItem]){
    self.label = label;
    self.colors =  colors;
  }
  
  init(fromPList plist:[String:Any]){
    self.label = plist["label"] as! String
    let plistColorArr:[[String:String]] = plist["colors"] as! [[String:String]]
    self.colors = plistColorArr.map { (color) -> ColorPaletteItem in
      return ColorPaletteItem(hexString: color["hex"]!, label: color["label"]!)
    }
  }
}

class ColorSwatchDescription {
  var name:String! = ""
  var description:String! = ""
  var productID:String! = ""
  var filename:String! = ""
  
  init(fromPList plist:[String:String]) {
    self.name = plist["name"]
    self.description = plist["description"]
    self.productID = plist["productID"]
    self.filename = plist["filename"]
  }
}

/*
  func fetchEventTypeExamples(completion:@escaping () -> ()) {
    if let fileUrl = Bundle.main.url(forResource: "EventTypeExamples", withExtension: "plist"),
      let data = try? Data(contentsOf: fileUrl) {
      if let result = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [Dictionary<String, String>] {
        self.eventTypeExamples = result!.map({ (color) -> EventTypeExample in
          return EventTypeExample(name: color["name"]!, color: color["hex"]!)
        })
      }
    }
    completion()
  }
 
 */
