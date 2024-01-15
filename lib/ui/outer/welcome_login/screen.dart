import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_gesture.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_form_field.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/outer/welcome_login/widget/page_bottom.dart';
import 'package:hyppe/ui/outer/welcome_login/widget/page_top.dart';
import 'package:hyppe/ui/outer/welcome_login/widget/position_welcome.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:move_to_background/move_to_background.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/asset_path.dart';
import '../../constant/widget/custom_icon_widget.dart';
import 'notifier.dart';

class WelcomeLoginScreen extends StatefulWidget {
  const WelcomeLoginScreen({super.key});

  @override
  State<WelcomeLoginScreen> createState() => _WelcomeLoginScreenState();
}

class _WelcomeLoginScreenState extends State<WelcomeLoginScreen> {
  TextEditingController endpoint = TextEditingController();
  late CarouselController controller;

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'WelcomeLoginScreen');
    controller = CarouselController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Consumer<WelcomeLoginNotifier>(builder: (context, notifier, _) {
      return WillPopScope(
          onWillPop: () async {
            MoveToBackground.moveTaskToBack();
            return false;
          },
          child: Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  AspectRatio(
                    aspectRatio: 375 / 600,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: CarouselSlider(
                            carouselController: controller,
                            options: CarouselOptions(
                                // height: 300
                                enlargeCenterPage: true,
                                enableInfiniteScroll: false,
                                viewportFraction: 1.0,
                                aspectRatio: 375 / 600,
                                onPageChanged: (index, reason) {
                                  setState(() {
                                    notifier.currIndex = index;
                                  });
                                }),
                            items: List.generate(
                              notifier.welcomeList.length,
                              (index) {
                                final data = notifier.welcomeList[index];
                                // final isSvg = (data?.image ?? '').isSVG();
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CustomIconWidget(
                                      iconData:
                                          "${AssetPath.vectorPath}${data.image}",
                                      defaultColor: false,
                                    ),
                                    thirtySixPx,
                                    SizedBox(
                                      width: double.infinity,
                                      height: 132,
                                      child: Stack(
                                        children: [
                                          Positioned(
                                            top: 0,
                                            left: 30,
                                            right: 30,
                                            child: CustomTextWidget(
                                              textToDisplay: data.title,
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              textStyle: const TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.w700),
                                            ),
                                          ),
                                          Positioned(
                                              bottom: 10,
                                              left: 30,
                                              right: 30,
                                              child: RichText(
                                                  maxLines: 4,
                                                  textAlign: TextAlign.center,
                                                  text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                  text: data.desc,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                      fontFamily: 'Lato',
                                                    color: Colors.black
                                                  ),
                                                ),
                                                  if(index == 3)
                                                    TextSpan(
                                                      text: '\n#ShareWhatInspireYou',
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                          fontFamily: 'Lato',
                                                          color: Colors.black,
                                                        fontWeight: FontWeight.bold
                                                      ),
                                                    ),
                                                ]
                                              )))
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 30,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              PositionWelcome(
                                  isActive: notifier.currIndex == 0),
                              fourPx,
                              PositionWelcome(
                                  isActive: notifier.currIndex == 1),
                              fourPx,
                              PositionWelcome(
                                  isActive: notifier.currIndex == 2),
                              fourPx,
                              PositionWelcome(isActive: notifier.currIndex == 3)
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  CustomGesture(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    onTap: () {
                      ShowBottomSheet.onLoginApp(context);
                    },
                    child: Container(
                      width: double.infinity,
                      height: 44,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: context.getColorScheme().primary.withOpacity(0.9)),
                      alignment: Alignment.center,
                      child: CustomTextWidget(
                        textToDisplay: notifier.language.login ?? '',
                        textAlign: TextAlign.center,
                        textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                    ),
                  ),
                  tenPx,
                  CustomGesture(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    onTap: () {
                      notifier.onClickGuest(context);
                    },
                    child: Container(
                      width: double.infinity,
                      height: 44,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.transparent,
                          border: Border.all(
                              color: context.getColorScheme().primary,
                              width: 1)),
                      alignment: Alignment.center,
                      child: notifier.goToGuest ? const CustomLoading() : CustomTextWidget(
                        textToDisplay: notifier.language.exploreAsGuest ?? '',
                        textAlign: TextAlign.center,
                        textStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: context.getColorScheme().primary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ));
    });
    // return WillPopScope(
    //   onWillPop: () async {
    //     MoveToBackground.moveTaskToBack();
    //     return false;
    //   },
    //   child: GestureDetector(
    //     child: Scaffold(
    //       body: SafeArea(
    //         child: SingleChildScrollView(
    //           child: Container(
    //             color: Theme.of(context).colorScheme.surface,
    //             width: SizeConfig.screenWidth,
    //             child: Column(
    //               children: [
    //                 const PageTop(),
    //                 PageBottom(),
    //                 // testLogin(),
    //                 // formEndpoint(),
    //               ],
    //             ),
    //           ),
    //         ),
    //       ),
    //     ),
    //     onTap: () {
    //       if (!FocusScope.of(context).hasPrimaryFocus) FocusScope.of(context).unfocus();
    //     },
    //   ),
    // );
  }

  Widget testLogin() {
    return GestureDetector(
      onTap: () {
        Routing().move(Routes.testLogin);
      },
      child: Text('Testlogin'),
    );
  }

  Widget formEndpoint() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          CustomTextFormField(
            inputAreaHeight: 55 * SizeConfig.scaleDiagonal,
            inputAreaWidth: SizeConfig.screenWidth!,
            textEditingController: endpoint,
            style: Theme.of(context).textTheme.bodyText1,
            textInputType: TextInputType.emailAddress,
            inputDecoration: InputDecoration(
              contentPadding: const EdgeInsets.only(left: 16, bottom: 16, right: 16),
              labelText: "End point test ",
              border: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.surface)),
            ),
          ),
          twelvePx,
          CustomElevatedButton(
              width: SizeConfig.screenWidth!,
              height: 50,
              function: () {
                SharedPreference().writeStorage(SpKeys.endPointTest, endpoint.text);
                print("${SharedPreference().readStorage(SpKeys.endPointTest)}");
              },
              buttonStyle: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(kHyppePrimary),
                overlayColor: MaterialStateProperty.all(Colors.transparent),
              ),
              child: const Text("Simpan end point")),
        ],
      ),
    );
  }
}
