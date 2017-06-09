//
//  EventsOfDayTableViewController.swift
//  tickadate
//
//  Created by Romain Bessuges-Meusy on 21/05/2017.
//  Copyright © 2017 Agilitation. All rights reserved.
//

import UIKit
import DynamicColor

class EventsOfDayTableViewController: UITableViewController {
  
  let data:DataController = DataController()
  let timeFormatter:DateFormatter = DateFormatter()
  let dateFormatter:DateFormatter = DateFormatter()
  var events:[Event] = []
  var currentDay:Date = Date()
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    dateFormatter.timeStyle = .none
    dateFormatter.dateStyle = .medium
    timeFormatter.dateStyle = .none
    timeFormatter.timeStyle = .short
    
    self.navigationItem.hidesBackButton = false
    self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem
    self.navigationItem.title = dateFormatter.string(from: self.currentDay)
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem()
  }
  
  @IBAction func nextDay(_ sender: Any) {
    setDay(Calendar.current.date(byAdding: .day,value: 1, to: self.currentDay)!)
    
  }
  
  @IBAction func prevDay(_ sender: Any) {
    setDay(Calendar.current.date(byAdding: .day, value: -1, to: self.currentDay)!)
  }
  
  // Only one that works
  @IBAction func onBack (_ sender: Any) {
    self.performSegue(withIdentifier: "unwindToViewController", sender: self)
  }
  
  func setDay(_ date:Date) {
    
    self.currentDay = date
    self.navigationItem.title = dateFormatter.string(from: self.currentDay)
    data.fetchEvents(forDay: date) { (events) in
      self.events = events
      self.tableView.reloadData()
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.events.count
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let event:Event = events[indexPath.item]
    return event.type?.promptForDetails ?? false ? CGFloat(60) : CGFloat(44)
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let event:Event = events[indexPath.item]
    let reuseIdentifier = event.type?.promptForDetails ?? false ? "cellWithDetails" : "cell"
    let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! EventsOfDayTableViewCell
    
    
    cell.detailsLabel?.text = event.details
    cell.timeLabel.text = timeFormatter.string(from: event.date! as Date)
    cell.eventTypeLabel.text = event.type?.name!
    cell.border.backgroundColor = DynamicColor(hexString: event.type?.color ?? "000000")
    // not working ?
    cell.timeLabel.isHidden = event.type?.isAllDay ??  false
    return cell
  }
  
  
  
  // Override to support conditional editing of the table view.
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    return true
  }
  
  // Override to support editing the table view.
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      // Delete the row from the data source
      let event:Event = events[indexPath.item]
      self.events.remove(at: indexPath.item)
      tableView.deleteRows(at: [indexPath], with: .fade)
      data.deleteSync(event: event)
      
    } else if editingStyle == .insert {
      // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
  }
  
}
