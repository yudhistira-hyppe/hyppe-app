import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

import '../notifier.dart';

class ResponsReportLive extends StatelessWidget {
  const ResponsReportLive({super.key});

  @override
  Widget build(BuildContext context) {
    final tn = context.read<TranslateNotifierV2>().translate;
    return Consumer<ViewStreamingNotifier>(
      builder: (context, notifier, _) {
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
                    CustomIconWidget(
                      iconData: "${AssetPath.vectorPath}celebrity.svg",
                      defaultColor: false,
                      width: MediaQuery.of(context).size.width * .15,
                      height: MediaQuery.of(context).size.width * .15,
                    ),
                    tenPx,
                    const Text(
                      'Laporan diterima',
                      style: TextStyle(
                          color: kHyppeBurem,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    tenPx,
                    const Text(
                      'Kami akan meninjau laporanmu dan mengambil tindakan jika ditemukan pelanggaran.',
                      style: TextStyle(
                        color: kHyppeBurem,
                        // fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    sixteenPx,
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Fluttertoast.showToast(msg: tn.reportSubmitted ?? 'Laporan terkirim', backgroundColor: Colors.black54);
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
                          child:
                              Text(tn.keepWatching ?? 'Lanjut Nonton', textAlign: TextAlign.center),
                        ),
                      ),
                    ),
                    fivePx,
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        context.read<ViewStreamingNotifier>().exitStreaming(context, notifier.reportdata!).whenComplete(() async {
                          // await context.read<ViewStreamingNotifier>().destoryPusher();
                          notifier.destoryPusher();
                          Routing().moveBack();
                          Future.delayed(const Duration(milliseconds: 300),(){
                            Routing().moveBack();
                            Fluttertoast.showToast(msg: tn.reportSubmitted ?? 'Laporan terkirim', backgroundColor: Colors.black54);
                          });
                        });
                      },
                      style: ElevatedButton.styleFrom(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          backgroundColor: Colors.white),
                      child: SizedBox(
                        width: double.infinity,
                        height: kToolbarHeight,
                        child: Center(
                          child:
                              Text(tn.exitLive ?? 'Keluar Live', textAlign: TextAlign.center, style: const TextStyle(color: Colors.black),),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            });
      }
    );
  }
}