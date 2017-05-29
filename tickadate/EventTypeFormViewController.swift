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
  
  var eventType:EventType?
  var dc:DataController! = DataController()
  var delegate:EventTypeFormViewDelegate?
  var colors:[ColorPaletteItem] = []
  
  override func viewWillDisappear(_ animated: Bool) {
    self.delegate?.eventTypeFormView(self, finishedEditingOf: self.eventType!)
  }
  
  func createColorPalette(){
    colors = []
    if let fileUrl = Bundle.main.url(forResource: "CrayolaBright", withExtension: "plist"),
      let data = try? Data(contentsOf: fileUrl) {
      if let result = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [Dictionary<String, String>] {
        colors = result!.map({ (color) -> ColorPaletteItem in
          return ColorPaletteItem(hexString: color["hex"]!, label: color["label"]!)
        })
      }
    }
  }
  
  func getColorPaletteItem(fromHexString hexString:String) -> ColorPaletteItem? {
    var ret:ColorPaletteItem?
    for color in colors {
      if color.color.toHexString() == hexString {
        ret = color
      }
    }
    return ret
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    createColorPalette()
    let eventStore : EKEventStore = EKEventStore()
    let locationManager = CLLocationManager()
    
    
    form +++ Section("Base")
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
        $0.options = self.colors
        $0.value = getColorPaletteItem(fromHexString: self.eventType?.color ?? "000000")
        }.onChange({ (row) in
          if let color = row.value?.color {
            self.eventType?.color = color.toHexString()
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
      <<< SwitchRow("shoudAskForLocation"){
        $0.title = NSLocalizedString("eventType/form/base/shouldAskForLocation/label", comment: "Label for the 'request location' Switch row")
        $0.value = eventType?.shouldAskForLocation ?? false
        }.onChange({ (row) in
          if(row.value ?? false){
            locationManager.requestWhenInUseAuthorization()
          }
          self.eventType!.shouldAskForLocation = row.value ?? false
          self.dc.save()
        })
      
      +++ Section("Default values")
      <<< TextRow("defaultValues.title"){
        $0.title = NSLocalizedString("eventType/form/defaultValues/title/label", comment: "Label for the 'DefaultValues / Title' textfield row")
        $0.placeholder = NSLocalizedString("eventType/form/defaultValues/title/placeholder",
                                           comment: "Placeholder for the 'DefaultValues / Title' textfield row")
        $0.value = eventType?.defaultValues?.title ?? nil
        }.onChange({ (row) in
          self.dc.getDefaultValues(forEventType: self.eventType!).title = row.value ?? ""
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
          self.dc.getDefaultValues(forEventType: self.eventType!).time = Int16(comps.hour! * 60 + comps.minute!)
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
          self.dc.getDefaultValues(forEventType: self.eventType!).duration = Int16(row.value ?? 0)
          self.dc.save()
        })
      <<< TextAreaRow("defaultValues.notes") {
        $0.title = NSLocalizedString("eventType/form/defaultValues/notes/label", comment: "Label for the 'DefaultValues / Notes' textarea row")
        $0.placeholder = NSLocalizedString("eventType/form/defaultValues/notes/placeholder", comment: "Placeholder for the 'DefaultValues / Notes' textarea row")
        $0.value = eventType?.defaultValues?.notes ?? nil
        }.onChange({ ( row) in
          self.dc.getDefaultValues(forEventType: self.eventType!).notes = row.value ?? ""
          self.dc.save()
        })
      
      +++ Section("Publish")
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
