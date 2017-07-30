//
//  WXApiManager.m
//  yiwa
//
//  Created by CF on 2017/7/30.
//  Copyright © 2017年 CF. All rights reserved.
//

#import "WXApiManager.h"


@implementation WXApiManager
#pragma mark - LifeCycle
+(instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static WXApiManager *instance;
    dispatch_once(&onceToken, ^{
        instance = [[WXApiManager alloc] init];
    });
    return instance;
}

#pragma mark - WXApiDelegate
- (void)onResp:(BaseResp *)resp {
    
}

- (void)onReq:(BaseReq *)req {
   
}
@end
