//
//  NewEventTypeFormViewController.swift
//  tickadate
//
//  Created by Romain Bessuges-Meusy on 13/05/2017.
//  Copyright © 2017 Agilitation. All rights reserved.
//

import UIKit
import Eureka
import EventKit

protocol EventTypeFormViewDelegate {
  func eventTypeFormView(_ controller: EventTypeFormViewController, finishedEditingOf eventType: EventType)
}

class EventTypeFormViewController: FormViewController {
  
  var eventType:EventType?
  var dc:DataController! = DataController()
  var delegate:EventTypeFormViewDelegate?
  
  override func viewWillDisappear(_ animated: Bool) {
      self.delegate?.eventTypeFormView(self, finishedEditingOf: self.eventType!)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let eventStore : EKEventStore = EKEventStore()
    
    form +++ Section("Base")
      <<< TextRow("name"){
        $0.title = "Name"
        $0.placeholder = "Enter text here"
        $0.value = eventType?.name ?? ""
        }.onChange({ (row) in
          self.eventType?.name = row.value
          self.dc.save()
        })
      <<< PushRow<String>("color"){
        $0.title = "Color"
        $0.options = ["000000", "00FFFF", "00FF00"]
        $0.value = eventType?.color ?? "000000"
        }.onChange({ (row) in
          self.eventType?.color = row.value
          self.dc.save()
        })
      <<< SwitchRow("promptForDetails"){
        $0.title = "Prompt for details"
        $0.value = eventType?.promptForDetails ?? false
        }.onChange({ (row) in
          self.eventType!.promptForDetails = row.value ?? false
          self.dc.save()
        })
      <<< SwitchRow("isAllDay"){
        $0.title = "All day"
        $0.value = eventType?.isAllDay ?? false
        }.onChange({ (row) in
          self.eventType!.isAllDay = row.value ?? false
          self.dc.save()
        })
      
      +++ Section("Default values")
      <<< TextRow("defaultValues.title"){
        $0.title = "Title"
        $0.placeholder = "Same as type name"
        $0.value = eventType?.defaultValues?.title ?? nil
        }.onChange({ (row) in
          self.dc.getDefaultValues(forEventType: self.eventType!).title = row.value ?? ""
          self.dc.save()
        })
      <<< TimeRow("defaultValues.time") {
        $0.hidden = Condition.function(["isAllDay"], { form in
          return ((form.rowBy(tag: "isAllDay") as? SwitchRow)?.value ?? false)
        })
        $0.title = "Start Time"
        if let time = eventType?.defaultValues?.time {
          var comps:DateComponents = DateComponents()
          comps.minute = Int(time)
          $0.value = Calendar.current.date(from: comps)
        }
        }.onChange({ (row) in
          let comps:DateComponents = Calendar.current.dateComponents([.hour, .minute], from: row.value!)
          self.dc.getDefaultValues(forEventType: self.eventType!).time = Int16(comps.hour! * 60 + comps.minute!)
          self.dc.save()
        })
      <<< IntRow("defaultValues.duration"){
        $0.hidden = Condition.function(["isAllDay"], { form in
          return ((form.rowBy(tag: "isAllDay") as? SwitchRow)?.value ?? false)
        })
        $0.title = "Duration"
        $0.placeholder = "60"
        if let duration = eventType?.defaultValues?.duration {
          $0.value = Int(duration)
        }
        }.onChange({ ( row) in
          self.dc.getDefaultValues(forEventType: self.eventType!).duration = Int16(row.value ?? 0)
          self.dc.save()
        })
      <<< TextAreaRow("defaultValues.notes") {
        $0.title = "Notes"
        $0.placeholder = "Notes"
        $0.value = eventType?.defaultValues?.notes ?? nil
        }.onChange({ ( row) in
          self.dc.getDefaultValues(forEventType: self.eventType!).notes = row.value ?? ""
          self.dc.save()
        })
      
      +++ Section("Publish")
      <<< SwitchRow("shouldCreateEventInCalendar"){
        $0.title = "Create event in calendar"
        $0.value = eventType?.shouldCreateEventInCalendar ?? false
        }.onChange({ (row) in
          let shouldCreateEventInCalendar:Bool = row.value ?? false
          
          if shouldCreateEventInCalendar {
            eventStore.requestAccess(to: .event) { (granted, error) in
              if granted {
                let calendarRow = self.form.rowBy(tag: "calendar") as! PushRow<EKCalendar>
                calendarRow.options = self.calendarsAllowingContentModifications()
                calendarRow.value = eventStore.defaultCalendarForNewEvents
                self.eventType!.shouldCreateEventInCalendar = shouldCreateEventInCalendar
                self.dc.save()
              } else {
                row.value = false
              }
            }
          }
        })
      <<< PushRow<EKCalendar>("calendar"){
        
        $0.hidden = Condition.function(["shouldCreateEventInCalendar"], { form in
          return !((form.rowBy(tag: "shouldCreateEventInCalendar") as? SwitchRow)?.value ?? false)
        })
        
        $0.title = "Calendars"
        $0.options = calendarsAllowingContentModifications()
      
        if let selectedCalendar = eventType?.ekCalendarIdentifier {
          $0.value = eventStore.calendar(withIdentifier: selectedCalendar)
        } else {
          $0.value = eventStore.defaultCalendarForNewEvents
        }
        
        $0.displayValueFor = { calendar in
          return calendar?.title ?? "Null"
        }
        }.onChange({ (row) in
          self.eventType!.ekCalendarIdentifier = row.value?.calendarIdentifier
          self.dc.save()
        })
    
//  Would not work... but still
//  http://stackoverflow.com/questions/30627694/modifying-ekparticipants-attendees-in-eventkit-like-sunrise
//    +++ MultivaluedSection(
//      multivaluedOptions: [.Reorder, .Insert, .Delete],
//      header: "Attendees",
//      footer: "Insert attendee email"
//    ) {
//        $0.hidden = Condition.function(["shouldCreateEventInCalendar"], { form in
//          return !((form.rowBy(tag: "shouldCreateEventInCalendar") as? SwitchRow)?.value ?? false)
//        })
//        
//        $0.addButtonProvider = { section in
//          return ButtonRow(){
//            $0.title = "Add a new attendee"
//          }
//        }
//        $0.multivaluedRowToInsertAt = { index in
//          return EmailRow() {
//            $0.placeholder = "Attendee Email"
//          }
//        }
//        $0 <<< EmailRow() {
//          $0.placeholder = "Attendee Email"
//        }
//    }
  }
  
  func calendarsAllowingContentModifications() -> [EKCalendar] {
    return EKEventStore().calendars(for: .event).filter({ (calendar) -> Bool in
      return calendar.allowsContentModifications
    })
  }
}
