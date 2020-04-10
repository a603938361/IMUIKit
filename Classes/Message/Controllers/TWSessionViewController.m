//
//  TWSessionViewController.m
//  TaiWuWang
//
//  Created by 田黎强 on 2020/2/19.
//  Copyright © 2020 zsf. All rights reserved.
//

#import "TWSessionViewController.h"
#import "NTESGalleryViewController.h"
#import "NIMLocationViewController.h"
#import "TWSessionConfig.h"
#import "TWTool.h"
#import "NIMKitUtil.h"
#import "TWNewMessageAttachMent.h"
#import "TWRNGlobalModel.h"
#import "TWRNViewController.h"
#import "TWMessageService.h"
#import "TWIMUtil.h"

@interface TWSessionViewController ()
@property (nonatomic, strong) TWSessionConfig *config;
@property (nonatomic, weak) id<NIMSessionInteractor> interactor;
@property (nonatomic, copy) NSString *phoneNumber;
@end

@implementation TWSessionViewController

- (id<NIMSessionConfig>)sessionConfig {
    //返回 nil，则使用默认配置，若需要自定义则自己实现
    //    self.config = [[TWSessionConfig alloc]init];
    return self.config;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

#pragma mark --Privities Methods
#pragma mark --Lazy Methods
- (TWSessionConfig *)config{
    if (!_config) {
        _config = [[TWSessionConfig alloc] init];
    }
    return _config;
}
#pragma mark --Request Methods
#pragma mark --UIViewController Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configSubViews];
    if ([TWIMUtil showCallIcon]) {
        [self setUpNorMalNav];
    }
}
-(void)configSubViews{
    
//    self.titleLabel.text =[NSString stringWithFormat:@"与%@的对话",[NIMKitUtil showNick:self.session.sessionId inSession:self.session]];
//    self.titleLabel.textColor = kRGB(51, 51, 51);
    
    NSString *sessinName =[NIMKitUtil showNick:self.session.sessionId inSession:self.session];
    BOOL isPhone =[TWTool isMobileNumber:sessinName];
    if (isPhone) {
        sessinName= [sessinName stringByReplacingOccurrencesOfString:[sessinName  substringWithRange:NSMakeRange(3,4)]withString:@"****"];
    }
    self.titleLabel.text =[NSString stringWithFormat:@"与%@的对话",sessinName];
    self.titleLabel.textColor = kRGB(51, 51, 51);

    
    if (![[TWIMUtil setSessionTips] isEqualToString:@""]) {
        UILabel *promptLable = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, kScreen_width, 37)];
        promptLable.backgroundColor = kRGB(234, 243, 255);
        promptLable.font = [UIFont systemFontOfSize:12];
        promptLable.textColor = kRGB(40, 137, 255);
        promptLable.text = [TWIMUtil setSessionTips];
        promptLable.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:promptLable];
    }
}


#pragma mark - Cell事件
- (BOOL)onTapCell:(NIMKitEvent *)event
{
    
    BOOL handled = [super onTapCell:event];
    NSString *eventName = event.eventName;
    if ([eventName isEqualToString:NIMKitEventNameTapContent])
    {
        NIMMessage *message = event.messageModel.message;
        NSDictionary *actions = [self cellActions];
        NSString *value = actions[@(message.messageType)];
        if (value) {
            SEL selector = NSSelectorFromString(value);
            if (selector && [self respondsToSelector:selector]) {
                SuppressPerformSelectorLeakWarning([self performSelector:selector withObject:message]);
                handled = YES;
            }
        }
    }
    
    if (!handled) {
        NSAssert(0, @"invalid event");
    }
    return handled;
    
}
#pragma mark - 辅助方法enterPersonInfoCard
- (NSDictionary *)cellActions
{
    static NSDictionary *actions = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        actions = @{
            @(NIMMessageTypeText):@"showGoHttp:",
            @(NIMMessageTypeImage) :    @"showImage:",
            @(NIMMessageTypeVideo) :    @"showVideo:",
            @(NIMMessageTypeLocation) : @"showLocation:",
            @(NIMMessageTypeFile)  :    @"showFile:",
            @(NIMMessageTypeCustom):    @"showCustom:"};
    });
    return actions;
}
#pragma mark - Cell Actions
- (void)showImage:(NIMMessage *)message
{
    NIMImageObject *object = message.messageObject;
    NTESGalleryItem *item = [[NTESGalleryItem alloc] init];
    item.thumbPath      = [object thumbPath];
    item.imageURL       = [object url];
    item.name           = [object displayName];
    item.itemId         = [message messageId];
    item.size           = [object size];
    
    NIMSession *session = [self isMemberOfClass:[TWSessionViewController class]]? self.session : nil;
    
    NTESGalleryViewController *vc = [[NTESGalleryViewController alloc] initWithItem:item session:session];
    [self.navigationController pushViewController:vc animated:YES];
    if(![[NSFileManager defaultManager] fileExistsAtPath:object.thumbPath]){
        //如果缩略图下跪了，点进看大图的时候再去下一把缩略图
        __weak typeof(self) wself = self;
        [[NIMSDK sharedSDK].resourceManager download:object.thumbUrl filepath:object.thumbPath progress:nil completion:^(NSError *error) {
            if (!error) {
                [wself uiUpdateMessage:message];
            }
        }];
    }
}

