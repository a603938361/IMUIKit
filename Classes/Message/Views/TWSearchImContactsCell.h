//
//  TWSearchImContactsCell.h
//  TaiWuOffice
//
//  Created by 田黎强 on 2020/3/12.
//  Copyright © 2020 zsf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NIMAvatarImageView.h"
NS_ASSUME_NONNULL_BEGIN

@interface TWSearchImContactsCell : UITableViewCell
@property (weak, nonatomic) IBOutlet NIMAvatarImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
-(void)dataForCell:(NIMRecentSession *)recentSession user:(NSMutableDictionary *)userDict searchString:(NSString *)serchStr;
@end

NS_ASSUME_NONNULL_END
