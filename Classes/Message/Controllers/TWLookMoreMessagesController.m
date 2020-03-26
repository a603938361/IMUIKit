//
//  TWLookMoreMessagesController.m
//  TaiWuWang
//
//  Created by 田黎强 on 2020/3/16.
//  Copyright © 2020 zsf. All rights reserved.
//

#import "TWLookMoreMessagesController.h"
#import "TWSearchImMessageCell.h"
#import "TWSessionViewController.h"
#import "TWSearchImHeadView.h"
#import "TWSearchImDescribeView.h"
#import "TWIMSearchField.h"
#import <UIView+Toast.h>
#import "UIBarButtonItem+Extension.h"
#import <SVProgressHUD.h>
@interface TWLookMoreMessagesController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)TWSearchImDescribeView *describeView;
@property(nonatomic,strong)TWIMSearchField *searchField;
@property(nonatomic,strong)UITableView *tabView;
@end

@implementation TWLookMoreMessagesController

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
            [_messagesDict removeAllObjects];
            //进行查询操作
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
            
            
        }else{
            self.tabView.hidden = YES;
            self.describeView.hidden = NO;
        }
    }
}




#pragma mark --UIViewControllers Methods
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabView.hidden = NO;
    self.describeView.hidden = YES;
    if (self.chatDataArr.count == 0) {
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
    _describeView.titleLabel.text = @"聊天记录";
    [self.view addSubview:_describeView];
}


#pragma mark --UITableView DataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.chatDataArr.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (self.chatDataArr.count > 0) {
        return 54.0f;
    }else{
        return 0;
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80.0f;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *nibs = [[NSBundle mainBundle]loadNibNamed:@"TWSearchImMessageCell" owner:self options:nil];
    TWSearchImMessageCell *messageCell = [nibs lastObject];
    NIMSession *session = self.chatDataArr[indexPath.row];
    [messageCell dataForCell:session searchDic:_messagesDict searchStr:_searchField.text];
    return messageCell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(self.chatDataArr.count>0){
        NSArray *nibs =[[NSBundle mainBundle]loadNibNamed:@"TWSearchImHeadView" owner:self options:nil];
        TWSearchImHeadView *headView =[nibs lastObject];
        headView.leftNameLabel.text = @"更多聊天记录";
        return headView;
    }else{
        return nil;
    }
    
}

#pragma mark --UITableView Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NIMSession *session = self.chatDataArr[indexPath.row];
    NSArray *messageArr = _messagesDict[session];
    TWSessionViewController *sessionVc = [[TWSessionViewController alloc]initWithSession:session];
    sessionVc.firstMessage = messageArr[0];
    [self.navigationController pushViewController:sessionVc animated:YES];
}



@end
