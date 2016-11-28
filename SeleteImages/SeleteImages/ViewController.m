//
//  ViewController.m
//  01.22 图片测试
//
//  Created by 一路向北 on 16/1/22.
//  Copyright © 2016年 一路向北. All rights reserved.
//

#import "ViewController.h"

#import "MessagePhotoView.h"//图片视图 01.22
#import "ZBMessageShareMenuView.h"

//网络请求
#import "AFNetworking.h"
#import "UIView+Toast.h"


@interface ViewController ()<MessagePhotoViewDelegate,ZBMessageShareMenuViewDelegate>
{
    NSMutableArray * imageArray;//接收选择后图片
    
    NSMutableArray * imageArr;//图片数组
    UIImage * image;
}

@property (nonatomic,strong) MessagePhotoView *photoView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self addOptionRighButton];
    
    //图片视图
    [self sharePhotoview];
    
    imageArr = [[NSMutableArray alloc]initWithCapacity:10];
    imageArray = [[NSMutableArray alloc]initWithCapacity:10];
}

- (void)sharePhotoview
{
    if (!self.photoView)
    {
        self.photoView = [[MessagePhotoView alloc]initWithFrame:CGRectMake(0,0,self.view.frame.size.width, 200)];
        [self.view addSubview:self.photoView];
        self.photoView.delegate = self;
        
    }
}


//加载右边button
- (void) addOptionRighButton {
    UIButton *optionButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [optionButton setFrame: CGRectMake(0, 0, 65, 40)];
    optionButton.center = self.view.center;
    [optionButton setTitle:@"提交" forState:UIControlStateNormal];
    [optionButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [optionButton setAlpha:0.85];
    optionButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [optionButton addTarget: self action: @selector(optionRightButtonAction) forControlEvents: UIControlEventTouchUpInside];
    
    [self.view addSubview:optionButton];
}


- (void) optionRightButtonAction {
    //将界面中的信息提交到服务器
    
    if (self.photoView.photoMenuItems.count == 0) {
        [self.view makeToast:@"没有照片选择"];
    }else
    {
        //上传到服务器
        NSLog(@"%@",self.photoView.photoMenuItems);
        
        [self ImageArrayLoad];
        
    }
    
    
}

//实现代理方法
-(void)addPicker:(UIImagePickerController *)picker{
    
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - ZBMessageShareMenuView Delegate
- (void)didSelecteShareMenuItem:(ZBMessageShareMenuItem *)shareMenuItem atIndex:(NSInteger)index{
    
    
    
}




//上传图片
-(void)ImageArrayLoad
{
    //http://www.aichengxu.com/view/55607
    
    
    for (int   i =0; i<self.photoView.photoMenuItems.count; i++) {
        //这里必须转成图片格式
        CGImageRef thum = [self.photoView.photoMenuItems[i] thumbnail];
        image = [UIImage imageWithCGImage:thum];
        [imageArray addObject:image];
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    for (int i = 0; i<imageArray.count; i++) {
        
        NSData *data = UIImagePNGRepresentation(imageArray[i]);
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyyMMddHHmmss";
        NSString *str = [formatter stringFromDate:[NSDate date]];
        NSString *fileName = [NSString stringWithFormat:@"%@.jpg", str];
        
        [manager POST:@"你的服务端地址" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            
            [formData appendPartWithFileData:data name:@"Filedata" fileName:fileName mimeType:@"image/jpg"];
            
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSLog(@"Success: %@", responseObject);
            NSString * str = [responseObject objectForKey:@"fileId"];
            if (str != nil) {
                [self UpImaheFinish:str];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            NSLog(@"Error: %@", error);
        }];
    }
}

-(void)UpImaheFinish:(NSString *)string
{
    if (string) {
        [imageArr addObject:string];
    }
    if (imageArr.count == imageArray.count) {
        
        NSLog(@"%@",imageArr);
        //返回的所有结果
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
