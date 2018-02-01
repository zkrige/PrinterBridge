#import "RNPrinterBridge.h"
#import <React/RCTConvert.h>
#import <React/RCTUtils.h>
#import "SimplyPrintController.h"
#import "ReceiptUtility.h"
#import "UIView+Toast.h"

@interface RNPrinterBridge()<SimplyPrintControllerDelegate>
@end

@implementation RNPrinterBridge{
    RCTResponseSenderBlock _callback;
    NSMutableArray <CBPeripheral *> *_pairedDevices;
    NSData * _receiptData;
    bool hasListeners;
}

// Will be called when this module's first listener is added.
-(void)startObserving {
    hasListeners = YES;
    // Set up any upstream listeners or background tasks as necessary
}

// Will be called when this module's last listener is removed, or on dealloc.
-(void)stopObserving {
    hasListeners = NO;
    // Remove upstream listeners, stop unnecessary background tasks
}

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

- (instancetype)init {
    self = [super init];
    NSString *build = [NSString stringWithFormat:@"API Version %@ (Build %@)",
                       [[SimplyPrintController sharedController] getApiVersion],
                       [[SimplyPrintController sharedController] getApiBuildNumber]];
    NSLog(@"%@", build);
    return self;
}

- (NSArray<NSString *> *)supportedEvents {
    return @[@"foundPrinters",
             @"onPrinterError",
             @"onBTConnectionStatusChanged",
             @"onReturnPrinterResult"];
}

- (void)sendEventWithName:(NSString *)name body:(id)body {
    //optimize for zero listeners
    if (hasListeners) {
        [super sendEventWithName:name body:body];
    }
}

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(testPrinterModule) {
    UIView *view = UIApplication.sharedApplication.keyWindow;
    [view makeToast:@"Printer module is Working..."];
}

RCT_EXPORT_METHOD(initPrinter) {
    if ([[SimplyPrintController sharedController] isDevicePresent]) {
        NSLog(@"device is present");
    } else {
        NSLog(@"No device present");
        [[SimplyPrintController sharedController] setDelegate:self];
        [self searchForPrinters];
    }
}

RCT_EXPORT_METHOD(searchForPrinters) {
    //start the scan and emit event once all devices are found
    [[SimplyPrintController sharedController] scanBTv4:nil scanTimeout:0];

}

- (void)onSimplyPrintBTv4DeviceListRefresh:(NSArray *)foundDevices {
    NSLog(@"foundDevices    : %@", foundDevices);
    if (foundDevices == nil){
        return;
    }
    NSMutableArray *devices = [NSMutableArray new];
    _pairedDevices = [NSMutableArray new];
    for (int i=0 ; i<[foundDevices count]; i++) {
        CBPeripheral *pairedDevice = (CBPeripheral *)[foundDevices objectAtIndex:i];
        [_pairedDevices addObject:pairedDevice];
        NSString *foundDeviceName = [pairedDevice name];
        [devices addObject:foundDeviceName];
    }
    [self sendEventWithName:@"foundPrinters" body:@{@"devices": devices}];
}

RCT_EXPORT_METHOD(connectToPrinterByName:(NSString *)name) {
    for (CBPeripheral *device in _pairedDevices){
        if (device == nil) {
            continue;
        }
        if ([[device name] isEqualToString:name]){
            NSLog(@"Connected to: %@",name);
            [[SimplyPrintController sharedController] connectBTv4:device];
        }
    }
}

RCT_EXPORT_METHOD(printReceipt:(NSString *)receiptContent isMerchantReceipt:(BOOL)isMerchantReceipt tradingName:(NSString *)tradingName) {
    _receiptData = [ReceiptUtility genReceipt:receiptContent isMerchantReceipt:isMerchantReceipt tradingName:tradingName];
    [[SimplyPrintController sharedController] startPrint];
}

#pragma mark - SimplyPrintControllerDelegate

- (void)onSimplyPrintRequestPrintData {
    [[SimplyPrintController sharedController] sendPrinterData:_receiptData];
}

- (void)onSimplyPrintBatteryLow:(SimplyPrintBatteryStatus)batteryStatus {
    NSLog(@"battery low");
}
- (void)onSimplyPrintError:(SimplyPrintErrorType)ErrorType errorMessage:(NSString *)errorMessage {
    NSString *errorName;
    switch (ErrorType) {
        case SimplyPrintErrorType_InvalidInput: errorName = @"Invalid Input"; break;
        case SimplyPrintErrorType_InvalidInput_InputValueOutOfRange: errorName = @"Input value out of range"; break;
        case SimplyPrintErrorType_InvalidInput_InvalidDataFormat: errorName = @"Invalid data format"; break;
        case SimplyPrintErrorType_CommandNotAvailable: errorName = @"Command not available"; break;
        case SimplyPrintErrorType_CommError: errorName = @"Comms error"; break;
        case SimplyPrintErrorType_Unknown: errorName = @"Unknown"; break;
        case SimplyPrintErrorType_IllegalStateException: errorName = @"Illegal state execption"; break;
        case SimplyPrintErrorType_CommLinkUninitialized: errorName = @"Comm link uninitialized"; break;
        case SimplyPrintErrorType_BTv4FailToStart: errorName = @"BTv4 Fail to start"; break;
        case SimplyPrintErrorType_BTv4Unsupported: errorName = @"BTv4 Unsupported"; break;
    }
    [self sendEventWithName:@"onPrinterError" body:@{@"message": errorName}];

}

- (void)onSimplyPrintBTv4Connected{
    [self sendEventWithName:@"onBTConnectionStatusChanged" body:@{@"status": @"connected"}];

}

- (void)onSimplyPrintBTv4Disconnected {
    [self sendEventWithName:@"onBTConnectionStatusChanged" body:@{@"status": @"disconnected"}];

}

- (void)onSimplyPrintReturnPrintResult:(SimplyPrintPrinterResult)result {
    NSString *resultName;
    switch (result) {
        case SimplyPrintPrinterResult_Success: resultName = @"Success"; break;
        case SimplyPrintPrinterResult_NoPaperOrCoverOpened: resultName = @"No paper or cover opened"; break;
        case SimplyPrintPrinterResult_WrongPrinterCommand: resultName = @"Wrong printer command"; break;
        case SimplyPrintPrinterResult_Overheat: resultName = @"Overheat"; break;
    }
    [self sendEventWithName:@"onReturnPrinterResult" body:@{@"message": resultName}];
}
@end

