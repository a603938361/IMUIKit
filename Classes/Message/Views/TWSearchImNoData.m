//
//  TWSearchImNoData.m
//  TaiWuOffice
//
//  Created by C.z on 2020/3/27.
//  Copyright © 2020 zsf. All rights reserved.
//

#import "TWSearchImNoData.h"

@interface TWSearchImNoData()

@property (nonatomic, strong) UIImageView *imageview;
@property (nonatomic, strong) UILabel *tipLabel;

@end


@implementation TWSearchImNoData


- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:self.imageview];
        [self addSubview:self.tipLabel];
        [self addSubview:self.searchLabel];
        
        [_imageview mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.centerY.equalTo(self).offset(-100);
        }];
        
        [_tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_imageview.mas_bottom).offset(20);
            make.left.equalTo(self).offset(20);
            make.right.equalTo(self).offset(-20);
            make.height.mas_equalTo(25);
        }];
        
        [_searchLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_tipLabel.mas_bottom).offset(5);
            make.left.equalTo(self).offset(20);
            make.right.equalTo(self).offset(-20);
        }];
        
    }
    return self;
}


- (UIImageView *)imageview
{
    if (!_imageview) {
        _imageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noData"]];
    }
    return _imageview;
}

- (UILabel *)tipLabel
{
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.text = @"找不到包含以下关键词的结果";
        _tipLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _tipLabel;
}

- (UILabel *)searchLabel
{
    if (!_searchLabel) {
        _searchLabel = [[UILabel alloc] init];
        _searchLabel.textAlignment = NSTextAlignmentCenter;
        _searchLabel.textColor = [UIColor redColor];
        _searchLabel.numberOfLines = 0;
    }
    return _searchLabel;
}


@end
