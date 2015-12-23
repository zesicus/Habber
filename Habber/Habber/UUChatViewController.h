//
//  RootViewController.h
//  UUChatTableView
//
//  Created by shake on 15/1/4.
//  Copyright (c) 2015年 uyiuyao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface UUChatViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, HabberMessageDelegate>

//接收传递过来的人名
@property (strong, nonatomic) NSString *chatUserName;

//接收好友界面的消息
@property (strong, nonatomic) NSMutableArray *messages;

//返回按钮
- (IBAction)back:(UIBarButtonItem *)sender;

@end
