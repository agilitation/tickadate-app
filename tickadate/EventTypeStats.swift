//
//  EventTypeStats.swift
//  tickadate
//
//  Created by Romain Bessuges-Meusy on 22/05/2017.
//  Copyright © 2017 Agilitation. All rights reserved.
//

import UIKit

struct EventTypeStat {
  var min:NSNumber
  var max:NSNumber
  var avg:NSNumber
  
  init(serie:[Float]) {
    self.min = NSNumber(value: serie.min()!)
    self.max = NSNumber(value: serie.max()!)
    
    var sum:Float = 0
    for val in serie {
      sum.add(val)
    }
    self.avg =  NSNumber(value: sum.divided(by: Float(serie.count)))
  }
}

class EventTypeStats: NSObject {
  var eventType:EventType!
  var data:DataController!
  
  var timesPerDay:EventTypeStat?
  var prevDate:Date?
  var nextDate:Date?
  
  
  init(_ eventType:EventType) {
    super.init()
    self.eventType = eventType
    data = DataController()
  }
  
  func generate(completion: @escaping ()->()){
    
    
    DispatchQueue.global().async {
      let cal:Calendar = Calendar.current
      let events:[Event] = self.data.fetchEventsSync(forEventType: self.eventType)
      var byDay:Dictionary<DateComponents,[Event]> = Dictionary()
      var byWeek:Dictionary<DateComponents,[Event]> = Dictionary()
      var isDatePast:Bool = false
      let now:Date = Date()
      
      for e in events {
        
        if e.date! as Date > now && !isDatePast {
          self.nextDate = e.date! as Date
          isDatePast = true
        }
        
        if !isDatePast {
          
          self.prevDate = e.date! as Date
          print(self.prevDate!)
        }
        
        let day = cal.dateComponents([.day, .month, .year], from: e.date! as Date)
        let week = cal.dateComponents([.weekOfYear], from: e.date! as Date)
        
        if byDay[day] == nil {
          byDay[day] = []
        }
        byDay[day]?.append(e)
        
        if byWeek[week] == nil {
          byWeek[week] = []
        }
        byWeek[week]?.append(e)
        
      }
      
      var countsByDay:[Float] = []
      byDay.forEach({ (key, events) in
        countsByDay.append(Float(events.count))
      })
      
      self.timesPerDay = EventTypeStat(serie: countsByDay)
      completion()
    }
  }
}
