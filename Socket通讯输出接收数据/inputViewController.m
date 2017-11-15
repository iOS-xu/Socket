//
//  inputViewController.m
//  Socket通讯输出接收数据
//
//  Created by MJRB on 2017/11/8.
//  Copyright © 2017年 szsxrkj. All rights reserved.
//

#import "inputViewController.h"
#import "Masonry.h"
#import<ifaddrs.h>
#import<sys/socket.h>
#import<arpa/inet.h>
@interface inputViewController ()<NSStreamDelegate,UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>{
    NSInputStream *_inputStream;//对应输入流
    NSOutputStream *_outputStream;//对应输出流
}
@property (nonatomic, strong) NSMutableArray *chatMessage;//聊天消息数组
@property (nonatomic, strong) UITableView * mainTableView; //列表

@end

@implementation inputViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupUI];
}

-(NSMutableArray *)chatMessage{
    if (!_chatMessage) {
        _chatMessage = [NSMutableArray array];
    }
    return _chatMessage;
}

/**
 搭建UI界面
 */
-(void)setupUI{
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
    
    UITableView * mainTableView = [[UITableView alloc] init];
    mainTableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:mainTableView];
    mainTableView.dataSource = self;
    mainTableView.delegate = self;
    [mainTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(80);
        make.left.right.equalTo(self.view);
        make.height.offset(300);
    }];
    self.mainTableView = mainTableView;
    
}
/*
 
 二：实现输入输出流的监听
 
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
            [self readData];
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
#pragma mark 读了服务器返回的数据
-(void)readData{
    
    //建立一个缓冲区 可以放1024个字节
    uint8_t buf[1024];
    
    // 返回实际装的字节数
    NSInteger len = [_inputStream read:buf maxLength:sizeof(buf)];
    
    // 把字节数组转化成字符串
    NSData *data = [NSData dataWithBytes:buf length:len];
    
    
    NSStringEncoding  gbkEncoding =CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    
    NSString  * recStr = [[NSString alloc] initWithData:data encoding:gbkEncoding];
    
    
    // 从服务器接收到的数据
    //    NSString *recStr =  [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSLog(@"从服务器接收到的数据%@",recStr);
    
    if ( [recStr isEqualToString:@""] || recStr == NULL  || recStr == nil ) {
        
    }else{
//        NSAttributedString *string =[LXEmotionManager transferMessageString:recStr font:[UIFont systemFontOfSize:16.0] lineHeight:[UIFont systemFontOfSize:16.0].lineHeight];
        [self.chatMessage addObject:recStr];
        
    }
    NSLog(@"从服务器接收数组=========%@",self.chatMessage);
    
    [self.mainTableView reloadData];
    [self.mainTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.chatMessage.count -1 inSection:0]  atScrollPosition:UITableViewScrollPositionBottom animated:NO];

}


/**
   数据源方法
 */
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  self.chatMessage.count;
 
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell =[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.backgroundColor = [UIColor whiteColor];
    cell.textLabel.text = self.chatMessage[indexPath.row];
    cell.textLabel.numberOfLines = 0;
    cell.selected = NO;
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;

}


/**
   tableview代理方法
 
 */
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
