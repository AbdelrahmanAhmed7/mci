import 'package:permission_handler/permission_handler.dart';

/// Helper to request permissions required for attachments.
class AttachmentsPermissions {
  /// Ensure camera permission is granted.
  ///
  /// Only needed when capturing a photo via the system camera app.
  static Future<bool> ensureCamera() async {
    final status = await Permission.camera.status;
    if (status.isGranted) return true;
    final req = await Permission.camera.request();
    return req.isGranted;
  }
}
