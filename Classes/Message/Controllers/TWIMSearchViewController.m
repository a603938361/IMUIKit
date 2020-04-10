//
//  TWIMSearchViewController.m
//  TaiWuWang
//
//  Created by 田黎强 on 2020/3/13.
//  Copyright © 2020 zsf. All rights reserved.
//

#import "TWIMSearchViewController.h"
#import "TWIMSearchField.h"
#import "UIBarButtonItem+Extension.h"
#import "UIView+NTES.h"
#import "TWSearchImDescribeView.h"
#import "TWSearchImMessageCell.h"
#import "TWSearchImContactsCell.h"
#import "TWSearchImHeadView.h"
#import "TWSearchImFootView.h"
#import <UIView+Toast.h>
#import <SVProgressHUD.h>
#import "TWLookMoreContactsController.h"
#import "TWSessionViewController.h"
#import "NTESBundleSetting.h"
#import "TWLookMoreMessagesController.h"
#import "TWLookMoreSomeOneMessageController.h"
#import "TWSearchImNoData.h"


@interface TWIMSearchViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)TWIMSearchField *searchField;
@property(nonatomic,strong)UITableView *tabView;
@property(nonatomic,strong)NSMutableArray<NIMRecentSession *> *clientDataArr;//存储客户的数组
@property(nonatomic,strong)NSMutableArray *chatDataArr;//聊天记录
@property(nonatomic,strong)TWSearchImDescribeView *describeView;
@property (nonatomic, strong) NSMutableDictionary <NSString *, NIMUser *> *userResultDictionary;
@property (nonatomic, strong) NSMutableDictionary <NSString *, NIMTeam *> *teamResultDictionary;
@property(nonatomic,strong)NSMutableDictionary<NIMSession *,NSArray<NIMMessage *> *> *messagesDict;
@property (nonatomic, strong) TWSearchImNoData *noDataView;
@end

@implementation TWIMSearchViewController
#pragma mark --Lazy Methods
#pragma mark --Privities Methods
- (void)cancel{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)textFieldDidChange:(UITextField *)field{
    //查询逻辑
    UITextRange * selectedRange = field.markedTextRange;
    NSString *text = [field.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if(selectedRange == nil || selectedRange.empty){
        if (text.length > 0) {
            self.tabView.hidden = NO;
            self.describeView.hidden = YES;
            //先进行昵称查找
            __weak typeof(self) weakSelf = self;
            //             [SVProgressHUD show];
            [self searchSessionIdWithText:text completion:^(NSError *error, NSMutableArray<NSMutableArray *> *sessionIds) {
                if (error) {
                    [SVProgressHUD dismiss];
                    [weakSelf.view makeToast:@"搜索失败" duration:2 position:CSToastPositionCenter];
                } else {
                    //反查recentsession
                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
                        NSMutableArray *resultSessions = [NSMutableArray array];
                        __block NIMRecentSession *recentSession = nil;
                        
                        [sessionIds enumerateObjectsUsingBlock:^(NSMutableArray * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            if (idx == 0) { //user
                                for (NSString *userId in obj) {
                                    recentSession = [self recentSessionWithId:userId type:NIMSessionTypeP2P];
                                    if (recentSession) {
                                        [resultSessions addObject:recentSession];
                                    }
                                }
                            } else if (idx == 1) { //team
                                for (NSString *teamId in obj) {
                                    recentSession = [self recentSessionWithId:teamId type:NIMSessionTypeTeam];
                                    if (recentSession) {
                                        [resultSessions addObject:recentSession];
                                    }
                                }
                            }
                        }];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [SVProgressHUD dismiss];
                            
                            if (resultSessions.count == 0) {
                                [self.view addSubview:self.noDataView];
                                self.noDataView.hidden = NO;
                                _noDataView.searchLabel.text = text;
                            }else{
                                if (!self.noDataView.hidden) {
                                    self.noDataView.hidden = YES;
                                }
                                weakSelf.clientDataArr = resultSessions;
                                [weakSelf searchChatWithText:text];
                            }
                            
                        });
                    });
                }
            }];
            
            
        }else{
            self.tabView.hidden = YES;
            self.describeView.hidden = NO;
            self.noDataView.hidden = YES;
            //这里清空数据
        }
    }
}
- (NIMRecentSession *)recentSessionWithId:(NSString *)sessionId type:(NIMSessionType)type{
    __block NIMRecentSession *ret = nil;
    [self.recentSessions enumerateObjectsUsingBlock:^(NIMRecentSession * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.session.sessionId isEqualToString:sessionId]
            && obj.session.sessionType == type) {
            ret = obj;
            *stop = YES;
        }
    }];
    return ret;
}

