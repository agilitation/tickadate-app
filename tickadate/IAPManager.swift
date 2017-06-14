//
//  IAPManager.swift
//  tickadate
//
//  Created by Romain Bessuges-Meusy on 02/06/2017.
//  Copyright © 2017 Agilitation. All rights reserved.
//

import UIKit
import StoreKit
import SwiftyStoreKit
import SwiftKeychainWrapper

enum ProductIDs : String {
  case threeAdditionalEventTypes = "com.agilitation.tickadate.3AdditionalEventTypes"
  case unlimitedEventTypes = "com.agilitation.tickadate.unlimited"
  case additionalColorSwatch = "com.agilitation.tickadate.additionalColorSwatch"
}

enum ConsumableIAPurchasesKeys:String {
  case eventTypesCount = "com.agilitation.tickadate.eventTypesCount"
  case colorSwatches = "com.agilitation.tickadate.colorSwatches"
}

class IAPManager: NSObject {
  
  static let shared:IAPManager = IAPManager()
  
  var shouldBypassITunesStore = false
  
  var activeColorSwatches:[ColorSwatch] = []
  
  var eventTypesCount:Int {
    get { return UserDefaults.standard.integer(forKey: "eventTypesCount") }
    set {
      UserDefaults.standard.set(newValue, forKey: "eventTypesCount")
      // Store eventTypesCount in keychain to restore the consumable IAP
      KeychainWrapper.standard.set(newValue, forKey: ConsumableIAPurchasesKeys.eventTypesCount.rawValue)
    }
  }
  
  var hasUnlimitedEventTypes: Bool {
    get { return UserDefaults.standard.bool(forKey: "unlimitedEventTypes") }
    set { UserDefaults.standard.set(newValue, forKey: "unlimitedEventTypes") }
  }
  
  var activeColorSwatchesIds:NSMutableArray {
    get { return UserDefaults.standard.mutableArrayValue(forKey: "activeColorSwatches") }
  }
  
  var products:[String:SKProduct] = [:]
  
  var nc:NotificationCenter = NotificationCenter.default
  
  func reset() {
    
    self.hasUnlimitedEventTypes = false
    
    SwiftyStoreKit.restorePurchases { (results) in
      print("restorePurchasesResult", results)
      results.restoredPurchases.forEach({ (purchase) in
        if purchase.productId == ProductIDs.unlimitedEventTypes.rawValue {
          self.hasUnlimitedEventTypes = true
        }
      })
    }
    
    self.activeColorSwatchesIds.removeAllObjects()
    
    if let colorSwatchesInKeychain = KeychainWrapper.standard.string(forKey: ConsumableIAPurchasesKeys.colorSwatches.rawValue) {
      print ("colorSwatchesInKeychain", colorSwatchesInKeychain)
      activeColorSwatchesIds.addObjects(from: colorSwatchesInKeychain.components(separatedBy: ";"))
    } else {
      self.activeColorSwatchesIds.add("iOS")
    }
    
    if let eventTypesCountInKeychain = KeychainWrapper.standard.integer(forKey: ConsumableIAPurchasesKeys.eventTypesCount.rawValue) {
      print("eventTypesCountInKeychain", eventTypesCountInKeychain)
      self.eventTypesCount = eventTypesCountInKeychain
    } else {
      self.eventTypesCount = 3
    }
    
  }
  
  func buyAdditionalColorSwatch(id:String, completion: @escaping () -> ()){
    self.purchase(.additionalColorSwatch) {
      self.activeColorSwatchesIds.add(id)
      self.nc.post(name: NSNotification.Name("colorSwatches.change"), object: self)
      // Store colorSwatches in keychain to restore the consumable IAP
      print(self.activeColorSwatchesIds.componentsJoined(by: ";"))
      KeychainWrapper.standard.set(self.activeColorSwatchesIds.componentsJoined(by: ";"), forKey: ConsumableIAPurchasesKeys.colorSwatches.rawValue)
      completion()
    }
  }
  
  func retreiveProductsInfo(completion: @escaping () -> ()) {
    
    if products.count > 0 {
      completion()
      return
    }
    
    SwiftyStoreKit.retrieveProductsInfo([
      ProductIDs.threeAdditionalEventTypes.rawValue,
      ProductIDs.unlimitedEventTypes.rawValue,
      ProductIDs.additionalColorSwatch.rawValue,
      ]) { result in
        result.retrievedProducts.forEach({ (product) in
          self.products[product.productIdentifier] = product
        })
        completion()
    }
  }
  
  func purchase(_ productID:ProductIDs, completion: @escaping () -> ()){
    
    if shouldBypassITunesStore {
      completion()
      return
    }
    retreiveProductsInfo {
      if self.products[productID.rawValue] == nil {
        print("no product found for ID", productID.rawValue)
        return
      }
      SwiftyStoreKit.purchaseProduct(self.products[productID.rawValue]!, completion: { (result) in
        switch result {
        case .success(let purchase):
          if productID == .threeAdditionalEventTypes {
            self.eventTypesCount = self.eventTypesCount + 3
            self.nc.post(name: Notification.Name("eventTypes.change"), object: nil)
          }
          
          if productID == .unlimitedEventTypes {
            self.hasUnlimitedEventTypes = true
            self.nc.post(name: Notification.Name("eventTypes.change"), object: nil)
          }
          
          print("Purchase Success: \(purchase.productId)")
          completion()
        case .error(let error):
          switch error.code {
          case .unknown: print("Unknown error. Please contact support")
          case .clientInvalid: print("Not allowed to make the payment")
          case .paymentCancelled: break
          case .paymentInvalid: print("The purchase identifier was invalid")
          case .paymentNotAllowed: print("The device is not allowed to make the payment")
          case .storeProductNotAvailable: print("The product is not available in the current storefront")
          case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
          case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
          case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
          }
        }
      })
    }
    
  }
  
}
