declare module "react-native-printer-bridge" {
    export default class RNPrinterBridge {
        static initPrinter(): void;
        static searchForPrinters(): void;
        static connectToPrinterByName(name : String): void;
        static printReceipt(receiptContent: String, isMerchantReceipt: Boolean, tradingName : String): void;
    }
}