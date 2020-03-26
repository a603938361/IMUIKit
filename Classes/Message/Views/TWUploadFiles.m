//
//  TWUploadFiles.m
//  TaiWuOffice
//
//  Created by xiaojin on 2018/12/12.
//  Copyright © 2018 zsf. All rights reserved.
//

#import "TWUploadFiles.h"
//#import "TWAnnexCollectionViewCell.h"
#import "TZImagePickerController.h"
#import "UIView+FindViewController.h"
//#import "TWAttendanceAppealService.h"
#import "TWNavigationController.h"
#import "TWUploadFileModel.h"
#import "TZImagePickerController+AddProperty.h"
#import "MBProgressHUD+Extension.h"

//#define maxImageCount   4
#define maxColumnNumber   4

@interface TWUploadFiles ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,TZImagePickerControllerDelegate>
@property (nonatomic,strong) UIViewController *parentVC;
@property (nonatomic, strong) UIImagePickerController *imagePickerVc;
@property (strong, nonatomic) CLLocation *location;
@property (nonatomic, assign) BOOL allowCropSwitch;
@property (nonatomic,strong) NSMutableArray *selectPhotos;
@property (nonatomic,strong) NSMutableArray *uploadFiles;
@property (nonatomic,strong) NSMutableArray *selectAssets;
@property (nonatomic,strong) NSDictionary *uploadParameter;

@property (nonatomic,assign)BOOL isCancle;
@end
static NSInteger maxImageCount = 1;
@implementation TWUploadFiles

#pragma mark - TZImagePickerController

-(instancetype)init{
    if (self = [super init]) {
        self.allowCropSwitch = NO; // 默认图片可裁剪
        _allowPickingVideo = NO;
    }
    return self;
}

- (void)pushTZImagePickerController:(UIViewController *)parentVC maxImageCount:(NSInteger)maxImageCount uploadParameter:(NSDictionary *)uploadParameter{
    if (!kDictIsEmpty(uploadParameter)) {
        self.uploadParameter = uploadParameter;
    }else{
        TWMinePersonalModel *model =[TWMinePersonalModel mj_objectWithKeyValues:[[NSUserDefaults standardUserDefaults]objectForKey:kPersonalInfo]];
        self.uploadParameter = @{
            @"istravel":kStringIsEmpty([TWLoginModelService shareInstance].accessToken)?@(0):@(1),
            @"ref":@(1),
            @"event":@(2),
            @"tmp":@(1),
            @"ResourceUse":@(2),
            @"userId":model.userId
        };
    }
    maxImageCount = maxImageCount;
    self.allowCropSwitch = NO; // 默认图片可裁剪
    self.parentVC = parentVC;
    if (maxImageCount <= 0) {
        return;
    }
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:maxImageCount columnNumber:maxColumnNumber delegate:self pushPhotoPickerVc:YES];
    imagePickerVc.doneBtnTitleStr = @"完成   ";
    imagePickerVc.minImagesCount = 1;
    imagePickerVc.maxImageSize = self.maxImageSize;
    imagePickerVc.maxVideoSize = self.maxVideoSize;
