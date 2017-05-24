//
//  StatsTableViewController.swift
//  tickadate
//
//  Created by Romain Bessuges-Meusy on 22/05/2017.
//  Copyright © 2017 Agilitation. All rights reserved.
//

import UIKit
import DynamicColor



class StatsTableViewController: UITableViewController {
  
  var eventType:EventType? {
    didSet {
      self.updateStats()
    }
  }
  
  var stats:EventTypeStats?
  
  func updateStats() {
    stats = EventTypeStats(self.eventType!)
    stats!.generate {
      if self.isViewLoaded {
        self.updateView()
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if stats != nil {
      updateView()
    }
  }
  
  func updateView() {
    
  }
  
  
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    if stats != nil {
      return statsRowDefs.count
    }
    return 0
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 180
  }
  typealias RowDef = (IndexPath, EventTypeStats)->StatTableViewCell
  lazy var statsRowDefs: [RowDef] = {
    
    var rows:[RowDef] = [
      
      { (ip, stats) in
        let cell = self.dequeueBarChartStatCell(for: ip)
        var bars:[String:Float] = [:]
        var statsWeekdays:[DateComponents : Float] = self.stats!.countsProportions["weekday"]!
        
        for (i, symbol) in Calendar.current.shortWeekdaySymbols.enumerated() {
          bars[symbol] = 0

          for (dc, proportion) in statsWeekdays{
            if i+1 == dc.weekday! {
              bars[symbol] = proportion
            }
          }
        }
        
        cell.bars = bars
        
        return cell
      },
      { (ip, stats) in
        let cell = self.dequeueSerieStatCell(for: ip)
        cell.setStat(label: "Times per day", stats: stats.countsSeries["day"]!, unit: "x")
        return cell
      },
      { (ip, stats) in
        let cell = self.dequeueLabelStatCell(for: ip)
        let df = DateFormatter()
        df.dateStyle = .full
        df.timeStyle = .none
        cell.label.text = "Last time"
        cell.value.text = self.stats!.prevDate != nil ? df.string(from: self.stats!.prevDate!) : "Never"
        return cell
      },
      { (ip, stats) in
        let cell = self.dequeueSerieStatCell(for: ip)
        cell.setStat(label: "Times per week", stats: stats.countsSeries["week"]!, unit: "x")
        return cell
      },
      { (ip, stats) in
        let cell = self.dequeueLabelStatCell(for: ip)
        let df = DateFormatter()
        df.dateStyle = .full
        df.timeStyle = .none
        cell.label.text = "Next time"
        cell.value.text = self.stats!.nextDate != nil ? df.string(from: self.stats!.nextDate!) : "Not yet"
        return cell
      }
    ]
    
    
    return rows;
  }()
  
  func dequeueSerieStatCell(for indexPath: IndexPath) -> SerieStatTableViewCell{
    return self.tableView.dequeueReusableCell(withIdentifier: "serieStatCell", for: indexPath) as! SerieStatTableViewCell
  }
  
  func dequeueLabelStatCell(for indexPath: IndexPath) -> LabelStatTableViewCell {
    return self.tableView.dequeueReusableCell(withIdentifier: "labelStatCell", for: indexPath) as! LabelStatTableViewCell
  }
  
  func dequeueBarChartStatCell(for indexPath: IndexPath) -> BarChartTableViewCell {
    return self.tableView.dequeueReusableCell(withIdentifier: "barChartStatCell", for: indexPath) as! BarChartTableViewCell
  }
  
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = self.statsRowDefs[indexPath.item](indexPath, stats!)
    cell.color = DynamicColor(hexString: eventType?.color ?? "000000")
    return cell
  }
}
