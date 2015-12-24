//
//  FriendListTableViewController.m
//  Habber
//
//  Created by Sunny on 12/15/15.
//  Copyright © 2015 Nine. All rights reserved.
//

#import "FriendListTableViewController.h"

@interface FriendListTableViewController () {
    AppDelegate *mainDelegate;
}

@property (nonatomic, strong) TSPopoverController *popoverController;
@property (nonatomic, strong) PopTableViewController *tableViewController;

@property (nonatomic, strong) UIButton *statusBtn;

@property (nonatomic, strong) NSString *chatUsername;
@property (nonatomic, strong) NSMutableArray *onlineUsers;

@property (nonatomic, strong) UIAlertView *logoutAlert;
@property (nonatomic, strong) UIAlertView *addFriendWindow;
@property (nonatomic, strong) UIAlertView *friendRequestAlert;

@end

@implementation FriendListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Habber";

    //做好带图片的UIButton
    UIImage *Status = [UIImage imageNamed:@"on"];
    _statusBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _statusBtn.frame = CGRectMake(0, 0, Status.size.width, Status.size.height);
    [_statusBtn setBackgroundImage:Status forState:UIControlStateNormal];
    [_statusBtn addTarget:self action:@selector(showPopover:forEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    //然后再以UIBarButton初始化，这样UIBarButton就可以显示图片了
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_statusBtn];
    
    UIBarButtonItem *addFriendBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addFriend)];
    self.navigationItem.rightBarButtonItem = addFriendBtn;
    
    //背景设置图片
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"friendsBg"]];
    self.tableView.opaque = NO;
    
    //初始化专用
    _onlineUsers = [NSMutableArray array];
    _messages = [NSMutableArray array];
    //注意，想要添加好友，要通过activate xmpp Stream才能够有效
    _xmppStorage = [[XMPPRosterCoreDataStorage alloc] initWithInMemoryStore]; //非永久存储，在内存中
    _xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:_xmppStorage dispatchQueue:dispatch_get_main_queue()];
    [_xmppRoster activate:[self xmppStream]];
    
    //代理专用
    mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    mainDelegate.chatDelegate = self;
    [_xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //接收通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popoverDismiss) name:@"PopoverDismiss" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectServerFailed) name:@"connectServerFailed" object:nil];
    
    mainDelegate.messageDelegate = self;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_messages removeAllObjects];
    [self.tableView reloadData];
}

#pragma mark - 设置上下线点击后按钮图案和navigation title的变化
- (void)onlineSet {
    self.navigationItem.title = @"Habber";
    [_statusBtn setBackgroundImage:[UIImage imageNamed:@"on"] forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_statusBtn];
}

- (void)offlineSet {
    self.navigationItem.title = @"Offline";
    [_statusBtn setBackgroundImage:[UIImage imageNamed:@"off"] forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_statusBtn];
    //离线状态清空联系人
    [_onlineUsers removeAllObjects];
    [self.tableView reloadData];
}

#pragma mark - 获取xmppStream
- (AppDelegate *)getAppDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (XMPPStream *)xmppStream {
    return [[self getAppDelegate] xmppStream];
}

#pragma mark - TSPopover implements
- (void)showPopover:(id)sender forEvent:(UIEvent*)event {
    _tableViewController = [PopTableViewController new];
    _tableViewController.view.frame = CGRectMake(0,0, 150, 130);
    _popoverController = [[TSPopoverController alloc] initWithContentViewController:_tableViewController];
    
    _popoverController.cornerRadius = 5;
    _popoverController.titleText = @"Pick status";
    _popoverController.popoverBaseColor = [UIColor colorWithRed:55.0/255 green:55.0/255 blue:55.0/255 alpha:0.9];
    _popoverController.popoverGradient= NO;
    [_popoverController showPopoverWithTouch:event];
}

