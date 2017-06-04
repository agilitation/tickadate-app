//
//  EventTypesTableViewController.swift
//  tickadate
//
//  Created by Romain Bessuges-Meusy on 10/05/2017.
//  Copyright © 2017 Agilitation. All rights reserved.
//

import UIKit
import CoreData
import DynamicColor

struct EventTypeExample {
  var name:String = "New event type"
  var color:String = "000000"
  
  init(name:String, color:String) {
    self.name = name
    self.color = color
  }
}


class EventTypesTableViewController: UITableViewController, EventTypeFormViewDelegate, UINavigationControllerDelegate {

  enum sections:Int {
    case progress = 0
    case eventTypes =  1
    case examples = 2
  }
  
  var eventTypeExamples:[EventTypeExample] = []
  var eventTypes:[EventType] = []
  var dataController:DataController!
  var isEditingCancelled:Bool! = false
  var nc:NotificationCenter = NotificationCenter.default

  
  @IBOutlet weak var backButtonItem: UIBarButtonItem!
  
  var cancelButtonItem: UIBarButtonItem!
  
  func reload(){
    self.fetchEventTypes {
      self.fetchEventTypeExamples {
        self.tableView.reloadData()
      }
    }
  }
  
  func fetchEventTypes(completion:@escaping () -> ()){
    dataController.fetchActiveEventTypes(completion: { (eventTypes) in
      self.eventTypes = eventTypes
      completion()
    })
    
  }
  
  func fetchEventTypeExamples(completion:@escaping () -> ()) {
    if let fileUrl = Bundle.main.url(forResource: "EventTypeExamples", withExtension: "plist"),
      let data = try? Data(contentsOf: fileUrl) {
      if let result = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [Dictionary<String, String>] {
        self.eventTypeExamples = result!.map({ (color) -> EventTypeExample in
          return EventTypeExample(name: color["name"]!, color: color["hex"]!)
        })
      }
    }
    completion()
  }
  
  override func viewDidLoad() {
    
    super.viewDidLoad()
    self.navigationController?.delegate = self
    self.dataController = DataController()
    cancelButtonItem = UIBarButtonItem(
      barButtonSystemItem: UIBarButtonSystemItem.cancel,
      target: self,
      action: #selector(EventTypesTableViewController.cancelEditMode(_:))
    )
    self.reload()
    self.cancelEditMode(nil)
    self.navigationItem.rightBarButtonItem = self.editButtonItem
    self.backButtonItem.title = CommonStrings.back
    
    nc.addObserver(forName: NSNotification.Name("eventTypes.change"), object: nil, queue: nil) { (notif) in
      let ip = IndexPath(item: 0, section: sections.progress.rawValue)
      self.tableView.reloadRows(at: [ip], with: .fade)
    }
  }
  
  
  
  // Only one that works
  @IBAction func onBack (_ sender: Any) {
    self.performSegue(withIdentifier: "unwindToViewController", sender: self)
  }
  
