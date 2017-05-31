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
    label.adjustsFontSizeToFitWidth = true
    
    self.minValue.textColor = valColor
    self.avgValue.textColor = valColor
    self.maxValue.textColor = valColor
    
    self.minValue.adjustsFontSizeToFitWidth = true
    self.maxValue.adjustsFontSizeToFitWidth = true
    self.avgValue.adjustsFontSizeToFitWidth = true
    
    self.minLabel.textColor = c
    self.avgLabel.textColor = c
    self.maxLabel.textColor = c
    
    self.backBox.borderColor = c
    self.centerBox.borderColor = c
    
    if isNegate {
      backBox.backgroundColor = color
      centerBox.backgroundColor = color
    } else {
      centerBox.backgroundColor = UIColor.clear
      backBox.backgroundColor = UIColor.clear
    }
  }
  
  
  static let timesFormatter:SerieStatValueFormatter = { value in
    let nbf = NumberFormatter()
    let unit = NSLocalizedString("stats/times/unit", comment: "Unit for times stat (multiplication symbol)")
    let formattedValue = nbf.string(from: value) ?? "0"
    let astr = NSMutableAttributedString(string: formattedValue.appending(unit))
    astr.addAttribute(
      NSFontAttributeName,
      value: UIFont.systemFont(
        ofSize: 30,
        weight: UIFontWeightThin
      ),
      range: NSRange(
        location: astr.length - 1,
        length: 1
      )
    )
    return astr
  }
  
  static let timeIntervalFormatter:SerieStatValueFormatter = { value in
    let duration = TimeInterval(value)
    let formatter = DateComponentsFormatter()
    let fval = Float(value)
    formatter.unitsStyle = .abbreviated
//    formatter.unitsStyle = .brief
    
    
    if fval > 3600*24 {
      formatter.allowedUnits = [ .day ]
    } else if fval > 3600 {
      formatter.allowedUnits = [ .hour, .minute ]
    } else {
      formatter.allowedUnits = [.minute]
    }
    
    formatter.collapsesLargestUnit = true
    formatter.maximumUnitCount = 5
    formatter.allowsFractionalUnits = true
    formatter.zeroFormattingBehavior = [ .pad ]
    
    let formattedDuration = formatter.string(from: duration)
    
    return NSMutableAttributedString(string: formattedDuration!)
  }
  
  
  typealias SerieStatValueFormatter = ((NSNumber)->(NSMutableAttributedString))
  
  
  var formatter:SerieStatValueFormatter = SerieStatTableViewCell.timesFormatter {
    didSet {
      self.updateValues()
    }
  }
  
  var stats:SerieStat? {
    didSet {
      self.updateValues()
    }
  }
  
  func updateValues(){
    if let s = self.stats {
      self.minValue.attributedText = self.formatter(s.min)
      self.avgValue.attributedText = self.formatter(s.avg)
      self.maxValue.attributedText = self.formatter(s.max)
    }
  }
  
  
  
}
