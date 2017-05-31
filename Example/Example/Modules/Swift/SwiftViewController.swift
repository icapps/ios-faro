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

	@IBOutlet var label: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

		doExample()
		doCoreDataExample()
		doStoreJSONExample()

    }

	func doExample() {
		do {
			try Air.fetch(succeed: { (response: [GameScore]) in
				print("🎉 successfully fetched \(response.count) objects")
				dispatch.async.main({
					self.label.text = "Received \(response.count) objects"
				})
			})

			try Air.fetchWithUniqueId("pyqCt2ZHWT", succeed: { (response: GameScore) in
				print("🎉 successfully fetched one object \(response.uniqueValue ?? "")")
			})
		} catch {
			print("💣 Error with request \(error)")
		}
	}

	func doCoreDataExample() {
		do {
			let coreDataEntity = try CoreDataEntity(json: ["uniqueValue": "something fun"])
			coreDataEntity.username = "Fons"
			print("🏪 Core data entity made successfully. \(coreDataEntity.username!)")
			//Saving all the time is no fun. But it works:). Uncomment if you want to save

			//			try Air.post(coreDataEntity,
			//			             succeed: { (response) in
			//					print("🎉 saved CoreDataEntity")
			//				})
			try Air.fetch(succeed: { (response: [CoreDataEntity]) in
				print("🎉 fetched CoreDataEntities: \(response)")
			})
		} catch {
			print("💣 \(error)")
		}
	}

	func doStoreJSONExample () {
		do {
			try Air.fetch(succeed: { (_: [GameScoreStore]) in
				print("🎉 fetched 'GameScoreStore' objects")
				print("Go take a look at the JSON file")
				print("1. Go to appliction bundle")
				print("2. Go to documents folder")
			})
		} catch {
			print("💣 [doStoreJSONExample] error: \(error)")
		}
	}

}
