//
//  TWSessionListController.m
//  TaiWuWang
//
//  Created by 田黎强 on 2020/2/24.
//  Copyright © 2020 zsf. All rights reserved.
//

#import "TWSessionListController.h"
#import "TWSessionViewController.h"
#import "TWLookBrokerMessageView.h"
#import "TWGlobalConst.h"
#import "NIMSessionViewController.h"
#import "NTESListHeader.h"
#import "UIView+NTES.h"
#import "TWIMSearchViewController.h"
#define SessionListTitle @"太平洋房屋"


//#import "NIMSessionListCell.h"
//#import "UIView+NIM.h"
//#import "NIMAvatarImageView.h"
//#import "NIMMessageUtil.h"
//#import "NIMKitUtil.h"
#import "TWNoBrokerView.h"

@interface TWSessionListController ()<NIMLoginManagerDelegate,NTESListHeaderDelegate>
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) NTESListHeader *header;
@property (nonatomic,strong) TWLookBrokerMessageView *brokerView;
@end

@implementation TWSessionListController
#pragma mark --Lazy Methods
-(TWLookBrokerMessageView *)brokerView{
    if (nil == _brokerView) {
        NSArray *nibs = [[NSBundle mainBundle]loadNibNamed:@"TWLookBrokerMessageView" owner:self options:nil];
        _brokerView = [nibs lastObject];
    }
    return _brokerView;

}
#pragma mark --Privite Methods
- (void)refreshSubview{
    [self.titleLabel sizeToFit];
//    self.titleLabel.centerX   = self.navigationItem.titleView.width * .5f;
    if (@available(iOS 11.0, *))
    {
        self.header.top = self.view.safeAreaInsets.top;
        self.tableView.top =self.header.bottom;
        CGFloat offset = self.view.safeAreaInsets.bottom;
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, offset, 0);
    }
    else
    {
        self.tableView.top = self.header.height;
        self.header.bottom    = self.tableView.top + self.tableView.contentInset.top;
    }
    self.tableView.height = self.view.height - self.tableView.top;

//    self.emptyTipLabel.centerX = self.view.width * .5f;
//    self.emptyTipLabel.centerY = self.tableView.height * .5f;
}
-(void)gotoBrokerAddressListVc{
    NSLog(@"--------");
}

-(void)serachBtnClick:(UIButton *)button{
    TWIMSearchViewController *searchVC = [[TWIMSearchViewController alloc]init];
    [self.navigationController pushViewController:searchVC animated:YES];
}
#pragma mark --UIViewControll Methods
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self haveLogin];
    


 
}
- (void)viewDidLoad {
    [super viewDidLoad];

    [self setTitle:@"微聊"];
    [self configSubViews];
    [self setUpNorMalNav];
    [[NIMSDK sharedSDK].loginManager addDelegate:self];
 
//    [[NIMSDK sharedSDK].subscribeManager addDelegate:self];
    // Do any additional setup after loading the view.
//    [self haveLogin];

  
}

