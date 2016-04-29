//
//  ViewController.swift
//  AirRivet
//
//  Created by StijnWillems on 04/01/2016.
//  Copyright (c) 2016 StijnWillems. All rights reserved.
//

import UIKit
import AirRivet

class ViewController: UIViewController {
	@IBOutlet var label: UILabel!


    override func viewDidLoad() {
        super.viewDidLoad()

		do {
			try Air.retrieve(succeed: { (response: [GameScore]) in
				print("🎉 successfully retreived \(response.count) objects")
				dispatch.async.main({
					self.label.text = "Received \(response.count) objects"
				})
			})

			try Air.retrieve("pyqCt2ZHWT", succeed: { (response: GameScore) in
				print("🎉 successfully retreived one object \(response.objectId)")
				})

		}catch {
			print("-------Error with request------")
		}

    }
	
}

