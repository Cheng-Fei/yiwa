//
//  ViewController.m
//  yiwa
//
//  Created by CF on 2017/7/22.
//  Copyright © 2017年 CF. All rights reserved.
//

#import "ViewController.h"
#import "MJRefresh.h"

@interface ViewController () <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.webView.backgroundColor = [UIColor whiteColor];
    self.webView.delegate = self;
    self.webView.scrollView.showsVerticalScrollIndicator = NO;
    self.webView.scrollView.showsHorizontalScrollIndicator = NO;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://edu.evabot.cc"]];
    
    [self.webView loadRequest:request];
    
    self.webView.scrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        if ([self.webView.request.URL.absoluteString isEqualToString:@"about:blank"]) {
            [self.webView loadRequest:request];
        }else {
            
            [self.webView loadRequest:self.webView.request];
        }
        
        
    }];
    
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.webView.scrollView.mj_header endRefreshing];
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
    NSLog(@"-----%@--",error);
    
    if (error.code == -1009) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"网络错误，请检查网络设置" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
            [self.webView.scrollView.mj_header endRefreshing];
            
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
        
        
    }
    
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
