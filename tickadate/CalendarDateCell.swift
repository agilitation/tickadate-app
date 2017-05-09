//
//  DateCollectionViewCell.swift
//  tickadate
//
//  Created by Romain Bessuges-Meusy on 08/05/2017.
//  Copyright © 2017 Agilitation. All rights reserved.
//

import UIKit

class CalendarDateCell: UICollectionViewCell {
    
    
    var label = UILabel(frame: CGRect(x: 4, y: 2, width: 46, height: 20))
    
    var calendarDate:CalendarDate?
    {
        didSet{
            self.label.text = calendarDate?.formatted
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let w:CGFloat = self.bounds.width
        let h:CGFloat = self.bounds.height
        
        let dotsStack = EventDotsStack(frame: CGRect(x:4,y:24,width: 50,height:30))
        dotsStack.events = []
            
        drawLine(
            onLayer: layer,
            fromPoint: CGPoint(x:0, y: h),
            toPoint: CGPoint(x: w, y: h),
            color: UIColor.lightGray.cgColor
        )
        drawLine(
            onLayer: layer,
            fromPoint: CGPoint(x:w, y: 0),
            toPoint: CGPoint(x: w, y: h),
            color: UIColor.lightGray.cgColor
        )
        self.contentView.addSubview(self.label)
        self.contentView.addSubview(dotsStack)
    
    }
    
    override var isSelected: Bool {
        didSet {
            self.backgroundColor = isSelected ? UIColor.red : UIColor.clear
        }
    }


    func drawLine(onLayer layer: CALayer, fromPoint start: CGPoint, toPoint end: CGPoint, color: CGColor) {
        let line = CAShapeLayer()
        let linePath = UIBezierPath()
        linePath.move(to: start)
        linePath.addLine(to: end)
        line.path = linePath.cgPath
        line.fillColor = nil
        line.opacity = 1.0
        line.strokeColor = color
        layer.addSublayer(line)
    }
    
}
