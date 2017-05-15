//
//  DateCollectionViewCell.swift
//  tickadate
//
//  Created by Romain Bessuges-Meusy on 08/05/2017.
//  Copyright © 2017 Agilitation. All rights reserved.
//

import UIKit
import DynamicColor

class CalendarDateCell: UICollectionViewCell {
  
  static let borderColor:UIColor = DynamicColor(hexString: "EEEEEE")
  static let currentMonthDateColor:UIColor = DynamicColor(hexString: "444444")
  static let dateColor:UIColor = DynamicColor(hexString: "A9A9A9")
  static let todayDateColor:UIColor = UIColor.black
  
  @IBOutlet weak var label: UILabel!
  @IBOutlet weak var stack: EventDotsStack!
  

  override func prepareForReuse() {
    super.prepareForReuse()
    stack.dots = []
  }
  
  func initViewElements(){
    backgroundView = UIView(frame: self.bounds)
    selectedBackgroundView = UIView(frame: self.bounds)
    selectedBackgroundView?.backgroundColor = DynamicColor(hexString: "EEEEEE")
    selectedBackgroundView?.isOpaque = true
    selectedBackgroundView?.layer.cornerRadius = 5
    
    label.textAlignment = .center
    stack.isOpaque = false
  
    contentView.addSubview(label)
    contentView.addSubview(stack)
  }
  
  
  override func layoutSubviews() {
    super.layoutSubviews()
    initViewElements()
  }
  
  
  func setEventDots(_ dots: [String]){
    stack.dots = dots
  }
  
  func setDate(_ cd:CalendarDate){
    self.label.text = cd.formatted
    
    if cd.isCurrentMonth {
      label.textColor = CalendarDateCell.currentMonthDateColor
    } else  {
      label.textColor = CalendarDateCell.dateColor
    }
    
    if cd.isToday {
      label.textColor = CalendarDateCell.todayDateColor
      label.font = UIFont.systemFont(ofSize: UIFont.labelFontSize, weight: 900)
//      UIFont.systemFont(ofSize: UIFont.labelFontSize, weight: 900)
    } else {
      label.font = UIFont.systemFont(ofSize: UIFont.labelFontSize)
    }
  }
  
  override var isSelected: Bool {
    didSet {
      if let selBg = selectedBackgroundView {
        selBg.isHidden = !isSelected
//        selBg.alpha = isSelected ? 0 : 1
//        selBg.isHidden = false
//        
//        UIView.animate(
//          withDuration: 0.1,
//          animations: { selBg.alpha = self.isSelected ? 1 : 0 },
//          completion: { (finished:Bool) in selBg.isHidden = !self.isSelected }
//        )
      }
    }
  }
}
