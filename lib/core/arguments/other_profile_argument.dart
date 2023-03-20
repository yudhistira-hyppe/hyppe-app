import 'package:hyppe/core/arguments/contents/content_screen_argument.dart';

import '../models/collection/user_v2/profile/user_profile_model.dart';

class OtherProfileArgument extends ContentScreenArgument {
  String? senderEmail;
  UserProfileModel? profile;
  bool? fromLanding;

  OtherProfileArgument({this.senderEmail, this.profile, this.fromLanding = false});
}
