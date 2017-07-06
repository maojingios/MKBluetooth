//
//  MKSessionFinder.m
//  MKBluetooth
//
//  Created by gw on 2017/7/6.
//  Copyright © 2017年 VS. All rights reserved.
//

/** 物理屏幕宽高**/
#define SCREENW [UIScreen mainScreen].bounds.size.width
#define SCREENH [UIScreen mainScreen].bounds.size.height

#import "MKSessionFinder.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface MKSessionFinder ()<MCSessionDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,MCBrowserViewControllerDelegate>

@property (nonatomic, strong) MCSession * mcSession;
@property (nonatomic, strong) MCBrowserViewController * browserVC;
@property (nonatomic, strong) UIImagePickerController * imagePicker;

@property (nonatomic, weak) UIImageView * showImageView;
@property (nonatomic, weak) UIButton * findBoardCastButton;
@property (nonatomic, weak) UIButton * chooseImageButton;
@property (nonatomic, weak) UIButton * backButton;

@property (nonatomic, weak) UITextView * stateTextView;
@property (nonatomic, copy) NSString * stateString;


@end

@implementation MKSessionFinder

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setUp];
    
    [self finderMcsession];
}
-(void)setUp{


    self.view.backgroundColor = [UIColor whiteColor];
    self.stateTextView.text = @"";
    [self showImageView];
    [self findBoardCastButton];
    [self chooseImageButton];
    [self backButton];

}

-(void)finderMcsession{

    [self mcSession];

}

#pragma mark - 点击事件

-(void)findBoardCast:(UIButton *)sender{
    
    self.stateTextView.text = [self.stateTextView.text stringByAppendingString:@"\n 查找设备"];
    [self presentViewController:self.browserVC animated:YES completion:nil];
    
}
-(void)pickImage:(UIButton *)sender{
    
    [self presentViewController:self.imagePicker animated:YES completion:nil];
    
}
-(void)back:(UIButton *)sender{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - <MCSessionDelegate>

-(void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state{
    
    NSString * string = nil;
    
    switch (state) {
        case MCSessionStateConnected:
        {
            string = @"\n 链接成功";
            [self.browserVC dismissViewControllerAnimated:YES completion:nil];
        }
            break;
        case MCSessionStateConnecting:
        {
            string = @"\n 链接中";
        }
            break;
        case MCSessionStateNotConnected:
        {
            string = @"\n 链接失败";
        }
            break;
            
        default:
            break;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
       
        self.stateTextView.text = [self.stateTextView.text stringByAppendingString:string];
        
    });

}

-(void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID{
    
    UIImage * image = [UIImage imageWithData:data];
    self.showImageView.image = image;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.stateTextView.text = [self.stateTextView.text stringByAppendingString:@"\n 收到数据"];
        
    });
    
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
}

#pragma mark - <MCBrowserViewControllerDelegate>

-(void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController{

    self.stateTextView.text = [self.stateTextView.text stringByAppendingString:@"\n 已经选择"];
    [self.browserVC dismissViewControllerAnimated:YES completion:nil];
}

-(void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController{

    self.stateTextView.text = [self.stateTextView.text stringByAppendingString:@"\n 取消选择"];

    [self.browserVC dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - <UIImagePickerControllerDelegate>

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{

    UIImage * image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self.showImageView setImage:image];
    
    NSError * error = nil;
    [self.mcSession sendData:UIImagePNGRepresentation(image) toPeers:[self.mcSession connectedPeers] withMode:MCSessionSendDataUnreliable error:&error];
    self.stateTextView.text = [self.stateTextView.text stringByAppendingString:@"\n 开始发送数据"];

    if (error) {
        self.stateTextView.text = [self.stateTextView.text stringByAppendingString:@"\n 发送数据失败"];
    }else{
        self.stateTextView.text = [self.stateTextView.text stringByAppendingString:@"\n 发送数据成功"];
    }
    
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];

}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{

    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - 懒加载

-(MCBrowserViewController *)browserVC{
    if (!_browserVC) {
        _browserVC = [[MCBrowserViewController alloc]initWithServiceType:@"cmj-photo" session:self.mcSession];
        _browserVC.delegate = self;
    }
    return _browserVC;
}

-(MCSession *)mcSession{
    if (!_mcSession) {
        MCPeerID * peerid = [[MCPeerID alloc] initWithDisplayName:@"MKin-finder"];
        _mcSession = [[MCSession alloc]initWithPeer:peerid];
        _mcSession.delegate = self;
    }
    return _mcSession;
}

-(UIImagePickerController *)imagePicker{
    if (!_imagePicker) {
        _imagePicker = [[UIImagePickerController alloc]init];
        _imagePicker.delegate = self;
    }
    return _imagePicker;
}

-(UIImageView *)showImageView{
    if (!_showImageView) {
        UIImageView * imageView = [[UIImageView alloc]init];
        _showImageView = imageView;
        _showImageView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _showImageView.frame = CGRectMake(10, 10, SCREENW-20, SCREENH * 0.6);
        [self.view addSubview:_showImageView];
    }
    return _showImageView;
}

-(UIButton *)findBoardCastButton{
    if (!_findBoardCastButton) {
        UIButton * button = [[UIButton alloc]init];
        _findBoardCastButton = button;
        _findBoardCastButton.frame = CGRectMake(10, CGRectGetMaxY(self.showImageView.frame) + 10, 80, 45);
        [_findBoardCastButton setTitle:@"发现设备" forState:UIControlStateNormal];
        [_findBoardCastButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_findBoardCastButton addTarget:self action:@selector(findBoardCast:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_findBoardCastButton];
    }
    return _findBoardCastButton;
}


-(UIButton *)chooseImageButton{
    if (!_chooseImageButton) {
        UIButton * button = [[UIButton alloc]init];
        _chooseImageButton = button;
        _chooseImageButton.frame = CGRectMake(CGRectGetMaxX(self.findBoardCastButton.frame)+10, CGRectGetMaxY(self.showImageView.frame) + 10, 80, 45);
        [_chooseImageButton setTitle:@"选择图片" forState:UIControlStateNormal];
        [_chooseImageButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_chooseImageButton addTarget:self action:@selector(pickImage:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_chooseImageButton];
    }
    return _chooseImageButton;
}

-(UIButton *)backButton{
    if (!_backButton) {
        UIButton * button = [[UIButton alloc]init];
        _backButton = button;
        _backButton.frame = CGRectMake(CGRectGetMaxX(self.chooseImageButton.frame)+10, CGRectGetMaxY(self.showImageView.frame) + 10, 80, 45);
        [_backButton setTitle:@"返回" forState:UIControlStateNormal];
        [_backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_backButton];
    }
    return _backButton;
}
-(UITextView *)stateTextView{
    if (!_stateTextView) {
        UITextView * view = [[UITextView alloc]init];
        _stateTextView = view;
        _stateTextView.editable = NO;
        _stateTextView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _stateTextView.frame = CGRectMake(10, CGRectGetMaxY(self.findBoardCastButton.frame), SCREENW-20, SCREENH * 0.2);
        [self.view addSubview:_stateTextView];
    }
    return _stateTextView;
}

@end
