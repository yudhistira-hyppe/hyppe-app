import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/kyc_status.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/services/shared_preference.dart';

class ButtonBoost extends StatelessWidget {
  const ButtonBoost({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _isKyc = SharedPreference().readStorage(SpKeys.statusVerificationId);
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: _isKyc == VERIFIED ? kHyppePrimary : kHyppeDisabled,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: _isKyc == VERIFIED ? () {} : null,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              width: SizeConfig.screenWidth,
              child: Text(
                'Boost',
                style: Theme.of(context).primaryTextTheme.subtitle2?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
