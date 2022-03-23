import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/services/error_service.dart';
import 'package:hyppe/ui/constant/entities/stories/notifier.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/stories/widget/account_component.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/stories/widget/handler.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/stories/widget/tile_component.dart';
import 'package:hyppe/ui/constant/widget/custom_error_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ViewedStoriesScreen extends StatefulWidget {
  final String storyID;

  const ViewedStoriesScreen({Key? key, required this.storyID}) : super(key: key);

  @override
  _ViewedStoriesScreenState createState() => _ViewedStoriesScreenState();
}

class _ViewedStoriesScreenState extends State<ViewedStoriesScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    final notifier = Provider.of<ViewerStoriesNotifier>(context, listen: false);
    notifier.getViewers(context, storyID: widget.storyID);
    scrollController.addListener(() => notifier.onScrollGetViewers(context, widget.storyID, scrollController));
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final error = context.select((ErrorService value) => value.getError(ErrorType.getViewerStories));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Handler(),
        Consumer<ViewerStoriesNotifier>(
          builder: (context, value, child) {
            if (value.isLoading) {
              return const CustomLoading();
            }

            return Expanded(
              child: context.read<ErrorService>().isInitialError(error, value.viewerStories)
                  ? CustomErrorWidget(
                      errorType: ErrorType.getViewerStories,
                      function: () => value.getViewers(context, storyID: widget.storyID),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: value.viewerStories == null ? 0 : value.viewerStories!.storyViews.length,
                      itemBuilder: (context, index) {
                        if (value.viewerStories!.storyViews[index].isLoading == null) {
                          return TileComponent(
                            function: () {},
                            title: '${value.viewerStories!.storyViews[index].fullName}',
                            subtitle: '${value.viewerStories!.storyViews[index].username}',
                            leading: AccountComponent(data: value.viewerStories!.storyViews[index]),
                          );
                        } else {
                          return const CustomLoading();
                        }
                      },
                    ),
            );
          },
        )
      ],
    );
  }
}
