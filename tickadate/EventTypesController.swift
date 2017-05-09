//
//  EventTypesCollectionViewDataSource.swift
//  tickadate
//
//  Created by Romain Bessuges-Meusy on 08/05/2017.
//  Copyright © 2017 Agilitation. All rights reserved.
//

import UIKit
import CoreData
import DynamicColor

class EventTypesController: UICollectionViewController {

    var context:NSManagedObjectContext! = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var eventTypes:[EventType] = []
    
    override func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "eventTypeCell",
            for: indexPath as IndexPath
            ) as! EventTypeCollectionViewCell
        
        
        
        cell.color = DynamicColor(hexString: eventTypes[indexPath.item].color!)
        
        return cell
        
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        getData()
        return eventTypes.count
    }
    
    func getData() {
        eventTypes = try! context.fetch(EventType.fetchRequest())
    }

}
