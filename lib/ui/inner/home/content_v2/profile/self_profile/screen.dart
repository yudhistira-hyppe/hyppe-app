import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/widget/self_profile_bottom.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/widget/self_profile_top.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/widget/both_profile_top_shimmer.dart';
import 'package:hyppe/ux/path.dart';
import 'package:provider/provider.dart';

class SelfProfileScreen extends StatefulWidget {
  @override
  _SelfProfileScreenState createState() => _SelfProfileScreenState();
}

class _SelfProfileScreenState extends State<SelfProfileScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<RefreshIndicatorState> _globalKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    final notifier = Provider.of<SelfProfileNotifier>(context, listen: false);
    notifier.initialSelfProfile(context);
    _scrollController.addListener(() => notifier.onScrollListener(context, _scrollController));
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Consumer<SelfProfileNotifier>(
      builder: (_, notifier, __) => WillPopScope(
        onWillPop: () async {
          notifier.routing.moveBack();
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            elevation: 0.0,
            automaticallyImplyLeading: false,
            flexibleSpace: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => notifier.routing.moveBack(),
                        icon: const CustomIconWidget(iconData: "${AssetPath.vectorPath}back-arrow.svg"),
                      ),
                      CustomTextWidget(
                        textToDisplay: notifier.displayUserName(),
                        textAlign: TextAlign.start,
                        textStyle: Theme.of(context).textTheme.subtitle1,
                      ),
                    ],
                  ),
                  IconButton(
                    // onPressed: () => notifier.routing.move(profileSettings),
                    onPressed: () => notifier.routing.move(Routes.appSettings),
                    icon: const CustomIconWidget(
                      iconData: "${AssetPath.vectorPath}setting.svg",
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: RefreshIndicator(
            key: _globalKey,
            strokeWidth: 2.0,
            color: Colors.purple,
            onRefresh: () async {
              await notifier.initialSelfProfile(context);
            },
            child: CustomScrollView(
              controller: _scrollController,
              scrollDirection: Axis.vertical,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverAppBar(
                  pinned: false,
                  stretch: false,
                  elevation: 0.0,
                  floating: false,
                  automaticallyImplyLeading: false,
                  expandedHeight: (200 * SizeConfig.scaleDiagonal) + 46,
                  backgroundColor: Theme.of(context).colorScheme.background,
                  flexibleSpace: FlexibleSpaceBar(
                      titlePadding: EdgeInsets.zero, background: notifier.user.profile != null ? SelfProfileTop() : BothProfileTopShimmer()),
                ),
                SliverAppBar(
                  pinned: true,
                  flexibleSpace: SelfProfileBottom(),
                  automaticallyImplyLeading: false,
                  backgroundColor: Theme.of(context).colorScheme.background,
                ),
                notifier.optionButton()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
