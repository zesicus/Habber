//
//  HabberMessageDelegate.h
//  Habber
//
//  Created by Sunny on 12/16/15.
//  Copyright © 2015 Nine. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HabberMessageDelegate <NSObject>

//就只负责聊天数据的传送
- (void)newMessageReceived:(NSDictionary *)messageContent;

@end
