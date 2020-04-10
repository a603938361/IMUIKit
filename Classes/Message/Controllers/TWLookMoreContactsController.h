//
//  TWLookMoreContactsController.h
//  TaiWuWang
//
//  Created by 田黎强 on 2020/3/16.
//  Copyright © 2020 zsf. All rights reserved.
//

#import "TWBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface TWLookMoreContactsController : TWBaseViewController
@property(nonatomic,strong)NSMutableArray<NIMRecentSession *> *clientDataArr;//存储客户的数组
@property (nonatomic, strong) NSMutableDictionary <NSString *, NIMUser *> *userResultDictionary;
@property(nonatomic,copy)NSString *searchStr;
@property (nonatomic, weak) NSMutableArray *recentSessions;

@end

NS_ASSUME_NONNULL_END
