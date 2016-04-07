//
//  ICAOBJCViewController.m
//  AirRivet
//
//  Created by Stijn Willems on 07/04/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

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
