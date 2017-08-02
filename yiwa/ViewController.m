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
        request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://edu.evabot.cc"]];
        
    } else {
        
        request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://edu.evabot.cc/eva/index.jsp"]];
        
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
//    JSContext *context = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
//    
//    context[@"onPay"] = ^(){
//        
//        NSArray *array = [JSContext currentArguments];
//        
//    };
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    // NOTE: ------  对alipays:相关的scheme处理 -------
    // NOTE: 若遇到支付宝相关scheme，则跳转到本地支付宝App
    NSString* reqUrl = request.URL.absoluteString;
    if ([reqUrl hasPrefix:@"alipays://"] || [reqUrl hasPrefix:@"alipay://"]) {
        // NOTE: 跳转支付宝App
        BOOL bSucc = [[UIApplication sharedApplication]openURL:request.URL];
        
        // NOTE: 如果跳转失败，则跳转itune下载支付宝App
//        if (!bSucc) {
//            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示"
//                                                           message:@"未检测到支付宝客户端，请安装后重试。"
//                                                          delegate:self
//                                                 cancelButtonTitle:@"立即安装"
//                                                 otherButtonTitles:nil];
//            [alert show];
//        }
        return NO;
    }
    return YES;
}

//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    // NOTE: 跳转itune下载支付宝App
//    NSString* urlStr = @"https://itunes.apple.com/cn/app/zhi-fu-bao-qian-bao-yu-e-bao/id333206289?mt=8";
//    NSURL *downloadUrl = [NSURL URLWithString:urlStr];
//    [[UIApplication sharedApplication]openURL:downloadUrl];
//}


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

/*
 
 
	$(".fakeloader").fakeLoader({
 timeToHide:3000,
 spinner:"spinner1",
	});
	
//	跳转支付
	
function onPay(pay_type){
    
    var bussines_id = $('#bussines_id').val();
    var pay_mode = $('#pay_mode').val();
    var share_user_id = $('#share_user_id').val();
    var car_type = $('#car_type').val();
    var fs_money = $('#fs_money').val();
    var all_money = $('#all_money').val();
    var all_point = $('#all_point').val();
    var fs_point = $('#fs_point').val();
    
    if(bussines_id!=''){
        var xjkj_object = new xjkj();
        xjkj_object.formSubmit('','payTypeCheck','','','',{},function(result){
            var msg = $.parseJSON(result)['msg'];
            var code = $.parseJSON(result)['code'];
            if(code=='0'){
                window.location.replace('eva/pay/pay_next.jsp?fs_point='+fs_point+'&all_point='+all_point+'&all_money='+all_money+'&car_type='+car_type+'&fs_money='+fs_money+'&share_user_id='+share_user_id+'&pay_type='+pay_type+'&bussines_id='+bussines_id+'&pay_mode='+pay_mode+'&pay_id='+$('#pay_id').val());
            }else{
                xjkj_object.dialog('操作提示','alert',msg,'info','3000');
            }
        });
    }
}


 
 */



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
