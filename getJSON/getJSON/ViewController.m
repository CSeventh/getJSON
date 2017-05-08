//
//  ViewController.m
//  getJSON
//
//  Created by Nine on 2017/4/24.
//  Copyright © 2017年 Nine. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"
#import "Vedio.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *showButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (IBAction)get:(id)sender {
    NSString *URLString=@"http://vedio.wxz.name/api/vedio.html";
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    ((AFJSONResponseSerializer *)manager.responseSerializer).removesKeysWithNullValues = YES;//有什么作用？  将所有的NSNull值变成nil：json解析的时候，会把null解析成NSNull对象，向这个NSNull对象发送消息的时候就会崩。
    
    //设置超时
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 15;//这个值是什么意思？  网络请求超时时间设置为5s
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = @"加载中...";
    //请求
    [manager GET:URLString parameters:nil progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
         {
             if ([responseObject[@"msg"] isEqualToString:@"ok"])
             {
                 //_datas=[[NSMutableArray alloc]init]; //不使用懒加载的话可以在这里或者GET之前初始化数据
                 for(NSDictionary *eachDic in responseObject[@"links"])
                 {
                     NSLog(@"%@",eachDic);
                     Vedio *vedio=[[Vedio alloc]initWithDic:eachDic];
                     [self.datas addObject:vedio];//换成_datas会怎么样？  懒加载调用 没有初始化不会输出数据
                     _showButton.hidden=false;  //不隐藏
                 }
                 hud.label.text = @"加载成功！";
                 [hud hideAnimated:YES afterDelay:0.2];
             }
             else
             {
                 hud.label.text = @"加载错误！";
                 NSLog(@"数据错误");
                 [hud hideAnimated:YES afterDelay:0.5];
             }
         }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
         {
             hud.label.text = @"网络超时";
             NSLog(@"网络超时");
             [hud hideAnimated:YES afterDelay:0.5];
         }
     ];
}
- (IBAction)show:(id)sender {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = @"打印中...";
    NSLog(@"%@",_datas[1]);
        for (Vedio *vedio in _datas) {
            NSLog(@"标题:%@，图片:%@",vedio.name,vedio.img);
        }
    [hud hideAnimated:YES afterDelay:0.3];
}

//为什么要有这个方法？   懒加载
-(NSMutableArray *)datas{
    if (!_datas) {
        _datas=[[NSMutableArray alloc]init];
    }
    return _datas;
}

@end
