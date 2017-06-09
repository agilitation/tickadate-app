//
//  GradientView.swift
//  tickadate
//
//  Created by Romain Bessuges-Meusy on 05/06/2017.
//  Copyright © 2017 Agilitation. All rights reserved.
//

import UIKit

@IBDesignable class GradientView: UIView {
  @IBInspectable var topColor: UIColor = UIColor.white
  @IBInspectable var bottomColor: UIColor = UIColor.black
  
  override class var layerClass: AnyClass {
    return CAGradientLayer.self
  }
  
  override func layoutSubviews() {
    let gradient = (layer as! CAGradientLayer)
    gradient.colors = [topColor.cgColor, bottomColor.cgColor]
    gradient.startPoint = CGPoint(x:0, y:1)
    gradient.endPoint = CGPoint(x:1, y:0)
  }
  
  override func prepareForInterfaceBuilder() {
    layoutSubviews()
  }
}
