declare module "PrinterBridge" {
    
        export function testPrinterModule(): void;
        export function initPrinter(): void;
        export function searchForPrinters(): void;
        export function connectToPrinterByName(name : String): void;
        export function printReceipt(receiptContent : String, isMerchantReceipt : Boolean, tradingName : String): void;
    
        export default PrinterBridge;
}