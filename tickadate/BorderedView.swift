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
    if borderWidth > 0 {
      let corners = DrawUtils.getCorners(fromRect: rect)
      
      if borderOnTopSide {
        DrawUtils.drawLine(onLayer: self.layer,
                           fromPoint: corners.topLeft,
                           toPoint: corners.topRight,
                           color: borderColor.cgColor)
      }
      if borderOnRightSide {
        DrawUtils.drawLine(onLayer: self.layer,
                           fromPoint: corners.topRight,
                           toPoint: corners.bottomRight,
                           color: borderColor.cgColor)
      }
      if borderOnBottomSide {
        DrawUtils.drawLine(onLayer: self.layer,
                           fromPoint: corners.bottomRight,
                           toPoint: corners.bottomLeft,
                           color: borderColor.cgColor)
      }
      if borderOnLeftSide {
        DrawUtils.drawLine(onLayer: self.layer,
                           fromPoint: corners.bottomLeft,
                           toPoint: corners.bottomRight,
                           color: borderColor.cgColor)
      }
    }
  }
}
