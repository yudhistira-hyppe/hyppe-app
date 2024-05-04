import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:provider/provider.dart';

import '../notifier.dart';

class AlreadyReported extends StatelessWidget {
  const AlreadyReported({super.key});

  @override
  Widget build(BuildContext context) {
    final tn = context.read<TranslateNotifierV2>().translate;
    return Consumer<ViewStreamingNotifier>(builder: (context, notifier, _) {
      return DraggableScrollableSheet(
          expand: false,
          maxChildSize: .5,
          initialChildSize: .4,
          builder: (context, controller) {
            return Container(
              clipBehavior: Clip.antiAlias,
              padding: const EdgeInsets.symmetric(horizontal: 22.0),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16.0),
                  topRight: Radius.circular(16.0),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  FractionallySizedBox(
                    widthFactor: 0.15,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: 12.0,
                      ),
                      child: Container(
                        height: 5.0,
                        decoration: const BoxDecoration(
                          color: kHyppeBurem,
                          borderRadius: BorderRadius.all(Radius.circular(2.5)),
                        ),
                      ),
                    ),
                  ),
                  fifteenPx,
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: FadeInImage(
                      image: NetworkImage(System().showUserPicture(
                              notifier.reportdata?.avatar?.mediaEndpoint ??
                                  '') ??
                          ''),
                      placeholder: const AssetImage(
                          '${AssetPath.pngPath}profile-error.jpg'),
                      width: 36 * SizeConfig.scaleDiagonal,
                      height: 36 * SizeConfig.scaleDiagonal,
                      imageErrorBuilder: (BuildContext context,
                          Object exception, StackTrace? stackTrace) {
                        return Image.asset(
                            '${AssetPath.pngPath}profile-error.jpg',
                            fit: BoxFit.fitWidth,
                            width: 36 * SizeConfig.scaleDiagonal,
                      height: 36 * SizeConfig.scaleDiagonal,
                            );
                      },
                      fit: BoxFit.cover,
                    ),
                  ),
                  fifteenPx,
                  const Divider(
                    color: kHyppeBurem,
                  ),
                  fifteenPx,
                  RichText(
                    text: TextSpan(
                        style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                        children: [
                          TextSpan(
                              text: tn.reportSubmittedLabel ?? 'Kamu sudah melaporkan LIVE '),
                          TextSpan(text: notifier.reportdata?.username)
                        ]),
                  ),
                  twentyFourPx,
                  Text(
                    tn.reportSubmittedLabel2 ?? 'Kami akan segera memberikan pembaruan mengenai status laporanmu.',
                    style: const TextStyle(
                      color: kHyppeBurem,
                      // fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  fortyPx,
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        backgroundColor: kHyppePrimary),
                    child: SizedBox(
                      width: double.infinity,
                      height: kToolbarHeight,
                      child: Center(
                        child: Text(tn.understand ?? 'Mengerti',
                            textAlign: TextAlign.center),
                      ),
                    ),
                  ),
                  tenPx,
                ],
              ),
            );
          });
    });
  }
}