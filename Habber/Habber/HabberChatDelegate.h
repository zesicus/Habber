//
//  HabberChatDelegate.h
//  Habber
//
//  Created by Sunny on 12/16/15.
//  Copyright © 2015 Nine. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HabberChatDelegate <NSObject>

- (void)newBuddyOnline:(NSString *)buddyName;
- (void)buddyWentOffline:(NSString *)buddyName;
- (void)didDisconnect;
- (void)didConnect;
- (void)receivedFriendRequest:(NSString *)presenceFrom;

@end
