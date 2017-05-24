//
//  StatTableViewCell.swift
//  tickadate
//
//  Created by Romain Bessuges-Meusy on 23/05/2017.
//  Copyright © 2017 Agilitation. All rights reserved.
//

import UIKit

class StatTableViewCell: UITableViewCell {

  @IBInspectable
  var color:UIColor = UIColor.black
  
  @IBInspectable
  var isNegate:Bool = false {
    didSet {
      self.contentView.backgroundColor = isNegate ? color : UIColor.white
    }
  }
  

}
