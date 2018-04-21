//
//  AgreementViewController.m
//  CDDStoreDemo
//
//  Created by 易信 on 2018/4/19.
//  Copyright © 2018年 RocketsChen. All rights reserved.
//

#import "AgreementViewController.h"

@interface AgreementViewController ()<UIWebViewDelegate>

@end

@implementation AgreementViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title=@"用户协议";
    
    //返回按钮
    UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake(20, kStatusBar_Height + 10, 30, 30)];
    backButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [backButton setImage:[UIImage imageNamed:@"address4_guanbi"] forState:UIControlStateNormal];
    [self.view addSubview:backButton];
    [backButton addTarget:self action:@selector(dissmissClick) forControlEvents:UIControlEventTouchUpInside];
    
    // frame 根据自己的需求自行修改
    UIWebView *agreeWebView = [[UIWebView alloc]initWithFrame:CGRectMake(0,DCTopNavH, self.view.bounds.size.width, self.view.bounds.size.height-DCTopNavH)];
    agreeWebView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:agreeWebView];
    NSURL *url = [NSURL URLWithString:@"http://192.168.0.136:8020/project/exin/protocol.html?__hbt=1524134143508"];
    [agreeWebView loadRequest:[NSURLRequest requestWithURL:url]];
    agreeWebView.delegate = self;
    
    [MBProgressHUD showHUDAddedTo:agreeWebView animated:YES];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [MBProgressHUD hideHUDForView:webView animated:YES];
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"加载错误%@",error);
}

- (void)dissmissClick
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
