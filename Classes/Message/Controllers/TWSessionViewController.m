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
#import "TWMessagePageService.h"
#import "MBProgressHUD+Extension.h"

@interface TWSessionViewController ()
{
    NSString *phoneNumber;
}

@property(nonatomic,strong)TWSessionConfig *config;
@property (nonatomic,weak)    id<NIMSessionInteractor> interactor;
@end

@implementation TWSessionViewController

- (id<NIMSessionConfig>)sessionConfig {
    //返回 nil，则使用默认配置，若需要自定义则自己实现
//    self.config = [[TWSessionConfig alloc]init];
    return self.config;
   
}

#pragma mark --Privities Methods
-(void)callPhone:(UIButton *)btn{
    NSLog(@"打电话");
    if (kStringIsEmpty(phoneNumber)) {
        [self searchPhoneNumberRequest];
       
    }else{
        
        NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",phoneNumber];

        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];

    }
    
}
-(void)wechatGoBack:(NSNotificationCenter *)notification{
    self.tabBarController.selectedIndex = 0;
    [self.navigationController popViewControllerAnimated:NO];
}
//重新登陆了聊天
-(void)loginWeChat:(NSNotificationCenter *)notification{
    NSString *account = [NTESSessionUtil yunxinLoginAccout];
    NSString *token = [TWLoginModelService shareInstance].wy;
    [[[NIMSDK sharedSDK] loginManager] login:account
                                                               token:token
                                                          completion:^(NSError *error) {
            
    }];
}
#pragma mark --Lazy Methods
- (TWSessionConfig *)config{
    if (!_config) {
        _config = [[TWSessionConfig alloc] init];
//        _config.session = self.session;
    }
    return _config;
}
#pragma mark --Request Methods
-(void)searchPhoneNumberRequest{
//    [MBProgressHUD showLoadToView:self.view];
//    __weak typeof(self) weakself = self;
    [TWMessagePageService getPhoneNumber:self.session.sessionId callback:^(id  _Nonnull respone, TWApiStatusCode code) {
//        [MBProgressHUD hideHUDForView:self.view];
        if(code==TWApiStatusSuccess){
          phoneNumber = respone[@"data"][@"phoneNumber"];
            if (kStringIsEmpty(phoneNumber)) {
                //如果是空，提示用户
                [[TWToastView surewWithMessage:@"抱歉，经纪人未开通拨号，我们会尽快开通耐心等待!" sureBtnhandle:^(UIButton *button) {}]show];
            }else{
                NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",phoneNumber];

                      [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];

            }
        }
    }];
}
#pragma mark --UIViewController Methods

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   
    [self configSubViews];
    [self setUpNorMalNav];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wechatGoBack:) name:kNotificationName_WechatGoBack object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginWeChat:) name:kNotificationName_ReLoginWeChat object:nil];

//    [self.tableView nim_scrollToBottom:YES];
}

-(void)configSubViews{
//    self.sessionInputView.toolBar.voiceButton.hidden = NO;
    self.titleLabel.text =[NSString stringWithFormat:@"与%@的对话",[NIMKitUtil showNick:self.session.sessionId inSession:self.session]];
    
    UILabel *promptLable = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, kScreen_width, 37)];
    promptLable.backgroundColor = kRGB(234, 243, 255);
    promptLable.font = [UIFont systemFontOfSize:12];
    promptLable.textColor = kRGB(40, 137, 255);
    promptLable.text = @"您的电话号码已对经纪人保密，请放心咨询";
    promptLable.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:promptLable];
    

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
//- (void)initNavBackItem{
//
//
//}


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

//判断是否是链接，如果是链接，则跳转网页打开
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
//    rnDict[@"params"]=params;
    if ([attachment.messageDic[@"type"] intValue]==1) {
        rnDict[@"initialScreenName"] = @"RentHouseDetail";

    }else if([attachment.messageDic[@"type"] intValue]==2){
        rnDict[@"initialScreenName"] = @"SaleHouseDetail";

    }
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
#pragma mark - Navigation


@end
