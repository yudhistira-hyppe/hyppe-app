import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/live_stream/banned_stream_model.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/leaderboard/widget/button_challange.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/appeal/appeal_screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/appeal/notifier.dart';
import 'package:provider/provider.dart';

class PelanggaranDetail extends StatefulWidget {
  final BannedStreamModel data;
  const PelanggaranDetail({super.key, required this.data});

  @override
  State<PelanggaranDetail> createState() => _PelanggaranDetailState();
}

class _PelanggaranDetailState extends State<PelanggaranDetail> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        context.read<AppealStreamNotifier>().dataBanned = widget.data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final translate = Provider.of<TranslateNotifierV2>(context, listen: false).translate;
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(
          color: kHyppeTextLightPrimary,
        ),
        title: CustomTextWidget(
          textStyle: Theme.of(context).textTheme.subtitle1?.copyWith(color: kHyppeTextLightPrimary),
          textToDisplay: translate.localeDatetime == 'id' ? 'Detail Pelanggaran' : 'Violation Detail',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          top: 28.0,
          left: 16,
          right: 16,
          bottom: 28,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            topDetail(context, translate),
            const Spacer(),
            bottomDetail(context, translate),
          ],
        ),
      ),
    );
  }

  Widget topDetail(BuildContext context, LocalizationModelV2 translate) {
    final dataProfile = context.read<SelfProfileNotifier>().user.profile;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextWidget(
          textToDisplay: translate.localeDatetime == 'id' ? 'Pelanggaran pedoman komunitas kami' : 'Community guidelines violation',
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: kHyppeTextLightPrimary),
        ),
        eightPx,
        CustomTextWidget(
          textToDisplay: translate.localeDatetime == 'id' ? 'Temukan Pedoman Komunitas kami di aplikasi Hyppe.' : 'Discover our Community Guidelines in the Hyppe app.',
          textStyle: const TextStyle(color: kHyppeBurem),
        ),
        sixteenPx,
        const Divider(),
        twentyFourPx,
        textTwo(
          translate.localeDatetime == 'id' ? 'Username' : 'Username',
          dataProfile?.username ?? '',
        ),
        twentyPx,
        textTwo(
          translate.localeDatetime == 'id' ? 'Waktu Pelanggaran' : 'Time of Violation',
          '${widget.data.streamBannedDate ?? '-'} WIB',
        ),
        twentyPx,
        textTwo(
          translate.localeDatetime == 'id' ? 'Jumlah Pelanggaran' : 'Number of Violations',
          '${widget.data.streamBannedMax ?? '-'} kali',
        ),
      ],
    );
  }

  Widget textTwo(String text1, String text2) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomTextWidget(
          textToDisplay: text1,
          textStyle: const TextStyle(color: kHyppeTextLightPrimary, fontWeight: FontWeight.w700),
        ),
        CustomTextWidget(
          textToDisplay: text2,
          textStyle: const TextStyle(color: kHyppeTextLightPrimary),
        ),
      ],
    );
  }

  Widget bottomDetail(BuildContext context, LocalizationModelV2 translate) {
    return ButtonChallangeWidget(
      bgColor: kHyppePrimary,
      text: translate.localeDatetime == 'id' ? 'Ajukan Permohonan Banding' : 'Submit an Appeal',
      textColors: Colors.white,
      function: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AppealStreamingScreen(),
            ));
        // Navigator.push(context, MaterialPageRoute(builder: (context) => AppealStreamingScreen()));
      },
    );
  }
}