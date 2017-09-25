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
    NSLog(@"---");
    if ([resp isKindOfClass:[PayResp class]]){
        PayResp*response=(PayResp*)resp;
        switch(response.errCode){
            case WXSuccess:
                //服务器端查询支付通知或查询API返回的结果再提示成功
                self.resultBlock(YES);
               // NSlog(@"支付成功");
                break;
            default:
                
                self.resultBlock(NO);
               // NSlog(@"支付失败，retcode=%d",resp.errCode);
                break;
        }
    }
}

- (void)onReq:(BaseReq *)req {
    NSLog(@"121212");
}
@end
