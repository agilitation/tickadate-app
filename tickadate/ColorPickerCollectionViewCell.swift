//
//  ColorPickerCollectionViewCell.swift
//  tickadate
//
//  Created by Romain Bessuges-Meusy on 16/05/2017.
//  Copyright © 2017 Agilitation. All rights reserved.
//

import UIKit
import DynamicColor


class ColorPickerCollectionViewCell: UICollectionViewCell {
  
  @IBOutlet weak var circleView: CircleView!
  @IBOutlet weak var label: UILabel!
  
  override var isSelected: Bool {
    didSet {
      self.selectedBackgroundView?.isHidden = !isSelected
    }
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    initViewElements()
  }
  
  func initViewElements(){
    
    circleView.isOpaque = false
    circleView.backgroundColor = nil
    backgroundView = UIView(frame: self.bounds)
    selectedBackgroundView = UIView(frame: self.bounds)
    selectedBackgroundView?.backgroundColor = circleView.color.tinted(amount: 0.8)
    selectedBackgroundView?.isOpaque = true
    selectedBackgroundView?.layer.cornerRadius = 10
  }

}
