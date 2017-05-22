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
  
  @IBInspectable var borderWidth:CGFloat = 1 {
    didSet { setNeedsDisplay() }
  }
  @IBInspectable var borderColor:UIColor = UIColor.black {
    didSet { setNeedsDisplay() }
  }
  @IBInspectable var borderRadius:CGFloat = 0 {
    didSet { setNeedsDisplay() }
  }
  @IBInspectable var borderOnLeftSide:Bool = true {
    didSet { setNeedsDisplay() }
  }
  @IBInspectable var borderOnTopSide:Bool = true {
    didSet { setNeedsDisplay() }
  }
  @IBInspectable var borderOnRightSide:Bool = true {
    didSet { setNeedsDisplay() }
  }
  @IBInspectable var borderOnBottomSide:Bool = true {
    didSet { setNeedsDisplay() }
  }
  
  override func draw(_ rect: CGRect) {
    self.layer.borderWidth = self.borderWidth
    self.layer.borderColor = self.borderColor.cgColor
    self.layer.cornerRadius = self.borderRadius
    super.draw(rect)
  }
}
