//
//  TWPhraseView.m
//  TaiWuWang
//
//  Created by 田黎强 on 2020/2/25.
//  Copyright © 2020 zsf. All rights reserved.
//

#import "TWPhraseView.h"
#import "UIView+NIM.h"

@interface TWPhraseView ()<UITableViewDelegate,UITableViewDataSource>
{
    NSArray *dateArray;
}
@property(nonatomic,strong)UITableView *phraseTab;

@end
@implementation TWPhraseView

#pragma mark --UIView Methods
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self loadConfig];
    }
    return self;
}

- (void)loadConfig{
    dateArray = [NSArray array];
    dateArray = @[@"您好，请问这套房子还在吗？",@"您好，我最近想看房，有好房推荐吗？",@"什么时间方便线下看房？",@"请问这套房子首付和贷款是多少？",@"这套房子价格还可以再商量么？",@"这个小区或附近小区还有相似的房子吗？"];
    _phraseTab = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.nim_width, 0) style:UITableViewStylePlain];
    _phraseTab.nim_size = self.nim_size;
    _phraseTab.dataSource = self;
    _phraseTab.delegate = self;
    _phraseTab.separatorStyle = NO;
    [self addSubview:_phraseTab];
    
}


- (CGSize)sizeThatFits:(CGSize)size
{
    return CGSizeMake(size.width, 216.f);
}

-(void)layoutSubviews{
    [super layoutSubviews];
    _phraseTab.nim_top =0;
    //    _phraseTab.nim_bottom = self.nim_height;
    _phraseTab.nim_size = self.nim_size;
    
}
#pragma mark --UITableView DataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dateArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    if (cell ==  nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cellID"];
    }
    cell.textLabel.textColor = kRGB(51, 51, 51);
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.textLabel.text = dateArray[indexPath.row];
    cell.selectionStyle = NO;
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 35.2;
}


#pragma mark --UITableView Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectPhraseMessage:)]) {
        [self.delegate   selectPhraseMessage:dateArray[indexPath.row]];
    }
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
