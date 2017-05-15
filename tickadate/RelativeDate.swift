//
//  RelativeDate.swift
//  tickadate
//
//  Created by Romain Bessuges-Meusy on 15/05/2017.
//  Copyright © 2017 Agilitation. All rights reserved.
//

import UIKit

class RelativeDate: NSObject {
  
  
  static func inAWeek() -> Date {
    var dc = DateComponents()
    dc.day = 7
    return Calendar.current.date(byAdding: dc, to: Date())!
  }
  
  static func nextWeek() -> Date {
    var dc = DateComponents()
    dc.weekday = Calendar.current.firstWeekday + 1
    return Calendar.current.nextDate(after: Date(), matching: dc, matchingPolicy: .nextTime)!
  }
  
  static func tomorrow() -> Date {
    return Calendar.current.date(byAdding: .day, value: 1, to: Date())!
  }
  
  static func yesterday() -> Date {
    return Calendar.current.date(byAdding: .day, value: -1, to: Date())!
  }
}
