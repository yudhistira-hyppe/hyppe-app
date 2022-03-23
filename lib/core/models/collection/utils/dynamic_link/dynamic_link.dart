import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/services/shared_preference.dart';

class DynamicLinkData {
  String routes;
  String? thumb;
  String? postID;
  String? fullName;
  String? description;

  final String email;

  DynamicLinkData({
    required this.thumb,
    required this.routes,
    required this.postID,
    required this.fullName,
    required this.description,
  }) : email = SharedPreference().readStorage(SpKeys.email);
}
