import Flutter
import UIKit

final class OrientationFlutterViewController: FlutterViewController {
  static var supportedOrientationMask: UIInterfaceOrientationMask = .portrait
  private var pendingOrientationMask: UIInterfaceOrientationMask?

  override func viewDidLoad() {
    super.viewDidLoad()
    configureOrientationChannel()
  }

  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return Self.supportedOrientationMask
  }

  override var shouldAutorotate: Bool {
    return true
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if let mask = pendingOrientationMask {
      pendingOrientationMask = nil
      updateOrientation(mask: mask, result: nil)
    }
  }

  private func configureOrientationChannel() {
    let channel = FlutterMethodChannel(
      name: "mediconsult/orientation",
      binaryMessenger: binaryMessenger
    )

    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else {
        result(nil)
        return
      }

      switch call.method {
      case "landscape":
        self.updateOrientation(
          mask: [.landscapeLeft, .landscapeRight],
          result: result
        )
      case "portrait":
        self.updateOrientation(
          mask: .portrait,
          result: result
        )
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func updateOrientation(
    mask: UIInterfaceOrientationMask,
    result: FlutterResult?
  ) {
    Self.supportedOrientationMask = mask

    if #available(iOS 16.0, *) {
      setNeedsUpdateOfSupportedInterfaceOrientations()
      guard let windowScene = view.window?.windowScene else {
        pendingOrientationMask = mask
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
          guard let self = self else {
            result?(nil)
            return
          }

          self.updateOrientation(mask: mask, result: result)
        }
        return
      }

      let preferences = UIWindowScene.GeometryPreferences.iOS(
        interfaceOrientations: mask
      )
      windowScene.requestGeometryUpdate(preferences) { error in
        NSLog("Orientation geometry update failed: \(error.localizedDescription)")
      }
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
        result?(nil)
      }
    } else {
      let fallbackOrientation = mask == .portrait
        ? UIInterfaceOrientation.portrait.rawValue
        : UIInterfaceOrientation.landscapeRight.rawValue
      UIDevice.current.setValue(fallbackOrientation, forKey: "orientation")
      UIViewController.attemptRotationToDeviceOrientation()
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
        result?(nil)
      }
    }
  }
}
