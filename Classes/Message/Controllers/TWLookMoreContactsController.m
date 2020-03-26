//
//  TWLookMoreContactsController.m
//  TaiWuWang
//
//  Created by 田黎强 on 2020/3/16.
//  Copyright © 2020 zsf. All rights reserved.
//

#import "TWLookMoreContactsController.h"
#import "TWSearchImContactsCell.h"
#import "TWSessionViewController.h"
#import "TWSearchImHeadView.h"
#import "TWSearchImDescribeView.h"
#import "TWIMSearchField.h"
#import <UIView+Toast.h>
#import "UIBarButtonItem+Extension.h"
#import <SVProgressHUD.h>


@interface TWLookMoreContactsController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)TWSearchImDescribeView *describeView;
@property(nonatomic,strong)TWIMSearchField *searchField;
@property(nonatomic,strong)UITableView *tabView;
@end

@implementation TWLookMoreContactsController
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
                             weakSelf.clientDataArr = resultSessions;
                             [weakSelf.tabView reloadData];
                             
                         });
                     });
                 }
             }];

             
         }else{
             self.tabView.hidden = YES;
             self.describeView.hidden = NO;
         }
     }
}

- (void)searchSessionIdWithText:(NSString *)text
                     completion:(void (^)(NSError *error, NSMutableArray <NSMutableArray *> *sessionIds))completion {
    NSMutableArray *ret = [NSMutableArray array];
    //查找user
    [_userResultDictionary removeAllObjects];
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
//                        weakSelf.teamResultDictionary[team.teamId] = team;
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
#pragma mark --UIViewControllers Methods
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabView.hidden = NO;
    self.describeView.hidden = YES;
    if (self.clientDataArr.count == 0) {
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
    // Do any additional setup after loading the view.
    [self configSubViews];
}

-(void)configSubViews{
    
    _searchField = [[TWIMSearchField alloc] initWithFrame:CGRectMake(0, 0, kScreen_width-15-61, 34)];
      kViewRadius(_searchField, 2);
      _searchField.backgroundColor = kRGB(246, 246, 246);
    _searchField.text = self.searchStr;
      [_searchField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
      self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_searchField];
      self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithTitle:@"取消" font:kFont(14) color:kRGB(37, 126, 223) image:nil target:self action:@selector(cancel)];
    _tabView = [[UITableView alloc]initWithFrame:self.view.bounds  style:UITableViewStylePlain];
      _tabView.delegate = self;
      _tabView.dataSource = self;
      _tabView.separatorStyle = NO;
      [self.view addSubview:_tabView];
    
       
        NSArray *nibs = [[NSBundle mainBundle]loadNibNamed:@"TWSearchImDescribeView" owner:self options:nil];
        _describeView = [nibs lastObject];
        _describeView.frame = self.view.bounds;
        _describeView.titleLabel.text = @"用户昵称   |   备注信息   ";
        [self.view addSubview:_describeView];
}


#pragma mark --UITableView DataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.clientDataArr.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (self.clientDataArr.count > 0) {
        return 54.0f;
    }else{
        return 0;
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80.0f;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
     NSArray *nibs = [[NSBundle mainBundle]loadNibNamed:@"TWSearchImContactsCell" owner:self options:nil];
    TWSearchImContactsCell *contactCell = [nibs lastObject];
    NIMRecentSession *recent = self.clientDataArr[indexPath.row];
    [contactCell dataForCell:recent user:_userResultDictionary searchString:_searchStr];
    return contactCell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(self.clientDataArr.count>0){
          NSArray *nibs =[[NSBundle mainBundle]loadNibNamed:@"TWSearchImHeadView" owner:self options:nil];
        TWSearchImHeadView *headView =[nibs lastObject];
        headView.leftNameLabel.text = @"更多联系人";
        return headView;
    }else{
        return nil;
    }
 
}

#pragma mark --UITableView Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
        if (self.clientDataArr.count > 0) {
            NIMRecentSession *recent = self.clientDataArr[indexPath.row];
            TWSessionViewController *sessionVc = [[TWSessionViewController alloc]initWithSession:recent.session];
            [self.navigationController pushViewController:sessionVc animated:YES];
        }
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
