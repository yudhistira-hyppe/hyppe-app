import 'package:hyppe/core/models/collection/user_v2/sign_in/sign_in_data.dart';

class SignIn {
  SignInData? data;

  SignIn({this.data});

  SignIn.fromJson(Map<String, dynamic> json) {
    data = SignInData.fromJson(json);
  }
}