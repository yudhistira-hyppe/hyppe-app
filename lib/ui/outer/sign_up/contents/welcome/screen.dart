import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/core/arguments/account_preference_screen_argument.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_tab_page_selector.dart';
import 'package:hyppe/ui/outer/sign_up/contents/welcome/content/slide_template.dart';
import 'package:hyppe/ui/outer/sign_up/contents/welcome/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignUpWelcome extends StatefulWidget {
  @override
  _SignUpWelcomeState createState() => _SignUpWelcomeState();
}

class _SignUpWelcomeState extends State<SignUpWelcome> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'SignUpWelcome');
    Provider.of<SignUpWelcomeNotifier>(context, listen: false).initWelcome(context);
    _tabController = TabController(length: 5, vsync: this);
    super.initState();
    _tabController?.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
    _tabController?.removeListener(() => this);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Consumer<SignUpWelcomeNotifier>(
      builder: (_, notifier, __) => Scaffold(
        body: DefaultTabController(
          length: 5,
          child: Stack(
            children: [
              TabBarView(
                controller: _tabController,
                children: const [
                  SlideTemplate(notesData: 0),
                  SlideTemplate(notesData: 1),
                  SlideTemplate(notesData: 2),
                  SlideTemplate(notesData: 3),
                  SlideTemplate(notesData: 4),
                ],
              ),
              Align(
                alignment: const Alignment(0, 0.6),
                child: CustomTabPageSelector(
                  controller: _tabController,
                  activeColor: Theme.of(context).colorScheme.primary,
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
              ),
              _tabController?.index == 4
                  ? Align(
                      alignment: const Alignment(0, 0.75),
                      child: CustomTextButton(
                        onPressed: () => Routing().moveAndRemoveUntil(Routes.homeTutor, Routes.root),
                        child: CustomTextWidget(
                          textToDisplay: notifier.language.completeLater ?? '',
                          textStyle: Theme.of(context).textTheme.button?.copyWith(color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
              _tabController?.index == 4
                  ? Align(
                      alignment: const Alignment(0, 0.9),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: CustomElevatedButton(
                          width: SizeConfig.screenWidth,
                          height: 50,
                          buttonStyle: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.primary),
                              overlayColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.primary),
                              foregroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.primary),
                              shadowColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.primary)),
                          function: () {
                            // context.read<SignUpCompleteProfileNotifier>().onReset();
                            /// TODO: Changed rules complete profile
                            // Routing().move(userCompleteProfile);
                            Routing().move(Routes.accountPreferences, argument: AccountPreferenceScreenArgument(fromSignUpFlow: true));

                            /// End TODO
                          },
                          child: CustomTextWidget(
                            textToDisplay: notifier.language.completeNow ?? '',
                            textStyle: Theme.of(context).textTheme.button?.copyWith(color: kHyppeLightButtonText),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
