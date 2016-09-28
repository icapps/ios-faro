//
//  JSONReader.swift
//  Pods
//
//  Created by Ben Algoet on 27/09/16.
//
//

import UIKit

class JSONReader: NSObject {
    static func parseFile(named: String!) -> [String : Any]? {
        do {
            guard let data = NSDataAsset(name: named, bundle: Bundle.init(for: self))?.data else {
                return nil
            }
            
            return try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
        } catch {
            print(FaroError.nonFaroError(error).localizedDescription)
            return nil
        }
    }
}
