//
//  BorderedTableViewCell.swift
//  tickadate
//
//  Created by Romain Bessuges-Meusy on 04/06/2017.
//  Copyright © 2017 Agilitation. All rights reserved.
//

import UIKit

class BorderedTableViewCell: UITableViewCell {

  override func layoutSubviews() {
    super.layoutSubviews()
    let corners = DrawUtils.getCorners(fromRect: self.bounds)
    DrawUtils.drawLine(onLayer: self.layer, fromPoint: corners.bottomLeft, toPoint: corners.bottomRight, color: UIColor.black.tinted(amount: 0.8).cgColor)
  }
  
  
}
