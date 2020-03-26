//
//  TWUploadFiles.h
//  TaiWuOffice
//
//  Created by xiaojin on 2018/12/12.
//  Copyright © 2018 zsf. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TWUploadFiles : UIViewController

@property (nonatomic,assign)BOOL allowPickingVideo;
@property (nonatomic,assign) float maxImageSize;
@property (nonatomic,assign) float maxVideoSize;

@property (nonatomic,copy) void (^callBackFiles)(NSArray *files);

/*
 * uploadParameter : 上传参数   默认为资产
 */
- (void)pushTZImagePickerController:(UIViewController *)parentVC maxImageCount:(NSInteger)maxImageCount uploadParameter:(NSDictionary *)uploadParameter;

@end

NS_ASSUME_NONNULL_END
