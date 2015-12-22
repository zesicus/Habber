//
//  FriendListTableViewController.h
//  Habber
//
//  Created by Sunny on 12/15/15.
//  Copyright © 2015 Nine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XMPPRoster.h>
#import <XMPPRosterCoreDataStorage.h>
#import "TSPopoverController.h"
#import "PopTableViewController.h"
#import "AppDelegate.h"
#import "HabberChatDelegate.h"
#import "HabberMessageDelegate.h"
#import "UUChatViewController.h"
#import "UUMessage.h"

@interface FriendListTableViewController : UITableViewController <UIAlertViewDelegate, HabberChatDelegate, XMPPRosterDelegate, HabberMessageDelegate>

@property (nonatomic, strong) NSString *loginFlag;

//花名册
@property (nonatomic, strong) XMPPRoster *xmppRoster;
@property (nonatomic, strong) XMPPRosterCoreDataStorage *xmppStorage;
//要加我好友的人
@property (nonatomic, strong) NSString *presenceFromUser;

//收到消息
@property (nonatomic, strong) NSMutableArray *messages;

@end
