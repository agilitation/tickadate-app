//
//  CircleView.swift
//  tickadate
//
//  Created by Romain Bessuges-Meusy on 09/05/2017.
//  Copyright © 2017 Agilitation. All rights reserved.
//

import UIKit

class CircleView: UIView {
    
    @IBInspectable var color:UIColor = UIColor.black {
        didSet {
            self.setNeedsLayout()
        }
    }
    @IBInspectable var strokeColor:UIColor = UIColor.black {
        didSet {
            self.setNeedsLayout()
        }
    }
    @IBInspectable var strokeWidth:CGFloat = 0.0 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    
    override func draw(_ rect: CGRect) {
        
        let ctx:CGContext = UIGraphicsGetCurrentContext()!
        //fill
        ctx.addEllipse(in: rect)
        ctx.setFillColor(self.color.cgColor)
        ctx.fillPath()
        //stroke
        
        if strokeWidth > 0 {
            ctx.addEllipse(in: getStrokeRect(self.bounds))
            ctx.setStrokeColor(strokeColor.cgColor)
            ctx.setLineWidth(strokeWidth)
            ctx.strokePath()
        }
    }
    
    internal func getStrokeRect(_ rect: CGRect) -> CGRect{
        return CGRect(
            x: self.strokeWidth / 2,
            y: self.strokeWidth / 2,
            width: rect.width - self.strokeWidth,
            height: rect.height - self.strokeWidth
        )
    }
}
