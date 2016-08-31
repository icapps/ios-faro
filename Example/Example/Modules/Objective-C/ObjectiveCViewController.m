
#import "ObjectiveCViewController.h"

/// In build settings look at the Module Identifier. This is the one you should use to import swift files from the same target.
#import "Faro_Example-Swift.h"

@interface ObjectiveCViewController ()

@property (strong, nonatomic) IBOutlet UILabel *label;

@end

@implementation ObjectiveCViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    WrapToObjectiveC * wrapper = [[WrapToObjectiveC alloc] init];

    [wrapper serve:^(Model * _Nonnull model) {
        self.label.text = model.value;
    } failure:^{
        NSLog(@"💣 damn this should not happen");
    }];
}

@end
