//
//  ViewController.swift
//  Rivet
//
//  Created by StijnWillems on 04/01/2016.
//  Copyright (c) 2016 StijnWillems. All rights reserved.
//

import UIKit

import Rivet

class ViewController: UIViewController {
	private let serviceParameters = ParseExampleService <GameScore>()
	/**
	The requestController should be owned by an object that lives long engough to receive the response.
	*/
	private var requestController: RequestController!

    override func viewDidLoad() {
        super.viewDidLoad()

		requestController =  RequestController(serviceParameters: serviceParameters)

		let gameScore = GameScore(json: [
			"score": 1337,
			"cheatMode": false,
			"playerName": "Sean Plott"
			])

		do {
			try requestController.save(gameScore, completion: { (response) in
					print(response)
				})

		}catch RequestError.InvalidBody {
			print(RequestError.InvalidBody)
		}catch {
			print("Unknown error")
		}

    }
}

