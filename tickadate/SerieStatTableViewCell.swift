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
    let valColor = isNegate ? UIColor.white : UIColor.black
    
    label.textColor = valColor
    
    self.minValue.textColor = valColor
    self.avgValue.textColor = valColor
    self.maxValue.textColor = valColor
    
    self.minLabel.textColor = c
    self.avgLabel.textColor = c
    self.maxLabel.textColor = c
    
    self.backBox.borderColor = c
    self.centerBox.borderColor = c
    
    if isNegate {
      backBox.backgroundColor = color
      centerBox.backgroundColor = color
      
      
    }
  }
  
  func setStat(label:String, stats:SerieStat, unit:String = ""){
    
    self.minValue.attributedText = format(stats.min, withUnit: unit)
    self.avgValue.attributedText = format(stats.avg, withUnit: unit)
    self.maxValue.attributedText = format(stats.max, withUnit: unit)
    
    self.label.text = label
  }
  
  func format(_ value: NSNumber, withUnit unit: String) -> NSAttributedString{
    let nbf = NumberFormatter()
    return makeAttributedString(for: nbf.string(from: value)!, withUnit: unit)
    
  }
  
  
  func makeAttributedString(for value:String, withUnit unit:String) -> NSMutableAttributedString {
    
    let astr = NSMutableAttributedString(string: value.appending(unit))
    astr.addAttribute(NSFontAttributeName,
                 value: UIFont.systemFont(ofSize: 30, weight: UIFontWeightThin),
                 range: NSRange(
                  location: astr.length - 1,
                  length: 1))
    return astr
    
  }
}
