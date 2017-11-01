//
//  ViewController.m
//  yiwa
//
//  Created by CF on 2017/7/22.
//  Copyright © 2017年 CF. All rights reserved.
//

#import "ViewController.h"
#import "MJRefresh.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "MBProgressHUD.h"
#import "JSBrigade.h"
#import "WXApi.h"
#import "WXApiManager.h"

static NSString * const isNeedNav = @"isNeedNav";


@interface ViewController () <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
    self.webView.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
    self.webView.delegate = self;
    self.webView.scrollView.showsVerticalScrollIndicator = NO;
    self.webView.scrollView.showsHorizontalScrollIndicator = NO;
    
    
    // http://edu.evabot.cc/eva/index.jsp
    
    [self loadRequest];
    
    self.webView.scrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        [self loadRequest];

    }];
    
    
}

- (void)loadRequest{
    
    NSURLRequest *request;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = @"加载中...";
//    hud.backgroundView.style = MBProgressHUDBackgroundStyleSolidColor;
//    hud.backgroundView.color = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:0.5];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:isNeedNav]) {
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:isNeedNav];
        request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://edu.evabot.cc:8280"]];
        
    } else {
        
        request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://edu.evabot.cc:8280/eva/index.jsp"]];
        
    }
    
    
    
    [self.webView loadRequest:request];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.webView.scrollView.mj_header endRefreshing];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    [WXApiManager sharedManager].resultBlock = ^(BOOL isSuccess) {
        
        if (isSuccess) {
            [self.webView stringByEvaluatingJavaScriptFromString:@"window.location.href = 'eva/index.jsp?dir_flag=wx_pay&dir_url=eva/context/my_orders_index.jsp?payment_status=8'"];
            ;
        } else {
            [self.webView stringByEvaluatingJavaScriptFromString:@"window.location.href = 'eva/index.jsp?dir_flag=wx_pay&dir_url=eva/context/my_orders_index.jsp?payment_status=0'"];
        }
    };
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    
    // NOTE: ------  对alipays:相关的scheme处理 -------
    // NOTE: 若遇到支付宝相关scheme，则跳转到本地支付宝App
    NSString* reqUrl = request.URL.absoluteString;
    if ([reqUrl hasPrefix:@"alipays://"] || [reqUrl hasPrefix:@"alipay://"]) {
        // NOTE: 跳转支付宝App
        [[UIApplication sharedApplication]openURL:request.URL];
        return NO;
    }else if ([reqUrl hasPrefix:@"openwexin://"]){
        // 跳转微信
        NSError *error;
        NSString *jsonStr = [reqUrl substringFromIndex:@"openwexin://".length];
        jsonStr = [jsonStr stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
        jsonStr = [jsonStr stringByReplacingOccurrencesOfString:@"%7B" withString:@"{"];
        jsonStr = [jsonStr stringByReplacingOccurrencesOfString:@"%7D" withString:@"}"];
        NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&error];
        
        [self openWeChat:dict];
        NSLog(@"---");
        return NO;
        
    }
    return YES;
}

- (void)openWeChat:(NSMutableDictionary *)dict{
    
    if(dict != nil){
        NSMutableString *retcode = [dict objectForKey:@"retcode"];
        if (retcode.intValue == 0){
            NSMutableString *stamp  = [dict objectForKey:@"timestamp"];
            
            //调起微信支付
            PayReq* req             = [[PayReq alloc] init];
            req.partnerId           = [dict objectForKey:@"partnerid"];
            req.prepayId            = [dict objectForKey:@"prepayid"];
            req.nonceStr            = [dict objectForKey:@"noncestr"];
            req.timeStamp           = stamp.intValue;
            req.package             = @"Sign=WXPay";
            req.sign                = [dict objectForKey:@"sign"];
            [WXApi sendReq:req];
            //日志输出
            NSLog(@"appid=%@\npartid=%@\nprepayid=%@\nnoncestr=%@\ntimestamp=%ld\npackage=%@\nsign=%@",[dict objectForKey:@"appid"],req.partnerId,req.prepayId,req.nonceStr,(long)req.timeStamp,req.package,req.sign );
            
        }
    }
    
    
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
    NSLog(@"-----%@--",error);
    
    if (error.code == -1009) {
        
        [self errorAlertWithMessage:@"网络错误，请检查网络设置"];
        
    }else if (error.code == -1004) {
        
        [self errorAlertWithMessage:@"不能连接到服务器，请稍后重试"];
        
    }
    
}

- (void)errorAlertWithMessage:(NSString *)message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        [self.webView.scrollView.mj_header endRefreshing];
        
    }];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

