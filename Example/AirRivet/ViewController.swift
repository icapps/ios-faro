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
	let requestController = RequestController<GameScore>(serviceParameters: ParseExampleService <GameScore>())

    override func viewDidLoad() {
        super.viewDidLoad()

		do {
			try requestController.retrieve({ (response) in
				print(response)
			})
		}catch {
			print("-------Error with request------")
		}

    }
}

