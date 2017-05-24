//
//  EventTypeTableViewCell.swift
//  tickadate
//
//  Created by Romain Bessuges-Meusy on 10/05/2017.
//  Copyright © 2017 Agilitation. All rights reserved.
//

import UIKit
import DynamicColor
class EventTypeTableViewCell: UITableViewCell {

    var eventType:EventType? {
        didSet {
            label.text = eventType!.name
            dot.color = DynamicColor(hexString: eventType!.color ?? "000000")
        }
    }
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var dot: CircleView!
}
