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
  
  var sectionsIds:[sections] {
    get {
      return IAPManager.shared.hasUnlimitedEventTypes
        ? [.eventTypes, .examples]
        : [.progress, .eventTypes, .examples]
    }
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
    PListParser<[[String:String]]>().parse(filename: "EventTypeExamples") { (result) in
      self.eventTypeExamples = result.map({ (color) -> EventTypeExample in
        return EventTypeExample(name: color["name"]!, color: color["hex"]!)
      })
      completion()
    }
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
    
    // reload the progress bar on eventTypes.change
    nc.addObserver(forName: NSNotification.Name("eventTypes.change"), object: nil, queue: nil) { (notif) in
      if let progressSectionIndex = self.sectionsIds.index(of: sections.progress){
        let ip = IndexPath(item: 0, section: progressSectionIndex)
        self.tableView.reloadRows(at: [ip], with: .fade)
      }
    }
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
    return sectionsIds.count
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch sectionsIds[section] {
    case sections.progress:
      return 1
    case sections.eventTypes:
      return self.eventTypes.count
    case sections.examples:
      return self.eventTypeExamples.count
    }
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if sectionsIds[indexPath.section] == sections.progress {
      return 34
    } else {
      return super.tableView(tableView, heightForRowAt: indexPath)
    }
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    switch sectionsIds[indexPath.section] {
    case sections.progress:
      let cell = tableView.dequeueReusableCell(withIdentifier: "progress", for: indexPath) as! EventTypeProgressTableViewCell
      cell.progress.progress = Float(self.eventTypes.count) / Float(IAPManager.shared.eventTypesCount)
      cell.caption.text = String(format: "%d / %d events", self.eventTypes.count, IAPManager.shared.eventTypesCount)
      return cell
    case sections.eventTypes:
      let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! EventTypeTableViewCell
      cell.eventType = eventTypes[indexPath.item]
      return cell
    case sections.examples:
      let cell = tableView.dequeueReusableCell(withIdentifier: "placeholderCell", for: indexPath) as! EventTypeExampleTableViewCell
      cell.eventTypeExample = eventTypeExamples[indexPath.item]
      return cell
    }
  }
  
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return sectionsIds[indexPath.section] == sections.eventTypes
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
    return sectionsIds[indexPath.section] == sections.eventTypes
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if sectionsIds[indexPath.section] != sections.examples {
      return
    }
    
    // MARK: - Check if sufficient event types
    if eventTypes.count < IAPManager.shared.eventTypesCount || IAPManager.shared.hasUnlimitedEventTypes {
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
      title: NSLocalizedString(
        "eventTypes/table/unsufficient/alert/title",
        comment: "The title of the alert panel displayed when the user has no more event types"
      ),
      message: NSLocalizedString(
        "eventTypes/table/unsufficient/alert/message",
        comment: "The message of the alert panel displayed when the user has no more event types"
      ),
      preferredStyle: .alert
    )
    
    alert.addAction(UIAlertAction(
      title: CommonStrings.cancel,
      style: .cancel,
      handler: { (action) in print("cancel") }
    ))
    
    alert.addAction(UIAlertAction(
      title: NSLocalizedString(
        "eventTypes/table/unsufficient/buy3",
        comment: "The label of the button that allows the user to buy 3 new event types"
      ),
      style: .default,
      handler: { (action) in
        IAPManager.shared.purchase(.threeAdditionalEventTypes, completion: {
          self.performSegue(withIdentifier: "createEventTypeSegue", sender: self)
        })
    }
    ))
    
    alert.addAction(UIAlertAction(
      title: NSLocalizedString(
        "eventTypes/table/unsufficient/unlock",
        comment: "The label of the button that allows the user to unlock event types"
      ),
      style: .default,
      handler: { (action) in
        IAPManager.shared.purchase(.unlimitedEventTypes, completion: {
          // we have to reload the table view to remove the progress bar
          IAPManager.shared.hasUnlimitedEventTypes = true
          self.tableView.reloadData()
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
