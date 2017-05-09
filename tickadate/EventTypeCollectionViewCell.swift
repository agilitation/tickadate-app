//
//  EventTypeCollectionViewCell.swift
//  tickadate
//
//  Created by Romain Bessuges-Meusy on 08/05/2017.
//  Copyright © 2017 Agilitation. All rights reserved.
//

import UIKit
import DynamicColor

class EventTypeCollectionViewCell: UICollectionViewCell {
    
    @IBInspectable
    var color:UIColor = UIColor.red
    
    private var selectionCircle:CircleView?
    private var eventTypeCircle:CircleView?
    
    override func draw(_ rect: CGRect) {
        eventTypeCircle = CircleView(frame: CGRect(x:7, y:7, width: 14, height: 14))
        eventTypeCircle!.color =  color
        eventTypeCircle!.strokeColor =  color.darkened(amount: 0.2)
        eventTypeCircle!.strokeWidth = 1
        
        
        selectionCircle = CircleView(frame: CGRect(x:0, y:0, width: 28, height: 28))
        selectionCircle!.color = UIColor.black.tinted(amount: 0.8)
        selectionCircle!.isHidden = true
        
        contentView.addSubview(selectionCircle!)
        contentView.addSubview(eventTypeCircle!)
        
    }
    override var isSelected: Bool {
        didSet {
            self.selectionCircle?.isHidden = !isSelected
        }
    }

    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
//    override func draw(_ rect: CGRect) {
//        let ctx:CGContext = UIGraphicsGetCurrentContext()!
//        ctx.addEllipse(in: rect)
//        ctx.setFillColor(self.color)
//        ctx.fillPath()
//    }

}
