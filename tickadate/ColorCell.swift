//
//  EKCalendarCell.swift
//  tickadate
//
//  Created by Romain Bessuges-Meusy on 13/05/2017.
//  Copyright © 2017 Agilitation. All rights reserved.
//

import UIKit
import Eureka
import EventKit
import DynamicColor

final class ColorCell: PushSelectorCell<ColorPaletteItem> {

  @IBOutlet weak var circleView: CircleView!
  @IBOutlet weak var titleLabel: UILabel!
  
  required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override func update() {
    super.update()
    titleLabel?.text = row.value?.label
    circleView?.color = UIColor(cgColor: row.value?.color.cgColor ?? UIColor.black.cgColor)
  }
}
