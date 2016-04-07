# AirRivet

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

1. Create a Model object that complies to protocol `BaseModel`
2. Create a class thtat complies to `ServiceParameters`
3. Do a request like:

```swift
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
```
> *See "(project root)/Example" *

### Documentation

* Of the example can be found in ""(project root)/Example/docs"
* Of the AirRivet pod in "(project root)/Example/Pods/docs"

## Requirements

ios 8 or higher 
## Installation

AirRivet is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "AirRivet"
```

## License

AirRivet is available under the MIT license. See the LICENSE file for more info.
