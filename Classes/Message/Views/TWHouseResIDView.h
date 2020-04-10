//
//  TWHouseResIDCell.h
//  TaiWuOffice
//
//  Created by zsf on 2019/3/21.
//  Copyright © 2019年 zsf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TWHouseResIDView : UICollectionReusableView
@property (nonatomic,strong)UITextField *field;
@property (nonatomic,strong)UILabel *buildingNameLabel;
@property(nonatomic,strong)UILabel *buildingAddressLabel;
@property(nonatomic,strong)UIButton *buildingNameBtn;
@property(nonatomic,strong)UIButton *buildingAddressBtn;
@property(nonatomic,strong)UIButton *nameDeleteBtn;
@property(nonatomic,strong)UIButton *addressDeleteBtn;
@property (nonatomic,strong)UIView *nameline;
@property(nonatomic,strong)UIView *addressline;
@property(nonatomic,strong)UILabel *nameTitleLabel;
@property(nonatomic,strong)UILabel *addressTitleLabel;
@property(nonatomic,assign)BOOL isHidden;
@property (nonatomic,strong)UIView  *buildingView;



@end
