//
//  RelativeDate.swift
//  tickadate
//
//  Created by Romain Bessuges-Meusy on 15/05/2017.
//  Copyright © 2017 Agilitation. All rights reserved.
//

import UIKit

class RelativeDate: NSObject {
  
  static func today() -> Date {
    let  now = Date()
    let cal = Calendar.current
    let dc = cal.dateComponents([.day, .month, .year], from: now)
    return cal.date(from: dc)!
  }
  
  static func inAWeek() -> Date {
    var dc = DateComponents()
    dc.day = 7
    return Calendar.current.date(byAdding: dc, to: RelativeDate.today())!
  }
  
  static func nextWeek() -> Date {
    var dc = DateComponents()
    dc.weekday = Calendar.current.firstWeekday + 1
    return Calendar.current.nextDate(after:  RelativeDate.today(), matching: dc, matchingPolicy: .nextTime)!
  }
  
  static func tomorrow() -> Date {
    return Calendar.current.date(byAdding: .day, value: 1, to:  RelativeDate.today())!
  }
  
  static func yesterday() -> Date {
    return Calendar.current.date(byAdding: .day, value: -1, to:  RelativeDate.today())!
  }
}
