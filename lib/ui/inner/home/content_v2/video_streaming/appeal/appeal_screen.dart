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
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/appeal/notifier.dart';
import 'package:provider/provider.dart';

class AppealStreamingScreen extends StatefulWidget {
  const AppealStreamingScreen({Key? key}) : super(key: key);

  @override
  State<AppealStreamingScreen> createState() => _AppealStreamingScreenState();
}

class _AppealStreamingScreenState extends State<AppealStreamingScreen> {
  TextEditingController noteCtrl = TextEditingController();

  List appealReaseonData = [
    {
      'id': 1,
      'title': 'Siaran LIVE ini tidak mengandung konten sensitif',
      'titleEn': 'This LIVE video contains no sensitive content',
      'desc': 'Konten ini tidak mengandung unsur telanjang, seksual, kekerasan, sadis, atau simbol kebencian lainnya.',
      'descEn': 'This content does not contain nudity, sexual elements, violence, cruelty, or any other hate symbols.',
    },
    {
      'id': 2,
      'title': 'Siaran LIVE ini memiliki konteks tambahan',
      'titleEn': 'This LIVE video has additional context',
      'desc': 'Konten memiliki konteks khusus tanpa tujuan melanggar merasa pedoman.',
      'descEn': 'The content has specific context without an intention to violate our guidelines.',
    },
    {
      'id': 3,
      'title': 'Lainnya',
      'titleEn': 'Other',
      'desc':
          'Alasan lainnya yang tidak termasuk dalam kategori di atas. Mohon tambahkan deskripsi lebih rinci di bawah ini untuk membantu kami memahami lebih baik mengapa kamu merasa kontennya tidak melanggar pedoman.',
      'descEn':
          'Other reasons not covered in the above categories. Please provide a detailed description below to help us better understand why you believe the content doesn`t violate our guidelines.',
    },
  ];

