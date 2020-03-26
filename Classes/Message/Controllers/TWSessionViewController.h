//
//  TWSessionViewController.h
//  TaiWuWang
//
//  Created by 田黎强 on 2020/2/19.
//  Copyright © 2020 zsf. All rights reserved.
//

#import "NIMSessionViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface TWSessionViewController : NIMSessionViewController
@property(nonatomic,copy)NSDictionary *messageDic;
@property(nonatomic,copy)NSString *account;
@property(nonatomic,strong)NIMMessage *firstMessage;
@end

NS_ASSUME_NONNULL_END
