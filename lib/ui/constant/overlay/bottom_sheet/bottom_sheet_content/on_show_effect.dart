import 'dart:io';
import 'package:hyppe/core/config/env.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/effect/effect_model.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/ui/constant/entities/camera/notifier.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:provider/provider.dart';

class OnShowEffect extends StatelessWidget {
  const OnShowEffect({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var token = SharedPreference().readStorage(SpKeys.userToken);
    var email = SharedPreference().readStorage(SpKeys.email);

    return Consumer<CameraNotifier>(
      builder: (context, notifier, child) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(12),
            topLeft: Radius.circular(12),
          ),
        ),
        child: Column(
          children: [
            sixteenPx,
            Container(
              height: 4,
              width: 36,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
            sixteenPx,
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Wrap(
                    children: [
                      for (EffectModel effect in notifier.effects)
                        renderEffect(
                          context,
                          notifier: notifier,
                          effect: effect,
                          email: email,
                          token: token,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget renderEffect(
    BuildContext context, {
    required CameraNotifier notifier,
    required EffectModel effect,
    required String token,
    required String email,
  }) {
    var filePath = '${notifier.effectPath}${Platform.pathSeparator}${effect.fileAssetName}';
    return InkWell(
      onTap: () {
        if(notifier.selectedEffect == effect){
          notifier.selectedEffect = null;
          notifier.notUseEffect(context);
        }else{
          notifier.selectedEffect = effect;
          notifier.setDeepAREffect(context, effect);
        }

      },
      child: Container(
        width: (MediaQuery.of(context).size.width - 24) / 3,
        height: (MediaQuery.of(context).size.width - 24) / 3,
        padding: const EdgeInsets.all(4),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: notifier.selectedEffect == effect ? Border.all(color: kHyppePrimary, width: 2) : Border.all(color: Colors.transparent, width: 2),
            borderRadius: BorderRadius.circular(12),
            color: Colors.black.withOpacity(0.2),
          ),
          child: Column(
            children: [
              Flexible(
                child: Stack(
                  children: [
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: FutureBuilder<bool>(
                            initialData: false,
                            future: File(filePath).exists(),
                            builder: (context, snapshot) {
                              print(filePath);
                              print(snapshot.data);
                              if (snapshot.data == true) {
                                return Image.network(
                                  '${Env.data.baseUrl}/api/assets/filter/image/thumb/${effect.postID}?x-auth-user=$email&x-auth-token=$token',
                                );
                              }
                              return Image.network(
                                '${Env.data.baseUrl}/api/assets/filter/image/thumb/${effect.postID}?x-auth-user=$email&x-auth-token=$token',
                                color: Colors.black45,
                                colorBlendMode: BlendMode.darken,
                              );
                            }),
                      ),
                    ),
                    if (notifier.selectedEffect == effect && notifier.isDownloadingEffect) const CustomLoading()
                  ],
                ),
              ),
              eightPx,
              CustomTextWidget(
                textToDisplay: effect.namafile ?? '',
                textStyle: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        // child:
        //     (notifier.selectedEffect == effect && notifier.isDownloadingEffect)
        //         ? const CustomLoading()
        //         : Container(),
      ),
    );
  }
}
