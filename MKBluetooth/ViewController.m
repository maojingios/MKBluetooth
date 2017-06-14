

#import "ViewController.h"
#import "CGPeerViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
   
}
- (IBAction)GKPeerButtonClick:(UIButton *)sender {
    
    CGPeerViewController * cgpeerViewController = [[CGPeerViewController alloc] init];
    [self presentViewController:cgpeerViewController animated:YES completion:nil];
    
}

- (IBAction)MultipeerButtonClick:(UIButton *)sender {
    
}

- (IBAction)CoreBluetoothButtonClick:(UIButton *)sender {

}



@end
