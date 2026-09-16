class AppConstants {
  static const String appName = 'Mess Manager Pro';
  static const String appTagline = 'স্মার্ট ব্যাচেলর ও মেস ম্যানেজমেন্ট সিস্টেম';
  static const String currencySymbol = '৳';

  // Firestore Collection Names
  static const String colManagers = 'managers';
  static const String colMembers = 'members';
  static const String colMeals = 'meals';
  static const String colDeposits = 'deposits';
  static const String colCosts = 'costs';
  static const String colExtraBills = 'extra_bills';
  static const String colMonthlyReports = 'monthly_reports';
  static const String colSettings = 'settings';

  // Regular Bazaar Categories
  static const List<String> costCategories = [
    'Food (সাধারণ বাজার)',
    'Rice (চাল)',
    'Vegetable (শাক-সবজি)',
    'Fish (মাছ)',
    'Meat (মাংস)',
    'Oil (তেল/মসলা)',
    'Gas (রান্নার গ্যাস)',
    'Cleaning (পরিষ্কার-পরিচ্ছন্নতা)',
    'Other (অন্যান্য)',
  ];

  // Extra Bill Categories
  static const List<String> extraBillCategories = [
    'WiFi Bill (ইন্টারনেট)',
    'Electricity Bill (বিদ্যুৎ বিল)',
    'Gas Bill (সিলিন্ডার/লাইন গ্যাস)',
    'House Maid (খালা/বুয়ার বিল)',
    'Water Bill (পানি বিল)',
    'House Rent (বাড়ি ভাড়া)',
    'Waste Cleaning (ময়লার বিল)',
    'Repair & Maintenance (মেরামত)',
    'Other Extra (অন্যান্য অতিরিক্ত বিল)',
  ];

  // Payment Methods
  static const List<String> paymentMethods = [
    'Cash (নগদ)',
    'bKash (বিকাশ)',
    'Nagad (নগদ অ্যাপ)',
    'Rocket (রকেট)',
    'Bank (ব্যাংক ট্রান্সফার)',
    'Other (অন্যান্য)',
  ];

  // Extra Bill Distribution Types
  static const String distEqual = 'equal';
  static const String distSelected = 'selected';
  static const String distManual = 'manual';

  // SharedPreferences Keys
  static const String prefThemeKey = 'isDarkMode';
  static const String prefActiveMonthKey = 'activeMonth';
  static const String prefManagerUidKey = 'managerUid';
}

