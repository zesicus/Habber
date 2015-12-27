//
//  AppDelegate.m
//  Habber
//
//  Created by Sunny on 12/15/15.
//  Copyright © 2015 Nine. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate () {
    NSUserDefaults *defaults;
    NSString *userId;
    NSString *pass;
    NSString *server;
    BOOL signupFlag;
}

@property (strong, nonatomic) UIImageView *splashView;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //设置界面显示等，标题栏颜色，状态栏颜色，字体大小等
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:36.0/255 green:36.0/255 blue:36.0/255 alpha:0.9]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:13], NSFontAttributeName, nil] forState:UIControlStateNormal];
    
    //程序打开自动连接服务器
    [self getData];
    if (userId && pass) {
        [self connect];
    }
    signupFlag = NO;
    isOpen = NO;
    [NSThread sleepForTimeInterval:1.5];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [self disconnect];
}

//XMPPStream初始化
- (void)setupStream {
    _xmppStream = [XMPPStream new];
    //设置线程
//    [_xmppStream addDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)];
    //像上面这样，放到其它线程中，那么代理和通知修改界面的时候就会出现问题，至于放到主线程中来，反正它里面集成的多线程操作可以应付消息传递了。
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

- (void)getData {
    //从本地取得用户名密码和服务器地址
    defaults = [NSUserDefaults standardUserDefaults];
    userId = [defaults stringForKey:USERID];
    pass = [defaults stringForKey:PASS];
    server = [defaults stringForKey:SERVER];
}

//发送连接服务器请求
- (BOOL)connect {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"connecting" object:nil];
    [self connectBasement];
    [_chatDelegate didConnect];
    return YES;
}

- (void)signup {
    [self connectBasement];
    
    signupFlag = YES;
}

- (void)connectBasement {
    [self setupStream];
    
    [self getData];
    
    //已经连接就不用再连接了
    if ([_xmppStream isConnected]) {
        return;
    }
    //没有用户名密码我也不去连接
    if (userId == nil || pass == nil) {
        return;
    }
    
    //设置用户
    [_xmppStream setMyJID:[XMPPJID jidWithString:userId]];
    //密码
    _password = pass;
    //设置服务器
    [_xmppStream setHostName:server];
    
    //连接服务器
    NSError *error = nil;
    if (![_xmppStream connectWithTimeout:5.0 error:&error]) {
        NSLog(@"connect-连接 失败 ！！！");
    }
}

- (void)disconnect {
    [self goOffline];
    [_xmppStream disconnect];
    [_chatDelegate didDisconnect];
}

- (void)acceptFriendRequest {
}

//控制上下线
- (void)goOnline {
    //发送在线状态
    XMPPPresence *presence = [XMPPPresence presence];
    [[self xmppStream] sendElement:presence];
}

- (void)goOffline {
    //发送下线状态
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [[self xmppStream] sendElement:presence];
}

#pragma mark - XMPPStreamDelegate实现
- (void)xmppStreamDidConnect:(XMPPStream *)sender {
    isOpen = YES;
    NSError *error = nil;
    //验证密码
    [[self xmppStream] authenticateWithPassword:_password error:&error];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error {
    NSError *err;
    if (signupFlag) {
        if (![_xmppStream registerWithPassword:pass error:&err]) {
            NSLog(@"注册失败！, %@", err);
        }
        signupFlag = NO;
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"authenticateFail" object:nil];
    }
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    [self goOnline];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hasAuthenticated" object:nil];
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error {
    isOpen = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"connectServerFailed" object:nil];
}

- (void)xmppStreamDidRegister:(XMPPStream *)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"registerSuccess" object:nil];
}

- (void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"registerFail" object:nil];
}

//收到消息后把消息传递给代理
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    //解析xml
    NSString *composing = [[message elementForName:@"composing"] stringValue];
    composing = !composing ? @"" : composing;
    NSString *msg = [[message elementForName:@"body"] stringValue];
    msg = !msg ? @"" : msg;
    NSString *img = [[message elementForName:@"image"] stringValue];
    img = !img ? @"" : img;
    NSString *voice = [[message elementForName:@"voice"] stringValue];
    NSString *voiceTime = [[[message elementForName:@"voice"] attributeForName:@"voiceTime"] stringValue];
    if (!voice) {
        voice = @"";
        voiceTime = @"";
    }
    NSString *from = [[message attributeForName:@"from"] stringValue];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:composing forKey:@"composing"];
    [dict setObject:msg forKey:@"msg"];
    [dict setObject:img forKey:@"photo"];
    [dict setObject:voice forKey:@"voice"];
    [dict setObject:voiceTime forKey:@"voiceTime"];
    [dict setObject:from forKey:@"sender"];
    
    [_messageDelegate newMessageReceived:dict];
}

//收到好友状态
- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence {
    //取得好友状态
    NSString *presenceType = [presence type];
    //我的id
    NSString *myId = [[sender myJID] user];
    //对方状态(用user也就相当于强制类型转换成NSString)
    NSString *presenceFromUser = [[presence from] user];
    //如果在列表中把“我”过滤掉
    if (![presenceFromUser isEqualToString:myId]) {
        if ([presenceType isEqualToString:@"available"]) {
            [_chatDelegate newBuddyOnline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, @"thinkdifferent.local"]];
        }
        if ([presenceType isEqualToString:@"unavailable"]) {
            [_chatDelegate buddyWentOffline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, @"thinkdifferent.local"]];
        }
        //收到好友请求
        if ([presenceType isEqualToString:@"subscribe"]) {
            [_chatDelegate receivedFriendRequest:[NSString stringWithFormat:@"%@@%@", presenceFromUser, @"thinkdifferent.local"]];
        }
    }
}

@end
