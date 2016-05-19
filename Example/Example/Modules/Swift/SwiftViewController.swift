//
//  SwiftViewController.swift
//  AirRivet
//
//  Created by Stijn Willems on 04/01/2016.
//  2016 iCapps. MIT Licensed.
//

import UIKit
import AirRivet

class SwiftViewController: UIViewController {
    
    // MARK: - Outlets
    
	@IBOutlet var label: UILabel!

    // MARK: - View flow

    override func viewDidLoad() {
        super.viewDidLoad()

		do {
			try Air.retrieve(succeed: { (response: [GameScore]) in
				print("🎉 successfully retreived \(response.count) objects")
				dispatch.async.main({
					self.label.text = "Received \(response.count) objects"
				})
			})

			try Air.retrieveWithUniqueId("pyqCt2ZHWT", succeed: { (response: GameScore) in
				print("🎉 successfully retreived one object \(response.objectId)")
            })
		} catch {
			print("-------Error with request------")
		}

		//Core data

		do {
			let coreDataEntity = try CoreDataEntity(json: ["objectId": "something fun"])
			print("🏪 Core data entity made successfully. \(coreDataEntity.objectId!)")
		}catch {
			print("💣 \(error)")
		}

    }
	
}

