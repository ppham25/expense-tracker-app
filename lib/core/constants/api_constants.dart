import 'package:flutter/foundation.dart';

// class ApiConstants {
//   static String get baseUrl {
//     if (kIsWeb) {
//       return 'http://localhost:5000';
//     }

//     if (defaultTargetPlatform == TargetPlatform.android) {
//       return 'http://10.0.2.2:5000';
//     }

//     return 'http://localhost:5000';
//   }

//   static String get authBase => '$baseUrl/api/auth';
// }

class ApiConstants {
  static const String baseUrl = 'http://192.168.68.109:5000';

  static String get authBase => '$baseUrl/api/auth';
}
