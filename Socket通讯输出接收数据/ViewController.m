//
//  ViewController.m
//  Socket通讯输出接收数据
//
//  Created by MJRB on 2017/11/8.
//  Copyright © 2017年 szsxrkj. All rights reserved.
//

#import "ViewController.h"
#import "Masonry.h"
#import "inputViewController.h"
#import "outputViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    self.view.backgroundColor  = [UIColor whiteColor];
    
}


/**
 搭建UI
 */
-(void)setupUI{
    
    
    //输出
    UIButton * outputButton = [[UIButton alloc] init];
    [outputButton setTitle:@"输出 >" forState:UIControlStateNormal];
    [outputButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    outputButton.backgroundColor = [UIColor blackColor];
    outputButton.layer.masksToBounds = YES;
    outputButton.layer.cornerRadius =  10;
    outputButton.tag = 100;
    [self.view addSubview:outputButton];
    [outputButton addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    [outputButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.offset(80);
        make.height.offset(50);
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view).offset(-80);
    }];
    
    //输入
    UIButton * inputButton = [[UIButton alloc] init];
    [inputButton setTitle:@"输入 >" forState:UIControlStateNormal];
    [inputButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    inputButton.layer.masksToBounds = YES;
    inputButton.layer.cornerRadius =  10;
    inputButton.tag = 101;
    inputButton.backgroundColor = [UIColor blackColor];
    [inputButton addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:inputButton];
    [inputButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.offset(80);
        make.height.offset(50);
        make.centerX.equalTo(self.view);
        make.top.equalTo(outputButton.mas_bottom).offset(20);
    }];

}

/**
    跳转
 */
-(void)click:(UIButton *)button{
    if (button.tag == 100) {

        outputViewController * vc= [[outputViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        inputViewController * vc =  [[inputViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
