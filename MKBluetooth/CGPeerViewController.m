//
//  CGPeerViewController.m
//  MKBluetooth
//
//  Created by gw on 2017/6/12.
//  Copyright © 2017年 VS. All rights reserved.
//

/** 物理屏幕宽高**/
#define SCREENW [UIScreen mainScreen].bounds.size.width
#define SCREENH [UIScreen mainScreen].bounds.size.height


#import "CGPeerViewController.h"
#import <GameKit/GameKit.h>


@interface CGPeerViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,GKPeerPickerControllerDelegate>

@property (nonatomic, readwrite, weak) UIImageView * transforImageView;
@property (nonatomic, readwrite, weak) UIButton * transforButton;
@property (nonatomic, readwrite, weak) UIButton * backButton;
@property (nonatomic, readwrite, weak) UIButton * connectButton;
@property (nonatomic, readwrite, weak) UIButton * selectePictureButton;
@property (nonatomic, readwrite, strong) GKSession * bluetoothSession;


@end

@implementation CGPeerViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setUp];
}

#pragma Mark - 初始化

-(void)setUp{
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self transforImageView];
    [self backButton];
    [self selectePictureButton];
    [self transforButton];
    [self connectButton];

}
#pragma mark - 点击事件
-(void)backMainMenu:(UIButton *)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)selectePictureFromAlbum:(UIButton *)sender{
    
    UIImagePickerController * pickViewController = [[UIImagePickerController alloc]init];
    pickViewController.delegate = self;
    [self presentViewController:pickViewController animated:YES completion:nil];
}
-(void)sendData:(UIButton *)sender{

    NSData * pictureData = UIImagePNGRepresentation(self.transforImageView.image);
    if (pictureData) {
        NSError * error = nil;
        [self.bluetoothSession sendDataToAllPeers:pictureData withDataMode:GKSendDataReliable error:&error];
        if (error) {
            NSLog(@"传输失败%@",error.localizedDescription);
        }
    }
}
-(void)startMatch:(UIButton *)sender{
    
    GKPeerPickerController * gkpeerVireController = [[GKPeerPickerController alloc] init];
    gkpeerVireController.delegate = self;
    [gkpeerVireController show];
}
#pragma mark - delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo NS_DEPRECATED_IOS(2_0, 3_0);{

}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    self.transforImageView.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self dismissViewControllerAnimated:YES completion:nil]; 
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession:(GKSession *)session {
    self.bluetoothSession = session;
    [self.bluetoothSession setDataReceiveHandler:self withContext:nil];
    [picker dismiss];//链接成功关闭窗口
}
- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker {

    NSLog(@"cancel");
}

/**
 *当前设备收到数据调用
 *data 收到数据
 *peer 另外一台设备 实例：“1107661370”
 *session 建立蓝牙连接
 */
- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context{

    UIImage *image=[UIImage imageWithData:data];
    self.transforImageView.image=image;
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    
    [self setUp];
}



#pragma mark - 懒加载

-(UIImageView *)transforImageView{
    if (!_transforImageView) {
        
        UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(20, 60, SCREENW-40, SCREENH-120)];
        _transforImageView = imageView;
        _transforImageView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [self.view addSubview:_transforImageView];
    }
    return _transforImageView;
}

-(UIButton *)transforButton{
    if (!_transforButton) {
        UIButton * button = [[UIButton alloc]initWithFrame:CGRectMake(140, SCREENH-50, 60, 45)];
        _transforButton = button;
        [_transforButton setTitle:@"发送" forState:UIControlStateNormal];
        [_transforButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_transforButton addTarget:self action:@selector(sendData:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_transforButton];
    }
    return _transforButton;
}
-(UIButton *)selectePictureButton{
    if (!_selectePictureButton) {
        UIButton * button = [[UIButton alloc]initWithFrame:CGRectMake(10, SCREENH-50, 120, 45)];
        _selectePictureButton = button;
        [_selectePictureButton setTitle:@"打开相册" forState:UIControlStateNormal];
        [_selectePictureButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_selectePictureButton addTarget:self action:@selector(selectePictureFromAlbum:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_selectePictureButton];
    }
    return _selectePictureButton;
}

-(UIButton *)backButton{
    if (!_backButton) {
        UIButton * button = [[UIButton alloc]initWithFrame:CGRectMake(10, 10, 60, 45)];
        _backButton = button;
        [_backButton setTitle:@"返回" forState:UIControlStateNormal];
        [_backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(backMainMenu:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_backButton];
    }
    return _backButton;
}

-(UIButton *)connectButton{
    if (!_connectButton) {
        UIButton * button = [[UIButton alloc]initWithFrame:CGRectMake(80, 10, 150, 45)];
        _connectButton = button;
        [_connectButton setTitle:@"启动链接" forState:UIControlStateNormal];
        [_connectButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_connectButton addTarget:self action:@selector(startMatch:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_connectButton];
    }
    return _connectButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

@end
