//
//  InAppPurchaseManager.h
//  shotgame
//
//  Created by frozenface zhu on 12-1-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <StoreKit/StoreKit.h>



@interface InAppPurchaseManager : NSObject <SKProductsRequestDelegate, UIAlertViewDelegate>
{
    SKProduct *proUpgradeProduct;
    SKProductsRequest *productsRequest;
}

@property(retain,nonatomic) NSString *currentBuyRoleID;

-(void)attachObserver;
-(BOOL)CanMakePayment;
-(void) requestProductData:(NSString *)productIdentifiers currentBuyRoleID :(NSString *) currentRoleId;
-(void)buyRequest:(SKProduct *)product;



@end