  override func setEditing(_ editing: Bool, animated: Bool) {
    super.setEditing(editing, animated: animated)
    if editing {
      self.navigationItem.leftBarButtonItem = cancelButtonItem
      self.isEditingCancelled = false
    } else {
      
      self.navigationItem.leftBarButtonItem = self.backButtonItem
      if !self.isEditingCancelled {
        self.dataController.save(activeEventTypes: self.eventTypes, completion: {})
      }
    }
  }
  
  
  func cancelEditMode(_ sender:UIBarButtonItem!) {
    isEditingCancelled = true;
    setEditing(false, animated: true)
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 3
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case sections.progress.rawValue:
      return 1
    case sections.eventTypes.rawValue:
      return self.eventTypes.count
    case sections.examples.rawValue:
      return self.eventTypeExamples.count
    default:
      return 0
    }
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if indexPath.section == sections.progress.rawValue {
      return 34
    } else {
      return super.tableView(tableView, heightForRowAt: indexPath)
    }
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    switch indexPath.section {
    case sections.progress.rawValue:
      let cell = tableView.dequeueReusableCell(withIdentifier: "progress", for: indexPath) as! EventTypeProgressTableViewCell
      cell.progress.progress = Float(self.eventTypes.count) / Float(IAPManager.shared.eventTypesCount)
      cell.caption.text = String(format: "%d / %d events", self.eventTypes.count, IAPManager.shared.eventTypesCount)
      return cell
    case sections.eventTypes.rawValue:
      let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! EventTypeTableViewCell
      cell.eventType = eventTypes[indexPath.item]
      return cell
    case sections.examples.rawValue:
      let cell = tableView.dequeueReusableCell(withIdentifier: "placeholderCell", for: indexPath) as! EventTypeExampleTableViewCell
      cell.eventTypeExample = eventTypeExamples[indexPath.item]
      return cell
    default :
      return tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    }
  }
  
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return indexPath.section == sections.eventTypes.rawValue
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      eventTypes.remove(at: indexPath.item)
      tableView.deleteRows(at: [indexPath], with: .fade)
    }
  }
  
  override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
    let element = eventTypes.remove(at: fromIndexPath.item)
    eventTypes.insert(element, at: to.item)
  }
  
  
  override func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
    if sourceIndexPath.section != proposedDestinationIndexPath.section {
      var row = 0
      if sourceIndexPath.section < proposedDestinationIndexPath.section {
        row = self.tableView(tableView, numberOfRowsInSection: sourceIndexPath.section) - 1
      }
      return IndexPath(row: row, section: sourceIndexPath.section)
    }
    return proposedDestinationIndexPath
  }
  
  
  override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
    return indexPath.section == sections.eventTypes.rawValue
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if indexPath.section != sections.examples.rawValue {
      return
    }
    
    if eventTypes.count < IAPManager.shared.eventTypesCount {
      performSegue(withIdentifier: "createEventTypeSegue", sender: self)
    } else {
      self.alertForUnsufficientEventTypes()
    }
    
  }
  
  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    setEditing(false, animated: false)
    
    if segue.identifier == "backToViewController" {
      let vc = segue.destination as! ViewController
      vc.reloadEventTypes()
      return
    }
    
    if ["selectEventTypeSegue", "createEventTypeSegue"].contains(segue.identifier ?? "") {
      
      let formVC = segue.destination as! EventTypeFormViewController
      formVC.delegate = self
      
      if segue.identifier == "selectEventTypeSegue" {
        let indexPath = tableView.indexPathForSelectedRow!
        formVC.isNewEventType = false
        formVC.eventType = eventTypes[indexPath.item]
      }
      
      if segue.identifier == "createEventTypeSegue" {
        self.dataController.createEventType(completion: { (et) in
          formVC.isNewEventType = true
          formVC.eventType = et
        })
      }
    }
  }
  
  func alertForUnsufficientEventTypes(){
    let alert:UIAlertController = UIAlertController(
      title: "Unsufficient event types",
      message: "Why dont you give me money", preferredStyle: .alert
    )
    
    alert.addAction(UIAlertAction(
      title: CommonStrings.cancel,
      style: .cancel,
      handler: { (action) in print("cancel") }
    ))
    
    alert.addAction(UIAlertAction(
      title: "Buy 3",
      style: .default,
      handler: { (action) in
        IAPManager.shared.purchase(.threeAdditionalEventTypes, completion: {
          self.performSegue(withIdentifier: "createEventTypeSegue", sender: self)
        })
    }
    ))
    
    alert.addAction(UIAlertAction(
      title: "Unlock",
      style: .default,
      handler: { (action) in
        IAPManager.shared.purchase(.unlimitedEventTypes, completion: {
          self.performSegue(withIdentifier: "createEventTypeSegue", sender: self)
        })
    }
    ))

    self.present(alert, animated: true, completion: nil)

  }
  
  func eventTypeFormView(_ controller: EventTypeFormViewController, finishedEditingOf eventType: EventType) {
    if !controller.wasChanged && controller.isNewEventType {
      dataController.delete(eventType: eventType)
    }
    
    self.reload()
  }
  
  
}
