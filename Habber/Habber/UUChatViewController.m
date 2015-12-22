//
//  RootViewController.m
//  UUChatTableView
//
//  Created by shake on 15/1/4.
//  Copyright (c) 2015年 uyiuyao. All rights reserved.
//

#import "UUChatViewController.h"
#import "UUInputFunctionView.h"
#import "MJRefresh.h"
#import "UUMessageCell.h"
#import "ChatModel.h"
#import "UUMessageFrame.h"
#import "UUMessage.h"

@interface UUChatViewController () <UUInputFunctionViewDelegate,UUMessageCellDelegate,UITableViewDataSource,UITableViewDelegate> {
    AppDelegate *mainDelegate;
}

@property (strong, nonatomic) ChatModel *chatModel;

@property (weak, nonatomic) IBOutlet UITableView *chatTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@end

@implementation UUChatViewController{
    UUInputFunctionView *IFView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = _chatUserName;
    
    //设置tableView透明
    _chatTableView.backgroundView = nil;
    _chatTableView.backgroundColor = [UIColor clearColor];
    _chatTableView.opaque = NO;
    
    [self loadBaseViewsAndData];
    mainDelegate = [self getAppDelegate];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    mainDelegate.messageDelegate = self;
    
    //add notification
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(tableViewScrollToBottom) name:UIKeyboardDidShowNotification object:nil];
    
    //把朋友界面传送过来的消息读取显示
    NSLog(@"%lu", (unsigned long)_messages.count);
    for (NSDictionary *dic in _messages) {
        NSLog(@"%@", dic);
        [self dealTheFunctionData:dic];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark - Get appDelegate for xmppStream
//获取xmppStream
- (AppDelegate *)getAppDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (XMPPStream *)xmppStream {
    return [[self getAppDelegate] xmppStream];
}

#pragma mark -
- (void)loadBaseViewsAndData
{
    self.chatModel = [[ChatModel alloc]init];
    [_chatModel loadDataSource];
    
    IFView = [[UUInputFunctionView alloc]initWithSuperVC:self];
    IFView.delegate = self;
    [self.view addSubview:IFView];
    
    [self.chatTableView reloadData];
    [self tableViewScrollToBottom];
}

-(void)keyboardChange:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardEndFrame;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    //adjust ChatTableView's height
    //由于原作是xib，storyboard已经不一样，这里改了一下布局size计算
    if (notification.name == UIKeyboardWillShowNotification) {
        self.bottomConstraint.constant -= keyboardEndFrame.size.height + 40;
    }else{
        self.bottomConstraint.constant = - 40;
    }
    
    [self.view layoutIfNeeded];
    
    //adjust UUInputFunctionView's originPoint
    CGRect newFrame = IFView.frame;
    newFrame.origin.y = keyboardEndFrame.origin.y - newFrame.size.height;
    IFView.frame = newFrame;
    
    [UIView commitAnimations];
    
}

//tableView Scroll to bottom
- (void)tableViewScrollToBottom
{
    if (self.chatModel.dataSource.count==0)
        return;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.chatModel.dataSource.count-1 inSection:0];
    [self.chatTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

#pragma mark - HabberMessageDelegate implements
- (void)newMessageReceived:(NSDictionary *)messageContent {
    dispatch_async(dispatch_get_main_queue(), ^{
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
        
        [self dealTheFunctionData:dic];
    });
}

#pragma mark - InputFunctionViewDelegate
- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendMessage:(NSString *)message
{
    NSDictionary *dic = @{@"strContent": message,
                          @"type": @(UUMessageTypeText),
                          @"sender": @"Me"};
    funcView.TextViewInput.text = @"";
    [funcView changeSendBtnWithPhoto:YES];
    [self dealTheFunctionData:dic];
    [self sendXML:message image:nil voice:nil time:0];
}

- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendPicture:(UIImage *)image
{
    NSDictionary *dic = @{@"picture": image,
                          @"type": @(UUMessageTypePicture),
                          @"sender": @"Me"};
    [self dealTheFunctionData:dic];
    [self sendXML:@"" image:image voice:nil time:0];
}

- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendVoice:(NSData *)voice time:(NSInteger)second
{
    NSDictionary *dic = @{@"voice": voice,
                          @"strVoiceTime": [NSString stringWithFormat:@"%d",(int)second],
                          @"type": @(UUMessageTypeVoice),
                          @"sender": @"Me"};
    [self dealTheFunctionData:dic];
    [self sendXML:@"" image:nil voice:voice time:second];
}

- (void)dealTheFunctionData:(NSDictionary *)dic
{
    [self.chatModel addSpecifiedItem:dic];
    [self.chatTableView reloadData];
    [self tableViewScrollToBottom];
}

#pragma mark - 发送XML封装数据
- (void)sendXML:(NSString *)message image:(UIImage *)img voice:(NSData *)voice time:(NSUInteger)second{
    //生成xml
    //<body>
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:message];
    //<message>
    NSXMLElement *mes = [NSXMLElement elementWithName:@"message"];
    //<message type = chat>
    [mes addAttributeWithName:@"type" stringValue:@"chat"];
    //<message type = "chat" to = _chatUserName>
    [mes addAttributeWithName:@"to" stringValue:_chatUserName];
    //<message type = "chat" to = _chatUserName from = ...>
    [mes addAttributeWithName:@"from" stringValue:[[NSUserDefaults standardUserDefaults] stringForKey:USERID]];
    //<message ...><body></body></message>
    [mes addChild:body];
    
    if (img) {
        //坑的我不轻的编码，这里因为png比较大（不清楚到底是转换出错还是xml有大小限制，但感觉是前者，毕竟好像base64是针对小文件编码的吧？），所以发送失败或接收不到(或者我得等个5分钟？)，所以选用压缩后传送。
//        NSData *imgData = UIImagePNGRepresentation(img);
        NSData *imgData = UIImageJPEGRepresentation(img, 0.1);
        NSString *imgStr=[imgData base64EncodedStringWithOptions:0];
        
        //<message ...><body></body><attachment></attachment></message>
        NSXMLElement *imgAttachment = [NSXMLElement elementWithName:@"image"];
        [imgAttachment setStringValue:imgStr];
        [mes addChild:imgAttachment];
    }
    
    if (voice) {
        NSString *voiceStr = [voice base64EncodedStringWithOptions:0];
        NSXMLElement *voiceAttachment = [NSXMLElement elementWithName:@"voice"];
        [voiceAttachment setStringValue:voiceStr];
        [voiceAttachment addAttributeWithName:@"voiceTime" unsignedIntegerValue:second];
        [mes addChild:voiceAttachment];
    }
    
    //发送消息
    [[self xmppStream] sendElement:mes];
}

#pragma mark - tableView delegate & datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.chatModel.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UUMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellID"];
    if (cell == nil) {
        cell = [[UUMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellID"];
        cell.delegate = self;
    }
    [cell setMessageFrame:self.chatModel.dataSource[indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self.chatModel.dataSource[indexPath.row] cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.view endEditing:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}

#pragma mark - cellDelegate
- (void)headImageDidClick:(UUMessageCell *)cell userId:(NSString *)userId{
    // headIamgeIcon is clicked
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:cell.messageFrame.message.strName message:@"headImage clicked" delegate:nil cancelButtonTitle:@"sure" otherButtonTitles:nil];
    [alert show];
}

- (IBAction)back:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
