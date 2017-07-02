/*
ultipeerConnectivity 准确的说它是一种支持Wi-Fi网络、P2P Wi-Fi已经蓝牙个人局域网的通信框架，
 ultipeerConnectivity的使用必须要清楚一个概念：广播（Advertisting）和发现（Disconvering），这很类似于一种Client-Server模式。假设有两台设备A、B，B作为广播去发送自身服务，A作为发现的客户端。一旦A发现了B就试图建立连接，经过B同意二者建立连接就可以相互发送数据。在使用GameKit框架时，A和B既作为广播又作为发现，当然这种情况在MultipeerConnectivity中也很常见。
 
 */

#import "MKMultiPeersConnectivity.h"

@implementation MKMultiPeersConnectivity

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
