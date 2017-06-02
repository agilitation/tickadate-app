//
//  BuyButton.swift
//  tickadate
//
//  Created by Romain Bessuges-Meusy on 01/06/2017.
//  Copyright © 2017 Agilitation. All rights reserved.
//

import UIKit

class BuyButton: UIButton {

  
  override func layoutSubviews() {
    super.layoutSubviews()
    layer.borderColor = self.tintColor.cgColor
    layer.borderWidth = 1
    layer.cornerRadius = 4
  }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
