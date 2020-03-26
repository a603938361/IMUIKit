//
//  TWPhraseView.h
//  TaiWuWang
//
//  Created by 田黎强 on 2020/2/25.
//  Copyright © 2020 zsf. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol TWPhraseViewDelegate <NSObject>
-(void)selectPhraseMessage:(NSString *)message;
@end
@interface TWPhraseView : UIView
@property(nonatomic,weak)id<TWPhraseViewDelegate>delegate;
@end

NS_ASSUME_NONNULL_END