#pragma mark - 五类个性化设置，这些参数都可以不传，此时会走默认设置
    //    imagePickerVc.isSelectOriginalPhoto = _isSelectOriginalPhoto;
    // 1.设置目前已经选中的图片数组
    //    if (maxImageCount > 1) {
    ////        imagePickerVc.selectedAssets = ((TWAnnexSectionModel *)self.annexModel.sectionArr[self.selectPath.section]).selectedAssets; // 目前已经选中的图片数组
    //    }
    imagePickerVc.allowTakePicture = !_allowPickingVideo; // 在内部显示拍照按钮
    imagePickerVc.allowTakeVideo = _allowPickingVideo;
    //    imagePickerVc.videoMaximumDuration = 10; // 视频最大拍摄时间
    //    [imagePickerVc setUiImagePickerControllerSettingBlock:^(UIImagePickerController *imagePickerController) {
    //        imagePickerController.videoQuality = UIImagePickerControllerQualityTypeHigh;
    //    }];
    // 2. 在这里设置imagePickerVc的外观
    imagePickerVc.iconThemeColor = [UIColor colorWithRed:31 / 255.0 green:185 / 255.0 blue:34 / 255.0 alpha:1.0];
    imagePickerVc.showPhotoCannotSelectLayer = YES;
    imagePickerVc.cannotSelectLayerColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    [imagePickerVc setPhotoPickerPageUIConfigBlock:^(UICollectionView *collectionView, UIView *bottomToolBar, UIButton *previewButton, UIButton *originalPhotoButton, UILabel *originalPhotoLabel, UIButton *doneButton, UIImageView *numberImageView, UILabel *numberLabel, UIView *divideLine) {
        [doneButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }];
    // 3. 设置是否可以选择视频/图片/原图
    imagePickerVc.allowPickingGif = NO;
    imagePickerVc.allowPickingVideo = _allowPickingVideo;// 不能选择视频
    imagePickerVc.allowPickingMultipleVideo = _allowPickingVideo;
    
    // 4. 照片排列按修改时间升序
    imagePickerVc.sortAscendingByModificationDate = YES;
    imagePickerVc.showSelectBtn = YES;

    // 设置竖屏下的裁剪尺寸
    NSInteger left = 30;
    NSInteger widthHeight = kScreen_width - 2 * left;
    NSInteger top = (kScreen_height - widthHeight) / 2;
    imagePickerVc.cropRect = CGRectMake(left, top, widthHeight, widthHeight);
    imagePickerVc.statusBarStyle = UIStatusBarStyleLightContent;
    // 设置是否显示图片序号
    imagePickerVc.showSelectedIndex = YES;
    if (@available(iOS 13.0, *)) {
        imagePickerVc.modalPresentationStyle =  UIModalPresentationFullScreen;
    }
    [self.parentVC presentViewController:imagePickerVc animated:YES completion:nil];
}

#pragma mark - UIImagePickerController

- (void)takePhoto {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
        // 无相机权限 做一个友好的提示
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"无法使用相机" message:@"请在iPhone的""设置-隐私-相机""中允许访问相机" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"设置", nil];
        [alert show];
    } else if (authStatus == AVAuthorizationStatusNotDetermined) {
        // fix issue 466, 防止用户首次拍照拒绝授权时相机页黑屏
        __weak typeof(self) weakSelfAVCaptureDevice = self;
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            __strong typeof(self) strongSelf = weakSelfAVCaptureDevice;
            if (granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [strongSelf takePhoto];
                });
            }
        }];
        // 拍照之前还需要检查相册权限
    } else if ([PHPhotoLibrary authorizationStatus] == 2) { // 已被拒绝，没有相册权限，将无法保存拍的照片
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"无法访问相册" message:@"请在iPhone的""设置-隐私-相册""中允许访问相册" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"设置", nil];
        [alert show];
    } else if ([PHPhotoLibrary authorizationStatus] == 0) { // 未请求过相册权限
        __weak typeof(self) weakSelfmanager = self;
        [[TZImageManager manager] requestAuthorizationWithCompletion:^{
            __strong typeof(self) strongSelf = weakSelfmanager;
            [strongSelf takePhoto];
        }];
    } else {
        [self pushImagePickerController];
    }
}

// 调用相机
- (void)pushImagePickerController {
    // 提前定位
    __weak typeof(self) weakSelf = self;
    [[TZLocationManager manager] startLocationWithSuccessBlock:^(NSArray<CLLocation *> *locations) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.location = [locations firstObject];
    } failureBlock:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.location = nil;
    }];
    
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController * imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.editing = YES;
        imagePicker.delegate = self;
        imagePicker.allowsEditing = YES;
        imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
        imagePicker.modalPresentationStyle = UIModalPresentationFullScreen;
        imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
        imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        [self.parentVC presentViewController:imagePicker animated:YES completion:nil];
        
    } else {
        NSLog(@"模拟器中无法打开照相机,请在真机中使用");
    }
}


- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    TZImagePickerController *tzImagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:self];
//    tzImagePickerVc.sortAscendingByModificationDate = self.sortAscendingSwitch;
    [tzImagePickerVc showProgressHUD];
    if ([type isEqualToString:@"public.image"]) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        // 保存图片，获取到asset
        [[TZImageManager manager] savePhotoWithImage:image location:self.location completion:^(PHAsset *asset, NSError *error){
            if (error) {
                [tzImagePickerVc hideProgressHUD];
                NSLog(@"图片保存失败 %@",error);
            } else {
                __weak typeof(self) weakSelf = self;
                [[TZImageManager manager] getCameraRollAlbum:NO allowPickingImage:YES needFetchAssets:NO completion:^(TZAlbumModel *model) {
                    [[TZImageManager manager] getAssetsFromFetchResult:model.result allowPickingVideo:NO allowPickingImage:YES completion:^(NSArray<TZAssetModel *> *models) {
                        __strong typeof(self) strongSelf = weakSelf;
                        [tzImagePickerVc hideProgressHUD];
                        TZAssetModel *assetModel = [models firstObject];
                        if (tzImagePickerVc.sortAscendingByModificationDate) {
                            assetModel = [models lastObject];
                        }
                        if (strongSelf.allowCropSwitch) { // 允许裁剪,去裁剪
                            TZImagePickerController *imagePicker = [[TZImagePickerController alloc] initCropTypeWithAsset:assetModel.asset photo:image completion:^(UIImage *cropImage, id asset) {
                                [strongSelf refreshCollectionViewWithAddedAsset:asset image:cropImage];
                            }];
                            imagePicker.needCircleCrop = strongSelf.allowCropSwitch;
                            imagePicker.circleCropRadius = 100;
                            if (@available(iOS 13.0, *)) {
                                  imagePicker.modalPresentationStyle =  UIModalPresentationFullScreen;
                              }
                            [strongSelf.parentVC presentViewController:imagePicker animated:YES completion:nil];
                        } else {
                            [self refreshCollectionViewWithAddedAsset:assetModel.asset image:image];
                        }
                    }];
                }];
            }
        }];
    } else if ([type isEqualToString:@"public.movie"]) {
        NSURL *videoUrl = [info objectForKey:UIImagePickerControllerMediaURL];
        if (videoUrl) {
            __weak typeof(self) weakSelf = self;
            [[TZImageManager manager] saveVideoWithUrl:videoUrl location:self.location completion:^(PHAsset *asset, NSError *error) {
                if (!error) {
                    [[TZImageManager manager] getCameraRollAlbum:YES allowPickingImage:NO needFetchAssets:NO completion:^(TZAlbumModel *model) {
                        [[TZImageManager manager] getAssetsFromFetchResult:model.result allowPickingVideo:YES allowPickingImage:NO completion:^(NSArray<TZAssetModel *> *models) {
                            __strong typeof(self) strongSelf = weakSelf;
                            [tzImagePickerVc hideProgressHUD];
                            TZAssetModel *assetModel = [models firstObject];
                            if (tzImagePickerVc.sortAscendingByModificationDate) {
                                assetModel = [models lastObject];
                            }
                            [[TZImageManager manager] getPhotoWithAsset:assetModel.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
                                if (!isDegraded && photo) {
                                    [strongSelf refreshCollectionViewWithAddedAsset:assetModel.asset image:photo];
                                }
                            }];
                        }];
                    }];
                } else {
                    [tzImagePickerVc hideProgressHUD];
                }
            }];
        }
    }
}

