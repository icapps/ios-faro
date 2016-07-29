#import "ObjectiveCViewController.h"
/**
 In build settings look at the Module Identifier. This is the one you should use to import swift files from the same target.
 */
#import "Faro_Example-Swift.h"

@interface ObjectiveCViewController ()

@property (strong, nonatomic) IBOutlet UILabel *label;

@end

@implementation ObjectiveCViewController

#pragma mark - View flow

- (void)viewDidLoad {
	[super viewDidLoad];
    
	GameScoreController * controller = [[GameScoreController alloc] init];
	[controller retrieve:^(NSArray<GameScore *> * _Nonnull response) {
        NSLog(@"%@", response);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.label.text = [NSString stringWithFormat:@"Received %lu objects", (unsigned long)response.count];
        });
	} failure:^(NSError * _Nonnull error) {
		NSLog(@"%@", error);
	}];
}

@end
