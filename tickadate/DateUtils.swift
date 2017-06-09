//
//  DateUtils.swift
//  tickadate
//
//  Created by Romain Bessuges-Meusy on 13/05/2017.
//  Copyright © 2017 Agilitation. All rights reserved.
//

import UIKit


struct DateRange {
  var from:Date!
  var to:Date!
  
  init(from:Date!, to:Date!) {
    self.from = from
    self.to = to
  }
  
  init(rangeAround date:Date, component:Calendar.Component, value:Int) {
    
    let cal = Calendar.current
    
    let today:Date! = cal.startOfDay(for: date);
    var dateComponents:DateComponents! = DateComponents()
    // WHY IN HELL do I have to do that
    dateComponents.weekday = cal.firstWeekday < 2 ? 7 : cal.firstWeekday - 1
    
    self.from = cal.nextDate(
      after: cal.date(byAdding: component, value: -value, to: today)!,
      matching: dateComponents, matchingPolicy: .nextTime, direction: .backward
    )
    
    self.to = cal.nextDate(
      after: cal.date(byAdding: component, value: value, to: today)!,
      matching: dateComponents, matchingPolicy: .nextTime, direction: .forward
    )
  }
}

struct CalendarDate {
  var date:Date!
  var formatted:String!
  var isToday:Bool! = false
  var isCurrentMonth:Bool! = false
  var monthAndYear:DateComponents!
}

class DateUtils: NSObject {
  
  static func getOrderedWeekdays() -> [String] {
    return Calendar.current.shortWeekdaySymbols
  }
  
  static func dateWithFixedTime(fromDate date:Date, withFixedTimeInMinutes minutes:NSNumber) -> Date{
    var comps = Calendar.current.dateComponents([.day, .month, .year], from: date)
    comps.minute = Int(minutes)
    return Calendar.current.date(from: comps)!
  }
  
  static func generateDates(_ dr:DateRange) -> [CalendarDate] {
    var dates:[CalendarDate] = []
    var tempDate:Date! = dr.from
    let calendar:Calendar! = Calendar.current
    let formatter:DateFormatter! = DateFormatter()
    let numberOfDays:Int! =  calendar.dateComponents([.day], from: dr.from, to: dr.to).day
    let today:Date! = Date()
    let todayComps = calendar.dateComponents([.year, .month], from: today)
    
    formatter.dateFormat = "dd"
    
    for _ in 1...numberOfDays{
      tempDate =  calendar.date(byAdding: .day, value: 1, to: tempDate)
      let tempDateComps = calendar.dateComponents([.year, .month], from: tempDate)
      
      let calDate = CalendarDate(
        date: tempDate,
        formatted: formatter.string(from: tempDate),
        isToday: calendar.isDateInToday(tempDate),
        isCurrentMonth: tempDateComps == todayComps,
        monthAndYear: calendar.dateComponents([.month, .year], from: tempDate)
      )
      
      dates.append(calDate)
    }
    return dates;
  }
  
}
