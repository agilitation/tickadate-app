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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
