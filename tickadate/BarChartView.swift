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
    label.font = UIFont.systemFont(ofSize: 10, weight: 200)
    
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

  var bars:[String : Float] = [ "A" : 0.5, "B" : 0.3, "C" : 0.15, "E": 0.05] {
    didSet {
      self.needsUpdateConstraints()
    }
  }
  
  var color:UIColor = UIColor.black

  override func layoutSubviews() {
  
    alignment = .center
    axis = .horizontal
    distribution = .fillEqually
    spacing = 8
    
    
    while arrangedSubviews.count < bars.count {
      addArrangedSubview(BarChartBar(frame: self.bounds))
    }
    
    while arrangedSubviews.count > bars.count {
      arrangedSubviews.first?.removeFromSuperview()
    }
    
    var i = 0
    
    var max:Float = 0.0
    
    bars.forEach { (label, value) in
      if value > max {
        max = value
      }
    }
    
    bars.forEach { (label, value) in
      let bar = arrangedSubviews[i] as! BarChartBar
      bar.label.text = label
      bar.percent = value / max
      bar.color = self.color
      i += 1
    }
  }

}
