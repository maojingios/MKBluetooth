//
//  MKMultiPeersBoardcarst.m
//  MKBluetooth
//
//  Created by gw on 2017/7/6.
//  Copyright © 2017年 VS. All rights reserved.
//

/** 物理屏幕宽高**/
#define SCREENW [UIScreen mainScreen].bounds.size.width
#define SCREENH [UIScreen mainScreen].bounds.size.height

#import "MKMultiPeersBoardcarst.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface MKMultiPeersBoardcarst ()<MCSessionDelegate,MCAdvertiserAssistantDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (nonatomic, strong) MCSession * mcsession;
@property (nonatomic, strong) MCAdvertiserAssistant * adAssistant;
@property (nonatomic, strong) UIImagePickerController * imagePicker;
@property (nonatomic, weak) UIImageView * showImageView;
@property (nonatomic, weak) UIButton * startBoardCastButton;
@property (nonatomic, weak) UIButton * chooseImageButton;
@property (nonatomic, weak) UIButton * backButton;

@property (nonatomic, weak) UITextView * stateTextView;
@property (nonatomic, copy) NSString * stateString;



@end

@implementation MKMultiPeersBoardcarst

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUp];//UI
    [self boardCarst];//boardCast
    
}

-(void)setUp{
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.stateTextView.text = @"";
    [self showImageView];
    [self startBoardCastButton];
    [self chooseImageButton];
    [self backButton];
    [self stateTextView];
}

-(void)boardCarst{
    
    //创建节点
    [self mcsession];
    
    //创建广播
    [self adAssistant];
}

#pragma mark - 点击事件

-(void)startBoardCast:(UIButton *)sender{
    
    self.stateTextView.text = [self.stateTextView.text stringByAppendingString:@"\n 广播启动"];
    [self.adAssistant start];
    
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
        case MCSessionStateNotConnected:// Not connected to the session.
        {
            string = @"\n 连接失败";
        }
            break;
        case MCSessionStateConnected:// Peer is connected to the session.
        {
            string = @"\n 连接成功";
        }
            break;
        case MCSessionStateConnecting:// Peer is connecting to the session.
        {
            string = @"\n 正在连接";
        }
            break;
            
        default:
            break;
    }
    
    //回主线程处理UI事情
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.stateTextView.text = [self.stateTextView.text stringByAppendingString:string];
        
    });
    
}
-(void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID{
    UIImage *image = [UIImage imageWithData:data];
    self.showImageView.image = image;
    
    //保存相册
    UIImageWriteToSavedPhotosAlbum(image, nil, @selector(saveComplete), nil);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.stateTextView.text = [self.stateTextView.text stringByAppendingString:@"\n 收到数据"];
    });
    
}


-(void)saveComplete{
    
    NSLog(@"图片保存成功");
}
#pragma mark - <MCAdvertiserAssistantDelegate>


#pragma mark - <UINavigationControllerDelegate,UIImagePickerControllerDelegate>

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    //获取图片
    UIImage * image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self.showImageView setImage:image];
    
    //发送数据
    NSError * error =nil;
    [self.mcsession sendData:UIImagePNGRepresentation(image) toPeers:[self.mcsession connectedPeers] withMode:MCSessionSendDataUnreliable error:&error];
    
    if (error) {
        self.stateTextView.text = [self.stateTextView.text stringByAppendingString:@"\n 发送失败"];
    }else{
        self.stateTextView.text = [self.stateTextView.text stringByAppendingString:@"\n 发送成功"];
    }
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    NSLog(@"取消获取图片");
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 懒加载

-(UIImagePickerController *)imagePicker{
    if (!_imagePicker) {
        _imagePicker = [[UIImagePickerController alloc]init];
        _imagePicker.delegate = self;
    }
    return _imagePicker;
}

-(MCSession *)mcsession{
    if (!_mcsession) {
        self.stateTextView.text = [self.stateTextView.text stringByAppendingString:@"\n 创建session"];
        MCPeerID * peerid = [[MCPeerID alloc] initWithDisplayName:@"MKin-BoardCarst"];
        _mcsession  = [[MCSession alloc]initWithPeer:peerid];
        _mcsession.delegate = self;
    }
    return _mcsession;
}

-(MCAdvertiserAssistant *)adAssistant{
    if (!_adAssistant) {
        _adAssistant = [[MCAdvertiserAssistant alloc]initWithServiceType:@"cmj-photo" discoveryInfo:nil session:self.mcsession];
        _adAssistant.delegate = self;
        self.stateTextView.text = [self.stateTextView.text stringByAppendingString:@"\n 创建广播"];
    }
    return _adAssistant;
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

-(UIButton *)startBoardCastButton{
    if (!_startBoardCastButton) {
        UIButton * button = [[UIButton alloc]init];
        _startBoardCastButton = button;
        _startBoardCastButton.frame = CGRectMake(10, CGRectGetMaxY(self.showImageView.frame) + 10, 80, 45);
        [_startBoardCastButton setTitle:@"发广播" forState:UIControlStateNormal];
        [_startBoardCastButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_startBoardCastButton addTarget:self action:@selector(startBoardCast:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_startBoardCastButton];
    }
    return _startBoardCastButton;
}


-(UIButton *)chooseImageButton{
    if (!_chooseImageButton) {
        UIButton * button = [[UIButton alloc]init];
        _chooseImageButton = button;
        _chooseImageButton.frame = CGRectMake(CGRectGetMaxX(self.startBoardCastButton.frame)+10, CGRectGetMaxY(self.showImageView.frame) + 10, 80, 45);
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
        _stateTextView.frame = CGRectMake(10, CGRectGetMaxY(self.startBoardCastButton.frame), SCREENW-20, SCREENH * 0.2);
        [self.view addSubview:_stateTextView];
    }
    return _stateTextView;
}
@end
