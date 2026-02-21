/// Application-wide constants
class AppConstants {
  AppConstants._();

  // Deep linking
  static const String appScheme = 'com.artio.app';
  static const String loginCallback = '$appScheme://login-callback';
  static const String resetPasswordCallback = '$appScheme://reset-password';

  // User defaults
  static const int defaultCredits = 5;
  static const int dailyFreeLimit = 5;

  // Ad rewards
  static const int dailyAdLimit = 10;
  static const int adRewardCredits = 5;

  // Generation
  static const List<String> aspectRatios = [
    '1:1',
    '4:3',
    '3:4',
    '16:9',
    '9:16',
  ];
  static const String defaultAspectRatio = '1:1';
  static const int maxPromptLength = 1000;

  // Template categories - must match database migration
  static const List<String> templateCategories = [
    'Portrait & Face Effects',
    'Removal & Editing',
    'Art Style Transfer',
    'Photo Enhancement',
    'Creative & Fun',
  ];
}
