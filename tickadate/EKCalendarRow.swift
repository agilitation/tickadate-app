//
//  EKCalendarRow.swift
//  tickadate
//
//  Created by Romain Bessuges-Meusy on 13/05/2017.
//  Copyright © 2017 Agilitation. All rights reserved.
//

import UIKit
import Eureka

final class EKCalendarRow: Row<EKCalendarCell>, RowType {
  required init(tag: String?) {
    super.init(tag: tag)
    cellProvider = CellProvider<EKCalendarCell>(nibName: "EKCalendarCell")
  }
}
