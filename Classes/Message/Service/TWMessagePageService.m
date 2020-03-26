//
//  TWMessagePageService.m
//  TaiWuWang
//
//  Created by 田黎强 on 2020/2/27.
//  Copyright © 2020 zsf. All rights reserved.
//

#import "TWMessagePageService.h"
#import "TWApiManager.h"
@implementation TWMessagePageService
+(void)getPhoneNumber:(NSString *)sessionId  callback:(void(^)(id respone,TWApiStatusCode code))callback
{
    NSDictionary *params = @{
        @"imAccount":sessionId
    };
    [TWApiManager postWithUrl:[kBaseUrl stringByAppendingString:kGetPhoneNumberUrl] parameters:params callback:^(id  _Nonnull response, TWApiStatusCode code) {
        if (code==TWApiStatusSuccess||code==TWApiStatusFailure) {
               callback(response,code);
        }else{
               callback(nil,code);
        }
    }];
}


@end
