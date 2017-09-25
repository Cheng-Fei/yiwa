//
//  WXApiManager.h
//  yiwa
//
//  Created by CF on 2017/7/30.
//  Copyright © 2017年 CF. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXApi.h"

@interface WXApiManager : NSObject<WXApiDelegate>
@property (nonatomic, copy) void (^resultBlock)(BOOL isSuccess);
+(instancetype)sharedManager;

@end
