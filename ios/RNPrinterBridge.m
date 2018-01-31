#import "RNPrinterBridge.h"
#import <React/RCTConvert.h>
#import <React/RCTUtils.h>
#import "SimplyPrintController.h"
#import "ReceiptUtility.h"
#import "UIView+Toast.h"

@interface RNPrinterBridge()<SimplyPrintControllerDelegate> {
    SimplyPrintController *_printController;
    RCTResponseSenderBlock _callback;
    NSArray <CBPeripheral *> *_pairedDevices;
}

@implementation RNPrinterBridge

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(testPrinterModule) {
    [self.view makeToast:@"Working..."];
}

RCT_EXPORT_METHOD(initPrinter) {
    if (_printController == nil) {
        NSLog(@"printController is nil");
        _printController = [SimplyPrintController sharedController];
    }

    if ([_printController isDevicePresent]) {
        NSLog(@"device is present");
    } else {
        NSLog(@"No device present");
        [self searchForPrinters];
    }
}

RCT_EXPORT_METHOD(searchForPrinters) {
    //start the scan and emit event once all devices are found
    [_printController scanBTv4:nil scanTimeout:10];

}

- (void)onSimplyPrintBTv4DeviceListRefresh:(NSArray *)foundDevices {
    NSLog(@"foundDevices    : %@", foundDevices);
    if (foundDevices == nil){
        return;
    }
    NSMutableArray *foundDevices = [NSMutableArray new];
    _pairedDevices = [NSMutableArray new];
    for (int i=0 ; i<[foundDevices count]; i++) {
        CBPeripheral *pairedDevice = (CBPeripheral *)[foundDevices objectAtIndex:i];
        [pairedDevices addObject:pairedDevice];
        foundDeviceName = [pairedDevice name];
        [foundDevices addObject:foundDeviceName];
    }
    [self sendEventWithName:@"foundPrinters" body:@{@"devices": foundDevices}];
}

RCT_EXPORT_METHOD(connectToPrinterByName:(NSString *)name) {
    for (CBPeripheral *device in _pairedDevices){
        if (device == nil) {
            continue
        }
        if ([[device name] isEqualToString:name]){
            NSLog(@"Connected to: " + name);
            [_printController connectBTv4:device];
        }
    }
}

RCT_EXPORT_METHOD(printReceipt:(NSString *)receiptContent isMerchantReceipt:(BOOL)isMerchantReceipt tradingName:(NSString *)tradingName) {
    [_printController startPrint];
}

#pragma mark - SimplyPrintControllerDelegate

- (void)onSimplyPrintRequestPrintData {
    NSData *receiptData = [ReceiptUtility genReceipt:receiptContent isMerchantReceipt:isMerchantReceipt tradingName:tradingName];
    [_printController sendPrinterData:receiptData];
}

- (void)onSimplyPrintBatteryLow:(SimplyPrintBatteryStatus)batteryStatus {
    NSLog(@"battery low");
}
- (void)onSimplyPrintError:(SimplyPrintErrorType)ErrorType errorMessage:(NSString *)errorMessage {
    NSString *errorName;
    switch ErrorType {
    case SimplyPrintErrorType_InvalidInput: errorName = @"Invalid Input" break;
    case SimplyPrintErrorType_InvalidInput_InputValueOutOfRange: errorName = @"Input value out of range" break;
    case SimplyPrintErrorType_InvalidInput_InvalidDataFormat: errorName = @"Invalid data format" break;
    case SimplyPrintErrorType_CommandNotAvailable: errorName = @"Command not available" break;
    case SimplyPrintErrorType_CommError: errorName = @"Comms error" break;
    case SimplyPrintErrorType_Unknown: errorName = @"Unknown" break;
    case SimplyPrintErrorType_IllegalStateException: errorName = @"Illegal state execption" break;
    case SimplyPrintErrorType_CommLinkUninitialized: errorName = @"Comm link uninitialized" break;
    case SimplyPrintErrorType_BTv4FailToStart: errorName = @"BTv4 Fail to start" break;
    case SimplyPrintErrorType_BTv4Unsupported: errorName = @"BTv4 Unsupported" break;
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
    switch result {
    case SimplyPrintPrinterResult_Success: resultName = @"Success"; break;
    case SimplyPrintPrinterResult_NoPaperOrCoverOpened: resultName = @"No paper or cover opened"; break;
    case SimplyPrintPrinterResult_WrongPrinterCommand: resultName = @"Wrong printer command"; break;
    case SimplyPrintPrinterResult_Overheat: resultName = @"Overheat"; break;
    }
    [self sendEventWithName:@"onReturnPrinterResult" body:@{@"message": errorName}];
}
@end
  
