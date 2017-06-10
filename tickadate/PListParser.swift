//
//  PListParser.swift
//  tickadate
//
//  Created by Romain Bessuges-Meusy on 02/06/2017.
//  Copyright © 2017 Agilitation. All rights reserved.
//

import UIKit

class PListParser<T>: NSObject {

  func parse(filename:String, completion: @escaping (T?) -> ()) {
    DispatchQueue.main.async {
      completion(self.parseSync(filename: filename))
    }
  }
  
  func parseSync(filename:String) -> T? {
    if let fileUrl = Bundle.main.url(forResource: filename, withExtension: "plist"), let data = try? Data(contentsOf: fileUrl) {
      if let result = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? T {
        return result!
      } else {
        print("could not cast file data to PList")
      }
    } else {
      print("could not fetch data from file", filename)
    }
    
    return nil
  }
}
