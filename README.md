
# react-native-printer-bridge

## Getting started

`$ npm install react-native-printer-bridge --save`

### Mostly automatic installation

`$ react-native link react-native-printer-bridge`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-printer-bridge` and add `RNPrinterBridge.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNPrinterBridge.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import com.reactlibrary.RNPrinterBridgePackage;` to the imports at the top of the file
  - Add `new RNPrinterBridgePackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-printer-bridge'
  	project(':react-native-printer-bridge').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-printer-bridge/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-printer-bridge')
  	```

## Usage
```javascript
import RNPrinterBridge from 'react-native-printer-bridge';

// TODO: What to do with the module?
RNPrinterBridge;
```
  
