


//
//  outputViewController.m
//  Socket通讯输出接收数据
//
//  Created by MJRB on 2017/11/8.
//  Copyright © 2017年 szsxrkj. All rights reserved.
//

#import "outputViewController.h"
#import "Masonry.h"
@import CoreTelephony;

@interface outputViewController ()<NSStreamDelegate,UITextViewDelegate>{
    NSInputStream *_inputStream;//对应输入流
    NSOutputStream *_outputStream;//对应输出流

}
@property(nonatomic,strong)UITextField * tongXintextField;
@property(nonatomic,strong)UIView * commentsView;

@end

@implementation outputViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupUI];
}


/**
 搭建界面
 */
-(void)setupUI{
    
    CTCellularData *cellularData = [[CTCellularData alloc]init];
    cellularData.cellularDataRestrictionDidUpdateNotifier =  ^(CTCellularDataRestrictedState state){
        //获取联网状态
        switch (state) {
            case kCTCellularDataRestricted:
                NSLog(@"Restricrted");//受限
                break;
            case kCTCellularDataNotRestricted:
                NSLog(@"Not Restricted");//不受限
                break;
            case kCTCellularDataRestrictedStateUnknown:
                NSLog(@"Unknown");//未知
                break;
            default:
                break;
        };
    };
    
    
    
    UITextField * textfield = [[UITextField alloc] init];
    textfield.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:textfield];
    self.tongXintextField = textfield;
    self.tongXintextField.text = @"11111";
    [textfield mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.offset(200);
        make.height.offset(60);
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(120);
    }];
    self.tongXintextField.layer.masksToBounds = YES;
    self.tongXintextField.layer.cornerRadius = 8;
    
    UIButton * querenBtn = [[UIButton alloc] initWithFrame:CGRectMake(150, 150, 50, 50)];
    querenBtn.backgroundColor = [UIColor redColor];
    [querenBtn setTitle:@"确认" forState:UIControlStateNormal];
    [querenBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:querenBtn];
    [querenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tongXintextField.mas_bottom).offset(30);
        make.centerX.equalTo(self.tongXintextField);
        make.width.height.offset(50);
    }];
    querenBtn.layer.masksToBounds = YES;
    querenBtn.layer.cornerRadius = 8;
    [querenBtn addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
    
    
    // 建立连接
    NSString *host = @"192.168.1.105";
    int port = 8899;
    
    // 定义C语言输入输出流
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)host, port, &readStream, &writeStream);
    
    // 把C语言的输入输出流转化成OC对象
    _inputStream = (__bridge NSInputStream *)(readStream);
    _outputStream = (__bridge NSOutputStream *)(writeStream);
    
    // 设置代理
    _inputStream.delegate = self;
    _outputStream.delegate = self;
    
    
    // 把输入输入流添加到主运行循环
    // 不添加主运行循环 代理有可能不工作
    [_inputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [_outputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
    // 打开输入输出流
    [_inputStream open];
    [_outputStream open];
    
    
    
    

}

/*
实现输入输出流的监听
 */
-(void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode{
    
    NSLog(@"%@",[NSThread currentThread]);
    
    //    NSStreamEventOpenCompleted = 1UL << 0,//输入输出流打开完成
    //    NSStreamEventHasBytesAvailable = 1UL << 1,//有字节可读
    //    NSStreamEventHasSpaceAvailable = 1UL << 2,//可以发放字节
    //    NSStreamEventErrorOccurred = 1UL << 3,// 连接出现错误
    //    NSStreamEventEndEncountered = 1UL << 4// 连接结束
    switch (eventCode) {
        case NSStreamEventOpenCompleted:
            NSLog(@"输入输出流打开完成");
            break;
        case NSStreamEventHasBytesAvailable:
            NSLog(@"有字节可读");
            
            break;
        case NSStreamEventHasSpaceAvailable:
            NSLog(@"可以发送字节");
            break;
        case NSStreamEventErrorOccurred:
            NSLog(@" 连接出现错误");
            break;
        case NSStreamEventEndEncountered:
            NSLog(@"连接结束");
            
            // 关闭输入输出流
            [_inputStream close];
            [_outputStream close];
            
            // 从主运行循环移除
            [_inputStream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            [_outputStream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            break;
        default:
            break;
    }
    
}

//发送消息
-(void)sendMessage{
    
    NSString *text = self.tongXintextField.text;
    
    NSLog(@"%@",text);
    // 聊天信息
    NSString *msgStr = [NSString stringWithFormat:@"msg:%@",text];
    
    //把Str转成NSData
    NSData *data = [msgStr dataUsingEncoding:NSUTF8StringEncoding];
    
    // 刷新表格
    //         [self reloadDataWithText:msgStr];
    
    // 发送数据
    [_outputStream write:data.bytes maxLength:data.length];
    
    // 发送完数据，清空textField
    self.tongXintextField.text = nil;
    
}



@end
