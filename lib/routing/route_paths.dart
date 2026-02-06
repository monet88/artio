class RoutePaths {
  RoutePaths._();

  // Main navigation
  static const String home = '/home';
  static const String create = '/create';
  static const String gallery = '/gallery';
  static const String settings = '/settings';

  // Auth
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Template engine
  static const String templateDetail = '/template/:id';
  static String templateDetailPath(String id) => '/template/$id';

  // Gallery
  static const String galleryImage = '/gallery/image';

  // Splash
  static const String splash = '/';
}
