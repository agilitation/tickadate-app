//
//  EventDotsStack.swift
//  tickadate
//
//  Created by Romain Bessuges-Meusy on 09/05/2017.
//  Copyright © 2017 Agilitation. All rights reserved.
//

import UIKit
import CoreData
import DynamicColor

class EventDotsStack: UIView {
    
    
    
    var events: [Event] = []
    {
        didSet {
            self.draw(self.bounds)
        }
    }
    
//    func groupEventsByType(_ events:[Event]){
//        var dict:Dictionary<NSManagedObjectID,[Event]> = Dictionary()
//        
//        for event in events {
//            if((dict.index(forKey: (event.type?.objectID)!)) != nil){
//                
//            }
//        }
//        
//    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
//    override func draw(_ rect: CGRect) {
//        self.isOpaque = false
//        for event in events {
//            let dot:EventDot = EventDot()
//            
////            dot.count = 1
//            self.addSubview(dot)
//        }
//    }
    

}