  int appealSelect = 0;

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
            leading: const BackButton(),
            title: CustomTextWidget(
              textStyle: Theme.of(context).textTheme.titleMedium,
              textToDisplay: translate.localeDatetime == 'id' ? 'Pengajuan Banding' : 'Violation Details',
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: CustomIconWidget(
                      height: 40,
                      iconData: "${AssetPath.vectorPath}report.svg",
                      color: Colors.red,
                      defaultColor: false,
                    ),
                  ),
                  sixteenPx,
                  Center(
                    child: CustomTextWidget(
                      textToDisplay: translate.localeDatetime == 'id' ? 'Akunmu ditangguhkan melakukan LIVE' : 'Account suspended',
                      textStyle: Theme.of(context).primaryTextTheme.titleMedium,
                    ),
                  ),
                  twelvePx,
                  RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: Theme.of(context).textTheme.titleSmall,
                        text: translate.localeDatetime == 'id'
                            ? 'Kamu dianggap telah melanggar terhadap Pedoman Komunitas kami.'
                            : 'Your account has been suspended from going LIVE due to violations of our Community Guidelines.',
                      )),
                  twentyFourPx,
                  detailContent(context, translate),
                  twentyFourPx,
                  const Divider(
                    color: kHyppeBorderTab,
                    thickness: 1,
                  ),
                  twentyFourPx,
                  Text(
                    translate.localeDatetime == 'id' ? 'Banding' : 'Appeal',
                    style: Theme.of(context).primaryTextTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  twentyPx,
                  Text(translate.localeDatetime == 'id'
                      ? 'Akunmu ditangguhkan untuk melakukan siaran LIVE karena melanggar Pedoman Komunitas kami. Untuk mengajukan banding, sertakan deskripsi masalah di bawah ini. '
                      : 'Your account has been suspended from going LIVE due to violations of our Community Guidelines. To file an appeal, please provide a detailed description below.'),
                  twentyPx,
                  const Divider(
                    color: kHyppeBorderTab,
                    thickness: 1,
                  ),
                  twentyPx,
                  Row(
                    children: [
                      Text(
                        translate.localeDatetime == 'id' ? 'Pilih alasan banding' : 'Select an appeal reason',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '*',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                    ],
                  ),
                  twelvePx,
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: appealReaseonData.length,
                    itemBuilder: (context, index) {
                      var data = appealReaseonData[index];
                      return RadioListTile<int>(
                        groupValue: appealSelect,
                        value: appealReaseonData[index]['id'],
                        onChanged: (val) {
                          if (mounted) {
                            setState(() {
                              appealSelect = val ?? 1;
                            });
                          }
                        },
                        title: Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: CustomTextWidget(
                            textAlign: TextAlign.left,
                            textToDisplay: translate.localeDatetime == 'id' ? data['title'] : data['titleEn'],
                            textStyle: Theme.of(context).primaryTextTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        subtitle: CustomTextWidget(
                          textAlign: TextAlign.left,
                          textToDisplay: translate.localeDatetime == 'id' ? data['desc'] : data['descEn'],
                          textStyle: Theme.of(context).textTheme.labelMedium,
                          maxLines: 5,
                        ),
                        activeColor: Theme.of(context).colorScheme.primary,
                        contentPadding: const EdgeInsets.only(bottom: 8),
                      );
                    },
                  ),
                  fortyTwoPx,
                  Text(
                    translate.localeDatetime == 'id' ? 'Deskripsikan masalahmu' : 'Describe your issue',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(),
                  ),
                  eightPx,
                  Container(
                      width: SizeConfig.screenWidth,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: kHyppeLightSurface,
                          border: Border.all(
                            color: kHyppeBorderTab,
                          )),
                      child: TextFormField(
                        keyboardType: TextInputType.text,
                        controller: noteCtrl,
                        textAlignVertical: TextAlignVertical.top,
                        textAlign: TextAlign.left,
                        style: const TextStyle(fontSize: 13, color: kHyppeTextLightPrimary),
                        cursorColor: kHyppeBurem,
                        buildCounter: (context, {required currentLength, required isFocused, maxLength}) {
                          return Container(
                            transform: Matrix4.translationValues(0, -125, 0),
                            child: Text(
                              "$currentLength/$maxLength",
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(),
                            ),
                          );
                        },
                        maxLength: 80,
                        minLines: 5,
                        maxLines: 10,
                        decoration: InputDecoration(
                          alignLabelWithHint: false,
                          isCollapsed: true,
                          hintText: translate.localeDatetime == 'id' ? 'Mohon berikan rincian tambahan' : 'Please provide additional details',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.only(),
                          hintStyle: const TextStyle(fontSize: 13, color: kHyppeBurem),
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      )),
                  twentyEightPx,
                  SizedBox(
                    width: SizeConfig.screenWidth,
                    height: 50,
                    child: CustomTextButton(
                      onPressed: notifier.loadingAppel
                          ? null
                          : appealSelect == 0
                              ? null
                              : () {
                                  print(appealSelect);
                                  notifier.submitAppeal(context, mounted, appealReaseonData[appealSelect - 1]['title'], noteCtrl.text);
                                },
                      style: ButtonStyle(backgroundColor: appealSelect == 0 ? MaterialStateProperty.all(kHyppeDisabled) : MaterialStateProperty.all(kHyppePrimary)),
                      child: notifier.loadingAppel
                          ? const CustomLoading()
                          : CustomTextWidget(
                              textToDisplay: translate.submit ?? '',
                              textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(color: kHyppeLightButtonText),
                            ),
                    ),
                  ),
                ],
              ),
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
                  "${translate.localeDatetime == 'id' ? 'LIVE pada' : 'LIVE on'}  ${data.streamBannedDate ?? '-'} WIB",
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
                    borderRadius: BorderRadius.circular(5),
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
                  borderRadius: BorderRadius.circular(5),
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
