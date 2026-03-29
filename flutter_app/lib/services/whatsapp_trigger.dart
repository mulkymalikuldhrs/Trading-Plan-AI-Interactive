import "package:flutter/foundation.dart";
import './api_service.dart';

class WhatsAppTrigger {
  /// Sends a notification message to the user via the WhatsApp bot.
  /// This utilizes the Google Apps Script backend to route the message securely.
  static Future<void> sendReminder(String message) async {
    try {
      // We don't specify 'to' here, the GAS backend uses USER_PHONE_NUMBER from Script Properties
      await ApiService.post('sendWhatsAppNotification', {
        'message': message,
      });
      debugPrint("WhatsApp notification sent via GAS backend.");
    } catch (e) {
      debugPrint("WhatsAppTrigger Error: $e");
    }
  }
}
