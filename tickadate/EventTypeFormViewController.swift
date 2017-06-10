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
import DynamicColor
protocol EventTypeFormViewDelegate {
  func eventTypeFormView(_ controller: EventTypeFormViewController, finishedEditingOf eventType: EventType)
}

class EventTypeFormViewController: FormViewController {
  
  var eventType:EventType? {
    didSet {
      self.title = eventType?.name
    }
  }
  var isNewEventType:Bool = false
  var dc:DataController! = DataController()
  var delegate:EventTypeFormViewDelegate?
  var wasChanged:Bool {
    get {
      var val:Bool = false
      
      form.allRows.forEach({ (row) in
        if row.wasChanged {
          val = true
        }
      })
      
      return val
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    self.delegate?.eventTypeFormView(self, finishedEditingOf: self.eventType!)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    print("prepare", segue)
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let eventStore : EKEventStore = EKEventStore()
    //    let locationManager = CLLocationManager()
    
    
    
    form +++ Section()
      <<< TextRow("name"){
        $0.title = NSLocalizedString("eventType/form/base/name/label", comment: "Label for the event type name textfield row")
        $0.placeholder = NSLocalizedString("eventType/form/base/name/placeholder", comment: "Placeholder inviting user to name its event type")
        $0.value = eventType?.name ?? ""
        }.onChange({ (row) in
          self.eventType?.name = row.value
          self.dc.save()
        })
      <<< ColorPickerPushRow("color"){
        $0.title = NSLocalizedString("eventType/form/base/color/label", comment: "Label for the event type color picker row")
        $0.value = ColorPaletteItem(hexString: self.eventType?.color ?? "000000", label: self.eventType?.colorName ?? NSLocalizedString("ColorPickerPushRow/cell/noColor", comment: "Detail text in ColorPickerPushRow cell when there's no color matching the saved version"))
        }.onChange({ (row) in
          if let color = row.value?.color {
            self.eventType?.color = color.toHexString()
            self.eventType?.colorName = row.value?.label
            self.dc.save()
          }
        })
      <<< SwitchRow("promptForDetails"){
        $0.title = NSLocalizedString("eventType/form/base/promptForDetails/label", comment: "Label for the 'prompt for details' Switch row")
        $0.value = eventType?.promptForDetails ?? false
        }.onChange({ (row) in
          self.eventType!.promptForDetails = row.value ?? false
          self.dc.save()
        })
      <<< SwitchRow("isAllDay"){
        $0.title = NSLocalizedString("eventType/form/base/isAllDay/label", comment: "Label for the 'All day' Switch row")
        $0.value = eventType?.isAllDay ?? false
        }.onChange({ (row) in
          self.eventType!.isAllDay = row.value ?? false
          self.dc.save()
        })
      <<< TimeRow("defaultValues.time") {
        $0.hidden = Condition.function(["isAllDay"], { form in
          return ((form.rowBy(tag: "isAllDay") as? SwitchRow)?.value ?? false)
        })
        $0.title = NSLocalizedString("eventType/form/defaultValues/time/label", comment: "Label for the 'DefaultValues / Time' time row")
        if let time = eventType?.defaultValues?.time {
          var comps:DateComponents = DateComponents()
          comps.minute = Int(time)
          $0.value = Calendar.current.date(from: comps)
        }
        }.onChange({ (row) in
          let comps:DateComponents = Calendar.current.dateComponents([.hour, .minute], from: row.value!)
          self.dc.getDefaultValues(forEventType: self.eventType!).time = Int16(comps.hour! * 60 + comps.minute!) as NSNumber
          self.dc.save()
        })
      <<< IntRow("defaultValues.duration"){
        $0.hidden = Condition.function(["isAllDay"], { form in
          return ((form.rowBy(tag: "isAllDay") as? SwitchRow)?.value ?? false)
        })
        $0.title = NSLocalizedString("eventType/form/defaultValues/duration/label", comment: "Label for the 'DefaultValues / Duration' int row")
        $0.placeholder = NSLocalizedString("eventType/form/defaultValues/duration/placeholder", comment: "Placeholder for the 'DefaultValues / Duration' int row")
        if let duration = eventType?.defaultValues?.duration {
          $0.value = Int(duration)
        }
        }.onChange({ ( row) in
          self.dc.getDefaultValues(forEventType: self.eventType!).duration = NSNumber(value: row.value ?? 0)
          self.dc.save()
        })
      
      /*
       <<< SwitchRow("shoudAskForLocation"){
       $0.title = NSLocalizedString("eventType/form/base/shouldAskForLocation/label", comment: "Label for the 'request location' Switch row")
       $0.value = eventType?.shouldAskForLocation ?? false
       }.onChange({ (row) in
       if(row.value ?? false){
       locationManager.requestWhenInUseAuthorization()
       }
       self.eventType!.shouldAskForLocation = row.value ?? false
       self.dc.save()
       })*/
      
      
      +++ Section()
      
      
      <<< SwitchRow("shouldCreateEventInCalendar"){
        $0.title = NSLocalizedString("eventType/form/publish/shouldCreateEventInCalendar/label", comment: "Label for the 'Publish / shouldCreateEventInCalendar' switch row")
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
                
                if self.eventType!.ekCalendarIdentifier == nil {
                  self.eventType!.ekCalendarIdentifier = eventStore.defaultCalendarForNewEvents.calendarIdentifier
                }
                
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
        
        $0.title = NSLocalizedString("eventType/form/publish/calendar/label", comment: "Title for the 'Publish / calendar' push row")
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
      
      <<< TextRow("defaultValues.title"){
        
        $0.hidden = Condition.function(["shouldCreateEventInCalendar"], { form in
          return !((form.rowBy(tag: "shouldCreateEventInCalendar") as? SwitchRow)?.value ?? false)
        })
        
        $0.title = NSLocalizedString("eventType/form/defaultValues/title/label", comment: "Label for the 'DefaultValues / Title' textfield row")
        $0.placeholder = NSLocalizedString("eventType/form/defaultValues/title/placeholder",
                                           comment: "Placeholder for the 'DefaultValues / Title' textfield row")
        $0.value = eventType?.defaultValues?.title ?? nil
        }.onChange({ (row) in
          self.dc.getDefaultValues(forEventType: self.eventType!).title = row.value ?? ""
          self.dc.save()
        })
      
      <<< TextAreaRow("defaultValues.notes") {
        
        $0.hidden = Condition.function(["shouldCreateEventInCalendar"], { form in
          return !((form.rowBy(tag: "shouldCreateEventInCalendar") as? SwitchRow)?.value ?? false)
        })
        
        $0.title = NSLocalizedString("eventType/form/defaultValues/notes/label", comment: "Label for the 'DefaultValues / Notes' textarea row")
        $0.placeholder = NSLocalizedString("eventType/form/defaultValues/notes/placeholder", comment: "Placeholder for the 'DefaultValues / Notes' textarea row")
        $0.value = eventType?.defaultValues?.notes ?? nil
        }.onChange({ ( row) in
          self.dc.getDefaultValues(forEventType: self.eventType!).notes = row.value ?? ""
          self.dc.save()
        })
      
      +++ Section()
      
      
      <<< SwitchRow("shouldCreateReminder"){
        $0.title = NSLocalizedString("eventType/form/publish/shouldCreateReminder/label", comment: "Label for the 'Publish / shouldCreateReminder' switch row")
        $0.value = eventType?.shouldCreateReminder ?? false
        }.onChange({ (row) in
          let shouldCreateReminder:Bool = row.value ?? false
          
          if shouldCreateReminder {
            eventStore.requestAccess(to: .reminder) { (granted, error) in
              if granted {
                let calendarRow = self.form.rowBy(tag: "reminderList") as! PushRow<EKCalendar>
                calendarRow.options = self.reminderListsAllowingContentModifications()
                calendarRow.value = eventStore.defaultCalendarForNewReminders()
                self.eventType!.shouldCreateReminder = shouldCreateReminder
                if self.eventType!.reminderEkCalendarIdentifier == nil {
                  self.eventType!.reminderEkCalendarIdentifier = eventStore.defaultCalendarForNewReminders().calendarIdentifier
                }
                self.dc.save()
              } else {
                row.value = false
              }
            }
          }
        })
      
      <<< PushRow<EKCalendar>("reminderList"){
        //VISIBLE IF REMINDER CHECKED
        $0.hidden = Condition.function(["shouldCreateReminder"], { form in
          return !((form.rowBy(tag: "shouldCreateReminder") as? SwitchRow)?.value ?? false)
        })
        
        $0.title = NSLocalizedString("eventType/form/publish/reminderLists/label", comment: "Title for the 'Publish / reminderLists' push row")
        $0.options = self.reminderListsAllowingContentModifications()
        
        if let selectedCalendar = eventType?.reminderEkCalendarIdentifier {
          $0.value = eventStore.calendar(withIdentifier: selectedCalendar)
        } else {
          $0.value = eventStore.defaultCalendarForNewReminders()
        }
        
        $0.displayValueFor = { calendar in
          return calendar?.title ?? ""
        }
        }.onChange({ (row) in
          self.eventType!.reminderEkCalendarIdentifier = row.value?.calendarIdentifier
          self.dc.save()
        })
      
      
      <<< IntRow("reminder.days"){
        //VISIBLE IF REMINDER CHECKED
        $0.hidden = Condition.function(["shouldCreateReminder"], { form in
          return !((form.rowBy(tag: "shouldCreateReminder") as? SwitchRow)?.value ?? false)
        })
        
        $0.title = NSLocalizedString("eventType/form/reminder/days/label", comment: "Label for the 'createReminder/day' int row")
        $0.placeholder = NSLocalizedString("eventType/form/reminder/days/placeholder", comment: "Placeholder for the 'createReminder/day' int row")
        if let duration = eventType?.reminderDaysDelay {
          $0.value = Int(duration)
        }
        }.onChange({ ( row) in
          self.eventType?.reminderDaysDelay = Int16(row.value ?? 0)
          self.dc.save()
          
        })
      
      <<< TimeRow("reminder.time") {
        //VISIBLE IF REMINDER CHECKED
        $0.hidden = Condition.function(["shouldCreateReminder"], { form in
          return !((form.rowBy(tag: "shouldCreateReminder") as? SwitchRow)?.value ?? false)
        })
        
        $0.title = NSLocalizedString("eventType/form/reminder/time/label", comment: "Label for the 'reminder / Time' time row")
        $0.noValueDisplayText = NSLocalizedString("eventType/form/reminder/time/placeholder", comment: "Placeholder for the 'reminder / Time' time row")
        
        if let time = eventType?.reminderTime {
          var comps:DateComponents = DateComponents()
          comps.minute = Int(time)
          $0.value = Calendar.current.date(from: comps)
        }
        }.onChange({ (row) in
          let comps:DateComponents = Calendar.current.dateComponents([.hour, .minute], from: row.value!)
          self.eventType?.reminderTime = Int16(comps.hour! * 60 + comps.minute!) as NSNumber
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
  
  func reminderListsAllowingContentModifications() -> [EKCalendar] {
    
    return EKEventStore().calendars(for: .reminder).filter({ (calendar) -> Bool in
      return true
      //      return calendar.allowsContentModifications
    })
  }
}
