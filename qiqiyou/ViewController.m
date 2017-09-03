//
//  ViewController.m
//  qiqiyou
//
//  Created by 傅上淞 on 2017/7/10.
//  Copyright © 2017年 傅上淞. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
     iapManager = [[IAPManager alloc] init];
    [iapManager attachObserver];
    if ([iapManager CanMakePayment]) {
        NSLog(@" 可以购买");
        [iapManager requestProductData:@"10001\t"];

    }
    
    
    
  }


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//bool IsProductAvailable(){
//
//    return [iapManager CanMakePayment];
//}
//
//void RequstProductInfo(void *p){
//    NSString *list = [NSString stringWithUTF8String:p];
//    NSLog(@"productKey:%@",list);
//    [iapManager requestProductData:list];
//}
//
//void BuyProduct(void *p){
//    [iapManager buyRequest:[NSString stringWithUTF8String:p]];
//}


@end
