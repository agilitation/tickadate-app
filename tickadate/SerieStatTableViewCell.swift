//
//  SerieStatTableViewCell.swift
//  tickadate
//
//  Created by Romain Bessuges-Meusy on 23/05/2017.
//  Copyright © 2017 Agilitation. All rights reserved.
//

import UIKit

class SerieStatTableViewCell: StatTableViewCell {

  @IBOutlet weak var backBox: BorderedView!
  @IBOutlet weak var centerBox: BorderedView!
  @IBOutlet weak var minValue: UILabel!
  @IBOutlet weak var minLabel: UILabel!
  @IBOutlet weak var avgValue: UILabel!
  @IBOutlet weak var avgLabel: UILabel!
  @IBOutlet weak var maxValue: UILabel!
  @IBOutlet weak var maxLabel: UILabel!
  @IBOutlet weak var label: UILabel!
  
  override func layoutSubviews() {
    super.layoutSubviews()    
    let c = isNegate ? UIColor.white : color
    
    self.minLabel.textColor = c
    self.avgLabel.textColor = c
    self.maxLabel.textColor = c
    
    self.backBox.borderColor = c
    self.centerBox.borderColor = c
  }
  
  func setStat(label:String, stats:SerieStat, unit:String = ""){
    let nbf = NumberFormatter()
  
    self.minValue.text = nbf.string(from: stats.min)?.appending(unit)
    self.avgValue.text = nbf.string(from: stats.avg)?.appending(unit)
    self.maxValue.text = nbf.string(from: stats.max)?.appending(unit)
    
    self.label.text = label
  }
}
