//
//  RelativeDateAlertController.swift
//  tickadate
//
//  Created by Romain Bessuges-Meusy on 29/05/2017.
//  Copyright © 2017 Agilitation. All rights reserved.
//

import UIKit

class RelativeDateAlertController: UIAlertController {
  
  var handler:((UIAlertAction, Date) -> Void) = {_,_ in }

  override func viewDidLoad() {
    let labels:[String:String] = [
      "inAWeek": NSLocalizedString("quickDatePicker/inAWeek", comment: "'In a week' action from the quick date picker, +7d"),
      "nextWeek": NSLocalizedString("quickDatePicker/nextWeek", comment: "'Next week' action from the quick date picker, 1st day of next week"),
      "tomorrow": NSLocalizedString("quickDatePicker/tomorrow", comment: "'Tomorrow' action from the quick date picker, +1d"),
      "today": NSLocalizedString("quickDatePicker/today", comment: "'Today' action from the quick date picker, +0d"),
      "yesterday": NSLocalizedString("quickDatePicker/yesterday", comment: "'Yesterday' action from the quick date picker, -1d"),
      ]
    
    self.addAction(QuickDatePickerItem(date: RelativeDate.inAWeek(), label: labels["inAWeek"]!, handler: self.handler).asAlertAction())
    self.addAction(QuickDatePickerItem(date: RelativeDate.nextWeek(), label: labels["nextWeek"]!, handler: self.handler).asAlertAction())
    self.addAction(QuickDatePickerItem(date: RelativeDate.tomorrow(), label: labels["tomorrow"]!, handler: self.handler).asAlertAction())
    self.addAction(QuickDatePickerItem(date: Date(), label: labels["today"]!, handler: self.handler).asAlertAction())
    self.addAction(QuickDatePickerItem(date: RelativeDate.yesterday(), label: labels["yesterday"]!, handler: self.handler).asAlertAction())
    
    self.addAction(UIAlertAction(title: CommonStrings.cancel, style: .cancel, handler: nil))
  
  }
}

class QuickDatePickerItem : NSObject {
  
  var date:Date!
  var label:String!
  var handler: ((UIAlertAction, Date) -> Swift.Void)?
  
  init(date:Date, label:String, handler:((UIAlertAction, Date) -> Swift.Void)? = nil) {
    super.init()
    self.date = date
    self.label = label
    self.handler = handler
  }
  
  func asAlertAction() -> UIAlertAction {
    return UIAlertAction(title: label, style: .default, handler: {
      self.handler?($0, self.date)
    })
  }
}

