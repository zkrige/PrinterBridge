//
//  SimplyPrintController.h
//  SimplyPrintAPI
//
//  Created by Alex Wong on 2015-07-28
//  Copyright 2015 BBPOS LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

typedef enum {
    SimplyPrintControllerState_CommLinkUninitialized,
    SimplyPrintControllerState_Idle,
    SimplyPrintControllerState_WaitingForResponse,
    SimplyPrintControllerState_Printing
} SimplyPrintControllerState;

typedef enum {
    SimplyPrintBatteryStatus_Low,
    SimplyPrintBatteryStatus_CriticallyLow
} SimplyPrintBatteryStatus;

typedef enum {
    SimplyPrintErrorType_InvalidInput,
    SimplyPrintErrorType_InvalidInput_InputValueOutOfRange,
    SimplyPrintErrorType_InvalidInput_InvalidDataFormat,
    
    SimplyPrintErrorType_CommandNotAvailable,
    SimplyPrintErrorType_CommError,
    SimplyPrintErrorType_Unknown,
    SimplyPrintErrorType_IllegalStateException,
    
    SimplyPrintErrorType_CommLinkUninitialized,
    SimplyPrintErrorType_BTv4FailToStart,
    SimplyPrintErrorType_BTv4Unsupported
    
} SimplyPrintErrorType;

typedef enum {
    SimplyPrintPrinterResult_Success,
    SimplyPrintPrinterResult_NoPaperOrCoverOpened,
    SimplyPrintPrinterResult_WrongPrinterCommand,
    SimplyPrintPrinterResult_Overheat //Added in 1.1.0
}SimplyPrintPrinterResult;

@protocol SimplyPrintControllerDelegate;

@interface SimplyPrintController:NSObject{
	NSObject <SimplyPrintControllerDelegate> *delegate;
}

@property (nonatomic, assign) NSObject <SimplyPrintControllerDelegate> *delegate;

- (NSString *)getApiVersion;
- (NSString *)getApiBuildNumber;

+ (SimplyPrintController *)sharedController;
- (SimplyPrintControllerState)getSimplyPrintControllerState;
- (BOOL)isDevicePresent;
- (void)getDeviceInfo;
- (void)resetSimplyPrintController; //Added in 1.1.0, Reset the API state only. Do not reset the Printer.

// Communication Channel - BTv4
- (void)scanBTv4:(NSArray *)deviceNameArray scanTimeout:(int)scanTimeout;
- (void)stopScanBTv4;
- (void)connectBTv4:(CBPeripheral *)peripheral; //Connect will stop scanning
- (void)disconnectBTv4;

// Printer
- (void)startPrint; //Updated in 1.1.0
- (void)sendPrinterData:(NSData *)data;
- (void)setDarkness:(int)Darkness; //Added in 1.4.0

// Printer Command Utility
- (NSString *)getBarcodeCommand:(NSDictionary *)barcodeDataDict;    //Fixed typo in 1.5.0. codeType accept 128 and 39 only.
- (NSString *)getImageCommand:(UIImage *)image;                     //Added in 1.2.0. Max image width is 384 pixel
- (NSString *)getUnicodeCommand:(NSString *)data;                   //Added in 1.5.0

@end

@protocol SimplyPrintControllerDelegate <NSObject>

- (void)onSimplyPrintBatteryLow:(SimplyPrintBatteryStatus)batteryStatus;
- (void)onSimplyPrintError:(SimplyPrintErrorType)ErrorType errorMessage:(NSString *)errorMessage;

@optional

- (void)onSimplyPrintReturnDeviceInfo:(NSDictionary *)deviceInfoDict;

// Communication Channel - BTv4
- (void)onSimplyPrintBTv4DeviceListRefresh:(NSArray *)foundDevices;
- (void)onSimplyPrintBTv4Connected;
- (void)onSimplyPrintBTv4ConnectTimeout; //Added in 1.2.0
- (void)onSimplyPrintBTv4Disconnected;
- (void)onSimplyPrintBTv4ScanStopped;
- (void)onSimplyPrintBTv4ScanTimeout;
- (void)onSimplyPrintRequestEnableBluetoothInSettings;

// SimplyPrint 2 Printer
- (void)onSimplyPrintRequestPrintData;                                      //Updated callback name in 1.5.0
- (void)onSimplyPrintReturnPrintResult:(SimplyPrintPrinterResult)result;    //Updated callback name in 1.5.0
- (void)onSimplyPrintDataPrintEnd;                                          //Updated callback name in 1.5.0
- (void)onSimplyPrintReturnSetDarknessResult:(BOOL)isSuccess;

@end
