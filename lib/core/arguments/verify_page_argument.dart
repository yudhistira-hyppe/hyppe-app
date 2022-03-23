import 'package:hyppe/core/constants/enum.dart';

class VerifyPageArgument {
  String? otp;
  VerifyPageRedirection redirect;

  VerifyPageArgument({
    this.otp,
    required this.redirect,
  });
}
