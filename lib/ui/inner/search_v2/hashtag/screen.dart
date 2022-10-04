import 'package:flutter/material.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/inner/search_v2/hashtag/notifier.dart';
import 'package:hyppe/ui/inner/search_v2/hashtag/widget/shimmer.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/asset_path.dart';
import '../../../../core/constants/size_config.dart';
import '../../../../core/constants/themes/hyppe_colors.dart';
import '../../../constant/widget/custom_icon_widget.dart';
import '../../../constant/widget/custom_text_widget.dart';

class HashtagScreen extends StatefulWidget {
  const HashtagScreen({Key? key}) : super(key: key);

  @override
  State<HashtagScreen> createState() => _HashtagScreenState();
}

class _HashtagScreenState extends State<HashtagScreen> {

  @override
  void initState() {
    final notifier = Provider.of<HashtagNotifier>(context, listen: false);
    Future.delayed(Duration.zero, () => notifier.initHashTag(context));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Consumer<HashtagNotifier>(builder: (context, notifier, child){
      return WillPopScope(
        onWillPop: () {

          return Future.value(true);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
              child: Text(notifier.language.popularHashtag!, style: const TextStyle(color: kHyppeLightSecondary, fontSize: 14, fontWeight: FontWeight.bold),),
            ),
            eightPx,
            notifier.isLoading != null ? notifier.isLoading! ? ListView.builder(
              shrinkWrap: true,
              itemBuilder: (context, index){
              return const HashtagShimmer();
            }, itemCount: 3,) : ListView.builder(
                shrinkWrap: true,
              itemCount: notifier.listHashtag?.length,
                itemBuilder: (context, index) {
              return ListTile(
                onTap: () {

                },
                leading: CustomIconWidget(
              iconData: "${AssetPath.vectorPath}hashtag_icon.svg",
                height: 40 ,
                width: 40 ,
                defaultColor: false,
              ),
                title: CustomTextWidget(
                  textToDisplay: notifier.listHashtag?[index].name ?? "",
                  textStyle: context.getTextTheme().bodyMedium,
                  textAlign: TextAlign.start,
                ),
                subtitle: Text(
                  (notifier.listHashtag?[index].count ?? 0) > 500 ? "500+ ${notifier.language.posts}" : "${notifier.listHashtag?[index].count} ${notifier.language.posts}",
                  style: const TextStyle(fontSize: 12, color: kHyppeGrey),
                ),
                // leading: StoryColorValidator(
                //   haveStory: false,
                //   featureType: FeatureType.pic,
                //   child: CustomProfileImage(
                //     width: 40,
                //     height: 40,
                //     onTap: () {},
                //     imageUrl: System().showUserPicture(notifier.searchPeolpleData![index].avatar?.mediaEndpoint),
                //     following: true,
                //     onFollow: () {},
                //   ),
                // ),
              );
            }) : const SizedBox()
          ],
        ),
      );
    });
  }
}

