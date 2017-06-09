//
//  AnalyseStepOnboardingViewController.swift
//  tickadate
//
//  Created by Romain Bessuges-Meusy on 06/06/2017.
//  Copyright © 2017 Agilitation. All rights reserved.
//

import UIKit

class AnalyseStepOnboardingViewController: OnboardingViewController {

  @IBOutlet weak var barChartView: BarChartView!
  
  override func setup() {
    let weekdays = DateUtils.getOrderedWeekdays()
    
    self.barChartView.color = UIColor.white
    self.barChartView.values = [
      BarChartValue(label: weekdays[0], value: 0.2),
      BarChartValue(label: weekdays[1], value: 0.5),
      BarChartValue(label: weekdays[2], value: 0.34),
      BarChartValue(label: weekdays[3], value: 0.54),
      BarChartValue(label: weekdays[4], value: 0.8),
      BarChartValue(label: weekdays[5], value: 0.9),
      BarChartValue(label: weekdays[6], value: 0.1),
    ]
  }
  
  override func viewDidAppear(_ animated: Bool) {
    barChartView.animateIn()
  }
}
