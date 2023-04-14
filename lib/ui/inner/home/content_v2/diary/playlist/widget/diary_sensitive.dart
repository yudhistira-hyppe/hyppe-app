import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/app.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/entities/report/notifier.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class DiarySensitive extends StatefulWidget {
  final ContentData? data;
  final Function()? function;
  const DiarySensitive({Key? key, this.data, this.function}) : super(key: key);

  @override
  State<DiarySensitive> createState() => _DiarySensitiveState();
}

class _DiarySensitiveState extends State<DiarySensitive> {
  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'DiarySensitive');
    return SafeArea(
        child: SizedBox(
      width: SizeConfig.screenWidth,
      child: Consumer<TranslateNotifierV2>(
        builder: (context, transnot, child) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Spacer(),
              const CustomIconWidget(
                iconData: "${AssetPath.vectorPath}eye-off.svg",
                defaultColor: false,
                height: 30,
                color: Colors.white,
              ),
              Text(transnot.translate.sensitiveContent ?? 'Sensitive Content', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
              Text("HyppeDiary ${transnot.translate.contentContainsSensitiveMaterial}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  )),
              widget.data?.email == SharedPreference().readStorage(SpKeys.email)
                  ? GestureDetector(
                      onTap: () => Routing().move(Routes.appeal, argument: widget.data),
                      child: Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.all(18),
                          decoration: BoxDecoration(border: Border.all(color: Colors.white), borderRadius: BorderRadius.circular(10)),
                          child: Text(transnot.translate.appealThisWarning ?? 'Appeal This Warning', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600))),
                    )
                  : const SizedBox(),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  if (globalAliPlayer != null) {
                    globalAliPlayer?.prepare();
                    globalAliPlayer?.play();
                  }

                  if (widget.function != null) {
                    widget.function!();
                  }

                  context.read<ReportNotifier>().seeContent(context, widget.data ?? ContentData(), hyppeDiary);
                },
                child: Container(
                  padding: const EdgeInsets.only(top: 8),
                  margin: const EdgeInsets.all(8),
                  width: SizeConfig.screenWidth,
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Colors.white,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Text(
                    "${transnot.translate.see} HyppeDiary",
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              thirtyTwoPx,
            ],
          ),
        ),
      ),
    ));
  }
}
