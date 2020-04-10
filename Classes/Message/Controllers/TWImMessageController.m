//
//  TWMessageController.m
//  TaiWuWang
//
//  Created by zsf on 2019/12/24.
//  Copyright © 2019 zsf. All rights reserved.
//

#import "TWImMessageController.h"
#import "TWSessionViewController.h"
#import "TWLookBrokerMessageView.h"
#import "TWGlobalConst.h"
#import "NIMSessionViewController.h"
#import "TWNoBrokerView.h"
#import "NTESListHeader.h"
#import "UIView+NTES.h"
#import "NTESSessionUtil.h"
#import "NTESAliasSettingViewController.h"
#import "TWIMSearchViewController.h"
#import "TWIMUtil.h"

static NSString *prefixTitle = @"太平洋房屋";

@interface TWImMessageController ()<NIMLoginManagerDelegate,NTESListHeaderDelegate>
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) TWLookBrokerMessageView *brokerView;
@property (nonatomic,strong) NTESListHeader *header;

@end

@implementation TWImMessageController
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
}

-(void)gotoBrokerAddressListVc{
    NSLog(@"--------");
}

//长按手势的点击事件
- (void)pressAction:(UILongPressGestureRecognizer *)longPressGesture
{
    
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:nil
                                                                message:nil
                                                         preferredStyle:UIAlertControllerStyleActionSheet];
    CGPoint point = [longPressGesture locationInView:self.tableView];
    NSIndexPath *currentIndexPath = [self.tableView indexPathForRowAtPoint:point]; // 可以获取我们在哪个cell上长按
    
    NSArray *actions = [self setupAlertActions:currentIndexPath];
    for (UIAlertAction *action in actions) {
        [vc addAction:action];
    }
    [self presentViewController:vc animated:YES completion:nil];

}

- (NSMutableArray *)setupAlertActions:(NSIndexPath *)indexPath {
    __weak typeof(self) weakSelf = self;
    
    UIAlertAction *addNodeAction = [UIAlertAction actionWithTitle:@"添加备注"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
        NIMRecentSession *recentSession = weakSelf.recentSessions[indexPath.row];
        NTESAliasSettingViewController *aliasVc = [[NTESAliasSettingViewController alloc]initWithUserId:recentSession.session.sessionId];
        [weakSelf.navigationController pushViewController:aliasVc animated:YES];
        
    }];
    
    
    UIAlertAction *deleteMessageAction = [UIAlertAction actionWithTitle:@"删除会话"
                                                                  style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction * _Nonnull action) {
        NIMRecentSession *recentSession = weakSelf.recentSessions[indexPath.row];
        [weakSelf onDeleteRecentAtIndexPath:recentSession atIndexPath:indexPath];
    }];
    
    BOOL isTop = [NTESSessionUtil recentSessionIsMark:self.recentSessions[indexPath.row] type:NTESRecentSessionMarkTypeTop];
    UIAlertAction *toTopMessagesAction = [UIAlertAction actionWithTitle:isTop?@"取消置顶":@"置顶"
                                                                  style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction * _Nonnull action) {
        
        NIMRecentSession *recentSession = weakSelf.recentSessions[indexPath.row];
        [weakSelf onTopRecentAtIndexPath:recentSession atIndexPath:indexPath isTop:isTop];
        
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消"
                                                     style:UIAlertActionStyleCancel
                                                   handler:nil];
    if ([TWIMUtil addRemark]) {
        return @[addNodeAction, deleteMessageAction, toTopMessagesAction, cancel].mutableCopy;
    }else{
        return @[deleteMessageAction, toTopMessagesAction, cancel].mutableCopy;
    }
}

- (NSMutableArray *)customSortRecents:(NSMutableArray *)recentSessions
{
    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:recentSessions];
    [array sortUsingComparator:^NSComparisonResult(NIMRecentSession *obj1, NIMRecentSession *obj2) {
        NSInteger score1 = [NTESSessionUtil recentSessionIsMark:obj1 type:NTESRecentSessionMarkTypeTop]? 10 : 0;
        NSInteger score2 = [NTESSessionUtil recentSessionIsMark:obj2 type:NTESRecentSessionMarkTypeTop]? 10 : 0;
        if (obj1.lastMessage.timestamp > obj2.lastMessage.timestamp)
        {
            score1 += 1;
        }
        else if (obj1.lastMessage.timestamp < obj2.lastMessage.timestamp)
        {
            score2 += 1;
        }
        if (score1 == score2)
        {
            return NSOrderedSame;
        }
        return score1 > score2? NSOrderedAscending : NSOrderedDescending;
    }];
    return array;
}

