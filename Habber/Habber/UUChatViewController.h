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

@property (strong, nonatomic) NSString *chatUserName;

//接收好友界面的消息
@property (strong, nonatomic) NSMutableArray *messages;

- (IBAction)back:(UIBarButtonItem *)sender;

@end
