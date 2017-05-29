//
//  EventTypeStats.swift
//  tickadate
//
//  Created by Romain Bessuges-Meusy on 22/05/2017.
//  Copyright © 2017 Agilitation. All rights reserved.
//

import UIKit

struct SerieStat {
  var min:NSNumber = 0
  var max:NSNumber = 0
  var avg:NSNumber = 0
  
  init(serie:[Float]) {
    self.min = NSNumber(value: serie.min() ?? 0)
    self.max = NSNumber(value: serie.max() ?? 0)
    
    if serie.count > 0 {
      var sum:Float = 0
      for val in serie {
        sum.add(val)
      }
      self.avg =  NSNumber(value: sum.divided(by: Float(serie.count)))
    }
  }
}

class EventTypeStats: NSObject {
  var eventType:EventType!
  var data:DataController!
  
  var counts:[String : Int] = [:]
  var countsSeries:[String : SerieStat] =  [:]
  var countsProportions:[String: [DateComponents : Float]] = [:]
  
  var prevDate:Date?
  var nextDate:Date?
  
  var groups:[String : Set<Calendar.Component>] = [
    "day": [.day, .month, .year],
    "week": [.weekOfYear, .year],
    "weekday": [.weekday],
    "hour": [.hour]
  ]
  
  init(_ eventType:EventType) {
    super.init()
    self.eventType = eventType
    data = DataController()
  }

  
  func generate(completion: @escaping ()->()){
    
    
    DispatchQueue.global().async {
      let cal:Calendar = Calendar.current
      let events:[Event] = self.data.fetchEventsSync(forEventType: self.eventType)
      var counts:[String:[DateComponents : Int]] = [:]
      var isDatePast:Bool = false
      let now:Date = Date()
      
      self.groups.forEach({ (label, comps) in
        counts[label] = [:]
      })
      
      for e in events {
        
        if e.date! as Date > now && !isDatePast {
          self.nextDate = e.date! as Date
          isDatePast = true
        }
        
        if !isDatePast {
          self.prevDate = e.date! as Date
        }
        
        self.groups.forEach({ (label, comps) in
          let dc:DateComponents = cal.dateComponents(comps, from: e.date! as Date)
          
          if counts[label]![dc] == nil {
            counts[label]![dc] = 1
          } else {
            counts[label]![dc]! += 1
          }
        })
      }
    
      counts.forEach({ (label, group) in
        var floats:[Float] = []
        self.countsProportions[label] = [:]
        group.forEach({ (key, count) in
          floats.append(Float(count))
          self.countsProportions[label]?.updateValue(Float(count).divided(by: Float(events.count))
, forKey: key)
        })
        self.countsSeries.updateValue(SerieStat(serie: floats), forKey: label)
      })
      
      
      print(self.countsSeries)
    }
  }
}
