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
  var addEventTypeCellCount:Int = 3
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.dataController = DataController()
    dataController.fetchActiveEventTypes(completion: { (eventTypes) in
      self.eventTypes = eventTypes
      self.reloadData()
    })
  }
  
  override func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
    return false
  }
  
  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 3
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    dataController.fetchActiveEventTypes(completion: { (eventTypes) in
      if eventTypes.count == 0 {
        return
      }
      
      let index:Int = (self.selectedEventType != nil) ? eventTypes.index(of: self.selectedEventType) ?? 0 : 0
      let indexPath = IndexPath(item: index, section: 1)
      
      self.collectionView?.reloadData()
      self.selectEventTypeAt(indexPath: indexPath, animated: animated)
    })
    
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    if indexPath.section == 0 {
      return collectionView.dequeueReusableCell(withReuseIdentifier: "settingsCell", for: indexPath)
    }
    
    if indexPath.section == 2 {
      return collectionView.dequeueReusableCell(withReuseIdentifier: "addEventTypeCell", for: indexPath)
    }
    
    
    let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: "eventTypeCell",
      for: indexPath
      ) as! EventTypeCollectionViewCell
    
    cell.color = DynamicColor(hexString: eventTypes[indexPath.item].color ?? "000000")
    return cell
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    switch section {
    case 0: return 1
    case 1: return eventTypes.count
    case 2: return addEventTypeCellCount
    default: return 0
    }
  }
  
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    // in case we're selecting a placeholder, do nothing
    if indexPath.section != 1 {
      return
    }
    selectEventTypeAt(indexPath: indexPath)
  }
  
  
  func selectEventTypeAt(indexPath: IndexPath, animated: Bool = true){
    selectedEventType = eventTypes[indexPath.item]
    self.collectionView?.selectItem(at: indexPath, animated: animated, scrollPosition: .centeredHorizontally)
    self.delegate?.eventTypesController(self, didSelectEventType: selectedEventType)
  }
  
  func reloadData() {
    dataController.fetchActiveEventTypes { (eventTypes) in
      self.eventTypes = eventTypes
      self.collectionView!.reloadData()
    }
  }
}


@IBDesignable
class SettingsCogWheel: UIView {
  
  override func draw(_ rect: CGRect) {
    StyleKit.drawCogWheel()
  }
}

