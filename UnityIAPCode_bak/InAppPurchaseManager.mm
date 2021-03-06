//
//  InAppPurchaseManager.m
//  shotgame
//
//  Created by frozenface zhu on 12-1-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
//#import "NSData+Base64.h"
//沙盒测试环境验证
#define SANDBOX @"https://sandbox.itunes.apple.com/verifyReceipt"
//正式环境验证
#define AppStore @"https://buy.itunes.apple.com/verifyReceipt"

#define POSTURL @"http://game.77yoo.com/rcserver/setIapCertificate.do"                           //正式上线验证地址
#define DEBUG_POSTURL @"http://192.168.1.111/rcserver/iap/setIapCertificate"                //iOS_IAP测试验证地址


#import "InAppPurchaseManager.h"

@implementation InAppPurchaseManager
@synthesize  currentBuyRoleID = currentBuyRoleID;


-(void) attachObserver{
    NSLog(@"AttachObserver");
//    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:(id)self];

}

-(BOOL) CanMakePayment{
    return [SKPaymentQueue canMakePayments];
}

-(void) requestProductData:(NSString *)productIdentifiers currentBuyRoleID :(NSString *) currentRoleId{
    self.currentBuyRoleID = currentRoleId;
    //    NSArray *idArray = [productIdentifiers componentsSeparatedByString:@"\t"];
    //    NSSet *idSet = [NSSet setWithArray:idArray];
    
    NSSet *idSet = [NSSet setWithObject:productIdentifiers];
    
    
    [self sendRequest:idSet];
}

-(void)sendRequest:(NSSet *)idSet{
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:idSet];
    request.delegate = self;
    [request start];
}

#pragma mark -
#pragma mark SKProductsRequestDelegate methods
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSArray *products = response.products;
    
    for (SKProduct *p in products) {
        //        UnitySendMessage("Main", "ShowProductList", [[self productInfo:p] UTF8String]);
        NSLog(@"%s",[[self productInfo:p] UTF8String]);
        
        
        
        // [self buyRequest:[NSString stringWithUTF8String:[[self productInfo:p] UTF8String]]];
        [self buyRequest:p];
    }
    
    for(NSString *invalidProductId in response.invalidProductIdentifiers){
        NSLog(@"Invalid product id:%@",invalidProductId);
    }
    
    //    [request autorelease];
}

