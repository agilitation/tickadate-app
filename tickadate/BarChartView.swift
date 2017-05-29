//
//  BarChartView.swift
//  tickadate
//
//  Created by Romain Bessuges-Meusy on 24/05/2017.
//  Copyright © 2017 Agilitation. All rights reserved.
//

import UIKit





extension NSLayoutConstraint {
  /**
   Change multiplier constraint
   
   - parameter multiplier: CGFloat
   - returns: NSLayoutConstraint
   */
  func setMultiplier(multiplier:CGFloat) {
    
    NSLayoutConstraint.deactivate([self])
    
    let newConstraint = NSLayoutConstraint(
      item: firstItem,
      attribute: firstAttribute,
      relatedBy: relation,
      toItem: secondItem,
      attribute: secondAttribute,
      multiplier: multiplier,
      constant: constant)
    
    newConstraint.priority = priority
    newConstraint.shouldBeArchived = self.shouldBeArchived
    newConstraint.identifier = self.identifier
    
    NSLayoutConstraint.activate([newConstraint])
  }
}

struct BarChartValue {
  var label:String
  var value:Float
}


@IBDesignable
class BarChartBar : UIView {
  
  var bar:UIView!
  var track:UIView!
  var label:UILabel!
  var heightConstraint:NSLayoutConstraint!
  
  var percent:Float = 0 {
    didSet {
      self.heightConstraint.setMultiplier(multiplier: CGFloat(percent))
      self.setNeedsLayout()
    }
  }
  
  var color:UIColor = UIColor.black {
    didSet {
      bar.backgroundColor = color
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }
  
  func setup(){
    bar = UIView()
    track = UIView()
    label = UILabel()
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 11, weight: UIFontWeightThin)
    
    bar.translatesAutoresizingMaskIntoConstraints = false
    label.translatesAutoresizingMaskIntoConstraints = false
    track.translatesAutoresizingMaskIntoConstraints = false
    
    bar.backgroundColor = UIColor.blue
    
    addSubview(label)
    addSubview(track)
    track.addSubview(bar)
    
    heightConstraint = NSLayoutConstraint(
      item: bar,
      attribute: .height,
      relatedBy: .equal,
      toItem: track,
      attribute: .height,
      multiplier: 0.7,
      constant: 0
    )
    
    addConstraint(NSLayoutConstraint(
      item: self,
      attribute: .height,
      relatedBy: .equal,
      toItem: nil,
      attribute: .notAnAttribute,
      multiplier: 1,
      constant: self.bounds.height
    ))
    
    addConstraint(NSLayoutConstraint(
      item: label,
      attribute: .height,
      relatedBy: .equal,
      toItem: nil,
      attribute: .notAnAttribute,
      multiplier: 1,
      constant: 20
    ))
    
    addConstraint(NSLayoutConstraint(
      item: track,
      attribute: .top,
      relatedBy: .equal,
      toItem: self,
      attribute: .top,
      multiplier: 1,
      constant: 0
    ))
    
    addConstraint(NSLayoutConstraint(
      item: track,
      attribute: .width,
      relatedBy: .equal,
      toItem: self,
      attribute: .width,
      multiplier: 1,
      constant: 0
    ))
    
    addConstraint(NSLayoutConstraint(
      item: track,
      attribute: .centerX,
      relatedBy: .equal,
      toItem: self,
      attribute: .centerX,
      multiplier: 1,
      constant: 0
    ))
    
    addConstraint(NSLayoutConstraint(
      item: label,
      attribute: .bottom,
      relatedBy: .equal,
      toItem: self,
      attribute: .bottom,
      multiplier: 1,
      constant: 0
    ))
    
    addConstraint(NSLayoutConstraint(
      item: label,
      attribute: .width,
      relatedBy: .equal,
      toItem: self,
      attribute: .width,
      multiplier: 1,
      constant: 0
    ))
    
    addConstraint(NSLayoutConstraint(
      item: label,
      attribute: .centerX,
      relatedBy: .equal,
      toItem: self,
      attribute: .centerX,
      multiplier: 1,
      constant: 0
    ))
    
    addConstraint(NSLayoutConstraint(
      item: label,
      attribute: .top,
      relatedBy: .equal,
      toItem: track,
      attribute: .bottom,
      multiplier: 1,
      constant: 0
    ))
    
    track.addConstraint(NSLayoutConstraint(
      item: bar,
      attribute: .width,
      relatedBy: .equal,
      toItem: track,
      attribute: .width,
      multiplier: 1,
      constant: 0
    ))
    
    
    track.addConstraint(NSLayoutConstraint(
      item: bar,
      attribute: .centerX,
      relatedBy: .equal,
      toItem: track,
      attribute: .centerX,
      multiplier: 1,
      constant: 0
    ))
    
    
    track.addConstraint(NSLayoutConstraint(
      item: bar,
      attribute: .bottom,
      relatedBy: .equal,
      toItem: track,
      attribute: .bottom,
      multiplier: 1,
      constant: 0
    ))
    
    track.addConstraint(self.heightConstraint)
  }
  
  
}

@IBDesignable
class BarChartView: UIStackView {
  
  var values:[BarChartValue] = []
  var labels:[String] = []
  var color:UIColor = UIColor.black
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init(coder: NSCoder) {
    super.init(coder: coder)
    setup()
  }
  
  func setup () {
    
    alignment = .center
    axis = .horizontal
    distribution = .fillEqually
    spacing = 8
  }
  
  
  override func layoutSubviews() {
    
    while arrangedSubviews.count < values.count {
      addArrangedSubview(BarChartBar(frame: self.bounds))
    }
    
    while arrangedSubviews.count > values.count {
      arrangedSubviews.first?.removeFromSuperview()
    }
    
    var maxValue:Float = 0.0
    var weightedValue:Float = 0.0
    for value in values {
      if value.value > maxValue {
        maxValue = value.value
      }
    }
    
    for (index, value) in values.enumerated() {
      weightedValue = maxValue > 0 ? value.value / maxValue : 0
      let bar = arrangedSubviews[index] as! BarChartBar
      bar.label.text = value.label
      bar.percent = weightedValue
      bar.color = self.color
      bar.alpha = CGFloat(Float(0.5) + weightedValue / 2)
    }
  }
  
}
