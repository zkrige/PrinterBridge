//
//  ReceiptUtility.h
//  RNBluetoothPrinter
//
//  Created by Zayin Krige on 2018/01/31.
//  Copyright © 2018 Apex Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReceiptUtility : NSObject
+ (NSData *)genReceipt:(NSString *)receipt isMerchantReceipt:(BOOL)isMerchantReceipt tradingName:(NSString *)tradingName;
@end
