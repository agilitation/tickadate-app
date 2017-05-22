//
//  StatsTableViewController.swift
//  tickadate
//
//  Created by Romain Bessuges-Meusy on 22/05/2017.
//  Copyright © 2017 Agilitation. All rights reserved.
//

import UIKit

class StatsTableViewController: UITableViewController {
  
  @IBOutlet weak var timesMin: UILabel!
  @IBOutlet weak var timesAvg: UILabel!
  @IBOutlet weak var timesMax: UILabel!
  @IBOutlet weak var lastTime: UILabel!
  @IBOutlet weak var interval: UILabel!
  
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
    updateView()
  }
  
  func updateView() {
    let nbf = NumberFormatter()
    let df = DateFormatter()
    df.dateStyle = .full
    df.timeStyle = .none
    
    if let s = self.stats {
      if let timesPerDay = s.timesPerDay {
        self.timesMin.text = nbf.string(from: timesPerDay.min)?.appending("x")
        self.timesAvg.text = nbf.string(from: timesPerDay.avg)?.appending("x")
        self.timesMax.text = nbf.string(from: timesPerDay.max)?.appending("x")
      }
      if s.prevDate != nil {
        self.lastTime.text = df.string(from: s.prevDate!)
        print(df.string(from: s.prevDate!))
      }
    }
  }
}
