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

protocol EventTypesControllerDelegate {
    func eventTypesController(_ eventTypesController: EventTypesController, didSelectEventType eventType: EventType)
}

class EventTypesController: UICollectionViewController {

    var delegate:EventTypesControllerDelegate?
    var context:NSManagedObjectContext! = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var eventTypes:[EventType] = []
    var dataController:DataController!
    var selectedEventType:EventType!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataController = DataController()
        self.eventTypes = dataController.fetchActiveEventTypes()
    }
    
    override func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        eventTypes = dataController.fetchActiveEventTypes()
        if eventTypes.count == 0 {
            return
        }
        
        let index:Int = (selectedEventType != nil) ? eventTypes.index(of: selectedEventType) ?? 0 : 0
        let indexPath = IndexPath(item: index, section: 0)
        
        collectionView?.selectItem(at: indexPath, animated: animated, scrollPosition: .centeredHorizontally)
        selectEventTypeAt(indexPath: indexPath)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if eventTypes.count == indexPath.item {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "addEventTypeCell", for: indexPath) 
        }
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "eventTypeCell",
            for: indexPath as IndexPath
            ) as! EventTypeCollectionViewCell
        
        cell.color = DynamicColor(hexString: eventTypes[indexPath.item].color ?? "000000")
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataController.fetchActiveEventTypes().count + 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // in case we're selecting a placeholder, do nothing
        if indexPath.item >= eventTypes.count {
            return
        }
        selectEventTypeAt(indexPath: indexPath)
    }
    
    
    func selectEventTypeAt(indexPath: IndexPath){
        selectedEventType = eventTypes[indexPath.item]
        self.collectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        self.delegate?.eventTypesController(self, didSelectEventType: selectedEventType)
    }
    
    func reloadData() {
        eventTypes = dataController.fetchActiveEventTypes()
        collectionView!.reloadData()
    }
}
