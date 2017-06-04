//
//  EventTypeTableViewCell.swift
//  tickadate
//
//  Created by Romain Bessuges-Meusy on 10/05/2017.
//  Copyright © 2017 Agilitation. All rights reserved.
//

import UIKit
import DynamicColor
class EventTypeTableViewCell: BorderedTableViewCell {

    var eventType:EventType? {
        didSet {
            label.text = eventType!.name
            dot.color = DynamicColor(hexString: eventType!.color ?? "000000")
        }
    }
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var dot: CircleView!
}


class EventTypeExampleTableViewCell:BorderedTableViewCell {
  
  var eventTypeExample:EventTypeExample? {
    didSet {
      if let example = eventTypeExample {
        label.text = example.name
        dot.color = DynamicColor(hexString: example.color).tinted(amount:0.5)
      }
    }
  }
  @IBOutlet weak var label: UILabel!
  @IBOutlet weak var dot: CircleView!
}

class EventTypeProgressTableViewCell:BorderedTableViewCell {
  @IBOutlet weak var caption: UILabel!
  @IBOutlet weak var progress: UIProgressView!
}