-(void)showGoHttp:(NIMMessage *)message{
    NSString *messageText = message.text;
    BOOL isUrl = [TWTool isUrlAddress:messageText];
    if (isUrl) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:messageText]];
    }
    
}
- (void)showLocation:(NIMMessage *)message
{
    NIMLocationObject *object = message.messageObject;
    NIMKitLocationPoint *locationPoint = [[NIMKitLocationPoint alloc] initWithLocationObject:object];
    NIMLocationViewController *vc = [[NIMLocationViewController alloc] initWithLocationPoint:locationPoint];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)showCustom:(NIMMessage *)message{
    NIMCustomObject *object = message.messageObject;
    TWNewMessageAttachMent *attachment = object.attachment;
    //1租2售
    
    NSMutableDictionary *rnDict = [TWRNGlobalModel model].mj_keyValues;
    TWRNViewController *rnVC = [[TWRNViewController alloc] init];
    
    rnDict[[TWIMUtil rnPageType]] = [TWIMUtil rnPageName:[attachment.messageDic[@"type"] intValue]];
    
    rnDict[@"propertyEffectiveId"]=kObjectIsEmpty(attachment.messageDic[@"propertyEffectiveId"])?nil:attachment.messageDic[@"propertyEffectiveId"];
    rnDict[@"propertyNumber"]=kObjectIsEmpty(attachment.messageDic[@"propertyNumber"])?@"":attachment.messageDic[@"propertyNumber"];
    rnDict[@"propertyId"]=kObjectIsEmpty(attachment.messageDic[@"propertyId"])?nil:attachment.messageDic[@"propertyId"];
    rnDict[@"id"]=kObjectIsEmpty(attachment.messageDic[@"id"])?nil:attachment.messageDic[@"id"];
    rnVC.propertyDict=rnDict;
    [self.navigationController pushViewController:rnVC animated:YES ];
}
#pragma mark - NIMSessionConfiguratorDelegate

- (void)didFetchMessageData
{
    [self.tableView reloadData];
    if (self.firstMessage) {
        [self scrollToFirstMsg];
    }
}

- (void)scrollToFirstMsg {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSInteger row = [self.interactor findMessageIndex:self.firstMessage];
        if (row > 0) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
    });
}

-(void)setUpNorMalNav{
    UIButton *phoneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [phoneBtn addTarget:self action:@selector(callPhone:) forControlEvents:UIControlEventTouchUpInside];
    [phoneBtn setImage:[UIImage imageNamed:@"message_phone"] forState:UIControlStateNormal];
    [phoneBtn setImage:[UIImage imageNamed:@"message_phone"] forState:UIControlStateHighlighted];
    [phoneBtn sizeToFit];
    UIBarButtonItem *phoneItem = [[UIBarButtonItem alloc] initWithCustomView:phoneBtn];
    
    self.navigationItem.rightBarButtonItems  = @[phoneItem];
}

#pragma mark - Navigation
#pragma mark --Privities Methods
-(void)callPhone:(UIButton *)btn{
    NSLog(@"打电话");
    if (kStringIsEmpty(_phoneNumber)) {
        [self searchPhoneNumberRequest];
    }else{
        NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",_phoneNumber];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    }
}

-(void)searchPhoneNumberRequest{
    WEAK_SELF(weakSelf)
    [TWMessageService getPhoneNumber:self.session.sessionId callback:^(id  _Nonnull respone, TWApiStatusCode code) {
        if(code==TWApiStatusSuccess){
            weakSelf.phoneNumber = respone[@"data"][@"phoneNumber"];
            if (kStringIsEmpty(weakSelf.phoneNumber)) {
                //如果是空，提示用户
                [[TWToastView surewWithMessage:@"抱歉，经纪人未开通拨号，我们会尽快开通耐心等待!" sureBtnhandle:^(UIButton *button) {}]show];
            }else{
                NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",weakSelf.phoneNumber];
                
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
                
            }
        }
    }];
}

- (BOOL)useWhiteBar{
    return YES;
}

@end
