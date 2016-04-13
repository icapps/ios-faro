# AirRivet

For quick start follow the instructions below. For more in dept info on why and how we build this AirRivet stuff you are more then welcome on the [wiki](https://github.com/icapps/ios-air-rivet/wiki)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

1. Create a Model object that complies to protocol `BaseModel`
2. Create a class that complies to `ServiceParameters`
3. Do a request like:

### Swift
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
### Objective-C
```objective-C
#import "ICAOBJCViewController.h"
/**
 In build settings look at the Module Identifier. This is the one you should use to import swift files from the same target.
 */
#import "AirRivet_Example-Swift.h"

@implementation ICAOBJCViewController

- (void)viewDidLoad {
	[ super viewDidLoad];
	GameScoreController * controller = [[GameScoreController alloc] init];

	[controller retrieve:^(NSArray<GameScore *> * _Nonnull response) {
		NSLog(@"%@", response);
	} failure:^(NSError * _Nonnull error) {
		NSLog(@"%@", error);
	}];
}
@end
```
> *See "(project root)/Example" *

### Documentation

* Of the example can be found in [(project root)/Example/docs](http://htmlpreview.github.io/?https://github.com/icapps/ios-air-rivet/blob/master/Example/docs/index.html)
* Of the AirRivet pod in [(project root)/Example/Pods/docs](http://htmlpreview.github.io/?https://github.com/icapps/ios-air-rivet/blob/master/Example/Pods/docs/index.html)

## Requirements

iOS 8 or higher
Because we use generics you can only use this pod in Swift only files. You can mix and Match with Objective-C but not with generic classes.  Types [More info](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/BuildingCocoaApps/InteractingWithObjective-CAPIs.html#//apple_ref/doc/uid/TP40014216-CH4-ID53)

## Installation

AirRivet is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "AirRivet"
```
## Contribution
> Don't think to hard, try hard!

More info on [3 step contribution guidelines](https://github.com/icapps/ios-air-rivet/wiki/Contribution)
## License

AirRivet is available under the MIT license. See the LICENSE file for more info.