#pragma mark - Selector point here
//添加好友
- (void)addFriend {
    _addFriendWindow = [[UIAlertView alloc] initWithTitle:@"Add friend" message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:@"Cancel", nil];
    [_addFriendWindow setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [[_addFriendWindow textFieldAtIndex:0] setPlaceholder:@"Friend ID here"];
    [_addFriendWindow show];
}

- (void)popoverDismiss {
    [_popoverController dismissPopoverAnimatd:YES];
    [_popoverController dismissViewControllerAnimated:YES completion:nil];
    //点击注销logout，弹出提示框，点击ok就执行注销
    if ([_tableViewController.status isEqualToString:@"logout"]) {
        _logoutAlert = [[UIAlertView alloc] initWithTitle:@"Logout" message:@"Are you sure about that？" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
        [_logoutAlert show];
        [[self getAppDelegate] disconnect];
    }
    //上线、
    if ([_tableViewController.status isEqualToString:@"online"]) {
        self.navigationItem.title = @"Connecting...";
        [[self getAppDelegate] connect];
    }
    //离线、
    if ([_tableViewController.status isEqualToString:@"offline"]) {
        [[self getAppDelegate] disconnect];
    }
}

//返回好友列表
- (void)dismissSelf {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self dismissViewControllerAnimated:YES completion:nil];
}

//既然连接失败，那我还是离线的状态
- (void)connectServerFailed {
    [self offlineSet];
}

#pragma mark - UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView == _logoutAlert) {
        if (buttonIndex == 0) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    if (alertView == _addFriendWindow) {
        if (buttonIndex == 0) {
            [self xmppAddFriendSubscribe:[[_addFriendWindow textFieldAtIndex:0] text]];
        }
    }
    if (alertView == _friendRequestAlert) {
        if (buttonIndex == 0) {
            XMPPJID *jid = [XMPPJID jidWithString:_presenceFromUser];
            [_xmppRoster acceptPresenceSubscriptionRequestFrom:jid andAddToRoster:YES];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _onlineUsers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FriendsCell" forIndexPath:indexPath];
    if (_messages.count > 0) {
        cell.imageView.image = [UIImage imageNamed:@"withMsg"];
    } else {
        cell.imageView.image = [UIImage imageNamed:@"habberOnline"];
    }
    NSString *cellTitle = [_onlineUsers objectAtIndex:indexPath.row];
    cellTitle = [cellTitle stringByAppendingFormat:@"(%lu)", (unsigned long)_messages.count];
    cell.textLabel.text = cellTitle;
    cell.detailTextLabel.text = @"available";
    return cell;
}

//删除好友
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    XMPPJID *jid = [XMPPJID jidWithString:[_onlineUsers objectAtIndex:indexPath.row]];
    [_xmppRoster removeUser:jid];
    [_onlineUsers removeObjectAtIndex:indexPath.row];
    [self.tableView reloadData];
}

#pragma mark - Table view delegate implements
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _chatUsername = (NSString *)[_onlineUsers objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"Chat" sender:nil];
}

#pragma mark - HabberChatDelegate implements
//好友上线刷新列表
- (void)newBuddyOnline:(NSString *)buddyName {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (![_onlineUsers containsObject:buddyName]) {
            [_onlineUsers addObject:buddyName];
            [self.tableView reloadData];
        }
    });
}

//好友下线
- (void)buddyWentOffline:(NSString *)buddyName {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_onlineUsers removeObject:buddyName];
        [self.tableView reloadData];
    });
}

//如果掉线了就显示灰色掉线图表
- (void)didDisconnect {
    [self offlineSet];
}

//不用通知那只好在代理中执行了
- (void)didConnect {
    [self onlineSet];
}

//收到好友请求，弹出提示框让你处理
- (void)receivedFriendRequest:(NSString *)presenceFrom {
    _presenceFromUser = presenceFrom;
    NSString *alertMessage = [NSString stringWithFormat:@"%@ wants add you.", _presenceFromUser];
    _friendRequestAlert = [[UIAlertView alloc] initWithTitle:@"Friend request" message:alertMessage delegate:self cancelButtonTitle:@"Accept" otherButtonTitles:@"No", nil];
    [_friendRequestAlert show];
}

#pragma mark - Habber message delegate implements
//这里就是处理收到的信息了，添加到一个数组里面，最后统统传递给聊天界面
- (void)newMessageReceived:(NSDictionary *)messageContent {
    NSDictionary *dic = [NSDictionary dictionary];
    NSString *msg = [messageContent objectForKey:@"msg"];
    NSString *imageStr = [messageContent objectForKey:@"photo"];
    NSString *voiceStr = [messageContent objectForKey:@"voice"];
    NSString *voiceTimeStr = [messageContent objectForKey:@"voiceTime"];
    NSString *from = [messageContent objectForKey:@"sender"];
    if (imageStr.length > 0) {
        NSData *imgData = [[NSData alloc] initWithBase64EncodedString:imageStr options:0];
        UIImage *image = [UIImage imageWithData:imgData];
        dic = @{@"picture": image,
                @"type": @(UUMessageTypePicture),
                @"sender": from};
    } else if (voiceStr.length > 0) {
        NSData *voiceData = [[NSData alloc] initWithBase64EncodedString:voiceStr options:0];
        dic = @{@"voice": voiceData,
                @"strVoiceTime": voiceTimeStr,
                @"type": @(UUMessageTypeVoice),
                @"sender": from};
    } else {
        dic = @{@"strContent": msg,
                @"type": @(UUMessageTypeText),
                @"sender": from};
    }
    //收到消息数组
    [_messages addObject:dic];
    
    //每次刷新表格，就可以看到有多少条未读信息
    [self.tableView reloadData];
}

#pragma mark - XMPPRoster impletes
//添加朋友
- (void)xmppAddFriendSubscribe:(NSString *)name {
    XMPPJID *jid = [XMPPJID jidWithString:name];
    [_xmppRoster subscribePresenceToUser:jid];
}

#pragma mark - segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Chat"]) {
        UUChatViewController *chatVC = (UUChatViewController *)[segue.destinationViewController topViewController];
        chatVC.chatUserName = _chatUsername;
        chatVC.messages = _messages;
    }
}

@end
