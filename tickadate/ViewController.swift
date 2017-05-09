//
//  ViewController.swift
//  tickadate
//
//  Created by Romain Bessuges-Meusy on 08/05/2017.
//  Copyright © 2017 Agilitation. All rights reserved.
//

import UIKit
import CoreData
import DynamicColor


class ViewController: UIViewController {
    
    @IBAction func onTick(_ sender: Any) {
        print("tick")
    }
    
    @IBOutlet weak var daysOfTheWeek: UIStackView!
    
    var appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
       
        //let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

//        let eventType = EventType(context:context)
//        eventType.name = "Fuck"
//        eventType.color = "1134F3"
//        appDelegate.saveContext()
        
        for weekdaySymbol in Calendar.current.shortWeekdaySymbols {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 46, height: 35))
            label.textAlignment = .center
            label.text = weekdaySymbol
            self.daysOfTheWeek.addArrangedSubview(label)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
