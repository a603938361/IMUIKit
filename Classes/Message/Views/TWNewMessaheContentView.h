//
//  TWNewMessaheContentView.h
//  TaiWuWang
//
//  Created by 田黎强 on 2020/2/19.
//  Copyright © 2020 zsf. All rights reserved.
//

#import "NIMSessionMessageContentView.h"

NS_ASSUME_NONNULL_BEGIN

@interface TWNewMessaheContentView : NIMSessionMessageContentView
@property(nonatomic,strong)UIImageView *houseImageView;
@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)UILabel *subTitileLabel;
@property(nonatomic,strong)UILabel *priceLabel;
@property(nonatomic,strong)UIView *bgView;
@end

NS_ASSUME_NONNULL_END