-(void)buyRequest:(SKProduct *)product{
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    //    SKPayment *payment = [SKPayment paymentWithProductIdentifier:productIdentifier];
    //    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)purchaseProUpgrade:(NSString *)iap_id
{
    SKPayment *payment = [SKPayment paymentWithProductIdentifier:iap_id];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}



-(NSString *)productInfo:(SKProduct *)product{
    NSArray *info = [NSArray arrayWithObjects:product.localizedTitle,product.localizedDescription,product.price,product.productIdentifier, nil];
    NSLog(@"info = %@",[info description]);
    return [info componentsJoinedByString:@"\t"];
}


-(NSString *)transactionInfo:(SKPaymentTransaction *)transaction{
    
    
    return [self encode:(uint8_t *)transaction.transactionReceipt.bytes length:transaction.transactionReceipt.length];
    
    //    transaction.transactionIdentifier
    
    
    
    
    //return [[NSString alloc] initWithData:transaction.transactionReceipt encoding:NSASCIIStringEncoding];
}

//-(NSString *)encode:(const uint8_t *)input length:(NSInteger) length{
//    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
//
//    NSMutableData *data = [NSMutableData dataWithLength:((length+2)/3)*4];
//    uint8_t *output = (uint8_t *)data.mutableBytes;
//
//    for(NSInteger i=0; i<length; i+=3){
//        NSInteger value = 0;
//        for (NSInteger j= i; j<(i+3); j++) {
//            value<<=8;
//
//            if(j<length){
//                value |=(0xff & input[j]);
//            }
//        }
//
//        NSInteger index = (i/3)*4;
//        output[index + 0] = table[(value>>18) & 0x3f];
//        output[index + 1] = table[(value>>12) & 0x3f];
//        output[index + 2] = (i+1)<length ? table[(value>>6) & 0x3f] : '=';
//        output[index + 3] = (i+2)<length ? table[(value>>0) & 0x3f] : '=';
//    }
//
//    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
//}
- (NSString *)encode:(const uint8_t *)input length:(NSInteger)length {
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData *data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t *output = (uint8_t *)data.mutableBytes;
    
    for (NSInteger i = 0; i < length; i += 3) {
        NSInteger value = 0;
        for (NSInteger j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger index = (i / 3) * 4;
        output[index + 0] =                    table[(value >> 18) & 0x3F];
        output[index + 1] =                    table[(value >> 12) & 0x3F];
        output[index + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[index + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

-(void) provideContent:(SKPaymentTransaction *)transaction{
    //    UnitySendMessage("Main", "ProvideContent", [[self transactionInfo:transaction] UTF8String]);
    //    NSLog(@"[self transactionInfo:transaction]  = %@",[self transactionInfo:transaction]);
    
    if(transaction.transactionState == SKPaymentTransactionStatePurchased){
        NSLog(@"支付成功");
        
        NSURL *receiptUrl=[[NSBundle mainBundle] appStoreReceiptURL];
        
        
        NSData *receiptData=[NSData dataWithContentsOfURL:receiptUrl];
        
        
        NSString *receiptString=[receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];//转化为base64字符串
        
        
        
        
        NSLog(@"receiptString = %@",receiptString);
        //        NSString *bodyString = [NSString stringWithFormat:@"{\"receipt-data\":\"%@\"}", receiptString];//拼接请求数据
        NSString *bodyString = [NSString stringWithFormat:@"receipt_data=%@&roleid=%@",receiptString, self.currentBuyRoleID];
        NSLog(@"bodyString = %@",bodyString);
        NSString *str3 = [bodyString stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
        NSData *bodyData = [str3 dataUsingEncoding:NSUTF8StringEncoding];
        //创建请求到苹果官方进行购买验证
        NSURL *url=[NSURL URLWithString: POSTURL];          //SANDBOX
        NSMutableURLRequest *requestM=[NSMutableURLRequest requestWithURL:url];
        requestM.HTTPBody=bodyData;
        requestM.HTTPMethod=@"POST";
        //创建连接并发送同步请求
        NSError *error=nil;
        NSData *responseData=[NSURLConnection sendSynchronousRequest:requestM returningResponse:nil error:&error];
        if (error) {
            NSLog(@"验证购买过程中发生错误，错误信息：%@",error.localizedDescription);
            return;
        }
        
        NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
        NSLog(@"%@",[dic description]);
        NSLog(@"environment = %@",[dic objectForKey:@"environment"]);
        if ([[dic objectForKey:@"status"] intValue] == 0) {
            NSLog(@"==================%@",[[dic objectForKey:@"receipt"] description]);
        }
    }
    
    UnitySendMessage("SDKLogin", "HideLoading","");
}


/**
 *  验证购买，避免越狱软件模拟苹果请求达到非法购买问题
 *
 */
/*
 -(void)verifyPurchaseWithPaymentTransaction{
 //从沙盒中获取交易凭证并且拼接成请求体数据
 NSURL *receiptUrl=[[NSBundle mainBundle] appStoreReceiptURL];
 NSLog(@"receiptUrl = %@",[receiptUrl description]);
 
 NSData *receiptData=[NSData dataWithContentsOfURL:receiptUrl];
 
 NSLog(@"receiptData string  = %@",receiptData);
 
 NSString *receiptString=[receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];//转化为base64字符串
 
 
 
 
 
 NSLog(@"receiptString = %@",receiptString);
 NSString *bodyString = [NSString stringWithFormat:@"{\"receipt-data\" : \"%@\"}", receiptString];//拼接请求数据
 NSLog(@"bodyString = %@",bodyString);
 
 NSData *bodyData = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
 
 //创建请求到苹果官方进行购买验证
 NSURL *url=[NSURL URLWithString:SANDBOX];
 NSMutableURLRequest *requestM=[NSMutableURLRequest requestWithURL:url];
 requestM.HTTPBody=bodyData;
 requestM.HTTPMethod=@"POST";
 //创建连接并发送同步请求
 NSError *error=nil;
 NSData *responseData=[NSURLConnection sendSynchronousRequest:requestM returningResponse:nil error:&error];
 if (error) {
 NSLog(@"验证购买过程中发生错误，错误信息：%@",error.localizedDescription);
 return;
 }
 NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
 NSLog(@"%@",[dic description]);
 if([dic[@"status"] intValue]==0){
 //        NSLog(@"购买成功！");
 //        NSDictionary *dicReceipt= dic[@"receipt"];
 //        NSDictionary *dicInApp=[dicReceipt[@"in_app"] firstObject];
 //        NSString *productIdentifier= dicInApp[@"product_id"];//读取产品标识
 //        //如果是消耗品则记录购买数量，非消耗品则记录是否购买过
 //        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
 //        if ([productIdentifier isEqualToString:@"123"]) {
 //            int purchasedCount=[defaults integerForKey:productIdentifier];//已购买数量
 //            [[NSUserDefaults standardUserDefaults] setInteger:(purchasedCount+1) forKey:productIdentifier];
 //        }else{
 //            [defaults setBool:YES forKey:productIdentifier];
 //        }
 //        //在此处对购买记录进行存储，可以存储到开发商的服务器端
 }else{
 NSLog(@"购买失败，未通过验证！");
 }
 }
 */


-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                // 发送到苹果服务器验证凭证
                //                [self verifyPurchaseWithPaymentTransaction];
                NSLog(@"-----交易完成 --------");
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                 UnitySendMessage("SDKLogin", "HideLoading","");
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                 UnitySendMessage("SDKLogin", "HideLoading","");
                break;
            default:
                break;
        }
    }
}

-(void) completeTransaction:(SKPaymentTransaction *)transaction{
    [self provideContent:transaction];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

-(void) failedTransaction:(SKPaymentTransaction *)transaction{
    NSLog(@"Failed transaction : %@",transaction.transactionIdentifier);
    
    if (transaction.error.code != SKErrorPaymentCancelled) {
        NSLog(@"!Cancelled");
    }
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

-(void) restoreTransaction:(SKPaymentTransaction *)transaction{
    NSLog(@"Restore transaction : %@",transaction.transactionIdentifier);
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}



@end

extern "C" {
    
    InAppPurchaseManager *shareMgr = nil;
    
    void IOS_IAP(const char *orderString)
    {

        NSData *jsonData = [NSData dataWithBytes:orderString length:strlen(orderString)];
        NSLog(@"orderString = %s",orderString);
        NSString *str = [[NSString alloc] initWithUTF8String:orderString ];
        NSLog(@"IOS_IAP================:%@",str);
        NSError *err;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&err];
        if(err)
        {
            NSLog(@"json解析失败：%@",err);
        }else{
            
            if(shareMgr == nil){
                shareMgr = [[InAppPurchaseManager alloc] init];
                [shareMgr attachObserver];
            }
            [shareMgr purchaseProUpgrade:str];
            
            if ([shareMgr CanMakePayment]) {
                NSLog(@" 可以购买");
                NSString *productId = [[dic objectForKey:@"mallid"] description];
                shareMgr.currentBuyRoleID = [[dic objectForKey:@"roldid"] description];
                [shareMgr purchaseProUpgrade:productId];
            }
        }
    }
}




