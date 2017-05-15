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

class EventTypesTableViewController: UITableViewController, EventTypeFormViewDelegate {
  
  var eventTypes:[EventType] = []
  var selectedEventType:EventType!
  var dataController:DataController!
  var isEditingCancelled:Bool! = false
  
  @IBOutlet weak var backButtonItem: UIBarButtonItem!
  var cancelButtonItem: UIBarButtonItem!
  
  func reload(){
    self.eventTypes = dataController.fetchActiveEventTypes()
    tableView.reloadData()
  }
  
  override func viewDidLoad() {
    
    super.viewDidLoad()
    self.dataController = DataController()
    cancelButtonItem = UIBarButtonItem(
      barButtonSystemItem: UIBarButtonSystemItem.cancel,
      target: self,
      action: #selector(EventTypesTableViewController.cancelEditMode(_:))
    )
    self.reload()
    self.cancelEditMode(nil)
    self.navigationItem.rightBarButtonItem = self.editButtonItem
    
    
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
      self.navigationItem.leftBarButtonItem = backButtonItem
      if !self.isEditingCancelled {
        self.dataController.save(activeEventTypes: self.eventTypes)
      }
    }
  }
  
  
  func cancelEditMode(_ sender:UIBarButtonItem!) {
    isEditingCancelled = true;
    setEditing(false, animated: true)
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.eventTypes.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! EventTypeTableViewCell
    cell.eventType = eventTypes[indexPath.item]
    return cell
  }
  
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
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
  
  override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
    return true
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
        formVC.eventType = eventTypes[indexPath.item]
      }
      
      if segue.identifier == "createEventTypeSegue" {
        formVC.eventType = self.dataController.createEventType()
      }
    }
  }
  
  func eventTypeFormView(_ controller: EventTypeFormViewController, finishedEditingOf eventType: EventType) {
    self.reload()
  }
}
