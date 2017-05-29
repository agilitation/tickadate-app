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
  
  override func layoutSubviews() {
    super.layoutSubviews()
    self.barChartView.color = isNegate ? UIColor.white : color
    self.label.textColor = isNegate ? UIColor.white : UIColor.black
  }
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
}
