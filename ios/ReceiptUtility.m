//
//  ReceiptUtility.m
//  RNBluetoothPrinter
//
//  Created by Zayin Krige on 2018/01/31.
//  Copyright © 2018 Apex Technology. All rights reserved.
//

#import "ReceiptUtility.h"
@import UIKit;

@implementation ReceiptUtility
const char INIT[]           = {0x1B,0x40};
const char POWER_ON[]       = {0x1B,0x3D,0x01};
const char POWER_OFF[]      = {0x1B,0x3D,0x02};
const char NEW_LINE[]       = {0x0A};
const char ALIGN_LEFT[]     = {0x1B,0x61,0x00};
const char ALIGN_CENTER[]   = {0x1B,0x61,0x01};
const char ALIGN_RIGHT[]    = {0x1B,0x61,0x02};
const char EMPHASIZE_ON[]   = {0x1B,0x45,0x01};
const char EMPHASIZE_OFF[]  = {0x1B,0x45,0x00};
const char FONT_5X8[]       = {0x1B,0x4D,0x00};
const char FONT_5X12[]      = {0x1B,0x4D,0x01};
const char FONT_8X12[]      = {0x1B,0x4D,0x02};
const char FONT_10X18[]     = {0x1B,0x4D,0x03};
const char FONT_SIZE_0[]    = {0x1D,0x21,0x00};
const char FONT_SIZE_1[]    = {0x1D,0x21,0x11};
const char CHAR_SPACING_0[] = {0x1B,0x20,0x00};
const char CHAR_SPACING_1[] = {0x1B,0x20,0x01};

+ (NSData *)genReceipt:(NSString *)receipt isMerchantReceipt:(BOOL)isMerchantReceipt tradingName:(NSString *)tradingName {

    NSString *lineSep = @"\n";
    NSString *yourString = receipt;
    yourString = [yourString stringByReplacingOccurrencesOfString:@"<br>" withString:@"brnl"];
    yourString = [yourString stringByReplacingOccurrencesOfString:@"<br/>" withString:@"brnl"];
    NSAttributedString *htmlString = [[NSAttributedString alloc] initWithData:[yourString dataUsingEncoding:NSUTF8StringEncoding]
                                                                      options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                                                                NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)
                                                                               }
                                                           documentAttributes:nil error:nil];
    yourString = htmlString.string;
    yourString = [yourString stringByReplacingOccurrencesOfString:@"brnl" withString:lineSep];
    NSInteger lineWidth = 384;
    NSInteger size0NoEmphasizeLineWidth = lineWidth / 8; //line width / font width
    NSString *singleLine = @"";
    for (int i = 0; i<size0NoEmphasizeLineWidth; ++i) {
        singleLine = [singleLine stringByAppendingString:@"-"];
    }
    NSString *doubleLine = @"";
    for (int i = 0; i<size0NoEmphasizeLineWidth; ++i) {
        doubleLine = [doubleLine stringByAppendingString:@"="];
    }
    NSMutableData *output = [NSMutableData new];
    [output appendBytes:INIT length:sizeof(INIT)];
    [output appendBytes:POWER_ON length:sizeof(POWER_ON)];
    [output appendBytes:NEW_LINE length:sizeof(NEW_LINE)];
    [output appendBytes:ALIGN_CENTER length:sizeof(ALIGN_CENTER)];
    [output appendBytes:FONT_SIZE_1 length:sizeof(FONT_SIZE_1)];
    [output appendBytes:FONT_10X18 length:sizeof(FONT_10X18)];
    [output appendBytes:EMPHASIZE_ON length:sizeof(EMPHASIZE_ON)];
    [output appendData:[tradingName dataUsingEncoding:NSUTF8StringEncoding]];
    [output appendBytes:EMPHASIZE_OFF length:sizeof(EMPHASIZE_OFF)];
    [output appendBytes:NEW_LINE length:sizeof(NEW_LINE)];
    [output appendBytes:CHAR_SPACING_0 length:sizeof(CHAR_SPACING_0)];
    [output appendBytes:FONT_SIZE_1 length:sizeof(FONT_SIZE_1)];
    [output appendBytes:FONT_5X12 length:sizeof(FONT_5X12)];
    if (isMerchantReceipt) {
        [output appendData:[@"Merchant Receipt" dataUsingEncoding:NSUTF8StringEncoding]];
    } else {
        [output appendData:[@"Customer Receipt" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [output appendBytes:NEW_LINE length:sizeof(NEW_LINE)];
    [output appendBytes:FONT_SIZE_0 length:sizeof(FONT_SIZE_0)];
    [output appendBytes:FONT_8X12 length:sizeof(FONT_8X12)];
    [output appendData:[singleLine dataUsingEncoding:NSUTF8StringEncoding]];
    [output appendBytes:NEW_LINE length:sizeof(NEW_LINE)];
    [output appendBytes:FONT_10X18 length:sizeof(FONT_10X18)];
    [output appendBytes:ALIGN_LEFT length:sizeof(ALIGN_LEFT)];

    NSArray <NSString *> *lines = [yourString componentsSeparatedByString:lineSep];
    for (NSString *line in lines) {
        [output appendBytes:EMPHASIZE_OFF length:sizeof(EMPHASIZE_OFF)];
        [output appendData:[line dataUsingEncoding:NSUTF8StringEncoding]];
        [output appendBytes:EMPHASIZE_ON length:sizeof(EMPHASIZE_ON)];
        [output appendBytes:NEW_LINE length:sizeof(NEW_LINE)];

    }

    [output appendBytes:NEW_LINE length:sizeof(NEW_LINE)];
    [output appendBytes:NEW_LINE length:sizeof(NEW_LINE)];
    [output appendBytes:ALIGN_CENTER length:sizeof(ALIGN_CENTER)];
    [output appendData:[@"Powered by SureSwipe" dataUsingEncoding:NSUTF8StringEncoding]];
    [output appendBytes:NEW_LINE length:sizeof(NEW_LINE)];
    [output appendBytes:NEW_LINE length:sizeof(NEW_LINE)];
    [output appendBytes:NEW_LINE length:sizeof(NEW_LINE)];
    [output appendBytes:NEW_LINE length:sizeof(NEW_LINE)];
    [output appendBytes:NEW_LINE length:sizeof(NEW_LINE)];
    [output appendBytes:NEW_LINE length:sizeof(NEW_LINE)];
    [output appendBytes:POWER_OFF length:sizeof(POWER_OFF)];
    return output;
}
@end
