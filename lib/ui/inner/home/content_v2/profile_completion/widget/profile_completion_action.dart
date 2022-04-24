import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile_completion/notifier.dart';
import 'package:provider/provider.dart';

class ProfileCompletionAction extends StatefulWidget {
  const ProfileCompletionAction({Key? key}) : super(key: key);

  @override
  State<ProfileCompletionAction> createState() =>
      _ProfileCompletionActionState();
}

class _ProfileCompletionActionState extends State<ProfileCompletionAction> {
  @override
  void initState() {
    Provider.of<ProfileCompletionNotifier>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileCompletionNotifier>(
      builder: (_, notifier, __) => Column(
        children: [
          CustomElevatedButton(
            width: SizeConfig.screenWidth,
            height: 49 * SizeConfig.scaleDiagonal,
            function: () {},
            child: CustomTextWidget(
              textToDisplay: notifier.language.logIn!,
              textStyle: Theme.of(context).primaryTextTheme.button,
            ),
          )
        ],
      ),
    );
  }
}
