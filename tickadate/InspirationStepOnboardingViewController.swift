//
//  InspirationStepOnboardingViewController.swift
//  tickadate
//
//  Created by Romain Bessuges-Meusy on 06/06/2017.
//  Copyright © 2017 Agilitation. All rights reserved.
//

import UIKit
import DynamicColor

class InspirationStepOnboardingViewController: OnboardingViewController {
  
  
  
  @IBOutlet weak var exampleFirstCol: UIStackView!
  @IBOutlet weak var exampleSecondCol: UIStackView!
  @IBAction func quitOnboarding(_ sender: Any) {
    
  }
  
  var eventTypeExamples:[EventTypeExample] = []
  
  func fetchEventTypeExamples(completion:@escaping () -> ()) {
    PListParser<[[String:String]]>().parse(filename: "EventTypeExamples") { (result) in
      self.eventTypeExamples = result.map({ (color) -> EventTypeExample in
        return EventTypeExample(name: color["name"]!, color: color["hex"]!)
      })
      completion()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.fetchEventTypeExamples {
      let cut = ceil(Double(self.eventTypeExamples.count) / 2)
      for (index, example) in self.eventTypeExamples.enumerated() {
        let circle:CircleView = CircleView(frame: CGRect(x: 0, y:0, width: 16, height: 16))
        circle.color = DynamicColor(hexString: example.color)
        circle.strokeWidth = 1
        circle.strokeColor = circle.color.lighter()
        circle.isOpaque = false
        circle.addConstraints([
          NSLayoutConstraint(
            item: circle, 
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: 14
          ),
          NSLayoutConstraint(
            item: circle,
            attribute: .width,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: 14
          ),
        ])
        let label:UILabel = UILabel(frame: CGRect(x:0, y:0, width: 300, height: 20))
        label.text = example.name
        label.font = UIFont.systemFont(ofSize: 14, weight: 0)
        label.textColor = UIColor.darkGray
        let exampleView:UIStackView = UIStackView()
        exampleView.axis = .horizontal
        exampleView.distribution = .fill
        exampleView.alignment = .center
        exampleView.spacing = 10
        
        exampleView.addArrangedSubview(circle)
        exampleView.addArrangedSubview(label)
        
        if Double(index) < cut {
          self.exampleFirstCol.addArrangedSubview(exampleView)
        } else {
          self.exampleSecondCol.addArrangedSubview(exampleView)
        }
      }
    }
  }
  

}
