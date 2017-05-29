//
//  GridStatView.swift
//  tickadate
//
//  Created by Romain Bessuges-Meusy on 24/05/2017.
//  Copyright © 2017 Agilitation. All rights reserved.
//

import UIKit
import DynamicColor

struct GridStatValue {
  var label:String
  var value:Float
}

struct GridStatLayoutDirection {
  var first:LayoutDirection
  var second:LayoutDirection
}

enum LayoutDirection {
  case ltr
  case rtl
  case ttb
  case btt
}

@IBDesignable
class GridStatView: UIView {
  
  var direction:GridStatLayoutDirection = GridStatLayoutDirection(first: .ltr, second: .ttb)
  var offset:Int = 0
  var numberOfRows:Int = 4
  var numberOfCols:Int = 10
  var space:CGFloat = 6
  var values:[Float] = [0.3, 0.5, 0.8, 0.9, 1] {
    didSet {
      self.max = values.max() ?? 0
      self.setNeedsDisplay()
    }
  }
  
  var max:Float = 0
  
  override func draw(_ rect: CGRect) {
    self.isOpaque = false
    self.backgroundColor = UIColor.clear
    
    if let context:CGContext =  UIGraphicsGetCurrentContext() {
      context.clear(rect)
      let cellWidth:CGFloat = (rect.width + space) / CGFloat(numberOfCols)  - space
      let cellHeight:CGFloat =  (rect.height + space) / CGFloat(numberOfRows)  - space
      
      for rowIndex in 0 ... numberOfRows - 1 {
        for colIndex in 0 ... numberOfCols - 1 {
          
          let index = rowIndex * numberOfCols + colIndex
          var value:Float = 0
          if(values.count > index){
            value = (self.max > 0) ? values[index] / self.max : 0
          }
          let square:CGRect = CGRect(
            x: CGFloat(colIndex) * (cellWidth + space),
            y: CGFloat(rowIndex) * (cellHeight + space),
            width: cellWidth,
            height: cellHeight
          )
          
        
          let color:CGColor = (value == 0) ? DynamicColor(hexString: "EEEEEE").cgColor :  tintColor.tinted(amount: CGFloat(1 - value / 2)).cgColor
          DrawUtils.drawRect(onContext: context, inRect: square, color: color)
        }
      }
    }
  }
  
}
