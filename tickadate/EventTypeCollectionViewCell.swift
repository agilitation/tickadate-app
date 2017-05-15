//
//  EventTypeCollectionViewCell.swift
//  tickadate
//
//  Created by Romain Bessuges-Meusy on 08/05/2017.
//  Copyright © 2017 Agilitation. All rights reserved.
//

import UIKit
import DynamicColor

@IBDesignable
class EventTypeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var eventTypeCircle: CircleView!
    @IBOutlet weak var selectionCircle: CircleView!
    
    func animateSelectionCircle() {
        self.selectionCircle?.alpha = 0.5
        UIView.animate(
            withDuration: 0.5,
            delay: 0.0,
            options: [.repeat, .autoreverse],
            animations: {
               self.selectionCircle?.alpha += 1
            },
            completion: nil
        )
    }
    
    
    override var isSelected: Bool {
        didSet {
            self.selectionCircle?.isHidden = !isSelected
            
            if isSelected {
                animateSelectionCircle()
            }
        }
    }
    
    var color:UIColor = UIColor.red {
        didSet {
            self.eventTypeCircle.color = color
            self.eventTypeCircle.strokeColor = color.darkened(amount: 0.05)
            self.eventTypeCircle.strokeWidth = 2
            
            self.eventTypeCircle.isOpaque = false
            self.selectionCircle.color = color.tinted(amount: 0.9)
        }
    }
    
}
