//
//  DrawUtils.swift
//  tickadate
//
//  Created by Romain Bessuges-Meusy on 11/05/2017.
//  Copyright © 2017 Agilitation. All rights reserved.
//

import UIKit

public class DrawUtils: NSObject {
  
  public static func drawLine(onLayer layer: CALayer,
                              fromPoint start: CGPoint,
                              toPoint end: CGPoint,
                              color: CGColor,
                              lineWidth: CGFloat = 1.0) {
    let line = CAShapeLayer()
    let linePath = UIBezierPath()
    linePath.move(to: start)
    linePath.addLine(to: end)
    line.path = linePath.cgPath
    line.fillColor = nil
    line.opacity = 1.0
    line.strokeColor = color
    line.lineWidth = lineWidth
    layer.addSublayer(line)
  }
  
  public  struct Corners {
    var topLeft:CGPoint
    var topRight:CGPoint
    var bottomLeft:CGPoint
    var bottomRight:CGPoint
  }
  
  public static func getCorners(fromRect rect:CGRect) -> Corners{
    let o = rect.origin
    let s = rect.size
    
    return Corners(topLeft: o,
                   topRight: CGPoint(x:o.x + s.width,y: o.y),
                   bottomLeft: CGPoint(x:o.x,y: o.y + s.height),
                   bottomRight: CGPoint(x:o.x + s.width,y: o.y + s.height))
  }
  
  public  static func drawCircle(
    onContext context:CGContext,
    inRect rect: CGRect,
    color: CGColor = UIColor.black.cgColor,
    lineWidth: CGFloat = 0,
    strokeColor: CGColor = UIColor.black.cgColor){
    
    context.addEllipse(in: rect)
    context.setFillColor(color)
    context.fillPath()
    
    if lineWidth > 0 {
      context.addEllipse(in: rect.insetBy(dx: lineWidth, dy: lineWidth))
      context.setStrokeColor(strokeColor)
      context.setLineWidth(lineWidth)
      context.strokePath()
    }
  }
  
  public  static func drawRect(
    onContext context:CGContext,
    inRect rect: CGRect,
    color: CGColor = UIColor.black.cgColor
    ) {
    context.addRect(rect)
    context.setFillColor(color)
    context.fillPath()
  }
  
  
}
