

#import "ViewController.h"
#import "CGPeerViewController.h"
#import "MKMultiPeersBoardcarst.h"
#import "MKSessionFinder.h"

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
- (IBAction)multiPeerADAssistant:(UIButton *)sender {
    
    [self presentViewController:[MKMultiPeersBoardcarst new] animated:YES completion:nil];
}
- (IBAction)multiPeerBrowser:(UIButton *)sender {
    
    [self presentViewController:[MKSessionFinder new] animated:YES completion:nil];
}


- (IBAction)CoreBluetoothButtonClick:(UIButton *)sender {

}



@end
