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


class ViewController: UIViewController, EventTypesControllerDelegate, CalendarControllerDelegate {
  
  @IBOutlet weak var quickSelectionButton: UIButton!
  @IBOutlet weak var visibleMonthLabel: UILabel!
  @IBOutlet weak var selectedEventTypeButton: UIButton!
  @IBOutlet weak var calendarViewContainer: UIView!
  @IBOutlet weak var weekDayHeader: WeekDayHeader!
  @IBOutlet weak var visibleMonthView: BorderedView!
  @IBOutlet weak var toolbarView: UIView!
  @IBOutlet weak var tickButton: TickButton!
  @IBOutlet weak var quickAddButton: QuickAddButton!
  @IBOutlet weak var daySummaryButton: DaySummaryButton!
  
  @IBAction func onTick(_ sender: Any) {
    
    let eventCreated:(Event) -> () = { (event) in
      self.dataController.fetchEvents(completion: { (events) in
        self.calendarController.events = events
        self.calendarController.reloadCell(forDate: event.date! as Date)
      })
    }
    
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
                                        withDetails: alert.textFields![0].text!,
                                        completion: eventCreated)
      }))
      
      self.present(alert, animated: true, completion: nil)
      
    } else {
      dataController.createEvent(ofType: selectedEventType!, onDate: selectedDate!, withDetails: nil, completion: eventCreated)
    }
  }
  
  @IBAction func scrollToToday(_ sender: UIBarButtonItem) {
    calendarController.scrollToToday()
  }
  
  
  var appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
  var calendarController:CalendarController!
  var eventTypesController:EventTypesController!
  //var eventsOfDayController:EventsOfDayTableViewController!
  
  var selectedEventType:EventType!
  var selectedDate:Date! = Date()
  var dataController:DataController = DataController()
  var visibleMonthFormatter:DateFormatter! = DateFormatter()
  
  var nc:NotificationCenter = NotificationCenter.default
  
  override func viewDidLoad() {
    super.viewDidLoad()
    visibleMonthFormatter.dateFormat = "MMMM YYYY"
    calendarController.select(date: self.selectedDate)
    
    nc.addObserver(forName: NSNotification.Name("event.delete"), object: nil, queue: nil) { (notif) in
      let event:Event = notif.object as! Event
      self.dataController.fetchEvents(completion: { (events) in
        self.calendarController.events = events
        self.calendarController.reloadCell(forDate: event.date! as Date)
      })
    }
  }
  
  func reloadEventTypes () {
    self.eventTypesController.reloadData()
  }
  
  @IBAction func unwindToViewController(withSegue:UIStoryboardSegue) {
    reloadEventTypes()
    calendarController.collectionView?.reloadData()
  }
  
  @IBAction func toggleQuickDatePicker(_ sender: Any) {
    let asc = RelativeDateAlertController()
    asc.handler = { (action:UIAlertAction, date:Date) in
      self.calendarController.select(date: date)
    }
    self.present(asc, animated: true, completion: nil)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "calendarEmbedView" {
      self.calendarController = segue.destination as! CalendarController
      self.calendarController.delegate = self
    }
    
    if segue.identifier == "eventTypesEmbedView" {
      self.eventTypesController = segue.destination as! EventTypesController
      self.eventTypesController.delegate = self
    }
    
    if segue.identifier == "showEventsOfDay" {
      let navCont = segue.destination as! UINavigationController
      let eventsOfDayController = navCont.topViewController as! EventsOfDayTableViewController
       eventsOfDayController.setDay(self.selectedDate)
    }
    
    if segue.identifier == "showEventTypeStats" {
      let nav:UINavigationController =  segue.destination as! UINavigationController
      let statsVC:StatsTableViewController = nav.viewControllers.first as! StatsTableViewController
      statsVC.eventType = self.selectedEventType
    }

  }
  
  // todo in ext
  
  func eventTypesController(_ eventTypesController: EventTypesController, didSelectEventType eventType: EventType) {
    let etColor:UIColor! = DynamicColor(hexString: eventType.color ?? "000000")
    selectedEventType = eventType
    selectedEventTypeButton.setTitle(eventType.name!, for: .normal)
    selectedEventTypeButton.tintColor = etColor.darkened(amount: 0.3)
   // toolbarView.backgroundColor = etColor.darkened(amount: 0.1)
   // visibleMonthView.backgroundColor = etColor.lighter(amount:  0.2)
   // visibleMonthView.borderColor = etColor(amount:  0.2)
    weekDayHeader.backgroundColor = etColor.darkened(amount: 0.1)
    weekDayHeader.borderColor = etColor.darkened(amount: 0.15)
    weekDayHeader.labels.forEach { (label) in
      label.layer.shadowColor = etColor.darkened(amount: 0.2).cgColor
      label.setNeedsDisplay()
    }
    calendarController.selectedEventType = eventType
    
    quickAddButton.color = etColor.isLight() ? etColor.darkened() : etColor
    tickButton.color = etColor.isLight() ? etColor.darkened() : etColor
    daySummaryButton.color = etColor.isLight() ? etColor.darkened() : etColor
    
  }
  
  func calendarController(_ calendarController: CalendarController, didSelectDate date: Date) {
    selectedDate = date
  }
  
  func calendarController(_ calendarController: CalendarController, setVisibleMonth monthAndYear: DateComponents) {
    visibleMonthLabel.text = visibleMonthFormatter.string(from: Calendar.current.date(from: monthAndYear)!)
  }
}


