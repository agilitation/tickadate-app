//
//  WeekDayHeader.swift
//  tickadate
//
//  Created by Romain Bessuges-Meusy on 11/05/2017.
//  Copyright © 2017 Agilitation. All rights reserved.
//

import UIKit
import DynamicColor

@IBDesignable
class WeekDayHeader: BorderedView {
  
  override func draw(_ rect: CGRect) {
    
    super.draw(rect)
    
    let labelWidth:CGFloat! = floor(rect.width / 7)
    var labelOffset:CGFloat! = 0.0
    
    let symbols = Calendar.current.shortWeekdaySymbols
    let first = Calendar.current.firstWeekday - 1
    var weekdaySymbol:String!
    var weekdayIndex:Int!
    
    for index in first ... first + 7 {
    
      weekdayIndex = index > 6 ? index - 7 : index
      weekdaySymbol = symbols[weekdayIndex]
    
      let label = UILabel(frame: CGRect(x: labelOffset, y: 0, width: labelWidth, height: rect.height))
      //            label.font = UIFont.systemFont(ofSize: 14, weight: 10)
      label.font = UIFont.preferredFont(forTextStyle: .caption1)
      label.textAlignment = .center
      label.text = weekdaySymbol
      self.addSubview(label)
      labelOffset.add(labelWidth)
    }
  }
}