-(void)setUpNorMalNav{
    
    UIButton *serachBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [serachBtn addTarget:self action:@selector(serachBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [serachBtn setTitle:@"查询" forState:UIControlStateNormal];
    [serachBtn setTitleColor:kRGB(162, 198, 244) forState:UIControlStateNormal];
    serachBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [serachBtn sizeToFit];
    UIBarButtonItem *serachItem = [[UIBarButtonItem alloc] initWithCustomView:serachBtn];
    
    self.navigationItem.rightBarButtonItems  = @[serachItem];

}

-(void)haveLogin{
        //没有登陆
    if (kStringIsEmpty([TWLoginModelService shareInstance].wy)) {
               [TWLoginService validateAccountAuth:^(TWLoginModel * _Nonnull model) {
                      
//                       NIMAutoLoginData *loginData = [[NIMAutoLoginData alloc] init];
                       NSString *account = [NTESSessionUtil yunxinLoginAccout];
//                       loginData.account =phone;
//                       loginData.token = model.data.wy;
//                       [[[NIMSDK sharedSDK] loginManager] autoLogin:loginData];
                   NSString *token   =model.data.wy;
                   [[[NIMSDK sharedSDK] loginManager] login:account
                                                      token:token
                                                 completion:^(NSError *error) {
                       self.recentSessions =  [[NIMSDK sharedSDK].conversationManager.allRecentSessions mutableCopy];
                       [self refresh];
                       
                   }];
            }];
    }else{
         NSString *account = [NTESSessionUtil yunxinLoginAccout];
        NSString *token = [TWLoginModelService shareInstance].wy;
        [[[NIMSDK sharedSDK] loginManager] login:account
                                                             token:token
                                                        completion:^(NSError *error) {
            self.recentSessions =  [[NIMSDK sharedSDK].conversationManager.allRecentSessions mutableCopy];
            [self refresh];
        }];
        
    }
}

-(void)configSubViews{

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    NSArray *nibs = [[NSBundle mainBundle]loadNibNamed:@"TWNoBrokerView" owner:self options:nil];
    _brokerView = [nibs lastObject];
    _brokerView.frame = self.view.frame;
    _brokerView.hidden = YES;
    [self.view addSubview:_brokerView];
    
    self.header = [[NTESListHeader alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 0)];
    self.header.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.header.delegate = self;
    [self.view addSubview:self.header];
    
    
}

- (void)refresh{
    [super refresh];
    self.brokerView.hidden = self.recentSessions.count;
    NSInteger underCount =[NIMSDK sharedSDK].conversationManager.allUnreadCount;
      NSString *navTitle = @"";
      if(underCount <= 0){
          navTitle = @"微聊";
      }else if(underCount>99){
          navTitle = @"微聊(99+)";
      }else{
          navTitle = [NSString stringWithFormat:@"微聊(%ld)",(long)underCount];
      }
      self.title=navTitle;

}
- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
}


#pragma mark --Override
-(void)onSelectedRecent:(NIMRecentSession *)recent atIndexPath:(NSIndexPath *)indexPath{
    TWSessionViewController *vc = [[TWSessionViewController alloc] initWithSession:recent.session];
    [self.navigationController pushViewController:vc animated:YES];
}

//右边滑动删除
- (void)onDeleteRecentAtIndexPath:(NIMRecentSession *)recent atIndexPath:(NSIndexPath *)indexPath
{
    id<NIMConversationManager> manager = [[NIMSDK sharedSDK] conversationManager];
    [manager deleteRecentSession:recent];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark - NIMLoginManagerDelegate
- (void)onLogin:(NIMLoginStep)step{
    [super onLogin:step];
    switch (step) {
        case NIMLoginStepLinkFailed:
            self.titleLabel.text = [SessionListTitle stringByAppendingString:@"(未连接)"];
            break;
        case NIMLoginStepLinking:
            self.titleLabel.text = [SessionListTitle stringByAppendingString:@"(连接中)"];
            break;
        case NIMLoginStepLinkOK:
        case NIMLoginStepSyncOK:
            self.titleLabel.text = SessionListTitle;
            break;
        case NIMLoginStepSyncing:
            self.titleLabel.text = [SessionListTitle stringByAppendingString:@"(同步数据)"];
            break;
        default:
            break;
    }
    [self.titleLabel sizeToFit];
    self.titleLabel.centerX   = self.navigationItem.titleView.width * .5f;
    [self.header refreshWithType:ListHeaderTypeNetStauts value:@(step)];
    [self refreshSubview];
}

- (void)onMultiLoginClientsChanged
{
    [self.header refreshWithType:ListHeaderTypeLoginClients value:[NIMSDK sharedSDK].loginManager.currentLoginClients];
    [self refreshSubview];
}

- (void)onTeamUsersSyncFinished:(BOOL)success
{
    NSLog(@">> 群消息同步完成：%@",@(success));
}

#pragma mark - SessionListHeaderDelegate

- (void)didSelectRowType:(NTESListHeaderType)type{
    //多人登录
    switch (type) {
        case ListHeaderTypeLoginClients:{
//            NTESClientsTableViewController *vc = [[NTESClientsTableViewController alloc] initWithNibName:nil bundle:nil];
//            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        default:
            break;
    }
}



-(void)dealloc{
    [[NIMSDK sharedSDK].loginManager removeDelegate:self];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
