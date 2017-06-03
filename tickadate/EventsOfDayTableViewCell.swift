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
  @IBOutlet weak var detailsLabel: UILabel?
  
  override func layoutSubviews() {
    super.layoutSubviews()
    let corners = DrawUtils.getCorners(fromRect: self.bounds)
    DrawUtils.drawLine(onLayer: self.layer, fromPoint: corners.bottomLeft, toPoint: corners.bottomRight, color: UIColor.black.tinted(amount: 0.8).cgColor)
  }
}
