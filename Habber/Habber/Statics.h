//
//  Statics.h
//  Habber
//
//  Created by Sunny on 12/16/15.
//  Copyright © 2015 Nine. All rights reserved.
//

#import <Foundation/Foundation.h>
//这里有三个，专门用于当做存储userDefaults的键值使用
static NSString *USERID = @"userId";
static NSString *PASS= @"pass";
static NSString *SERVER = @"server";

@interface Statics : NSObject

//获得当前时间
+ (NSString *)getCurrentTime;

@end
