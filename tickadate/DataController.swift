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
  var nc:NotificationCenter!
  
  
  override init() {
    super.init()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    context = appDelegate.persistentContainer.viewContext
    // TODO Fix background thread / core data
    // https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/CoreData/InitializingtheCoreDataStack.html#//apple_ref/doc/uid/TP40001075-CH4-SW1
    
    nc = NotificationCenter.default
    
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
  
  
  func fetchEvents(completion: @escaping ([Event])->Void){
    var results:[Event] = []
    DispatchQueue.main.async {
      results = self.fetchEventsSync()
      completion(results)
    }
  }
  
  func fetchEvents(forDay date: Date, completion: @escaping([Event]) -> ()) {
    
    DispatchQueue.main.async {
      
      let cal = Calendar.current
      let comps = cal.dateComponents([.day, .month, .year], from: date)
      let start = cal.date(from: comps)!
      var add = DateComponents()
      add.day = 1
      let end = cal.date(byAdding: add, to: start)!
      
      let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Event")
      let predicate = NSPredicate(format: "(date >= %@) AND (date <= %@)", start as NSDate, end as NSDate)
      var results:[Event] = []
      fetchRequest.predicate = predicate
      fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
      
      do {
        results = try self.context.fetch(fetchRequest) as! [Event]
      } catch let error as NSError {
        print(error.userInfo)
      }
      
      completion(results)
    }
  }
  
  func fetchEventsSync(forEventType eventType:EventType) -> [Event]{
    
    
    
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Event")
    let predicate = NSPredicate(format: "type = %@", eventType)
    fetchRequest.predicate = predicate
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
    return try! self.context.fetch(fetchRequest) as! [Event]
  }
  
  func fetchEventsSync() -> [Event] {
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Event")
    return try! self.context.fetch(fetchRequest) as! [Event]
  }
  
  func createEvent(ofType type: EventType, onDate date: Date, withDetails details: String?, completion: @escaping (Event) -> ()) {
    
    
    var event:Event!
    
    let cal:Calendar = Calendar.current
    
    
    func finishCreationOfEvent(){
      context.insert(event)
      save()
      
      self.nc.post(name: Notification.Name("event.create"), object: event)
      completion(event)
      
      if type.shouldCreateEventInCalendar && type.ekCalendarIdentifier != nil {
        createCalendarEvent(fromEvent: event)
      }
      
      if type.shouldCreateReminder && type.reminderEkCalendarIdentifier != nil {
        createReminder(fromEvent: event)
      }
    }
    
    DispatchQueue.main.async {
      event = Event(context: self.context)
      event.type = type
      event.isAllDay = type.isAllDay
      event.details = details
      event.duration = 60 // todo const
      
      let dayComps = cal.dateComponents([.day, .month, .year], from: date)
      let dayDate = cal.date(from: dayComps)!
      let todayTimeComps = cal.dateComponents([.hour, .minute], from: Date())
      var minutes:Int = Int(todayTimeComps.hour! * 60 + todayTimeComps.minute!)
      
      if let defaultValues = type.defaultValues {
        
        if defaultValues.duration != nil {
          event.duration = Int16(defaultValues.duration!)
        }
        
        if defaultValues.time != nil {
          minutes = Int(defaultValues.time!)
        }
      }
      
      event.date = cal.date(
        byAdding: .minute,
        value: minutes,
        to: dayDate
        )! as NSDate
      
      
      if(type.shouldAskForLocation){
        DispatchQueue.main.async {
          self.getLocation(forEvent: event, completionHandler: finishCreationOfEvent)
        }
      } else {
        finishCreationOfEvent()
      }
    }
  }
  
  func getLocation(forEvent event:Event, completionHandler: @escaping () -> Void) {
    let locationManager:CLLocationManager! = CLLocationManager()
    locationManager.delegate = self
    locationManager.requestLocation()
    
    if let location = locationManager.location {
      
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
  
  
  
  func createReminder(fromEvent event:Event){
    let eventStore : EKEventStore = EKEventStore()
    let type:EventType = event.type!
    eventStore.requestAccess(to: .reminder) { (granted, error) in
      let reminder =  EKReminder(eventStore: eventStore)
      reminder.title = type.defaultValues?.title ?? type.name!
      
      if let calendar = eventStore.calendar(withIdentifier: type.reminderEkCalendarIdentifier!) {
        reminder.calendar = calendar
      } else {
        return
      }
      
      var dueDate = Calendar.current.date(byAdding: .day, value: Int(type.reminderDaysDelay) , to: event.date! as Date)!
      // todo -> it's flawed
      if type.reminderTime != nil{
        dueDate = DateUtils.dateWithFixedTime(fromDate: dueDate, withFixedTimeInMinutes: type.reminderTime!)
      }
      
      reminder.dueDateComponents = Calendar.current.dateComponents([.day, .month, .year, .hour, .minute], from: dueDate)
      do {
        try eventStore.save(reminder, commit: true)
        print("Successfully created the reminder")
      }catch{
        print("Error creating and saving new reminder : \(error)")
      }
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
  
  func deleteSync(event:Event){
    let date:Date = event.date! as Date
    context.delete(event)
    self.nc.post(name: Notification.Name("event.delete"), object: date)
    save()
  }
  
  /***
   EVENT TYPES
   ****/
  
  private func fetchActiveEventTypesSync() -> [EventType]{
    var results:[EventType] = []
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "EventType")
    let predicate = NSPredicate(format: "isActive == TRUE")
    
    fetchRequest.predicate = predicate
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
    
    do {
      results = try self.context.fetch(fetchRequest) as! [EventType]
    } catch let error as NSError {
      print(error.userInfo)
    }
    
    return results
  }
  
  func fetchActiveEventTypes(completion: @escaping ([EventType])->Void) {
    var results:[EventType] = []
    DispatchQueue.main.async {
      results = self.fetchActiveEventTypesSync()
      completion(results)
    }
  }
  
  func createEventType(completion: @escaping (EventType)->Void){
    
    DispatchQueue.main.async {
      let activeEventTypes = self.fetchActiveEventTypesSync()
      let eventType = EventType(context: self.context)
      eventType.isActive = true
      eventType.color = "000000"
      eventType.order = Int16(activeEventTypes.count)
      self.context.insert(eventType)
      
      self.nc.post(name: Notification.Name("eventType.create"), object: eventType)
      self.nc.post(name: Notification.Name("eventTypes.change"), object: nil)
      completion(eventType)
    }
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
  
  
  func save(activeEventTypes: [EventType], completion: @escaping () -> Void) {
    DispatchQueue.main.async {
      for existingActiveEventsType in self.fetchActiveEventTypesSync() {
        if activeEventTypes.contains(existingActiveEventsType){
          existingActiveEventsType.order = Int16(activeEventTypes.index(of: existingActiveEventsType)!)
        } else {
          existingActiveEventsType.isActive = false
        }
      }
      self.save()
      completion()
      self.nc.post(name: Notification.Name("eventTypes.change"), object: nil)
    }
  }
  
  func delete(eventType: EventType) {
    context.delete(eventType)
    save()
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
  
  func reset() {
    self.deleteAllEvents()
    self.deleteAllEventTypes()
    self.bootstrapEventTypes()
  }
  
  func bootstrapEventTypes() {
    
    func createEventTypeFromExample(desc:[String:String], position:Int){
      let et = EventType(context: context)
      et.name = desc["name"]
      et.color = desc["hex"]
      et.order = Int16(position)
      et.isActive = true
      context.insert(et)
    }
    
    let result = PListParser<[[String:String]]>().parseSync(filename: "EventTypeExamples")
    createEventTypeFromExample(desc: result![0], position: 0)
    createEventTypeFromExample(desc: result![1], position: 1)
    save()
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    
  }
  
  
}
