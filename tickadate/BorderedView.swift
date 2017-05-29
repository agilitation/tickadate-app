//
//  BorderedView.swift
//  tickadate
//
//  Created by Romain Bessuges-Meusy on 13/05/2017.
//  Copyright © 2017 Agilitation. All rights reserved.
//

import UIKit


@IBDesignable
class BorderedView: UIView {
  
  @IBInspectable var borderWidth:CGFloat = 1
  @IBInspectable var borderColor:UIColor = UIColor.black
  @IBInspectable var borderRadius:CGFloat = 0
  @IBInspectable var borderOnLeftSide:Bool = true
  @IBInspectable var borderOnTopSide:Bool = true
  @IBInspectable var borderOnRightSide:Bool = true
  @IBInspectable var borderOnBottomSide:Bool = true
  
  override func draw(_ rect: CGRect) {
    self.layer.borderWidth = self.borderWidth
    self.layer.borderColor = self.borderColor.cgColor
    self.layer.cornerRadius = self.borderRadius
    super.draw(rect)
  }
}
