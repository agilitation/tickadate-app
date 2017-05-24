//
//  BarChartTableViewCell.swift
//  tickadate
//
//  Created by Romain Bessuges-Meusy on 23/05/2017.
//  Copyright © 2017 Agilitation. All rights reserved.
//

import UIKit

class BarChartTableViewCell: StatTableViewCell {
  
  @IBOutlet weak var barChartView: BarChartView!
  @IBOutlet weak var label: UILabel!
  
  var bars:[String : Float] = [ "A" : 0.5, "B" : 0.3, "C" : 0.15, "E": 0.05] {
    didSet {
      self.barChartView.bars = bars
    }
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    self.barChartView.color = isNegate ? UIColor.white : color
  }
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
}
