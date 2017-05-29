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
        let cell:GridStatTableViewCell = self.dequeueGridStatCell(for:  ip)
        cell.label.text = NSLocalizedString("stats/frequency/hoursOfday", comment: "Frequency by hours")
        
        var statsByHours:[DateComponents : Float] = self.stats!.countsProportions["hour"]!
        var values:[Float] = [Float](repeating: 0.0, count: 24)
        
        for (h, proportion) in statsByHours {
          values[h.hour!] = proportion
        }
        
        cell.grid.tintColor = DynamicColor(hexString: self.eventType!.color!)
        cell.grid.numberOfCols = 12
        cell.grid.numberOfRows = 2
        cell.grid.values = values
        cell.grid.space = 1
        
        return cell
      },
      { (ip, stats) in
        let cell = self.dequeueSerieStatCell(for: ip)
        cell.setStat(label: NSLocalizedString("stats/timesPerDay/label", comment: "Label for times per day stat"),
                     stats: stats.countsSeries["day"]!,
                     unit: NSLocalizedString("stats/timesPerDay/unit", comment: "Unit for times per day stat"))
        return cell
      },
      { (ip, stats) in
        let cell = self.dequeueLabelStatCell(for: ip)
        let df = DateFormatter()
        df.dateStyle = .full
        df.timeStyle = .none
        cell.isNegate = true
        cell.label.text = NSLocalizedString("stats/lastTime/label", comment: "Label for last time stat")
        cell.value.text = (self.stats!.prevDate != nil) ?
          df.string(from: self.stats!.prevDate!) :
          NSLocalizedString("stats/lastTime/none",
                            comment: "Placeholder used when no event of this type have happened yet")
        return cell
      },
      { (ip, stats) in
        let cell = self.dequeueLabelStatCell(for: ip)
        let df = DateFormatter()
        df.dateStyle = .full
        df.timeStyle = .none
        cell.isNegate = false
        cell.label.text = NSLocalizedString("stats/nextTime/label", comment: "Label for next time stat")
        cell.value.text = self.stats!.nextDate != nil ? df.string(from: self.stats!.nextDate!) : NSLocalizedString("stats/nextTime/none",
                                                                                                                   comment: "Placeholder used when no event of this type are note expected yet")
        return cell
      },
      { (ip, stats) in
        let cell = self.dequeueSerieStatCell(for: ip)
        cell.setStat(label: NSLocalizedString("stats/timesPerWeek/label",
                                              comment: "Label for times per week stat"),
                     stats: stats.countsSeries["week"]!,
                     unit: NSLocalizedString("stats/timesPerWeek/unit", comment: "Unit for times per week stat"))
        cell.isNegate = true
        return cell
      },
      { (ip, stats) in
        let cell = self.dequeueBarChartStatCell(for: ip)
        var values:[BarChartValue] = []
        var statsWeekdays:[DateComponents : Float] = self.stats!.countsProportions["weekday"]!
        var max = 0
        var maxIndex = 0
        
        for (i, symbol) in Calendar.current.shortWeekdaySymbols.enumerated() {
          
          var bar = BarChartValue(label: symbol, value: 0)
          
          for (dc, proportion) in statsWeekdays{
            if i+1 == dc.weekday! {
              bar.value = proportion
            }
          }
          values.append(bar)
        }
        cell.label.text = NSLocalizedString("stats/timesPerWeekday/label",
                                            comment: "Label for times per weekday stat")
        cell.barChartView.values = values
        cell.barChartView.setNeedsLayout()
        return cell
      },
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
  
  func dequeueGridStatCell(for indexPath: IndexPath) -> GridStatTableViewCell {
    return self.tableView.dequeueReusableCell(withIdentifier: "gridStatCell", for: indexPath) as! GridStatTableViewCell
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = self.statsRowDefs[indexPath.item](indexPath, stats!)
    cell.color = DynamicColor(hexString: eventType?.color ?? "000000")
    return cell
  }
}