- (void)refreshCollectionViewWithAddedAsset:(PHAsset *)asset image:(UIImage *)image {
    @try {
        // 上传附件
        [self upLoadFileWithImage:image];
    } @catch (NSException *exception) {
        NSLog(@"%s",__func__);
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    if ([picker isKindOfClass:[UIImagePickerController class]]) {
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) { // 去设置界面，开启相机访问权限
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

#pragma mark - TZImagePickerControllerDelegate

/// User click cancel button
/// 用户点击了取消
- (void)tz_imagePickerControllerDidCancel:(TZImagePickerController *)picker {
    // NSLog(@"cancel");
}

// 这个照片选择器会自己dismiss，当选择器dismiss的时候，会执行下面的代理方法
// 如果isSelectOriginalPhoto为YES，表明用户选择了原图
// 你可以通过一个asset获得原图，通过这个方法：[[TZImageManager manager] getOriginalPhotoWithAsset:completion:]
// photos数组里的UIImage对象，默认是828像素宽，你可以通过设置photoWidth属性的值来改变它
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto infos:(NSArray<NSDictionary *> *)infos {
    
    if (_allowPickingVideo) {
        self.selectAssets = [NSMutableArray arrayWithArray:assets];
        self.uploadFiles = [NSMutableArray array];
        [self startUploadVideo];

        kWeakSelf(weakSelf)
        [MBProgressHUD showMessage:@"" ToView:self.parentVC.view cancelAction:^(MBProgressHUD *hud) {
            weakSelf.isCancle = YES;
            [MBProgressHUD hideHUDForView:weakSelf.parentVC.view];
            if (weakSelf.callBackFiles) {
                weakSelf.callBackFiles(nil);
                weakSelf.callBackFiles = nil;
            }
        }];
    }else{
        @try {
            //        self.isSelectOriginalPhoto = isSelectOriginalPhoto;
            self.selectPhotos =  [NSMutableArray arrayWithArray:photos];
            self.selectAssets = [NSMutableArray arrayWithArray:assets];
            self.uploadFiles = [NSMutableArray array];
            [self startUploadImage];

           kWeakSelf(weakSelf)
            [MBProgressHUD showMessage:@"" ToView:self.parentVC.view cancelAction:^(MBProgressHUD *hud) {
                weakSelf.isCancle = YES;
                 [MBProgressHUD hideHUDForView:weakSelf.parentVC.view];
                if (weakSelf.callBackFiles) {
                     weakSelf.callBackFiles(nil);
                     weakSelf.callBackFiles = nil;
                }
                
            }];
        } @catch (NSException *exception) {
            NSLog(@"%s",__func__);
        }
    }
    
}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(PHAsset *)asset{
    if (_allowPickingVideo) {
        self.selectAssets = [NSMutableArray arrayWithObjects:asset, nil];
        self.uploadFiles = [NSMutableArray array];
        [self startUploadVideo];
        
        kWeakSelf(weakSelf)
        [MBProgressHUD showMessage:@"" ToView:self.parentVC.view cancelAction:^(MBProgressHUD *hud) {
            weakSelf.isCancle = YES;
            [MBProgressHUD hideHUDForView:weakSelf.parentVC.view];
            if (weakSelf.callBackFiles) {
                weakSelf.callBackFiles(nil);
                weakSelf.callBackFiles = nil;
            }
        }];
    }
}

-(void)startUploadImage{
    if (self.selectPhotos.count>0&&!self.isCancle) {
        [self upLoadFileWithImage:self.selectPhotos.firstObject];
    }else{
        [MBProgressHUD hideHUDForView:self.parentVC.view];
        if (self.callBackFiles) {
//            [[TWToastView surewWithMessage:@"上传成功" sureBtnhandle:^(UIButton *button) {
//            }] show];
            self.callBackFiles([self.uploadFiles mutableCopy]);
        }
    }
}

- (void)startUploadVideo{
    if (self.selectAssets.count>0&&!self.isCancle) {
        [self uploadVideoWithAssets:self.selectAssets.firstObject];
    }else{
        [MBProgressHUD hideHUDForView:self.parentVC.view];
        if (self.callBackFiles) {
            [[TWToastView surewWithMessage:@"上传成功" sureBtnhandle:^(UIButton *button) {
            }] show];
            self.callBackFiles([self.uploadFiles mutableCopy]);
        }
    }
}

- (void)uploadVideoWithAssets:(PHAsset *)asset{
    [[TZImageManager manager] getVideoOutputPathWithAsset:asset presetName:AVAssetExportPresetHighestQuality success:^(NSString *outputPath) {
        NSData *data = [NSData dataWithContentsOfFile:outputPath];
        NSLog(@"视频导出到本地完成,沙盒路径为:%@",outputPath);
        NSString *fileName = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
        
        //上传服务器
        [TWApiManager upLoadFileWithUrl:[NSString stringWithFormat:@"%@%@",kBaseUrl,kFileupload] parameters:self.uploadParameter mimeType:@"video/mp4" fileName:fileName data:data progress:^(NSProgress *progress) {
            
        } success:^(id response) {
            
            if (!self.isCancle) {
                NSMutableDictionary *fileDic = [NSMutableDictionary dictionary];
                [fileDic setObject:kStringIsEmpty([TWUploadFileModel mj_objectWithKeyValues:response[@"data"]].address)?@"":[TWUploadFileModel mj_objectWithKeyValues:response[@"data"]].address forKey:@"address"];
                [fileDic setObject:kStringIsEmpty([TWUploadFileModel mj_objectWithKeyValues:response[@"data"]].filename)?@"":[TWUploadFileModel mj_objectWithKeyValues:response[@"data"]].filename forKey:@"filename"];
                [fileDic setObject:kStringIsEmpty([TWUploadFileModel mj_objectWithKeyValues:response[@"data"]].absolute_path)?@"":[TWUploadFileModel mj_objectWithKeyValues:response[@"data"]].absolute_path forKey:@"absolute_path"];
                [fileDic setObject:kStringIsEmpty([TWUploadFileModel mj_objectWithKeyValues:response[@"data"]].file_type)?@"":[TWUploadFileModel mj_objectWithKeyValues:response[@"data"]].file_type forKey:@"file_type"];
                [fileDic setObject:kStringIsEmpty([TWUploadFileModel mj_objectWithKeyValues:response[@"data"]].host)?@"":[TWUploadFileModel mj_objectWithKeyValues:response[@"data"]].host forKey:@"host"];
                [fileDic setObject:kStringIsEmpty([TWUploadFileModel mj_objectWithKeyValues:response[@"data"]].relative_path)?@"":[TWUploadFileModel mj_objectWithKeyValues:response[@"data"]].relative_path forKey:@"relative_path"];
                [fileDic setObject:kStringIsEmpty([TWUploadFileModel mj_objectWithKeyValues:response[@"data"]].uri)?@"":[TWUploadFileModel mj_objectWithKeyValues:response[@"data"]].uri forKey:@"uri"];
                [self.uploadFiles addObject:fileDic];
                
                if (!kArrayIsEmpty(self.selectAssets)) {
                    [self.selectAssets removeObjectAtIndex:0];
                }
                [self startUploadVideo];
            }
            
        } failure:^(NSError *error) {
            [MBProgressHUD hideHUDForView:self.parentVC.view];
        }];
        
    } failure:^(NSString *errorMessage, NSError *error) {
        NSLog(@"视频导出失败:%@,error:%@",errorMessage, error);
        [MBProgressHUD hideHUDForView:self.parentVC.view];
    }];
}

// 附件上传
-(void)upLoadFileWithImage:(UIImage *)image{
    
    __weak typeof(self) weakSelf = self;
    
    [TWApiManager upLoadFileWithUrl:[NSString stringWithFormat:@"%@%@",kBaseUrl,kFileupload] parameters:self.uploadParameter name:@"file" image:image progress:^(NSProgress * _Nonnull progress) {
    
    }  success:^(id response) {

        if (!self.isCancle) {

            __strong typeof(self) strongSelf = weakSelf;
            NSMutableDictionary *fileDic = [NSMutableDictionary dictionary];
            [fileDic setObject:kStringIsEmpty([TWUploadFileModel mj_objectWithKeyValues:response[@"data"]].address)?@"":[TWUploadFileModel mj_objectWithKeyValues:response[@"data"]].address forKey:@"address"];
            [fileDic setObject:kStringIsEmpty([TWUploadFileModel mj_objectWithKeyValues:response[@"data"]].filename)?@"":[TWUploadFileModel mj_objectWithKeyValues:response[@"data"]].filename forKey:@"filename"];
            [fileDic setObject:kStringIsEmpty([TWUploadFileModel mj_objectWithKeyValues:response[@"data"]].absolute_path)?@"":[TWUploadFileModel mj_objectWithKeyValues:response[@"data"]].absolute_path forKey:@"absolute_path"];
            [fileDic setObject:kStringIsEmpty([TWUploadFileModel mj_objectWithKeyValues:response[@"data"]].file_type)?@"":[TWUploadFileModel mj_objectWithKeyValues:response[@"data"]].file_type forKey:@"file_type"];
            [fileDic setObject:kStringIsEmpty([TWUploadFileModel mj_objectWithKeyValues:response[@"data"]].host)?@"":[TWUploadFileModel mj_objectWithKeyValues:response[@"data"]].host forKey:@"host"];
            [fileDic setObject:kStringIsEmpty([TWUploadFileModel mj_objectWithKeyValues:response[@"data"]].relative_path)?@"":[TWUploadFileModel mj_objectWithKeyValues:response[@"data"]].relative_path forKey:@"relative_path"];
            [fileDic setObject:kStringIsEmpty([TWUploadFileModel mj_objectWithKeyValues:response[@"data"]].uri)?@"":[TWUploadFileModel mj_objectWithKeyValues:response[@"data"]].uri forKey:@"uri"];
            [strongSelf.uploadFiles addObject:fileDic];
            if (!kArrayIsEmpty(strongSelf.selectPhotos)) {
                [strongSelf.selectPhotos removeObjectAtIndex:0];
            }
            if (!kArrayIsEmpty(strongSelf.selectAssets)) {
                [strongSelf.selectAssets removeObjectAtIndex:0];
            }
            [strongSelf startUploadImage];


        }

    } failure:^(NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        @try {
            [MBProgressHUD hideHUDForView:strongSelf.parentVC.view];
        } @catch (NSException *exception) {
            NSLog(@"%s",__func__);
        }
    }];
}

// 如果用户选择了一个gif图片，下面的handle会被执行
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingGifImage:(UIImage *)animatedImage sourceAssets:(PHAsset *)asset {
    @try {
        [self upLoadFileWithImage:animatedImage];
    } @catch (NSException *exception) {
        NSLog(@"%s",__func__);
    }
}

// 决定相册显示与否
- (BOOL)isAlbumCanSelect:(NSString *)albumName result:(PHFetchResult *)result {
    return YES;
}

// 决定asset显示与否
- (BOOL)isAssetCanSelect:(PHAsset *)asset {
    
    if (_allowPickingVideo) {
        switch (asset.mediaType) {
            case PHAssetMediaTypeVideo:{
                // 视频时长
                // NSTimeInterval duration = phAsset.duration;
                return YES;
            }
                break;
            default:
                break;
        }
        return NO;
    }
    
    NSString *imgType = [asset valueForKeyPath:@"filename"];
    if (imgType && [imgType hasSuffix:@"GIF"]) {
        return NO;
    }
    return YES;
}

@end
