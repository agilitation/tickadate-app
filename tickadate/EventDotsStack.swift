//
//  EventDotsStack.swift
//  tickadate
//
//  Created by Romain Bessuges-Meusy on 09/05/2017.
//  Copyright © 2017 Agilitation. All rights reserved.
//

import UIKit
import CoreData
import DynamicColor


class EventDotsStack: UIView {
  
  static let margin:CGFloat! = 2.0
  static let diameter:CGFloat! = 6.0
  
  var cnt:Int = 0
  var dots:[String] = [] {
    didSet {
      
      // maybe use oldValue ?
      if (dots.count > 0 || cnt != dots.count) {
        cnt = dots.count
        self.setNeedsDisplay()
      }
    }
  }
  
  override func draw(_ rect: CGRect) {
    if let context:CGContext =  UIGraphicsGetCurrentContext() {
      context.clear(rect)
      let existingCircleCount = self.subviews.count
      let numberOfCircles:CGFloat = CGFloat(dots.count)
      let maxNumberOfCirclesByRow:CGFloat = floor((rect.width - EventDotsStack.margin) / (EventDotsStack.diameter + EventDotsStack.margin))
      
      
      var remainingCircles:CGFloat = numberOfCircles
      var drawnCirclesCountInRow:CGFloat = 0
      var numberOfCirclesInRow:CGFloat = 0
      var rowWidth:CGFloat! = 0
      var offset:CGFloat! = 0
      var row:CGFloat = -1
      var oldDrawn:CGFloat = 0
      var numberOfRows:CGFloat = ceil(numberOfCircles / maxNumberOfCirclesByRow)
      
      func nextRow() {
        oldDrawn = drawnCirclesCountInRow
        remainingCircles.subtract(drawnCirclesCountInRow)
        numberOfCirclesInRow = ceil(remainingCircles / numberOfRows)
        rowWidth = EventDotsStack.diameter * numberOfCirclesInRow + EventDotsStack.margin * (numberOfCirclesInRow + 1)
        offset = floor((rect.width - rowWidth) / 2)
        drawnCirclesCountInRow = 0
        row.add(1)
        numberOfRows.subtract(1)
      }
      
      nextRow()
      
      for (index, dot) in dots.enumerated() {
        
        let x:CGFloat = EventDotsStack.margin + offset + drawnCirclesCountInRow * (EventDotsStack.diameter + EventDotsStack.margin)
        let y:CGFloat = row * (EventDotsStack.diameter + EventDotsStack.margin)
        
        DrawUtils.drawCircle(
          onContext: context,
          inRect: CGRect(x: x, y: y, width: EventDotsStack.diameter, height: EventDotsStack.diameter),
          color: DynamicColor(hexString: dot).cgColor
        )
        
        drawnCirclesCountInRow += 1
        
        if(drawnCirclesCountInRow  == numberOfCirclesInRow && CGFloat(index) < numberOfCircles - 1){
          nextRow()
        }
      }
    }

  }
}