- (void)searchSessionIdWithText:(NSString *)text
                     completion:(void (^)(NSError *error, NSMutableArray <NSMutableArray *> *sessionIds))completion {
    NSMutableArray *ret = [NSMutableArray array];
    //查找user
    [_userResultDictionary removeAllObjects];
    [_teamResultDictionary removeAllObjects];
    [_messagesDict removeAllObjects];
    NIMUserSearchOption *option = [[NIMUserSearchOption alloc] init];
    option.searchRange = NIMUserSearchRangeOptionAll;
    option.searchContent = text;
    option.ignoreingCase = YES;
    __weak typeof(self) weakSelf= self;
    [[NIMSDK sharedSDK].userManager searchUserWithOption:option completion:^(NSArray<NIMUser *> * _Nullable users, NSError * _Nullable error) {
        if (!error) {
            NSMutableArray *userResults = [NSMutableArray array];
            for (NIMUser *user in users) {
                [userResults addObject:user.userId];
                weakSelf.userResultDictionary[user.userId] = user;
            }
            [ret addObject:userResults];
            
            NIMTeamSearchOption *teamSeacheOption = [[NIMTeamSearchOption alloc] init];
            teamSeacheOption.searchContent = text;
            teamSeacheOption.ignoreingCase = YES;
            [[NIMSDK sharedSDK].teamManager searchTeamWithOption:teamSeacheOption completion:^(NSError * _Nullable error, NSArray<NIMTeam *> * _Nullable teams) {
                if (!error) {
                    NSMutableArray *teamResults = [NSMutableArray array];
                    for (NIMTeam *team in teams) {
                        [teamResults addObject:team.teamId];
                        weakSelf.teamResultDictionary[team.teamId] = team;
                    }
                    [ret addObject:teamResults];
                }
                if (completion) {
                    completion(error, ret);
                }
            }];
        } else {
            if (completion) {
                completion(error, nil);
            }
        }
    }];
}

//查询聊天记录
-(void)searchChatWithText:(NSString *)text{
    NIMMessageSearchOption *option = [[NIMMessageSearchOption alloc]init];
    option.allMessageTypes = YES;
    option.searchContent = text;
    __weak typeof(self) weakSelf= self;
    [[NIMSDK sharedSDK].conversationManager searchAllMessages:option result:^(NSError * _Nullable error, NSDictionary<NIMSession *,NSArray<NIMMessage *> *> * _Nullable messages) {
        weakSelf.messagesDict = (NSMutableDictionary *)messages;
        NSMutableArray *array = [NSMutableArray array];
        array = messages.allKeys;
        weakSelf.chatDataArr = array;
        [weakSelf.tabView reloadData];
        
    }];
}

-(void)lookMoreBtnClick:(UIButton *)btn{
    if([btn.titleLabel.text containsString:@"联系人"]){
        TWLookMoreContactsController *contactVc = [[TWLookMoreContactsController alloc]init];
        contactVc.clientDataArr = self.clientDataArr;
        contactVc.userResultDictionary = self.userResultDictionary;
        contactVc.searchStr = self.searchField.text;
        contactVc.recentSessions = self.recentSessions;
        [self.navigationController pushViewController:contactVc animated:YES];
    }
    
    if([btn.titleLabel.text containsString:@"聊天记录"]){
        TWLookMoreMessagesController *messageVc = [[TWLookMoreMessagesController alloc]init];
        messageVc.chatDataArr = self.chatDataArr;
        messageVc.messagesDict = self.messagesDict;
        messageVc.searchStr = self.searchField.text;
        [self.navigationController pushViewController:messageVc animated:YES];
    }
}

//-(void)keyboardWillHide:(NSNotification *)note
//{
//    if (self.tabView.frame.origin.y == 0) {
//        self.tabView.frame = CGRectMake(0, kTopBarHeight, kScreen_width, kScreen_height-kTopBarHeight);
//        self.describeView.frame = CGRectMake(0, kTopBarHeight, kScreen_width, kScreen_height-kTopBarHeight);
//    }
//
//}

#pragma mark --UIViewCongtroller Methods

