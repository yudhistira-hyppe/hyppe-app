import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyppe/app.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_cache_image.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/appeal/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class AppealSuccessStreamingScreen extends StatefulWidget {
  const AppealSuccessStreamingScreen({Key? key}) : super(key: key);

  @override
  State<AppealSuccessStreamingScreen> createState() => _AppealSuccessStreamingScreenState();
}

class _AppealSuccessStreamingScreenState extends State<AppealSuccessStreamingScreen> {
  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final translate = Provider.of<TranslateNotifierV2>(context, listen: false).translate;
    return Consumer<AppealStreamNotifier>(
      builder: (_, notifier, __) => WillPopScope(
        onWillPop: () async {
          if (globalAliPlayer != null) {
            globalAliPlayer?.play();
          }
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            // leading: const BackButton(),
            title: CustomTextWidget(
              textStyle: Theme.of(context).textTheme.titleMedium,
              textToDisplay: translate.localeDatetime == 'id' ? 'Pengajuan Banding' : 'Violation Details',
            ),

            automaticallyImplyLeading: false,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Icon(
                    Icons.check_circle_outline_rounded,
                    color: kHyppeTextSuccess,
                    size: 40,
                  ),
                ),
                sixteenPx,
                Center(
                  child: CustomTextWidget(
                    textToDisplay: translate.localeDatetime == 'id' ? 'Pengajuan banding dikirim' : 'Appeal submitted',
                    textStyle: Theme.of(context).primaryTextTheme.titleMedium,
                  ),
                ),
                twelvePx,
                RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: Theme.of(context).textTheme.titleSmall,
                      text: translate.localeDatetime == 'id'
                          ? 'Kami akan mengirimkan notifikasi untuk update status pengajuan bandingmu.'
                          : 'We will send you a notification as soon as we have an update.',
                    )),
                twentyFourPx,
                detailContent(context, translate),
                const Spacer(),
                twentyEightPx,
                SizedBox(
                  width: SizeConfig.screenWidth,
                  height: 50,
                  child: CustomTextButton(
                    onPressed: () {
                      Routing().moveAndRemoveUntil(Routes.lobby, Routes.root);
                    },
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all(kHyppePrimary)),
                    child: notifier.loadingAppel
                        ? const CustomLoading()
                        : CustomTextWidget(
                            textToDisplay: translate.localeDatetime == 'id' ? 'Kembali Keberanda' : 'Back to Home',
                            textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(color: kHyppeLightButtonText),
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

  Widget detailContent(BuildContext context, LocalizationModelV2 translate) {
    var profile = context.read<SelfProfileNotifier>().user.profile;
    var data = context.read<AppealStreamNotifier>().dataBanned;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  translate.localeDatetime == 'id' ? 'Detail Konten' : 'Content Details',
                  style: Theme.of(context).primaryTextTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                  textAlign: TextAlign.start,
                ),
                sixPx,
                Text(
                  "${translate.localeDatetime == 'id' ? 'LIVE pada' : 'LIVE on'}   ${System().dateFormatter(data.streamBannedDate ?? '2024-01-01', 11) ?? '-'} WIB",
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.start,
                ),
              ],
            )),
            const SizedBox(width: 10),
            CustomCacheImage(
              imageUrl: profile?.avatar == null ? '' : System().showUserPicture(profile?.avatar?.mediaEndpoint),
              imageBuilder: (_, imageProvider) {
                return Container(
                  width: 48 * SizeConfig.scaleDiagonal,
                  height: 48 * SizeConfig.scaleDiagonal,
                  alignment: Alignment.topRight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                  ),
                );
              },
              errorWidget: (_, __, ___) {
                return Container(
                  width: 48 * SizeConfig.scaleDiagonal,
                  height: 48 * SizeConfig.scaleDiagonal,
                  alignment: Alignment.topRight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    image: const DecorationImage(
                      fit: BoxFit.contain,
                      image: AssetImage('${AssetPath.pngPath}profile-error.jpg'),
                    ),
                  ),
                );
              },
              emptyWidget: Container(
                width: 48 * SizeConfig.scaleDiagonal,
                height: 48 * SizeConfig.scaleDiagonal,
                alignment: Alignment.topRight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  image: const DecorationImage(
                    fit: BoxFit.contain,
                    image: AssetImage('${AssetPath.pngPath}profile-error.jpg'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
