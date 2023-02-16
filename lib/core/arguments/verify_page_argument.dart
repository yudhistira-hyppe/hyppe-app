import 'package:hyppe/core/constants/enum.dart';

class VerifyPageArgument {
  String? otp;
  String email;
  VerifyPageRedirection redirect;

  VerifyPageArgument({
    this.otp,
    required this.email,
    required this.redirect,
  });
}
