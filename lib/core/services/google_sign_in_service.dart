import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService {
  GoogleSignInService._private();

  static final GoogleSignInService _instance = GoogleSignInService._private();

  factory GoogleSignInService() {
    return _instance;
  }

  static final GoogleSignIn _gAuthInstance = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );

  Future<GoogleSignInAccount?> handleSignIn(BuildContext context) async {
    try {
      final _googleAccountInfo = await _gAuthInstance.signIn();

      if (_googleAccountInfo?.id == null) {
        _showAlert(context, 'Canceled');
        return null;
      }

      return _googleAccountInfo;
    } catch (error) {
      error.logger();
      _showAlert(context, error);
    }
  }

  void onCurrentUserChanged({required Function(GoogleSignInAccount? account) onChange}) => _gAuthInstance.onCurrentUserChanged.listen((GoogleSignInAccount? account) => onChange(account));

  Future<void> handleSignOut() async {
    await _gAuthInstance.isSignedIn().then((value) {
      if (value) _gAuthInstance.disconnect();
      _gAuthInstance.signOut();
    });
  }

  void _showAlert(BuildContext context, msg) {
    ShowBottomSheet().onShowColouredSheet(
      context,
      msg.toString(),
      maxLines: null,
      textOverflow: TextOverflow.visible,
      color: Theme.of(context).colorScheme.error,
      iconSvg: "${AssetPath.vectorPath}close.svg",
    );
  }
}
