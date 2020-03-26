//
//  TWHouseResIDCell.m
//  TaiWuOffice
//
//  Created by zsf on 2019/3/21.
//  Copyright © 2019年 zsf. All rights reserved.
//

#import "TWHouseResIDView.h"

@interface TWHouseResIDView()
@property (nonatomic,strong)UIView *line;
@property (nonatomic,strong)UILabel *titleLabel;
@property (nonatomic,strong)UILabel *bottomLabel;
@property(nonatomic,strong)UIButton *btn;
@end

@implementation TWHouseResIDView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews{
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = kFont(14);
    _titleLabel.textColor = kRGB(51, 51, 51);
    _titleLabel.text = @"房源ID";
    [self addSubview:_titleLabel];
    

    
     _line = [[UIView alloc] init];
     _line.backgroundColor = kRGB(218, 218, 218);
     [self addSubview:_line];
    
 

//
    _buildingView = [[UIView alloc]init];
    [self addSubview:_buildingView];
    
        _field = [[UITextField alloc] init];
    //    _field.textColor = kRGB(153, 153, 153);
        _field.placeholder = @"请输入房源ID";
        _field.font = kFont(14);
        [self addSubview:_field];
    
    
    _nameTitleLabel = [[UILabel alloc] init];
    _nameTitleLabel.font = kFont(14);
    _nameTitleLabel.textColor = kRGB(51, 51, 51);
    _nameTitleLabel.text = @"栋号";
    [_buildingView addSubview:_nameTitleLabel];
    
      _buildingNameLabel = [[UILabel alloc] init];
      _buildingNameLabel.font = kFont(14);
      _buildingNameLabel.textColor = kRGB(51, 51, 51);
      _buildingNameLabel.highlightedTextColor = kRGB(153, 153, 153);
     _buildingNameLabel.highlighted = YES;
    _buildingNameLabel.text = @"请选择栋号";
      [_buildingView addSubview:_buildingNameLabel];
    
    _buildingNameBtn =[UIButton buttonWithType:UIButtonTypeCustom];
    _buildingNameBtn.backgroundColor = [UIColor clearColor];
    [_buildingView addSubview:_buildingNameBtn];
//    @property(nonatomic,strong)UIButton *buildingAddressBtn;
    _buildingAddressBtn =[UIButton buttonWithType:UIButtonTypeCustom];
    _buildingAddressBtn.backgroundColor = [UIColor clearColor];
       [_buildingView addSubview:_buildingAddressBtn];

        
    _nameDeleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_nameDeleteBtn setImage:[UIImage imageNamed:@"icon_delete"] forState:UIControlStateNormal];
  
    [_buildingView addSubview:_nameDeleteBtn];
    
    
    _addressDeleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
      [_addressDeleteBtn setImage:[UIImage imageNamed:@"icon_delete"] forState:UIControlStateNormal];
    
      [_buildingView addSubview:_addressDeleteBtn];
    
    
    _nameline = [[UIView alloc] init];
    _nameline.backgroundColor = kRGB(218, 218, 218);
    [_buildingView addSubview:_nameline];
    
    _addressTitleLabel = [[UILabel alloc] init];
    _addressTitleLabel.font = kFont(14);
    _addressTitleLabel.textColor = kRGB(51, 51, 51);
    _addressTitleLabel.text = @"室号";
    [_buildingView addSubview:_addressTitleLabel];
    
    _buildingAddressLabel = [[UILabel alloc] init];
        _buildingAddressLabel.font = kFont(14);
        _buildingAddressLabel.textColor = kRGB(51, 51, 51);
        _buildingAddressLabel.highlightedTextColor = kRGB(153, 153, 153);
       _buildingAddressLabel.highlighted = YES;
      _buildingAddressLabel.text = @"搜索室号";
        [_buildingView addSubview:_buildingAddressLabel];
       
    _addressline = [[UIView alloc] init];
    _addressline.backgroundColor = kRGB(218, 218, 218);
    [_buildingView addSubview:_addressline];
    
    _bottomLabel = [[UILabel alloc] init];
    _bottomLabel.font = kFont(14);
    _bottomLabel.textColor = kRGB(51, 51, 51);
    _bottomLabel.text = @"交易类型";

    [self addSubview:_bottomLabel];
    
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(16);
        make.top.equalTo(self).offset(20);
        make.height.equalTo(@20);
    }];
    
 

    [_field mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(_line);
        make.bottom.equalTo(_line.mas_top);
        make.height.equalTo(@30);
    }];
   

    [_line mas_makeConstraints:^(MASConstraintMaker *make) {
         make.left.equalTo(_titleLabel);
         make.right.equalTo(self).offset(-119);
         make.height.equalTo(@1);
     }];

    if (!_isHidden) {
        
    
    [_buildingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_line.mas_bottom).offset(0);
        make.left.right.equalTo(self);
        make.height.equalTo(_isHidden?@0:@156);
        
    }];

    [_nameTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_buildingView).offset(20);
        make.left.equalTo(_buildingView).offset(16);
        make.height.equalTo(@20);
    }];
