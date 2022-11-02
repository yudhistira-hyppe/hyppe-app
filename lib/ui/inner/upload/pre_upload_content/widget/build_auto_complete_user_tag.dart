import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_profile_image.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/story_color_validator.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/notifier.dart';
import 'package:provider/provider.dart';

class AutoCompleteUserTag extends StatelessWidget {
  const AutoCompleteUserTag({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<PreUploadContentNotifier>(
      builder: (context, notifier, child) => Visibility(
        visible: notifier.isShowAutoComplete,
        child: Padding(
          padding: EdgeInsets.only(top: 100),
          child: Container(
            height: notifier.searchPeolpleData != null ? 200 : 20,
            color: Theme.of(context).colorScheme.background,
            child: notifier.searchPeolpleData != null
                ? notifier.isLoading
                    ? Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(child: SizedBox(height: 50, child: CustomLoading())),
                        ],
                      )
                    : notifier.searchPeolpleData.length == 0
                        ? Row(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(child: Center(child: Text('User tidak ditemukan'))),
                            ],
                          )
                        : ListView.builder(
                            itemCount: notifier.searchPeolpleData.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                onTap: () {
                                  notifier.insertAutoComplete(index);
                                },

                                title: CustomTextWidget(
                                  textToDisplay: '@ ${notifier.searchPeolpleData[index].username}',
                                  textStyle: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.start,
                                ),
                                // subtitle: Text("${notifier.searchPeolpleData[index].fullName}"),
                                leading: StoryColorValidator(
                                  haveStory: false,
                                  featureType: FeatureType.pic,
                                  child: CustomProfileImage(
                                    width: 30,
                                    height: 30,
                                    onTap: () {},
                                    imageUrl: System().showUserPicture(notifier.searchPeolpleData[index].avatar?.mediaEndpoint),
                                    following: true,
                                    onFollow: () {},
                                  ),
                                ),
                              );
                            },
                          )
                : Container(),
          ),
        ),
      ),
    );
  }
}
