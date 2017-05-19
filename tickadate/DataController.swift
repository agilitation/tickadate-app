//
//  DataController.swift
//  tickadate
//
//  Created by Romain Bessuges-Meusy on 11/05/2017.
//  Copyright © 2017 Agilitation. All rights reserved.
//

import UIKit
import CoreData
import EventKit
import Contacts

extension String {
  func index(of target: String) -> Int? {
    if let range = self.range(of: target) {
      return characters.distance(from: startIndex, to: range.lowerBound)
    } else {
      return nil
    }
  }
  
  func lastIndex(of target: String) -> Int? {
    if let range = self.range(of: target, options: .backwards) {
      return characters.distance(from: startIndex, to: range.lowerBound)
    } else {
      return nil
    }
  }
}

class DataController: NSObject, CLLocationManagerDelegate {
  
  
  var context:NSManagedObjectContext!
  
  override init() {
    super.init()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    context = appDelegate.persistentContainer.viewContext
  }
  
  func deleteAllEventTypes() {
    let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "EventType")
    let request = NSBatchDeleteRequest(fetchRequest: fetch)
    try! context.execute(request)
  }
  
  func deleteAllEvents() {
    let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Event")
    let request = NSBatchDeleteRequest(fetchRequest: fetch)
    try! context.execute(request)
  }
  
  func fetchActiveEventTypes() -> [EventType] {
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "EventType")
    let predicate = NSPredicate(format: "isActive == TRUE")
    
    fetchRequest.predicate = predicate
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
    
    do {
      let results = try context.fetch(fetchRequest) as! [EventType]
      return results
      
    } catch let error as NSError {
      print(error.userInfo)
    }
    
    return []
  }
  
  func fetchEvents() -> [Event] {
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Event")
    //        let predicate = NSPredicate(format: "type.isActive == TRUE")
    //        fetchRequest.predicate = predicate
    do {
      let results = try context.fetch(fetchRequest) as! [Event]
      return results
    } catch let error as NSError {
      print(error.userInfo)
    }
    return []
  }
  
  func createEvent(ofType type: EventType, onDate date: Date, withDetails details: String?) {
    let event = Event(context: context)
    
    event.type = type
    
    
    if let defaultValues = type.defaultValues {
      event.date = Calendar.current.date(
        byAdding: .minute,
        value: Int(defaultValues.time),
        to: date
        )! as NSDate
      event.duration = Int16(defaultValues.duration)
      
    } else {
      let todayComps = Calendar.current.dateComponents([.hour, .minute], from: Date())
      event.date = Calendar.current.date(
        byAdding: .minute,
        value: Int(todayComps.hour! * 60 + todayComps.minute!),
        to: date
        )! as NSDate
      event.duration = 60
    }
    
    event.isAllDay = type.isAllDay
    event.details = details
    
    func finishCreationOfEvent(){
      context.insert(event)
      save()
      
      print("Event created", event)
      
      if type.shouldCreateEventInCalendar && type.ekCalendarIdentifier != nil {
        createCalendarEvent(fromEvent: event)
      }
    }
    
    if(type.shouldAskForLocation){
      self.getLocation(forEvent: event, completionHandler: finishCreationOfEvent)
    } else {
      finishCreationOfEvent()
    }
  }
  
  func getLocation(forEvent event:Event, completionHandler: @escaping () -> Void) {
    let manager = CLLocationManager()
    manager.delegate = self
    manager.requestLocation()
    
    if let location = manager.location {
      
      event.hasLocation = true
      event.locationLatitude = location.coordinate.latitude as Double
      event.locationLongitude =  location.coordinate.longitude as Double
      event.locationAltitude = location.altitude as Double
      event.locationTimestamp = location.timestamp as NSDate
      event.locationVerticalAccuracy = location.verticalAccuracy as Double
      event.locationHorizontalAccuracy = location.horizontalAccuracy as Double
      
      CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
        if error != nil {
          print(error!)
          completionHandler()
          return
        }
        
        if placemarks!.count > 0 {
          var addressString = String(describing:placemarks![0])
          event.locationAddress = addressString.substring(to: addressString.characters.index(of: "@") ?? addressString.endIndex)
        }
        
        completionHandler()
      })
    } else {
      completionHandler()
    }
  }
  
  func createCalendarEvent(fromEvent event:Event){
    let eventStore : EKEventStore = EKEventStore()
    let type:EventType = event.type!
    
    eventStore.requestAccess(to: .event) { (granted, error) in
      if (granted) && (error == nil) {
        
        let calendarEvent:EKEvent = EKEvent(eventStore: eventStore)
        if let calendar = eventStore.calendar(withIdentifier: type.ekCalendarIdentifier!) {
          calendarEvent.calendar = calendar
        } else {
          return
        }
        
        
        calendarEvent.title = event.title ?? type.name!
        if(event.details != nil){
          calendarEvent.title.append(": ")
          calendarEvent.title.append(event.details!)
        }
        
        if(event.hasLocation){
          calendarEvent.structuredLocation = EKStructuredLocation(title: event.locationAddress ?? "")
          calendarEvent.structuredLocation?.geoLocation = CLLocation(
            coordinate: CLLocationCoordinate2D(),
            altitude: event.locationAltitude as CLLocationDistance,
            horizontalAccuracy: event.locationHorizontalAccuracy as CLLocationAccuracy,
            verticalAccuracy: event.locationVerticalAccuracy as CLLocationAccuracy,
            timestamp: event.locationTimestamp! as Date
          )
          
        }
        calendarEvent.startDate = event.date! as Date
        calendarEvent.endDate = Calendar.current.date(
          byAdding: .minute,
          value: Int(event.duration),
          to: event.date! as Date)!
        calendarEvent.notes = event.notes ?? ""
        calendarEvent.isAllDay = type.isAllDay
        
        
        do {
          try eventStore.save(calendarEvent, span: .thisEvent)
        } catch let error as NSError {
          print("failed to save event with error : \(error)")
        }
        
      }
    }
  }
  func createEventType() -> EventType {
    let eventType = EventType(context: context)
    eventType.isActive = true
    eventType.color = "000000"
    context.insert(eventType)
    return eventType
  }
  
  func getDefaultValues(forEventType et: EventType) -> DefaultValues {
    if et.defaultValues == nil {
      let dv:DefaultValues! = DefaultValues(context: context)
      context.insert(dv)
      et.defaultValues = dv
      self.save()
    }
    return et.defaultValues!
  }
  
  func save(activeEventTypes: [EventType]) {
    for existingActiveEventsType in fetchActiveEventTypes() {
      if activeEventTypes.contains(existingActiveEventsType){
        existingActiveEventsType.order = Int16(activeEventTypes.index(of: existingActiveEventsType)!)
      } else {
        existingActiveEventsType.isActive = false
      }
    }
    self.save()
  }
  
  func save(){
    if context.hasChanges {
      do {
        try context.save()
      } catch {
        let nserror = error as NSError
        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        
      }
    }
  }
  
  func bootstrapEventTypes() {
    let names = ["Dinner at the restaurant", "Sport training", "Family meeting"]
    let colors = ["50E3C2", "9012FE", "F0A91A"]
    var eventTypes:[EventType] = []
    for i in 0..<names.count {
      let et = EventType(context: context)
      et.name = names[i]
      et.color = colors[i]
      et.isActive = true
      context.insert(et)
      eventTypes.append(et)
    }
    
    save()
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    
  }
  
  
}