- (BOOL)useWhiteBar{
    return YES;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabView.hidden = NO;
    self.describeView.hidden = YES;
    if (self.chatDataArr.count == 0 && self.clientDataArr.count == 0) {
        self.tabView.hidden = YES;
    }
    
    if (self.searchField.text.length>0) {
        [self textFieldDidChange:self.searchField];
        //这里展示是查询无数据
    }else{
        //这里展示无查询结果
        self.describeView.hidden = !self.tabView.hidden;
    }
    
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _userResultDictionary = [NSMutableDictionary dictionary];
    _teamResultDictionary = [NSMutableDictionary dictionary];
    _messagesDict = [NSMutableDictionary dictionary];
    [self initUI];
    //    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    // Do any additional setup after loading the view.
}

- (void)initUI{
    _searchField = [[TWIMSearchField alloc] initWithFrame:CGRectMake(0, 0, kScreen_width-15-61, 34)];
    kViewRadius(_searchField, 2);
    _searchField.backgroundColor = kRGB(246, 246, 246);
    [_searchField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_searchField];
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithTitle:@"取消" font:kFont(14) color:kRGB(37, 126, 223) image:nil target:self action:@selector(cancel)];
    
    _tabView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreen_width, kScreen_height-kTopBarHeight)  style:UITableViewStylePlain];
    _tabView.delegate = self;
    _tabView.dataSource = self;
    _tabView.separatorStyle = NO;
    [self.view addSubview:_tabView];
    
    
    NSArray *nibs = [[NSBundle mainBundle]loadNibNamed:@"TWSearchImDescribeView" owner:self options:nil];
    _describeView = [nibs lastObject];
    _describeView.frame = CGRectMake(0, 0, kScreen_width, kScreen_height-kTopBarHeight);
    //    _describeView.backgroundColor = [UIColor redColor];
    [self.view addSubview:_describeView];
    
    //     [_searchField becomeFirstResponder];
}

-(void)viewDidLayoutSubviews{
    
}

