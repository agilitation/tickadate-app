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
      NSLog("event created %@", event)
    }
    
    if selectedEventType!.promptForDetails {
      let alert = UIAlertController(
        title: NSLocalizedString("eventDetailsPrompt/title", comment: "Title for the event details prompt"),
        message: NSLocalizedString("eventDetailsPrompt/message", comment: "Message for the event details prompt"),
        preferredStyle: .alert
      )
      
      alert.addTextField(configurationHandler: { (textField) in
        textField.placeholder = NSLocalizedString("eventDetailsPrompt/placeholder", comment: "Placeholder text in the texfield of the event details prompt")
      })
      
      alert.addAction(UIAlertAction(title: CommonStrings.cancel, style: .cancel, handler: nil))
      alert.addAction(UIAlertAction(title: CommonStrings.confirm, style: .default, handler: { (action) in
        self.dataController.createEvent(
          ofType: self.selectedEventType!,
          onDate: self.selectedDate!,
          withDetails: alert.textFields![0].text!,
          completion: eventCreated
        )
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
  var pageViewController:UIPageViewController!
  
  var onboardingPager:OnboardingPager?
  //var eventsOfDayController:EventsOfDayTableViewController!
  
  var selectedEventType:EventType!
  var selectedDate:Date! = Date()
  var dataController:DataController = DataController()
  var visibleMonthFormatter:DateFormatter! = DateFormatter()
  
  var nc:NotificationCenter = NotificationCenter.default
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.onboarding()
    visibleMonthFormatter.dateFormat = "MMMM YYYY"
    calendarController.select(date: self.selectedDate)
    
    nc.addObserver(forName: NSNotification.Name("event.delete"), object: nil, queue: nil) { (notif) in
      let date:Date = notif.object as! Date
      self.dataController.fetchEvents(completion: { (events) in
        self.calendarController.events = events
        self.calendarController.reloadCell(forDate: date)
      })
    }
    nc.addObserver(forName: NSNotification.Name("event.create"), object: nil, queue: nil) { (notif) in
      let event:Event = notif.object as! Event
      self.dataController.fetchEvents(completion: { (events) in
        self.calendarController.events = events
        if let d = event.date {
          self.calendarController.reloadCell(forDate: d as Date)
        }
      })
    }
  }
  
  func reloadEventTypes () {
    self.eventTypesController.reloadData()
  }
  
  @IBAction func unwindToViewController(withSegue:UIStoryboardSegue) {
    leaveUnboarding()
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
      let nav = segue.destination as! UINavigationController
//      nav.navigationBar.barTintColor = DynamicColor(hexString: selectedEventType.color ?? "000000")
      let eventsOfDayController = nav.topViewController as! EventsOfDayTableViewController
       eventsOfDayController.setDay(self.selectedDate)
      
    }
    
    if segue.identifier == "showEventTypeStats" {
      let nav:UINavigationController =  segue.destination as! UINavigationController
//      nav.navigationBar.barTintColor = DynamicColor(hexString: selectedEventType.color ?? "000000")
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
    
    weekDayHeader.labels.forEach { (label) in
      label.layer.shadowColor = etColor.darkened(amount: 0.2).cgColor
      label.setNeedsDisplay()
    }
    calendarController.selectedEventType = eventType
    let uiColor:UIColor! = etColor.isLight() ? etColor.darkened() : etColor
    
    quickAddButton.color = uiColor
    tickButton.color  = uiColor
    daySummaryButton.color  = uiColor
    
    quickAddButton.color = UIColor.white
    tickButton.color  = UIColor.white
    daySummaryButton.color  = UIColor.white
    
    toolbarView.backgroundColor = etColor
    
    visibleMonthView.backgroundColor = uiColor
    DrawUtils.drawLine(
      onLayer: toolbarView.layer,
      fromPoint: CGPoint(x:0, y:0),
      toPoint: CGPoint(x:toolbarView.bounds.width, y: 0),
      color: uiColor.cgColor,
      lineWidth: 1
    )
    
    DrawUtils.drawLine(
      onLayer: visibleMonthView.layer,
      fromPoint: CGPoint(x:0, y:0),
      toPoint: CGPoint(x:visibleMonthView.bounds.width, y:0),
      color: etColor.darkened(amount: 0.15).cgColor,
      lineWidth: 0.5
    )
    
    DrawUtils.drawLine(
      onLayer: visibleMonthView.layer,
      fromPoint: CGPoint(x:0, y:visibleMonthView.bounds.height),
      toPoint: CGPoint(x:visibleMonthView.bounds.width, y:visibleMonthView.bounds.height),
      color: etColor.darkened(amount: 0.15).cgColor,
      lineWidth: 1
    )
    
    DrawUtils.drawLine(
      onLayer: weekDayHeader.layer,
      fromPoint: CGPoint(x:0, y:weekDayHeader.bounds.height),
      toPoint: CGPoint(x:weekDayHeader.bounds.width, y:weekDayHeader.bounds.height),
      color: etColor.darkened(amount: 0.2).cgColor,
      lineWidth: 1
    )
    appDelegate.window?.tintColor = uiColor
  }
  
  func calendarController(_ calendarController: CalendarController, didSelectDate date: Date) {
    selectedDate = date
  }
  
  func calendarController(_ calendarController: CalendarController, setVisibleMonth monthAndYear: DateComponents) {
    visibleMonthLabel.text = visibleMonthFormatter.string(from: Calendar.current.date(from: monthAndYear)!)
  }
}


