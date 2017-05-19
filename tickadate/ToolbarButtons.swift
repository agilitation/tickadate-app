//
//  ToolbarButtons.swift
//  tickadate
//
//  Created by Romain Bessuges-Meusy on 17/05/2017.
//  Copyright © 2017 Agilitation. All rights reserved.
//

import UIKit

@IBDesignable
class VectorButton : UIButton {
  @IBInspectable
  var color:UIColor = UIColor.black {
    didSet {
      self.setNeedsDisplay()
    }
  }
}

@IBDesignable
class TickButton: VectorButton {
  override func draw(_ rect: CGRect) {
    StyleKit.drawTick(themeColor: self.color)
  }
}

@IBDesignable
class QuickAddButton: VectorButton {
  override func draw(_ rect: CGRect) {
    StyleKit.drawQuickAdd(themeColor: self.color)
  }
}

@IBDesignable
class DaySummaryButton: VectorButton {
  override func draw(_ rect: CGRect) {
    StyleKit.drawDaySummary(themeColor: self.color)
  }
}
