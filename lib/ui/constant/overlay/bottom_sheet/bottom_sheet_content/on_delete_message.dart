import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/models/collection/message_v2/message_data_v2.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_profile_image.dart';
import 'package:hyppe/ui/constant/widget/custom_rich_text_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/story_color_validator.dart';
import 'package:hyppe/ui/inner/message_v2/notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OnDeleteMessageBottomSheet extends StatelessWidget {
  MessageDataV2? data;
  final Function() function;
  OnDeleteMessageBottomSheet({
    Key? key,
    this.data,
    required this.function,
  }) : super(key: key);
  final _notifier = MessageNotifier();

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    // return Consumer<MessageNotifier>(builder: (_, notifier, __) => Padding(padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0), child: Column()));

    return ChangeNotifierProvider<MessageNotifier>(
      create: (context) => _notifier,
      child: Consumer2<MessageNotifier, TranslateNotifierV2>(
        builder: (_, notifier, notifier2, __) => Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8 * SizeConfig.scaleDiagonal),
              child: Column(
                children: [
                  const CustomIconWidget(iconData: "${AssetPath.vectorPath}handler.svg"),
                  SizedBox(height: 16 * SizeConfig.scaleDiagonal),
                  Row(
                    children: [
                      StoryColorValidator(
                        featureType: FeatureType.other,
                        // haveStory: notifier.isHaveStory,
                        haveStory: false,
                        child: CustomProfileImage(
                          width: 48,
                          height: 48,
                          following: true,
                          imageUrl: System().showUserPicture(data!.senderOrReceiverInfo?.avatar?.mediaEndpoint),
                        ),
                      ),
                      sixteenPx,
                      CustomRichTextWidget(
                        textSpan: TextSpan(
                          style: Theme.of(context).textTheme.subtitle2?.copyWith(color: Theme.of(context).colorScheme.onBackground),
                          text: "${data!.senderOrReceiverInfo?.username}\n",
                          children: <TextSpan>[
                            TextSpan(
                              text: data!.senderOrReceiverInfo?.fullName,
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.secondaryVariant,
                              ),
                            )
                          ],
                        ),
                        textAlign: TextAlign.start,
                        textStyle: Theme.of(context).textTheme.overline,
                      ),
                    ],
                  ),

                  // CustomTextWidget(
                  //   textToDisplay: notifier2.translate.about!,
                  //   textStyle: Theme.of(context).textTheme.headline6,
                  // ),
                ],
              ),
            ),
            _buildDivider(context),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Padding(
                //   padding: const EdgeInsets.fromLTRB(16.0, 0, 0, 0),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     crossAxisAlignment: CrossAxisAlignment.center,
                //     children: [
                //       CustomTextWidget(
                //         textToDisplay: notifier2.translate.muteMessage!,
                //         textStyle: Theme.of(context).textTheme.subtitle2?.copyWith(color: Theme.of(context).colorScheme.onBackground),
                //       ),
                //       SizedBox(
                //         height: 30,
                //         child: CustomSwitchButton(
                //           value: notifier.muteMessage,
                //           onChanged: (value) => notifier.muteMessage = value,
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                // twelvePx,
                Material(
                  child: ListTile(
                    onTap: function,
                    title: CustomTextWidget(
                      textToDisplay: notifier2.translate.deleteMessage!,
                      textAlign: TextAlign.start,
                      textStyle: Theme.of(context).textTheme.subtitle2?.copyWith(color: Theme.of(context).colorScheme.onBackground),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(context) => Divider(thickness: 1.0, color: Theme.of(context).dividerTheme.color!.withOpacity(0.1));
}
