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

	let request = RequestController() //TODO: remove the need for this owning thing.

    override func viewDidLoad() {
        super.viewDidLoad()

		do {
			try request.retrieve({ (response: [GameScore]) in
				print(response)
				dispatch.async.main({ 
					self.label.text = "Received \(response.count) objects"
				})
			})
		}catch {
			print("-------Error with request------")
		}

    }
	
}

