//
//  ChatModel.m
//  UUChatTableView
//
//  Created by shake on 15/1/6.
//  Copyright (c) 2015年 uyiuyao. All rights reserved.
//

#import "ChatModel.h"

#import "UUMessage.h"
#import "UUMessageFrame.h"

@implementation ChatModel

static NSString *previousTime = nil;

- (void)loadDataSource {
    self.dataSource = [NSMutableArray array];
}

// 添加自己的item
- (void)addSpecifiedItem:(NSDictionary *)dic
{
    UUMessageFrame *messageFrame = [[UUMessageFrame alloc]init];
    UUMessage *message = [[UUMessage alloc] init];
    NSMutableDictionary *dataDic = [NSMutableDictionary dictionaryWithDictionary:dic];
    
    if ([[dic objectForKey:@"sender"] isEqualToString:@"Me"]) {
        [dataDic setObject:@(UUMessageFromMe) forKey:@"from"];
    } else {
        [dataDic setObject:@(UUMessageFromOther) forKey:@"from"];
    }
    [dataDic setObject:[[NSDate date] description] forKey:@"strTime"];
    if ([[dic objectForKey:@"sender"] isEqualToString:@"Me"]) {
        [dataDic setObject:@"Me" forKey:@"strName"];
    } else {
        [dataDic setObject:@"He" forKey:@"strName"];
    }
    [dataDic setObject:@"" forKey:@"strIcon"];
    
    [message setWithDict:dataDic];
    [message minuteOffSetStart:previousTime end:dataDic[@"strTime"]];
    messageFrame.showTime = message.showDateLabel;
    [messageFrame setMessage:message];
    
    if (message.showDateLabel) {
        previousTime = dataDic[@"strTime"];
    }
    [self.dataSource addObject:messageFrame];
}


@end
