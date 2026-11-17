import Flutter
import UIKit
import connectivity_plus
import flutter_local_notifications
import flutter_secure_storage_darwin
import geolocator_apple
import image_picker_ios
import integration_test
import package_info_plus
import permission_handler_apple
import shared_preferences_foundation
import sqflite_darwin
import url_launcher_ios

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    #if targetEnvironment(simulator)
      #if arch(x86_64)
        let registry = engineBridge.pluginRegistry
        ConnectivityPlusPlugin.register(with: registry.registrar(forPlugin: "ConnectivityPlusPlugin")!)
        FlutterLocalNotificationsPlugin.register(with: registry.registrar(forPlugin: "FlutterLocalNotificationsPlugin")!)
        FlutterSecureStorageDarwinPlugin.register(with: registry.registrar(forPlugin: "FlutterSecureStorageDarwinPlugin")!)
        GeolocatorPlugin.register(with: registry.registrar(forPlugin: "GeolocatorPlugin")!)
        ImagePickerPlugin.register(with: registry.registrar(forPlugin: "ImagePickerPlugin")!)
        IntegrationTestPlugin.register(with: registry.registrar(forPlugin: "IntegrationTestPlugin")!)
        FPPPackageInfoPlusPlugin.register(with: registry.registrar(forPlugin: "FPPPackageInfoPlusPlugin")!)
        PermissionHandlerPlugin.register(with: registry.registrar(forPlugin: "PermissionHandlerPlugin")!)
        SharedPreferencesPlugin.register(with: registry.registrar(forPlugin: "SharedPreferencesPlugin")!)
        SqflitePlugin.register(with: registry.registrar(forPlugin: "SqflitePlugin")!)
        URLLauncherPlugin.register(with: registry.registrar(forPlugin: "URLLauncherPlugin")!)
      #else
        GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
      #endif
    #else
      GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    #endif
  }

  override func application(
    _ application: UIApplication,
    supportedInterfaceOrientationsFor window: UIWindow?
  ) -> UIInterfaceOrientationMask {
    return OrientationFlutterViewController.supportedOrientationMask
  }
}
