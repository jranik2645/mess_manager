class AppValidators {
  static String? required(String? value, {String message = 'এই ঘরটি পূরণ করা আবশ্যক'}) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'মোবাইল নম্বর আবশ্যক';
    }
    final clean = value.replaceAll(RegExp(r'[\s-]'), '');
    if (!RegExp(r'^(?:\+?88)?01[3-9]\d{8}$').hasMatch(clean)) {
      return 'সঠিক ১১ ডিজিটের মোবাইল নম্বর লিখুন';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
      return 'সঠিক ইমেইল ঠিকানা দিন';
    }
    return null;
  }

  static String? amount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'টাকার পরিমাণ লিখুন';
    }
    final parsed = double.tryParse(value.trim());
    if (parsed == null || parsed <= 0) {
      return 'টাকার পরিমাণ ০-এর বেশি হতে হবে';
    }
    return null;
  }

  static String? mealQuantity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'মিলের সংখ্যা লিখুন';
    }
    final parsed = double.tryParse(value.trim());
    if (parsed == null || parsed < 0) {
      return 'মিলের সংখ্যা ঋণাত্মক হতে পারবে না';
    }
    return null;
  }
}

