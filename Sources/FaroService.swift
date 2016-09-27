//
//  FaroService
//  Pods
//
//  Created by Ben Algoet on 27/09/16.
//
//

import UIKit

public struct MockSwitch {
    public static var shouldMock = false
}

open class FaroService: Service {
    
    private static var sharedService: Service?
    
    public init(with baseURL: String) {
        FaroService.sharedService = Service(configuration: Configuration(baseURL: baseURL))
        super.init(configuration: Configuration(baseURL: baseURL))
    }
    
    private static let sharedMockService = MockService()
    
    public static var shared: Service {
        return MockSwitch.shouldMock ? sharedMockService : sharedService!
    }
    
}