- (void)setShowSearch:(BOOL)showSearch
{
    _showSearch = showSearch;
    if (showSearch) {
        [self setUpNorMalNav];
    }
}

//查询入口
-(void)serachBtnClick:(UIButton *)button{
    TWIMSearchViewController *searchVC = [[TWIMSearchViewController alloc]init];
    searchVC.recentSessions = self.recentSessions;
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
    [[NIMSDK sharedSDK].loginManager addDelegate:self];
    
    [self refresh];
}

-(void)setUpNorMalNav{
    
    UIButton *serachBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [serachBtn addTarget:self action:@selector(serachBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [serachBtn setBackgroundImage:[UIImage imageNamed:@"icon_search"] forState:UIControlStateNormal];
    UIBarButtonItem *serachItem = [[UIBarButtonItem alloc] initWithCustomView:serachBtn];
    
    if (self.recentSessions.count) {
        self.navigationItem.rightBarButtonItems  = @[serachItem];
    }else{
        self.navigationItem.rightBarButtonItems  = @[];
    }
}

-(void)haveLogin{
    if (self.recentSessions.count == 0) {
        [[[NIMSDK sharedSDK] loginManager] login:[TWIMUtil getAccount]
                                           token:[TWIMUtil getToken]
                                      completion:^(NSError *error) {
            
            self.recentSessions =  [[NIMSDK sharedSDK].conversationManager.allRecentSessions mutableCopy];
            self.recentSessions = [self customSortRecents:self.recentSessions];
            [self refresh];
        }];
    }
}

-(void)configSubViews{
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.autoRemoveRemoteSession = YES;

    UILongPressGestureRecognizer *longpress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(pressAction:)];
    [self.tableView addGestureRecognizer:longpress];
    
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
    [self setUpNorMalNav];

    NSInteger underCount =[NIMSDK sharedSDK].conversationManager.allUnreadCount;
    NSString *navTitle = @"";
    if(underCount <= 0){
        navTitle = @"微聊";
    }else if(underCount>99){
        navTitle = @"微聊(99+)";
    }else{
        navTitle = [NSString stringWithFormat:@"微聊(%ld)",(long)underCount];
    }
    self.navigationItem.title=navTitle;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_ShowUnReadCount object:[NSString stringWithFormat:@"%ld",underCount]];
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
    //    manager deleteSelfRemoteSession
    
    //    [manager deleteRecentSession:recent];
    //删除会话列表，删除聊天记录
    NIMDeleteMessagesOption *option = [[NIMDeleteMessagesOption alloc]init];
    option.removeSession = YES;
    option.removeTable = YES;
    [manager deleteAllmessagesInSession:recent.session option:option];
}

- (void)onTopRecentAtIndexPath:(NIMRecentSession *)recent
                   atIndexPath:(NSIndexPath *)indexPath
                         isTop:(BOOL)isTop
{
    if (isTop)
    {
        [NTESSessionUtil removeRecentSessionMark:recent.session type:NTESRecentSessionMarkTypeTop];
    }
    else
    {
        [NTESSessionUtil addRecentSessionMark:recent.session type:NTESRecentSessionMarkTypeTop];
    }
    self.recentSessions = [self customSortRecents:self.recentSessions];
    [self.tableView reloadData];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}
#pragma mark - NIMLoginManagerDelegate
- (void)onLogin:(NIMLoginStep)step{
    [super onLogin:step];
    switch (step) {
        case NIMLoginStepLinkFailed:
            self.titleLabel.text = [prefixTitle stringByAppendingString:@"(未连接)"];
            break;
        case NIMLoginStepLinking:
            self.titleLabel.text = [prefixTitle stringByAppendingString:@"(连接中)"];
            break;
        case NIMLoginStepLinkOK:
        case NIMLoginStepSyncOK:
            self.titleLabel.text = prefixTitle;
            break;
        case NIMLoginStepSyncing:
            self.titleLabel.text = [prefixTitle stringByAppendingString:@"(同步数据)"];
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

- (BOOL)useWhiteBar{
    return YES;
}

-(void)dealloc{
    [[NIMSDK sharedSDK].loginManager removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}



@end