//
 
    [_buildingNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_nameline.mas_left);
            make.right.equalTo(_nameDeleteBtn.mas_left);
            make.height.equalTo(@30);
            make.top.equalTo(_nameTitleLabel.mas_bottom).offset(7);
    }];
    [_buildingNameBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.top.equalTo(_buildingNameLabel);
       }];
//
    [_nameDeleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_nameline.mas_right);
        make.height.width.equalTo(@30);
        make.top.bottom.equalTo(_buildingNameLabel);
    }];
    
   
    [_nameline mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_nameTitleLabel);
        make.right.equalTo(self).offset(-119);
        make.height.equalTo(@1);
        make.top.equalTo(_buildingNameLabel.mas_bottom);
    }];
    
    [_addressTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_nameline.mas_bottom).offset(20);
        make.left.equalTo(self).offset(16);
        make.height.equalTo(@20);
    }];
    
    [_buildingAddressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_nameline.mas_left);
        make.right.equalTo(_addressDeleteBtn.mas_left);
        make.height.equalTo(@30);
        make.top.equalTo(_addressTitleLabel.mas_bottom).offset(7);
    }];
    
    [_buildingAddressBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(_buildingAddressLabel);
    }];
    
    [_addressDeleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
           make.right.equalTo(_nameline.mas_right);
           make.height.width.equalTo(@30);
           make.top.bottom.equalTo(_buildingAddressLabel);
       }];
       
    
    [_addressline mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_addressTitleLabel);
        make.right.equalTo(self).offset(-119);
        make.height.equalTo(@1);
        make.top.equalTo(_buildingAddressLabel.mas_bottom);
    }];
        
    [_bottomLabel mas_makeConstraints:^(MASConstraintMaker *make) {
               make.top.equalTo(_buildingView.mas_bottom).offset(20);
               make.left.equalTo(self).offset(16);
               make.height.equalTo(@20);
               make.bottom.equalTo(self);
    }];
    }else{
        [_bottomLabel mas_makeConstraints:^(MASConstraintMaker *make) {
               make.top.equalTo(_line.mas_bottom).offset(20);
               make.left.equalTo(self).offset(16);
               make.height.equalTo(@20);
               make.bottom.equalTo(self);
           }];
    }

   
}


-(void)nameDeleteBtnClick{
    _buildingNameLabel.text = @"请选择栋号";
    _buildingNameLabel.highlighted = YES;
    _buildingAddressLabel.text = @"搜索室号";
    _buildingAddressLabel.highlighted = YES;
}

-(void)addressDeleteBtnClick{
    _buildingAddressLabel.text = @"搜索室号";
    _buildingAddressLabel.highlighted = YES;
   
}



@end
