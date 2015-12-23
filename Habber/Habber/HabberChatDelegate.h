//
//  HabberChatDelegate.h
//  Habber
//
//  Created by Sunny on 12/16/15.
//  Copyright © 2015 Nine. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HabberChatDelegate <NSObject>

//传递上线人的名字
- (void)newBuddyOnline:(NSString *)buddyName;
//传递下线人的名字
- (void)buddyWentOffline:(NSString *)buddyName;
//发送与服务器断开连接的信息
- (void)didDisconnect;
//发送与服务器连接的信息
- (void)didConnect;
//传送好友申请信息
- (void)receivedFriendRequest:(NSString *)presenceFrom;

@end
