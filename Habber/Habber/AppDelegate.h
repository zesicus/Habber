//
//  AppDelegate.h
//  Habber
//
//  Created by Sunny on 12/15/15.
//  Copyright © 2015 Nine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XMPP.h>
#import "Statics.h"
#import "HabberMessageDelegate.h"
#import "HabberChatDelegate.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, XMPPStreamDelegate> {
    //是否连接状态
    BOOL isOpen;
}

@property (strong, nonatomic) UIWindow *window;

//用于传输xmpp协议数据的封装流。
@property (nonatomic, readonly) XMPPStream *xmppStream;
//密码
@property (nonatomic, strong) NSString *password;

@property (nonatomic, strong) id<HabberChatDelegate> chatDelegate;
@property (nonatomic, strong) id<HabberMessageDelegate> messageDelegate;

//XMPPStream的初始化
- (void)setupStream;

//连接功能
- (BOOL)connect;
- (void)disconnect;

//控制上下线
- (void)goOnline;
- (void)goOffline;

//注册
- (void)signup;

@end

