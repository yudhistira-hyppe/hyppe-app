import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_profile_image.dart';
import 'package:hyppe/ui/constant/widget/custom_search_bar.dart';
import 'package:hyppe/ui/constant/widget/story_color_validator.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/notifier.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';

class OnUserTagBottomSheet extends StatefulWidget {
  final String value;
  final Function() onSave;
  final Function() onCancel;

  final Function(String value) onChange;

  const OnUserTagBottomSheet({
    Key? key,
    required this.value,
    required this.onSave,
    required this.onChange,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<OnUserTagBottomSheet> createState() => _OnUserTagBottomSheetState();
}

class _OnUserTagBottomSheetState extends State<OnUserTagBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final _notifier = PreUploadContentNotifier();
  String? lastInputValue;

  @override
  void initState() {
    // _scrollController.addListener(() => _notifier.scrollListPeopleListener(
    //       context,
    //       _scrollController,
    //       _controller.text,
    //     ));
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

    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        leading: GestureDetector(
            onTap: widget.onSave,
            child: Icon(
              Icons.clear_rounded,
              color: Theme.of(context).colorScheme.onSurface,
            )),
        title: CustomTextWidget(
          textToDisplay: 'Tag People',
          textStyle: textTheme.headline6?.copyWith(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Consumer<PreUploadContentNotifier>(
        builder: (context, notifier, child) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              CustomSearchBar(
                  hintText: notifier.language.search,
                  contentPadding: EdgeInsets.symmetric(vertical: 16 * SizeConfig.scaleDiagonal),
                  controller: _controller,
                  onChanged: (val) {
                    if (lastInputValue != val) {
                      lastInputValue = val;
                      notifier.startSearch = 0;
                      notifier.searchPeople(context, input: _controller.text);
                    }
                  }),
              NotificationListener<ScrollUpdateNotification>(
                child: Expanded(
                  child: notifier.searchPeolpleData != null
                      ? notifier.isLoading
                          ? SizedBox(height: 30, child: CustomLoading())
                          : ListView.builder(
                              shrinkWrap: true,
                              controller: _scrollController,
                              scrollDirection: Axis.vertical,
                              physics: const BouncingScrollPhysics(),
                              itemCount: notifier.searchPeolpleData.length,
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    ListTile(
                                      onTap: () => notifier.inserTagPeople(index),
                                      contentPadding: EdgeInsets.zero,
                                      title: Text("@${notifier.searchPeolpleData[index].username!}"),
                                      subtitle: Text("${notifier.searchPeolpleData[index].fullName!}"),
                                      leading: StoryColorValidator(
                                        haveStory: false,
                                        featureType: FeatureType.pic,
                                        child: CustomProfileImage(
                                          width: 50,
                                          height: 50,
                                          onTap: () {},
                                          imageUrl: System().showUserPicture(notifier.searchPeolpleData[index].avatar?.mediaEndpoint),
                                          following: true,
                                          onFollow: () {},
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            )
                      : Container(),
                ),
                onNotification: (t) {
                  notifier.scrollListPeopleListener(
                    context,
                    _scrollController,
                    _controller.text,
                  );

                  return true;
                },
              ),
              notifier.isLoadingLoadMore == true ? const SizedBox(height: 30, child: CustomLoading()) : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
