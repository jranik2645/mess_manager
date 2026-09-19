import 'package:url_launcher/url_launcher.dart';
import '../utils/formatters.dart';

class NotificationService {
  /// Send Due Alert via SMS
  static Future<void> sendDueSMS({
    required String phone,
    required String memberName,
    required double dueAmount,
    required String month,
  }) async {
    final message = 'স্বাগতম $memberName, মেস ম্যানেজার অ্যাপ অনুযায়ী $month মাসের আপনার বকেয়া বিল ${AppFormatters.formatCurrency(dueAmount.abs())}। দয়া করে দ্রুত পরিশোধ করুন।';
    final Uri uri = Uri.parse('sms:$phone?body=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  /// Send Due Alert via WhatsApp
  static Future<void> sendDueWhatsApp({
    required String phone,
    required String memberName,
    required double dueAmount,
    required String month,
  }) async {
    // Clean phone number: remove any non-digit
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final finalPhone = cleanPhone.startsWith('88') ? cleanPhone : '88$cleanPhone';
    
    final message = '--- মেস বিল নোটিশ ---\n'
        'সদস্য: $memberName\n'
        'মাস: $month\n'
        'বকেয়া পরিমাণ: ${AppFormatters.formatCurrency(dueAmount.abs())}\n'
        '----------------------\n'
        'দয়া করে আপনার বকেয়া বিলটি পরিশোধ করে ম্যানেজারকে জানান। ধন্যবাদ।';
        
    final Uri uri = Uri.parse('https://wa.me/$finalPhone?text=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  /// Send Due Alert via Email
  static Future<void> sendDueEmail({
    required String email,
    required String memberName,
    required double dueAmount,
    required String month,
  }) async {
    if (email.isEmpty) return;
    
    final subject = 'বকেয়া মেস বিল সংক্রান্ত নোটিশ - $month';
    final body = 'সম্মানিত $memberName,\n\n'
        'আশা করি ভালো আছেন। আপনার $month মাসের মেস বিলের হিসাব নিচে দেওয়া হলো:\n\n'
        'বকেয়া টাকার পরিমাণ: ${AppFormatters.formatCurrency(dueAmount.abs())}\n\n'
        'দয়া করে দ্রুত সময়ের মধ্যে বিলটি পরিশোধ করার জন্য অনুরোধ করা হলো।\n\n'
        'ধন্যবাদান্তে,\n'
        'মেস ম্যানেজার টিম।';
        
    final Uri uri = Uri.parse('mailto:$email?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
