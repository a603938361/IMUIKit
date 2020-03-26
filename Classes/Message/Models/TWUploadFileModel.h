//
//  TWUploadFileModel.h
//  TaiWuOffice
//
//  Created by hyj on 2018/8/28.
//  Copyright © 2018年 zsf. All rights reserved.
//

#import "TWBaseModel.h"

@interface TWUploadFileModel : TWBaseModel
@property(nonatomic,copy)NSString *attachmentId;
@property(nonatomic,copy)NSString *createDate;
@property(nonatomic,copy)NSString *createUser;
@property(nonatomic,copy)NSString *dataName;
@property(nonatomic,copy)NSString *dataType; //文件类别（file_dictionary表主键dictionaryId）
@property(nonatomic,copy)NSString *deleteFlag;
@property(nonatomic,copy)NSString *displayName;
@property(nonatomic,copy)NSString *fileType;
@property(nonatomic,copy)NSString *parameter1;
@property(nonatomic,copy)NSString *parameter2;
@property(nonatomic,copy)NSString *parameter3;
@property(nonatomic,copy)NSString *sorting;
@property(nonatomic,copy)NSString *tableId;
@property(nonatomic,copy)NSString *tableName;
@property(nonatomic,copy)NSString *thumbnailUrl;
@property(nonatomic,copy)NSString *updateDate;
@property(nonatomic,copy)NSString *updateUser;
@property(nonatomic,copy)NSString *url;
@property(nonatomic,copy)NSString *customCode;
@property(nonatomic,copy)NSString *qrCode;


@property(nonatomic,copy)NSString *address;
@property(nonatomic,copy)NSString *filename;
@property(nonatomic,copy)NSString *absolute_path;
@property(nonatomic,copy)NSString *file_type;
@property(nonatomic,copy)NSString *host;
@property(nonatomic,copy)NSString *relative_path;
@property(nonatomic,copy)NSString *uri;

@end
