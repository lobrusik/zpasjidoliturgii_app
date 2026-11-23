import 'package:flutter/foundation.dart' show kIsWeb;

class AdConfig {
  static bool get showWebAds {
    if (!kIsWeb) return false;
    final host = Uri.base.host.toLowerCase();
    return host == 'aplikacja.zpasjidoliturgii.pl' ||
           host == 'www.aplikacja.zpasjidoliturgii.pl';
  }
  static bool get showMobileAds => !kIsWeb;
}