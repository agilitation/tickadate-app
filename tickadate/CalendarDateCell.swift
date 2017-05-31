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
  static let currentMonthDateColor:UIColor = DynamicColor(hexString: "000000")
  static let dateColor:UIColor = DynamicColor(hexString: "A9A9A9")
  static let todayDateColor:UIColor = UIColor.black
  
  @IBOutlet weak var label: UILabel!
  @IBOutlet weak var stack: EventDotsStack!
  
  var calendarDate:CalendarDate!
  var visibleMonth:DateComponents!
  
  override func prepareForReuse() {
    super.prepareForReuse()
    stack.dots = []
  }
  
  func initViewElements(){
    backgroundView = UIView(frame: self.bounds)
    
    let selBg = UIView(frame: self.bounds)
    
    selBg.backgroundColor = DynamicColor(hexString: "EEEEEE")
    selBg.isOpaque = true
    selBg.layer.cornerRadius = 5
    selBg.layer.borderWidth = 1
    selBg.layer.borderColor = DynamicColor(hexString: "DDDDDD").cgColor
    
    selectedBackgroundView = selBg
    
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
    self.calendarDate = cd
    
    if cd.isToday {
      label.textColor = CalendarDateCell.todayDateColor
      label.font = UIFont.systemFont(ofSize: UIFont.labelFontSize, weight: 900)
      //      UIFont.systemFont(ofSize: UIFont.labelFontSize, weight: 900)
    } else {
      label.font = UIFont.systemFont(ofSize: UIFont.labelFontSize)
    }
    
    if visibleMonth != nil {
      updateVisibleMonth()
    }
    
  }
  
  func setVisibleMonth(dateComponents dc: DateComponents){
    self.visibleMonth = dc
    self.updateVisibleMonth();
  }
  
  func updateVisibleMonth(){
    
    //    if let bgView = self.backgroundView {
    //      bgView.backgroundColor = UIColor.blue
    //      let path = UIBezierPath(roundedRect:bgView.bounds,
    //                              byRoundingCorners:[.topRight, .bottomLeft],
    //                              cornerRadii: CGSize(width: 4, height:  4))
    //
    //      let maskLayer = CAShapeLayer()
    //
    //      maskLayer.path = path.cgPath
    //      bgView.layer.mask = maskLayer
    //    }
//    if calendarDate.monthAndYear == visibleMonth {
//      self.label.textColor = CalendarDateCell.currentMonthDateColor
//      //      self.backgroundColor = UIColor.black.tinted(amount: 0.9)
//    } else {
//      self.label.textColor = CalendarDateCell.dateColor
//      //      self.backgroundColor = UIColor.clear
//    }
    
    UIView.animate(
      withDuration: 0.2,
      animations: {
        self.label.alpha = (self.calendarDate.monthAndYear == self.visibleMonth) ? 1 : 0.4
    })
  }
  
  override var isSelected: Bool {
    get {
      return super.isSelected
    }
    set {
      super.isSelected = newValue
      
      if let selBg = selectedBackgroundView {
          UIView.animate(
            withDuration: 0.1,
            animations: { selBg.alpha = self.isSelected ? 1 : 0
          })
      }
    }
  }
}
