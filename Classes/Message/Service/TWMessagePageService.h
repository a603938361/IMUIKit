//
//  TWMessagePageService.h
//  TaiWuWang
//
//  Created by 田黎强 on 2020/2/27.
//  Copyright © 2020 zsf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TWApiManager.h"
NS_ASSUME_NONNULL_BEGIN

@interface TWMessagePageService : NSObject
+(void)getPhoneNumber:(NSString *)sessionId  callback:(void(^)(id respone,TWApiStatusCode code))callback;
//上传图片

@end

NS_ASSUME_NONNULL_END
