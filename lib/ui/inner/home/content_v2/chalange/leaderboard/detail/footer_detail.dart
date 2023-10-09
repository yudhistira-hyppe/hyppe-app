import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyppe/app.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/chalange/leaderboard_challange_model.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/show_general_dialog.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/leaderboard/widget/button_challange.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/notifier.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart';
import 'package:hyppe/ui/inner/main/notifier.dart';
import 'package:hyppe/ui/inner/upload/make_content/notifier.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class FooterChallangeDetail extends StatefulWidget {
  const FooterChallangeDetail({super.key});

  @override
  State<FooterChallangeDetail> createState() => _FooterChallangeDetailState();
}

class _FooterChallangeDetailState extends State<FooterChallangeDetail> {
  @override
  Widget build(BuildContext context) {
    var tn = context.read<TranslateNotifierV2>();

    return Consumer<ChallangeNotifier>(
      builder: (_, cn, __) {
        bool twoWidget = false;
        var challengeData = cn.leaderBoardDetailData?.challengeData?[0];
        if (challengeData?.objectChallenge == "AKUN") {
          if (challengeData?.metrik?[0].aktivitasAkun?.isNotEmpty ?? [].isEmpty) {
            if ((challengeData?.metrik?[0].aktivitasAkun?[0].ikuti ?? 0) > 0 && (challengeData?.metrik?[0].aktivitasAkun?[0].referal ?? 0) > 0) {
              twoWidget = true;
            }
          }
          if (challengeData?.metrik?[0].interaksiKonten?.isNotEmpty ?? [].isEmpty) {
            var dataChallange = challengeData?.metrik?[0].interaksiKonten;
            var suka = dataChallange?[0].suka;
            var tonton = dataChallange?[0].tonton;
            var buatKonten = dataChallange?[0].buatKonten;

            int sukaHyppe = (suka?[0].hyppeDiary ?? 0) > 0 || (suka?[0].hyppePic ?? 0) > 0 || (suka?[0].hyppeVid ?? 0) > 0 ? 1 : 0;
            int tontonHyppe = (tonton?[0].hyppeDiary ?? 0) > 0 || (tonton?[0].hyppeVid ?? 0) > 0 ? 1 : 0;
            int buatHyppe = (buatKonten?[0].hyppeDiary ?? 0) > 0 || (buatKonten?[0].hyppePic ?? 0) > 0 || (buatKonten?[0].hyppeVid ?? 0) > 0 ? 1 : 0;
            int tot = ((sukaHyppe > 0) || (tontonHyppe > 0) ? 1 : 0) + buatHyppe;
            if (tot == 2) {
              twoWidget = true;
            }
          }
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            accountActivity(context, tn, cn),
            Divider(
              color: kHyppeLightSurface,
              thickness: twoWidget == true ? 4.0 : 0,
            ),
            twoWidget ? accountActivity(context, tn, cn, widgetTwo: true) : Container(),
          ],
        );
      },
    );
  }

  Widget accountActivity(BuildContext context, TranslateNotifierV2 tn, ChallangeNotifier cn, {bool widgetTwo = false}) {
    String titleText = "";
    String buttonText = "";
    bool referral = false;
    Color bgColor = kHyppePrimary;
    Color textColors = kHyppeLightButtonText;
    String referralLink = '';
    var challengeData = cn.leaderBoardDetailData?.challengeData?[0];
    if (widgetTwo) {
      if (challengeData?.objectChallenge == "AKUN") {
        if (challengeData?.metrik?[0].aktivitasAkun?.isNotEmpty ?? [].isEmpty) {
          titleText = "${tn.translate.followMostHyppeAccountsToWinTheCompetition}"; //Ikuti akun - akun TerhHyppe untuk memenangkan kompetisi
          buttonText = "${tn.translate.exploreAndFollowtheHyppeAccountsHere}"; //Jelajahi dan Ikuti Akun Terhyppe disini!";
        }
      }
      if (challengeData?.metrik?[0].interaksiKonten?.isNotEmpty ?? [].isEmpty) {
        if (((challengeData?.metrik?[0].interaksiKonten?[0].suka?.isNotEmpty ?? [].isEmpty) || (challengeData?.metrik?[0].interaksiKonten?[0].tonton?.isNotEmpty ?? [].isEmpty)) &&
            (challengeData?.metrik?[0].interaksiKonten?[0].buatKonten?.isNotEmpty ?? [].isEmpty)) {
          titleText = "${tn.translate.uploadasmuchcontentaspossibletowinthechallenge}"; //Unggah konten sebanyak mungkin untuk menangin challenge nya!";
          buttonText = "${tn.translate.uploadInterestingContentHere}"; //Unggah Konten - Konten Menarik Disini!";
        }
      }
    } else {
      if (challengeData?.objectChallenge == "AKUN") {
        if (challengeData?.metrik?[0].aktivitasAkun?.isNotEmpty ?? [].isEmpty) {
          if ((challengeData?.metrik?[0].aktivitasAkun?[0].referal ?? 0) > 0) {
            titleText = "${tn.translate.joinandinviteyourfriendstoHyppenow}"; //Gabung dan undang temanmu ke Hyppe sekarang!";
            buttonText = "${tn.translate.viewQRCode}"; //Lihat QR Kode";
            bgColor = kHyppeLightButtonText;
            textColors = kHyppePrimary;
            referral = true;
          } else {
            titleText = "${tn.translate.followMostHyppeAccountsToWinTheCompetition}"; //"Ikuti akun - akun TerhHyppe untuk memenangkan kompetisi";
            buttonText = "${tn.translate.exploreAndFollowtheHyppeAccountsHere}"; // "Jelajahi dan Ikuti Akun Terhyppe disini!";
          }
        }
        if (challengeData?.metrik?[0].interaksiKonten?.isNotEmpty ?? [].isEmpty) {
          if (((challengeData?.metrik?[0].interaksiKonten?[0].suka?.isNotEmpty ?? [].isEmpty) || (challengeData?.metrik?[0].interaksiKonten?[0].tonton?.isNotEmpty ?? [].isEmpty)) &&
              (challengeData?.metrik?[0].interaksiKonten?[0].buatKonten?.isNotEmpty ?? [].isEmpty)) {
            titleText =
                "${tn.translate.comeonLikeandwatchasmuchinterestingcontentaspossibletowinthechallenge}"; //Yuk!! Like dan Tonton konten-konten menarik sebanyak mungkin untuk menangin challenge nya!";
            buttonText = "${tn.translate.exploreInterestingContentHere}"; //Jelajahi Konten - Konten Menarik Disini!";
            bgColor = kHyppeLightButtonText;
            textColors = kHyppePrimary;
          } else {
            if (challengeData?.metrik?[0].interaksiKonten?[0].suka?.isNotEmpty ?? [].isEmpty) {
              titleText = "${tn.translate.watchinterestingcontenthere}"; //Tonton konten-konten menarik disini!";
              buttonText = "${tn.translate.watchinterestingcontenthere}"; //"Tonton konten-konten menarik disini!";
              bgColor = kHyppeLightButtonText;
              textColors = kHyppePrimary;
            }
            if (challengeData?.metrik?[0].interaksiKonten?[0].tonton?.isNotEmpty ?? [].isEmpty) {
              titleText = "${tn.translate.likeHyppecontenthere}"; //Like konten-konten Hyppe disini!";
              buttonText = "${tn.translate.exploreInterestingContentHere}"; //"Jelajahi Konten - Konten Menarik Disini!";
              bgColor = kHyppeLightButtonText;
              textColors = kHyppePrimary;
            }
            if (challengeData?.metrik?[0].interaksiKonten?[0].buatKonten?.isNotEmpty ?? [].isEmpty) {
              var list = challengeData?.metrik?[0].interaksiKonten?[0].buatKonten;
              var hyppeDiary = list?[0].hyppeDiary ?? 0;
              var hyppePic = list?[0].hyppePic ?? 0;
              var hyppeVid = list?[0].hyppeVid ?? 0;
              var tot = hyppeDiary + hyppePic + hyppeVid;
              if (tot > 1) {
                titleText = "${tn.translate.joinanduploadyourbestideastoHyppenow}"; // Gabung dan unggah  ide terbaikmu ke Hyppe sekarang!";
                buttonText = "${tn.translate.postNow}"; // "Posting Sekarang";
              } else {
                titleText = "${tn.translate.joinanduploadyourbestideastoHyppenow}"; //Gabung dan unggah  ide terbaikmu ke Hyppe sekarang!";
                if (hyppePic >= 1) {
                  buttonText = "${tn.translate.postYourHyppePicNow}"; // ]Posting HyppePic Kamu Sekarang";
                }
                if (hyppeVid >= 1) {
                  buttonText = "${tn.translate.postYourHyppeVidNow}"; // "Posting HyppeVid Kamu Sekarang";
                }
                if (hyppeDiary >= 1) {
                  buttonText = "${tn.translate.postYourHyppeDiaryNow}"; // "Posting HyppeDiary Kamu Sekarang";
                }
              }
            }
          }
        }
      } else {
        var list = challengeData?.metrik?[0].interaksiKonten?[0];
        var hyppeDiary = ((list?.suka?[0].hyppeDiary ?? 0) >= 1 || (list?.tonton?[0].hyppeDiary ?? 0) >= 1 ? 1 : 0);
        var hyppePic = ((list?.suka?[0].hyppePic ?? 0) >= 1 ? 1 : 0);
        var hyppeVid = ((list?.suka?[0].hyppeVid ?? 0) >= 1 || (list?.tonton?[0].hyppeVid ?? 0) >= 1 ? 1 : 0);
        var tot = hyppeDiary + hyppePic + hyppeVid;
        titleText = "${tn.translate.takeonthechallengeanduploadyourbestideashere}"; //Ikuti challenge dan unggah ide terbaikmu disini!";
        textColors = kHyppeLightButtonText;

        if (tot > 1) {
          titleText = "${tn.translate.takeonthechallengeanduploadyourbestideashere}"; // "Ikuti challenge dan unggah ide terbaikmu disini!";
          buttonText = "${tn.translate.postNow}"; //"Posting Sekarang";
        } else {
          if (hyppePic >= 1) {
            buttonText = "${tn.translate.postYourHyppePicNow}"; // ]Posting HyppePic Kamu Sekarang";
          }
          if (hyppeVid >= 1) {
            buttonText = "${tn.translate.postYourHyppeVidNow}"; //"Posting HyppeVid Kamu Sekarang";
          }
          if (hyppeDiary >= 1) {
            buttonText = "${tn.translate.postYourHyppeDiaryNow}"; //"Posting HyppeDiary Kamu Sekarang";
          }
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titleText,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
          twelvePx,
          referral
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  margin: const EdgeInsets.only(bottom: 16),
                  height: 44.0,
                  decoration: BoxDecoration(
                    color: kHyppeLightSurface,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: CustomTextWidget(
                          textToDisplay: cn.referralLink,
                          textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: kHyppeLightSecondary,
                              ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: cn.referralLink));
                            ShowGeneralDialog.showToastAlert(
                              context,
                              '${tn.translate.referralCodeLinkCopiedSuccessfully}',
                              () async {},
                              title: "${tn.translate.copiedLinks}",
                            );
                            // ShowBottomSheet().onShowColouredSheet(context, "asd", maxLines: 2, color: kHyppeTextLightPrimary);
                          },
                          child: Container(
                            height: 24,
                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                            decoration: BoxDecoration(color: kHyppePrimary, borderRadius: BorderRadius.circular(8)),
                            child: Text(
                              tn.translate.copy ?? '',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Container(),
          ButtonChallangeWidget(
            text: buttonText,
            bgColor: bgColor,
            borderColor: kHyppePrimary,
            textColors: textColors,
            function: () {
              navigate(context, tn, cn, widgetTwo: widgetTwo);
            },
          ),
        ],
      ),
    );
  }

  void navigate(BuildContext context, TranslateNotifierV2 tn, ChallangeNotifier cn, {bool widgetTwo = false}) {
    var challengeData = cn.leaderBoardDetailData?.challengeData?[0];
    print("======navigate=======");
    print("${widgetTwo} ${challengeData?.objectChallenge}  ${challengeData?.metrik?[0].aktivitasAkun?.isNotEmpty}");
    if (widgetTwo) {
      if (challengeData?.objectChallenge == "AKUN") {
        if (challengeData?.metrik?[0].aktivitasAkun?.isNotEmpty ?? [].isEmpty) {
          Routing().moveBack();
          Routing().moveBack();
          // titleText = "Ikuti akun - akun TerhHyppe untuk memenangkan kompetisi";
          // buttonText = "Jelajahi dan Ikuti Akun Terhyppe disini!";
        } else {
          if (challengeData?.metrik?[0].interaksiKonten?.isNotEmpty ?? [].isEmpty) {
            if (((challengeData?.metrik?[0].interaksiKonten?[0].suka?.isNotEmpty ?? [].isEmpty) || (challengeData?.metrik?[0].interaksiKonten?[0].tonton?.isNotEmpty ?? [].isEmpty)) &&
                (challengeData?.metrik?[0].interaksiKonten?[0].buatKonten?.isNotEmpty ?? [].isEmpty)) {
              var interaksiData = challengeData?.metrik?[0].interaksiKonten?[0];
              if ((interaksiData?.buatKonten?[0].hyppeVid ?? 0) > 0 || (interaksiData?.buatKonten?[0].hyppeDiary ?? 0) > 0 || (interaksiData?.buatKonten?[0].hyppePic ?? 0) > 0) {
                onTapbuatKonten(interaksiKonten: challengeData?.metrik?[0].interaksiKonten?[0] ?? InteraksiKonten());
              }
            }
          }
        }
      }
    } else {
      if (challengeData?.objectChallenge == "AKUN") {
        if (challengeData?.metrik?[0].aktivitasAkun?.isNotEmpty ?? [].isEmpty) {
          if ((challengeData?.metrik?[0].aktivitasAkun?[0].referal ?? 0) > 0) {
            ShowBottomSheet.onQRCodeChallange(context);
          } else if ((challengeData?.metrik?[0].aktivitasAkun?[0].ikuti ?? 0) > 0) {
            Routing().moveBack();
            Routing().moveBack();
          }
        }
        if (challengeData?.metrik?[0].interaksiKonten?.isNotEmpty ?? [].isEmpty) {
          if (((challengeData?.metrik?[0].interaksiKonten?[0].suka?.isNotEmpty ?? [].isEmpty) || (challengeData?.metrik?[0].interaksiKonten?[0].tonton?.isNotEmpty ?? [].isEmpty)) &&
              (challengeData?.metrik?[0].interaksiKonten?[0].buatKonten?.isNotEmpty ?? [].isEmpty)) {
            var interaksiData = challengeData?.metrik?[0].interaksiKonten?[0];

            if ((interaksiData?.suka?[0].hyppePic ?? 0) > 0) {
              context.read<HomeNotifier>().tabIndex = 0;
              context.read<HomeNotifier>().initNewHome(context, mounted, isreload: false, isNew: true);
              Routing().moveAndRemoveUntil(Routes.lobby, Routes.root);
              return;
            } else if ((interaksiData?.suka?[0].hyppeDiary ?? 0) > 0) {
              context.read<HomeNotifier>().tabIndex = 1;
              context.read<HomeNotifier>().initNewHome(context, mounted, isreload: false, isNew: true);
              Routing().moveAndRemoveUntil(Routes.lobby, Routes.root);
              return;
            } else if ((interaksiData?.tonton?[0].hyppeDiary ?? 0) > 0) {
              context.read<HomeNotifier>().tabIndex = 1;
              context.read<HomeNotifier>().initNewHome(context, mounted, isreload: false, isNew: true);
              Routing().moveAndRemoveUntil(Routes.lobby, Routes.root);
              return;
            } else if ((interaksiData?.suka?[0].hyppeVid ?? 0) > 0) {
              context.read<HomeNotifier>().tabIndex = 2;
              context.read<HomeNotifier>().initNewHome(context, mounted, isreload: false, isNew: true);
              Routing().moveAndRemoveUntil(Routes.lobby, Routes.root);
              return;
            } else if ((interaksiData?.tonton?[0].hyppeVid ?? 0) > 0) {
              context.read<HomeNotifier>().tabIndex = 2;
              context.read<HomeNotifier>().initNewHome(context, mounted, isreload: false, isNew: true);
              Routing().moveAndRemoveUntil(Routes.lobby, Routes.root);
              return;
            } else if ((interaksiData?.buatKonten?[0].hyppeVid ?? 0) > 0 || (interaksiData?.buatKonten?[0].hyppeDiary ?? 0) > 0 || (interaksiData?.buatKonten?[0].hyppePic ?? 0) > 0) {
              onTapbuatKonten(interaksiKonten: challengeData?.metrik?[0].interaksiKonten?[0] ?? InteraksiKonten());
              return;
            }
          }
        }
      } else {
        onTapbuatKonten(interaksiKonten: challengeData?.metrik?[0].interaksiKonten?[0] ?? InteraksiKonten());
      }
    }
  }

  void onTapbuatKonten({BuatKonten? contentD, InteraksiKonten? interaksiKonten}) {
    int contentVid = 0;
    int contentDiary = 0;
    int contentPict = 0;
    String tagar = "";
    if (contentD != null) {
      contentVid = (contentD.hyppeVid ?? 0) > 0 ? 1 : 0;
      contentDiary = (contentD.hyppeDiary ?? 0) > 0 ? 1 : 0;
      contentPict = (contentD.hyppePic ?? 0) > 0 ? 1 : 0;
    } else {
      contentDiary = (interaksiKonten?.suka?[0].hyppeDiary ?? 0) >= 1 || (interaksiKonten?.tonton?[0].hyppeDiary ?? 0) >= 1 ? 1 : 0;
      contentPict = ((interaksiKonten?.suka?[0].hyppePic ?? 0) >= 1 ? 1 : 0);
      contentVid = (interaksiKonten?.suka?[0].hyppeVid ?? 0) >= 1 || (interaksiKonten?.tonton?[0].hyppeVid ?? 0) >= 1 ? 1 : 0;
    }
    var tot = contentVid + contentDiary + contentPict;
    PreUploadContentNotifier pn = context.read<PreUploadContentNotifier>();
    pn.hastagChallange = interaksiKonten?.tagar ?? '';
    print("====== pn.hastagChallange ${contentD}");
    print("====== pn.hastagChallange ${interaksiKonten}");
    print("====== pn.hastagChallange ${interaksiKonten?.tagar}");
    print("====== pn.hastagChallange ${pn.hastagChallange}");
    if (tot > 1) {
      ShowBottomSheet.onUploadContent(
        context,
        isStory: false,
        isDiary: contentDiary >= 1,
        isPict: contentPict >= 1,
        isVid: contentVid >= 1,
      );
    } else {
      MakeContentNotifier mn = context.read<MakeContentNotifier>();
      context.read<PreviewVidNotifier>().canPlayOpenApps = false; //biar ga play di landingpage
      if (contentPict >= 1) {
        mn.featureType = FeatureType.pic;
        mn.isVideo = false;
        mn.selectedDuration = 15;
        final tempIsHome = isHomeScreen;
        if (tempIsHome) {
          isHomeScreen = false;
        }
        Routing().moveAndPop(Routes.makeContent);
        if (tempIsHome) {
          isHomeScreen = true;
        }
      }
      if (contentVid >= 1) {
        mn.featureType = FeatureType.vid;
        mn.isVideo = true;
        mn.selectedDuration = 15;
        final tempIsHome = isHomeScreen;
        if (tempIsHome) {
          isHomeScreen = false;
        }
        Routing().moveAndPop(Routes.makeContent);
        if (tempIsHome) {
          isHomeScreen = true;
        }
      }
      if (contentDiary >= 1) {
        mn.featureType = FeatureType.diary;
        mn.isVideo = true;
        mn.selectedDuration = 15;
        final tempIsHome = isHomeScreen;
        if (tempIsHome) {
          isHomeScreen = false;
        }
        Routing().moveAndPop(Routes.makeContent);
        if (tempIsHome) {
          isHomeScreen = true;
        }
      }
    }
  }
}