#pragma mark --UITableView DataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.chatDataArr.count>0 && self.clientDataArr.count>0) {
        return 2;
    }else if(self.chatDataArr.count == 0 && self.clientDataArr.count == 0){
        return 0;
    }else{
        return 1;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        if (self.clientDataArr.count>3) {
            return 3;
        }else if(self.clientDataArr.count>0){
            return self.clientDataArr.count;
        }else{
            if (self.chatDataArr.count > 3) {
                return 3;
            }else{
                return self.chatDataArr.count;
            }
        }
    }else{
        if (self.chatDataArr.count > 3) {
            return 3;
        }else{
            return self.chatDataArr.count;
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (self.chatDataArr.count > 0 || self.clientDataArr.count > 0) {
        return 54.0f;
    }else{
        return 0;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 0) {
        if (self.clientDataArr.count > 3 ||(self.clientDataArr.count==0 && self.chatDataArr.count>3)) {
            return 54.0f;
        }else{
            return 0;
        }
    }else{
        if (self.chatDataArr.count > 3) {
            return 54.0f;
        }else{
            return 0;
        }
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (self.clientDataArr.count>0) {
            NSArray *nibs = [[NSBundle mainBundle]loadNibNamed:@"TWSearchImContactsCell" owner:self options:nil];
            TWSearchImContactsCell *contactCell = [nibs lastObject];
            NIMRecentSession *recent = self.clientDataArr[indexPath.row];
            [contactCell dataForCell:recent user:_userResultDictionary searchString:_searchField.text];
            return contactCell;
        }else{
            if (self.chatDataArr.count>0) {
                NSArray *nibs = [[NSBundle mainBundle]loadNibNamed:@"TWSearchImMessageCell" owner:self options:nil];
                TWSearchImMessageCell *messageCell = [nibs lastObject];
                NIMSession *session = self.chatDataArr[indexPath.row];
                
                [messageCell dataForCell:session searchDic:_messagesDict searchStr:_searchField.text];
                return messageCell;
            }else{
                return nil;
            }
        }
    }else{
        if (self.chatDataArr.count>0) {
            NSArray *nibs = [[NSBundle mainBundle]loadNibNamed:@"TWSearchImMessageCell" owner:self options:nil];
            TWSearchImMessageCell *messageCell = [nibs lastObject];
            NIMSession *session = self.chatDataArr[indexPath.row];
            [messageCell dataForCell:session searchDic:_messagesDict searchStr:_searchField.text];
            return messageCell;
        }else{
            return nil;
        }
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(section == 0){
        NSArray *nibs =[[NSBundle mainBundle]loadNibNamed:@"TWSearchImHeadView" owner:self options:nil];
        TWSearchImHeadView *headView =[nibs lastObject];
        if (self.clientDataArr.count>0 ) {
            headView.leftNameLabel.text = @"联系人";
        }else{
            headView.leftNameLabel.text = @"聊天记录";
        }
        return headView;
    }else{
        if (self.chatDataArr.count>0) {
            NSArray *nibs =[[NSBundle mainBundle]loadNibNamed:@"TWSearchImHeadView" owner:self options:nil];
            TWSearchImHeadView *headView =[nibs lastObject];
            headView.leftNameLabel.text = @"聊天记录";
            return headView;
        }else{
            return nil;
        }
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 0) {
        if (self.chatDataArr.count > 3 ||(self.clientDataArr.count > 3 && self.chatDataArr.count == 0)) {
            NSArray *nibs =[[NSBundle mainBundle]loadNibNamed:@"TWSearchImFootView" owner:self options:nil];
            TWSearchImFootView *footView =[nibs lastObject];
            if (self.clientDataArr.count > 3) {
                [footView.lookMoreBtn setTitle:@"查看更多联系人" forState:UIControlStateNormal];
            }else{
                if(self.chatDataArr.count>3 && self.clientDataArr.count == 0){
                    [footView.lookMoreBtn setTitle:@"查看更多聊天记录" forState:UIControlStateNormal];
                }
            }
            [footView.lookMoreBtn addTarget:self action:@selector(lookMoreBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            return footView;
        }else{
            return nil;
        }
    }else{
        if (self.chatDataArr.count > 3) {
            NSArray *nibs =[[NSBundle mainBundle]loadNibNamed:@"TWSearchImFootView" owner:self options:nil];
            TWSearchImFootView *footView =[nibs lastObject];
            [footView.lookMoreBtn setTitle:@"查看更多聊天记录" forState:UIControlStateNormal];
            [footView.lookMoreBtn addTarget:self action:@selector(lookMoreBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            return footView;
        }else{
            return nil;
        }
    }
}
#pragma mark --UITableView Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        if (self.clientDataArr.count > 0) {
            NIMRecentSession *recent = self.clientDataArr[indexPath.row];
            TWSessionViewController *sessionVc = [[TWSessionViewController alloc]initWithSession:recent.session];
            [self.navigationController pushViewController:sessionVc animated:YES];
        }else{
            if (self.chatDataArr.count>0) {
                NIMSession *session = self.chatDataArr[indexPath.row];
                NSArray *messageArr = _messagesDict[session];
                if (messageArr.count > 1) {
                    //跳转到个人更多页面
                    TWLookMoreSomeOneMessageController *someoneMessageVc = [[TWLookMoreSomeOneMessageController alloc]init];
                    someoneMessageVc.searchStr = _searchField.text;
                    someoneMessageVc.chatDataArr = (NSMutableArray *)messageArr;
                    someoneMessageVc.session = session;
                    [self.navigationController pushViewController:someoneMessageVc animated:YES];
                }else{
                    //跳转到个人页面
                    TWSessionViewController *sessionVc = [[TWSessionViewController alloc]initWithSession:session];
                    sessionVc.firstMessage = messageArr[0];
                    [self.navigationController pushViewController:sessionVc animated:YES];
                    
                }
                
            }
        }
    }else{
        if (self.chatDataArr.count>0) {
            NIMSession *session = self.chatDataArr[indexPath.row];
            NSArray *messageArr = _messagesDict[session];
            if (messageArr.count > 1) {
                //跳转到个人更多页面
                TWLookMoreSomeOneMessageController *someoneMessageVc = [[TWLookMoreSomeOneMessageController alloc]init];
                someoneMessageVc.searchStr = _searchField.text;
                someoneMessageVc.chatDataArr = (NSMutableArray *)messageArr;
                someoneMessageVc.session = session;
                [self.navigationController pushViewController:someoneMessageVc animated:YES];
            }else{
                //跳转到个人页面
                TWSessionViewController *sessionVc = [[TWSessionViewController alloc]initWithSession:session];
                sessionVc.firstMessage = messageArr[0];
                [self.navigationController pushViewController:sessionVc animated:YES];
            }
            
        }
    }
}

- (TWSearchImNoData *)noDataView
{
    if (!_noDataView) {
        _noDataView = [[TWSearchImNoData alloc] init];
        _noDataView.frame = CGRectMake(0, 0, kScreen_width, kScreen_height);
    }
    return _noDataView;
}


@end
