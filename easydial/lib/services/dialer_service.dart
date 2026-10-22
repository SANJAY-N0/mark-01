import 'package:url_launcher/url_launcher.dart';

import '../utils/phone_utils.dart';

class DialerService {
  /// Opens the phone's own dialler with [phone] filled in.
  /// The user presses the call button themselves; nothing is dialled automatically.
  /// Returns false if the dialler could not be opened.
  Future<bool> openDialer(String phone) async {
    final number = toDialNumber(phone);
    if (number.replaceAll('+', '').isEmpty) return false;

    try {
      return await launchUrl(
        Uri(scheme: 'tel', path: number),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      return false;
    }
  }
}
