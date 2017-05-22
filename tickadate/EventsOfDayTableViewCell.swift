//
//  EventsOfDayTableViewCell.swift
//  tickadate
//
//  Created by Romain Bessuges-Meusy on 21/05/2017.
//  Copyright © 2017 Agilitation. All rights reserved.
//

import UIKit

class EventsOfDayTableViewCell: UITableViewCell {

  
  @IBOutlet weak var border: UIView!
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var eventTypeLabel: UILabel!
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
