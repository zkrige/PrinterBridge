
package za.co.sovtech;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.support.annotation.Nullable;
import android.util.Log;
import android.widget.Toast;
import za.co.sovtech.ReceiptUtility;
import com.bbpos.simplyprint.SimplyPrintController;

import java.util.ArrayList;
import java.util.Hashtable;
import java.util.List;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableNativeArray;
import com.facebook.react.modules.core.DeviceEventManagerModule;

class RNPrinterBridgeModule extends ReactContextBaseJavaModule implements SimplyPrintController.SimplyPrintControllerListener {

    private static final String TAG = RNPrinterBridgeModule.class.getSimpleName();
    private ReactApplicationContext reactContext;

    RNPrinterBridgeModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
    }

    @Override
    public String getName() {
        return "RNPrinterBridge";
    }

    SimplyPrintController printController;
    BluetoothDevice[] pairedDevices;
    private List<byte[]> receipts = null;

    @ReactMethod
    public void testPrinterModule() {
        Toast.makeText(getReactApplicationContext(), "Working...", Toast.LENGTH_LONG).show();
    }

    @ReactMethod
    public void initPrinter() {
        if (printController == null) {
            Log.d("BTPrinter", "printController is null!");
            printController = new SimplyPrintController(getReactApplicationContext(), this);
        }

        if (printController.isDevicePresent()) {
            Log.d("BTPrinter", "Device present!");
        } else {
            Log.d("BTPrinter", "No device present!");
            searchForPrinters();
        }
    }

    @ReactMethod
    public void searchForPrinters() {
        try {
            Object[] pairedObjects = BluetoothAdapter.getDefaultAdapter().getBondedDevices().toArray();
            pairedDevices = new BluetoothDevice[pairedObjects.length];
            WritableArray array = new WritableNativeArray();

            for (int i = 0; i < pairedObjects.length; ++i) {
                pairedDevices[i] = (BluetoothDevice) pairedObjects[i];
                array.pushString(pairedDevices[i].getName());
                Log.d("BTPrinter", pairedDevices[i].getName());
            }

            WritableMap params = Arguments.createMap();
            params.putArray("devices", array);
            sendEvent(getReactApplicationContext(), "foundPrinters", params);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }


    /**
     * Connect to a Printer by name
     */
    @ReactMethod
    public void connectToPrinterByName(String deviceName) {
        for (BluetoothDevice pairedDevice : pairedDevices) {
            if (pairedDevice == null) {
                continue;
            }
            if (pairedDevice.getName().equals(deviceName)) {
                Log.d("BTPrinter", "Connected to: " + pairedDevice.getName());
                printController.startBTv2(pairedDevice);
            }
        }
    }

    /**
     * Print a receipt
     */
    @ReactMethod
    public void printReceipt(String receiptContent, Boolean isMerchantReceipt, String tradingName) {
        receipts = new ArrayList<byte[]>();

        receipts.add(ReceiptUtility.genReceipt(getReactApplicationContext(), receiptContent, isMerchantReceipt, tradingName));

        printController.startPrinting(receipts.size(), 120, 120);
    }

    private void sendEvent(ReactContext reactContext, String eventName, @Nullable WritableMap params) {
        reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit(eventName, params);
    }

    @Override
    public void onBTv2Detected() {
    }

    @Override
    public void onBTv2DeviceListRefresh(List<BluetoothDevice> list) {
        Log.d("BTPrinter", "onBTv2DeviceListRefresh");
    }

    @Override
    public void onBTv2Connected(BluetoothDevice bluetoothDevice) {
        Log.d("BTPrinter", "onBTv2Connected");
        WritableMap params = Arguments.createMap();
        params.putString("status", "connected");
        sendEvent(getReactApplicationContext(), "onBTConnectionStatusChanged", params);
    }

    @Override
    public void onBTv2Disconnected() {
        Log.d("BTPrinter", "onBTv2Disconnected");
        WritableMap params = Arguments.createMap();
        params.putString("status", "disconnected");
        sendEvent(getReactApplicationContext(), "onBTConnectionStatusChanged", params);
    }

    @Override
    public void onBTv2ScanStopped() {
        Log.d("BTPrinter", "onBTv2ScanStopped");
    }

    @Override
    public void onBTv2ScanTimeout() {
        Log.d("BTPrinter", "onBTv2ScanTimeout");
    }

    @Override
    public void onBTv4DeviceListRefresh(List<BluetoothDevice> list) {
        Log.d("BTPrinter", "onBTv4DeviceListRefresh");
    }

    @Override
    public void onBTv4Connected() {
        Log.d("BTPrinter", "onBTv4Connected");
        WritableMap params = Arguments.createMap();
        params.putString("status", "connected");
        sendEvent(getReactApplicationContext(), "onBTConnectionStatusChanged", params);
    }

    @Override
    public void onBTv4Disconnected() {
        Log.d("BTPrinter", "onBTv4Disconnected");
        WritableMap params = Arguments.createMap();
        params.putString("status", "disconnected");
        sendEvent(getReactApplicationContext(), "onBTConnectionStatusChanged", params);
    }

    @Override
    public void onBTv4ScanStopped() {
        Log.d("BTPrinter", "onBTv4ScanStopped");
    }

    @Override
    public void onBTv4ScanTimeout() {
        Log.d("BTPrinter", "onBTv4ScanTimeout");
    }

    @Override
    public void onReturnDeviceInfo(Hashtable<String, String> hashtable) {
        Log.d("BTPrinter", "onReturnDeviceInfo");
        Log.d("BTPrinter", String.valueOf(hashtable));
    }

    @Override
    public void onReturnPrinterResult(SimplyPrintController.PrinterResult printerResult) {
        Log.d("BTPrinter", "onReturnPrinterResult");
        WritableMap params = Arguments.createMap();
        params.putString("result", printerResult.name());
        sendEvent(getReactApplicationContext(), "onReturnPrinterResult", params);
    }

    @Override
    public void onReturnGetDarknessResult(int i) {
        Log.d("BTPrinter", "onReturnGetDarknessResult");
    }

    @Override
    public void onReturnSetDarknessResult(boolean b) {
        Log.d("BTPrinter", "onReturnSetDarknessResult");
    }

    @Override
    public void onRequestPrinterData(int i, boolean b) {
        printController.sendPrinterData(receipts.get(i));
        Log.d("BTPrinter", "onRequestPrinterData");
    }

    @Override
    public void onPrinterOperationEnd() {
        Log.d("BTPrinter", "onPrinterOperationEnd");
    }

    @Override
    public void onBatteryLow(SimplyPrintController.BatteryStatus batteryStatus) {
        Log.d("BTPrinter", "onBatteryLow");
    }

    @Override
    public void onBTv2DeviceNotFound() {
        Log.d("BTPrinter", "onBTv2DeviceNotFound");
    }

    @Override
    public void onError(SimplyPrintController.Error errorState) {
        if (errorState == SimplyPrintController.Error.UNKNOWN) {
            Log.d("BTPrinter", "Unknown");
        } else if (errorState == SimplyPrintController.Error.CMD_NOT_AVAILABLE) {
            Log.d("BTPrinter", "Command not av");
        } else if (errorState == SimplyPrintController.Error.TIMEOUT) {
            Log.d("BTPrinter", "device no response");
        } else if (errorState == SimplyPrintController.Error.DEVICE_BUSY) {
            Log.d("BTPrinter", "device busy");
        } else if (errorState == SimplyPrintController.Error.INPUT_OUT_OF_RANGE) {
            Log.d("BTPrinter", "Out of range");
        } else if (errorState == SimplyPrintController.Error.INPUT_INVALID) {
            Log.d("BTPrinter", "invalid input");
        } else if (errorState == SimplyPrintController.Error.CRC_ERROR) {
            Log.d("BTPrinter", "crc error");
        } else if (errorState == SimplyPrintController.Error.FAIL_TO_START_BTV2) {
            Log.d("BTPrinter", "failed to start bluetooth");
        } else if (errorState == SimplyPrintController.Error.COMM_LINK_UNINITIALIZED) {
            Log.d("BTPrinter", "Link uninit");
        } else if (errorState == SimplyPrintController.Error.BTV2_ALREADY_STARTED) {
            Log.d("BTPrinter", "Bluetooth already started");
        } else {
            Log.d("BTPrinter", "ERROR!");
        }
        WritableMap params = Arguments.createMap();
        params.putString("message", String.valueOf(errorState));
        sendEvent(getReactApplicationContext(), "onPrinterError", params);
    }
}

