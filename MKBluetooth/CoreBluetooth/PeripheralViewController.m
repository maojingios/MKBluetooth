//
//  PeripheralViewController.m
//  MKBluetooth
//
//  Created by gw on 2017/7/7.
//  Copyright © 2017年 VS. All rights reserved.
/*1. 创建外围设备CBPeripheralManager对象并指定代理。
 2. 创建特征CBCharacteristic、服务CBSerivce并添加到外围设备
 3. 外围设备开始广播服务（startAdvertisting:）。
 4. 和中央设备CBCentral进行交互。*/

#import "PeripheralViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

#define PeripheralName @"MKin-Peripheral"
#define myServerUUID @"6345F472-5E32-4B42-B363-82E3B2CE374D"
#define myCharacter @"A5C43394-00A3-4381-A7C9-AF574A1F42F5"


@interface PeripheralViewController ()<CBPeripheralManagerDelegate>

@property (nonatomic, strong) CBPeripheralManager * peripheralManager;
@property (nonatomic, strong) CBMutableCharacteristic * characteristic;
@property (nonatomic, strong) NSMutableArray * centralMutableArray;

@property (strong, nonatomic) IBOutlet UITextView *stateTextView;

@end

@implementation PeripheralViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    

}
- (IBAction)creatPeripheral:(UIButton *)sender {

    [self peripheralManager];

}
- (IBAction)updateValueClick:(UIButton *)sender {
    
    [self updateCharactericValue];
}

#pragma mark - CBPeripheralManagerDelegate

-(void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral{
    
    switch (peripheral.state) {
        case CBManagerStatePoweredOn:
        {
        
            [self updateState:@"\n 蓝牙打开"];
            
            /*添加服务*/
            [self setUpService];
            
        }
            break;
        case CBManagerStatePoweredOff:
        {
            [self updateState:@"\n 蓝牙关闭"];
        }
            break;
            
        default:
            [self updateState:@"\n 此设备不支持蓝牙或为打开蓝牙，不能作为外围设备"];
            break;
    }
}

/*
 外围设备添加服务后调用
 */
-(void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error{
    
    if(error){
    
        [self updateState:[NSString stringWithFormat:@"\n 向外围设备添加服务失败--%@",error.localizedDescription]];
        
        return;
    }
    
    /*添加服务后开始广播*/
    NSDictionary * dic = @{CBAdvertisementDataLocalNameKey:PeripheralName};
    [self.peripheralManager startAdvertising:dic];
    
    [self updateState:@"向外围设备添加了服务，并开始广播"];

}
/*
 外围设备开始广播
 */
-(void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error{
    
    if (error) {
        
        [self updateState:[NSString stringWithFormat:@"外围设备广播失败，错误信息=%@",error.localizedDescription]];
    
        return;
    }
    
    [self updateState:@"广播启动"];
}


/*
 向中心设备订阅特征信息
 */
-(void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic{

    [self updateState:[NSString stringWithFormat:@"中心设备：%@ 订阅特征：%@",central,characteristic]];
    
    
    /*发现并存储中心设备*/
    if (![self.centralMutableArray containsObject:central]) {
        [self.centralMutableArray addObject:central];
    }
}

/*
 取消订阅特征
 */
-(void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic{

    [self updateState:@"取消订阅"];
}

-(void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request{

    [self updateState:@"didReceiveReadRequest"];
}

-(void)peripheralManager:(CBPeripheralManager *)peripheral willRestoreState:(NSDictionary<NSString *,id> *)dict{

    [self updateState:@"willRestoreState"];

}
#pragma mark - 私有方法

/*
 更新文本状态信息
 */
-(void)updateState:(NSString *)stateString{

    self.stateTextView.text = [self.stateTextView.text stringByAppendingString:[NSString stringWithFormat:@"\n %@",stateString]];
}

/*
 创建特征、服务并添加进外围设备
 */
-(void)setUpService{

    /*创建特征的UUID对象*/
    CBUUID * characteristicUUID = [CBUUID UUIDWithString:myCharacter];
    
    /*设置特征
      参数
      uuid:特征标识
      properties:特征的属性，例如：可通知、可写、可读等
      value:特征值
      permissions:特征的权限
     */

    
    CBMutableCharacteristic * characteristicM = [[CBMutableCharacteristic alloc] initWithType:characteristicUUID properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
    self.characteristic = characteristicM;
    
    /*创建服务UUID对象*/
    CBUUID * serviceUUID = [CBUUID UUIDWithString:myServerUUID];
    
    /*创建服务*/
    CBMutableService * serviceM = [[CBMutableService alloc]initWithType:serviceUUID primary:YES];
    
    /*设置服务的特征*/
    [serviceM setCharacteristics:@[characteristicM]];
    
    /*将服务添加到外围设备*/
    [self.peripheralManager addService:serviceM];
    
}

/*
 更新特征值
 */
-(void)updateCharactericValue{
    
    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
    dic[@"name"] = @"Mkin";
    dic[@"age"] = @"25";
    dic[@"phoneBrand"] = @"iphone";

    /*特征值*/
    NSString * valueString = [NSString stringWithFormat:@"%@--%@",PeripheralName,[NSDate date]];
    
    NSData * dicData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    
    NSData * value = [valueString dataUsingEncoding:NSUTF8StringEncoding];
    
    /*更新特征值*/
    [self.peripheralManager updateValue:dicData forCharacteristic:self.characteristic onSubscribedCentrals:nil];
    
    /*输出打印*/
    [self updateState:@"更新特征值"];
    
    
}
#pragma mark - 懒加载
-(CBPeripheralManager *)peripheralManager{
    if (!_peripheralManager) {
        _peripheralManager = [[CBPeripheralManager alloc]initWithDelegate:self queue:nil];
        
    }
    return _peripheralManager;
}
-(NSMutableArray *)centralMutableArray{
    if (!_centralMutableArray) {
        _centralMutableArray = [NSMutableArray array];
    }
    return _centralMutableArray;
}


@end
