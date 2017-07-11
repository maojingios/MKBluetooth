//
//  CentralViewController.m
//  MKBluetooth
//
//  Created by gw on 2017/7/10.
//  Copyright © 2017年 VS. All rights reserved.
//

#define PeripheralName @"MKin-Peripheral"
#define myServerUUID @"6345F472-5E32-4B42-B363-82E3B2CE374D"
#define myCharacter @"A5C43394-00A3-4381-A7C9-AF574A1F42F5"

#import "CentralViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
@interface CentralViewController ()<CBCentralManagerDelegate,CBPeripheralDelegate>


@property (nonatomic, strong) CBCentralManager * centralManager;
@property (nonatomic, strong) NSMutableArray * peripheralMutableArray;
@property (strong, nonatomic) IBOutlet UITextView *statusTextView;

@end

@implementation CentralViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}

#pragma mark - 点击事件

- (IBAction)startCentral:(UIButton *)sender {

    [self centralManager];

}

#pragma mark - CBCentralManagerDelegate

-(void)centralManagerDidUpdateState:(CBCentralManager *)central{

    switch (central.state) {
        case CBManagerStatePoweredOn:
        {
            [self updateState:@"蓝牙打开"];
            
            /*扫描外部设备*/
            [central scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
            
        }
            break;
            
        default:
            
             [self updateState:@"\n 此设备不支持蓝牙或为打开蓝牙，不能作为外围设备"];
            break;
    }

}

/*
 发现外围设备
 
 @param central           中心设备
 @param peripheral        外围设备
 @param advertisementData 特征数据
 @param RSSI              信号质量（信号强度）
 */

-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI{

    [self updateState:@"发现外围设备"];
    
    /*停止扫描*/
    [self.centralManager stopScan];
    
    /*连接外围设备*/
    
    if(peripheral){//给peripheral强引用
        if (![self.peripheralMutableArray containsObject:peripheral]) {
            
            [self.peripheralMutableArray addObject:peripheral];
        }
    
        [self updateState:@"开始连接外围设备"];
        
        /*开始连接外围设备*/
        [self.centralManager connectPeripheral:peripheral options:nil];
    
    }

}
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{

    [self updateState:@"连接到外围设备"];
    
    /*设置外围代理为当前控制器*/
    peripheral.delegate = self;
    
    /*外围设备开始寻找服务*/
    [peripheral discoverServices:@[[CBUUID UUIDWithString:myServerUUID]]];

}

-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{

    [self updateState:@"链接外围设备失败"];
}

#pragma mark - CBPeripheralDelegate

/*外围设备寻找到服务*/
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{

    [self updateState:@"发现可用服务"];
    
    if(error){
    
        [self updateState:[NSString stringWithFormat:@"外围设备寻找服务过程中出现错误，错误信息：%@",error.localizedDescription]];
    }
    
    /*遍历查找服务*/
    CBUUID * serviceUUID = [CBUUID UUIDWithString:myServerUUID];
    CBUUID * characteristicUUID = [CBUUID UUIDWithString:myCharacter];
    
    for (CBService * service in peripheral.services) {
        
        if ([service.UUID isEqual:serviceUUID]) {
            
            /*外围设备查找制定服务特征*/
            [peripheral discoverCharacteristics:@[characteristicUUID] forService:service];
        }
    }
}

/*
 外围设备寻找到特征值后
 */
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{

    [self updateState:@"外围设备寻找到特征值"];
    
    if (error) {
        
        [self updateState:[NSString stringWithFormat:@"外围设备找到特征值过程出现错误，错误信息：%@",error.localizedDescription]];
    }
    
    /*遍历服务特征中的值*/
    CBUUID * serviceUUID = [CBUUID UUIDWithString:myServerUUID];
    CBUUID * characteristicUUID = [CBUUID UUIDWithString:myCharacter];
    
    if ([service.UUID isEqual:serviceUUID]) {
        
        for (CBCharacteristic * characteristic in service.characteristics) {
            
            if ([characteristic.UUID isEqual:characteristicUUID]) {
                
                /*找到特征值后，将外围设备设为已通知状态,会调用下面代理方法*/
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            }
        }
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{

    [self updateState:@"收到特征值更新。。。"];
    
    if (error) {
        [self updateState:[NSString stringWithFormat:@"更新特征值状态发生错误，错误信息：%@",error.localizedDescription]];
    }
    
    /*给特征值设置新的值*/
    CBUUID * characteristicUUID = [CBUUID UUIDWithString:myCharacter];
    
    if ([characteristic.UUID isEqual:characteristicUUID]) {
        
        if (characteristic.isNotifying) {

            if (characteristic.properties ==CBCharacteristicPropertyNotify) {
                
                [self updateState:@"已订阅特征通知"];
                
                return;
            }
            /*从外围设备读取新值*/
            else if (characteristic.properties ==CBCharacteristicPropertyRead){
            
                /*更新特征值后调用下面代理方法*/
                [peripheral readValueForCharacteristic:characteristic];
            }

        }
        
        else{
        
            [self updateState:@"已停止"];
            
            [self.centralManager cancelPeripheralConnection:peripheral];
        
        }
    }

}
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{

    if (error) {
        
        [self updateState:[NSString stringWithFormat:@"跟新特征值时发现错误，错误信息：%@",error.localizedDescription]];
        
        return;
    }
    
    if (characteristic.value) {
        
        NSString * value = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        
        [self updateState:[NSString stringWithFormat:@"读取到特征值：%@",value]];
    }else{
    
        [self updateState:@"未发现特征值"];
    }

}
#pragma mark - 私有方法

/*
 更新文本状态信息
 */
-(void)updateState:(NSString *)stateString{
    
    self.statusTextView.text = [self.statusTextView.text stringByAppendingString:[NSString stringWithFormat:@"\n %@",stateString]];
}


#pragma mark  - 懒加载

-(NSMutableArray *)peripheralMutableArray{
    if (!_peripheralMutableArray) {
        _peripheralMutableArray = [NSMutableArray array];
    }
    return _peripheralMutableArray;
}

-(CBCentralManager *)centralManager{
    if (!_centralManager) {
        _centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
    }
    return _centralManager;
}

@end
