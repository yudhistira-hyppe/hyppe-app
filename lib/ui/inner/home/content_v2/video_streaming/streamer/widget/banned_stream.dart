import 'package:flutter/material.dart';
import 'package:hyppe/core/arguments/general_argument.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/live_stream/banned_stream_model.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/appeal/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/appeal/pelanggaran_detail.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/streamer/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

class BannedStream extends StatelessWidget {
  final bool? mounted;
  const BannedStream({super.key, this.mounted});

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('id', null);
    var trans = context.read<TranslateNotifierV2>().translate;
    return Consumer<StreamerNotifier>(
      builder: (_, notifier, __) => SizedBox(
        height: SizeConfig.screenHeight,
        width: SizeConfig.screenWidth,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () {
                      notifier.destoryPusher();
                      Routing().moveBack();
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                twentyFourPx,
                GestureDetector(
                  onTap: () {
                    if (!(notifier.dataBanned?.statusAppeal ?? false)) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PelanggaranDetail(
                            data: notifier.dataBanned ?? BannedStreamModel(),
                          ),
                        ),
                      );
                    } else if (notifier.dataBanned?.statusApprove == 'WAITING_RESPONSE') {
                      context.read<AppealStreamNotifier>().dataBanned = notifier.dataBanned ?? BannedStreamModel();
                      notifier.destoryPusher();
                      Routing().moveReplacement(Routes.appealLiveSuccess, argument: GeneralArgument(isTrue: false));
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(color: kHyppeBorderDanger, borderRadius: BorderRadius.circular(4)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: kHyppeLightButtonText,
                        ),
                        eightPx,
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                                text: trans.localeDatetime == 'id'
                                    ? "Akunmu saat ini tidak dapat melakukan siaran LIVE karena telah melanggar Pedoman Komunitas Hyppe. "
                                    : "Your account currently restricted to go LIVE due to a violation of Hyppe`s Community Guidelines. ",
                                children: [
                                  TextSpan(
                                    text: trans.localeDatetime == 'id'
                                        ? "Penangguhan Live berlangsung selama ${notifier.dataBanned?.streamBannedMax} hari sejak ${System().dateFormatter(
                                            notifier.dataBanned?.streamBannedDate ?? '2024-01-01',
                                            10,
                                          )} WIB"
                                        : "The live streaming suspension will last for  ${notifier.dataBanned?.streamBannedMax} days from ${System().dateFormatter(
                                            notifier.dataBanned?.streamBannedDate ?? '2024-01-01',
                                            10,
                                          )} WIB.  ",
                                    style: const TextStyle(),
                                  ),
                                  if (!(notifier.dataBanned?.statusAppeal ?? false))
                                    TextSpan(
                                      text: trans.localeDatetime == 'id' ? "\nAjukan banding di sini" : "\nSubmit appeal here ",
                                      style: const TextStyle(decoration: TextDecoration.underline),
                                    ),
                                ]),
                          ),
                        ),
                        if ((!(notifier.dataBanned?.statusAppeal ?? false))) eightPx,
                        if ((!(notifier.dataBanned?.statusAppeal ?? false)))
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: kHyppeLightButtonText,
                          )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
