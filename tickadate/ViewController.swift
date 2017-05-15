//
//  ViewController.swift
//  tickadate
//
//  Created by Romain Bessuges-Meusy on 08/05/2017.
//  Copyright © 2017 Agilitation. All rights reserved.
//

import UIKit
import CoreData
import DynamicColor
import SwiftIconFont

class QuickDatePickerItem : NSObject {
  
  var date:Date!
  var label:String!
  var handler: ((UIAlertAction, Date) -> Swift.Void)?
  
  init(date:Date, label:String, handler:((UIAlertAction, Date) -> Swift.Void)? = nil) {
    super.init()
    self.date = date
    self.label = label
    self.handler = handler
  }
  
  func asAlertAction() -> UIAlertAction {
    return UIAlertAction(title: label, style: .default, handler: {
      self.handler?($0, self.date)
    })
  }
}

class ViewController: UIViewController, EventTypesControllerDelegate, CalendarControllerDelegate {
  
  @IBAction func onTick(_ sender: Any) {
    
    if selectedEventType!.promptForDetails {
      let alert = UIAlertController(
        title: "Event details",
        message: "Should display a prompt",
        preferredStyle: .alert
      )
      
      alert.addTextField(configurationHandler: { (textField) in
        textField.placeholder = "Enter event details"
      })
      
      alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
      alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (action) in
        self.dataController.createEvent(ofType: self.selectedEventType!,
                                        onDate: self.selectedDate!,
                                        withDetails: alert.textFields![0].text!)
        self.calendarController.events = self.dataController.fetchEvents()
      }))
      
      self.present(alert, animated: true, completion: nil)
      return
    }
    dataController.createEvent(ofType: selectedEventType!, onDate: selectedDate!, withDetails: nil)
    calendarController.events = dataController.fetchEvents()
  }
  
  @IBAction func scrollToToday(_ sender: UIBarButtonItem) {
    calendarController.scrollToToday()
  }
  
  @IBOutlet weak var quickSelectionButton: UIButton!
  @IBOutlet weak var visibleMonthLabel: UILabel!
  @IBOutlet weak var selectedEventTypeLabel: UILabel!
  @IBOutlet weak var calendarViewContainer: UIView!
  
  var appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
  
  var calendarController:CalendarController!
  var eventTypesController:EventTypesController!
  
  var selectedEventType:EventType!
  var selectedDate:Date!
  var dataController:DataController = DataController()
  var visibleMonthFormatter:DateFormatter! = DateFormatter()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    visibleMonthFormatter.dateFormat = "MMMM YYYY"
  }
  
  func reloadEventTypes () {
    self.eventTypesController.reloadData()
  }
  
//  @IBAction func unwindToViewController(segue:UIStoryboardSegue) { }
  
  @IBAction func unwindToViewController(withSegue:UIStoryboardSegue) { }
  
  @IBAction func toggleQuickDatePicker(_ sender: Any) {
    
    let asc = UIAlertController(
      title: nil,
      message: nil,
      preferredStyle: .actionSheet
    )
    
    let handler = { (action:UIAlertAction, date:Date) in
      self.calendarController.select(date: date)
    }
    
    asc.addAction(QuickDatePickerItem(date: RelativeDate.inAWeek(), label: "In a week", handler: handler).asAlertAction())
    asc.addAction(QuickDatePickerItem(date: RelativeDate.nextWeek(), label: "Next week", handler: handler).asAlertAction())
    asc.addAction(QuickDatePickerItem(date: RelativeDate.tomorrow(), label: "Tomorrow", handler: handler).asAlertAction())
    asc.addAction(QuickDatePickerItem(date: Date(), label: "Today", handler: handler).asAlertAction())
    asc.addAction(QuickDatePickerItem(date: RelativeDate.yesterday(), label: "Yesterday", handler: handler).asAlertAction())
    
    self.present(asc, animated: true, completion: nil)
  }
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "calendarEmbedView" {
      self.calendarController = segue.destination as! CalendarController
      self.calendarController.delegate = self
      self.calendarController.events = dataController.fetchEvents()
    }
    
    if segue.identifier == "eventTypesEmbedView" {
      self.eventTypesController = segue.destination as! EventTypesController
      self.eventTypesController.delegate = self
    }
  }
  
  func eventTypesController(_ eventTypesController: EventTypesController, didSelectEventType eventType: EventType) {
    selectedEventType = eventType
    selectedEventTypeLabel.text = eventType.name!
    selectedEventTypeLabel.textColor = DynamicColor(hexString: eventType.color ?? "000000")
    calendarController.selectedEventType = eventType
  }
  
  func calendarController(_ calendarController: CalendarController, didSelectDate date: Date) {
    selectedDate = date
  }
  
  func calendarController(_ calendarController: CalendarController, setVisibleMonth monthAndYear: DateComponents) {
    visibleMonthLabel.text = visibleMonthFormatter.string(from: Calendar.current.date(from: monthAndYear)!)
  }
}
