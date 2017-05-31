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
  
  lazy var statsRowDefs:[EventTypeStatCellBuilder] = { () -> [EventTypeStatCellBuilder] in
    
    return [
      TimesPerDayStatCell(),
      TimesPerWeekStatCell(),
      TimesPerWeekdayStatCell(),
      LastTimeStatCell(),
      NextTimeStatCell(),
      HoursOfDayStatCell(),
      TimeIntervalStatCell(),
      DayOfYearStatCell()
    ]
  }()
  
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
    return self.statsRowDefs[indexPath.item].getHeight(forViewController: self, atIndexPath: indexPath)
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = self.statsRowDefs[indexPath.item].getCell(forViewController: self, atIndexPath: indexPath)
    cell.color = DynamicColor(hexString: eventType?.color ?? "000000")
    cell.isNegate = (indexPath.item % 2 == 0)
    cell.setNeedsLayout()
    return cell
  }
}


extension StatsTableViewController {
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
}
