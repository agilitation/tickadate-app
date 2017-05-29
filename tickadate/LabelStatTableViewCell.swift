//
//  LabelStatTableViewCell.swift
//  tickadate
//
//  Created by Romain Bessuges-Meusy on 23/05/2017.
//  Copyright © 2017 Agilitation. All rights reserved.
//

import UIKit

class LabelStatTableViewCell: StatTableViewCell {

  @IBOutlet weak var label: UILabel!
  @IBOutlet weak var value: UILabel!
  
  override func layoutSubviews() {
    super.layoutSubviews()
    label.textColor = isNegate ? UIColor.white : UIColor.black
    value.textColor = isNegate ? UIColor.white : color
  }
}
