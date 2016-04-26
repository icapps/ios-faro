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
			try RequestController.retrieve(completion: { (response: [GameScore]) in
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

