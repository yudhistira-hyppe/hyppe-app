import 'dart:io';
import 'package:hyppe/core/bloc/posts_v2/state.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/widget/video_player_page.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AdsPopUpDialog extends StatefulWidget {
  const AdsPopUpDialog({Key? key}) : super(key: key);

  @override
  State<AdsPopUpDialog> createState() => _AdsPopUpDialogState();
}

class _AdsPopUpDialogState extends State<AdsPopUpDialog> {
  final _routing = Routing();

  bool _isLoading = false;
  List<ContentData>? _vidData;

  @override
  void initState() {
    const jsonDataAsString = {
      "data": [
        {
          "rotate": 0,
          "metadata": {"duration": 7, "postRoll": 7, "postType": "vid", "preRoll": 0, "midRoll": 4, "postID": "b40d0927-b41d-4702-8da6-f99138675c96", "email": "movaz@dropjar.com"},
          "description": "wkwkwkwkwk",
          "privacy": {"isPostPrivate": false, "isCelebrity": false, "isPrivate": false},
          "postID": "b40d0927-b41d-4702-8da6-f99138675c96",
          "title": "wkwkwkwkwk",
          "isViewed": false,
          "createdAt": "2022-08-05 14:32:43",
          "certified": false,
          "saleLike": false,
          "email": "movaz@dropjar.com",
          "updatedAt": "2022-08-05 14:32:43",
          "saleAmount": null,
          "visibility": "PUBLIC",
          "mediaBasePath": "62d7ad156bdb2f0e669b0265/vid/b40d0927-b41d-4702-8da6-f99138675c96/",
          "postType": "vid",
          "isApsara": false,
          "mediaUri": "784a719c-f67e-46d6-b601-2ee49687655a.m3u8",
          "isLiked": false,
          "active": true,
          "mediaType": "video",
          "saleView": false,
          "mediaThumbEndpoint": "/thumb/b40d0927-b41d-4702-8da6-f99138675c96",
          "tags": null,
          "allowComments": true,
          "insight": {
            "shares": 0,
            "insightLogs": [
              {
                "_id": "7d067393-15df-472f-8df0-a24d8dba5ba9",
                "insightID": "db6d476a-ae1e-b0bf-fdb8-cb8366b61f8f",
                "active": true,
                "createdAt": "2022-08-05 14:34:00",
                "updatedAt": "2022-08-05 14:34:00",
                "mate": "ilhamarahman97@gmail.com",
                "postID": "b40d0927-b41d-4702-8da6-f99138675c96",
                "eventInsight": "VIEW"
              },
              {
                "_id": "cf1ab3ad-ed62-466a-9f39-adc7b8824681",
                "insightID": "db6d476a-ae1e-b0bf-fdb8-cb8366b61f8f",
                "active": true,
                "createdAt": "2022-08-08 13:47:52",
                "updatedAt": "2022-08-08 13:47:52",
                "mate": "ilhamarahman97@gmail.com",
                "postID": "b40d0927-b41d-4702-8da6-f99138675c96",
                "eventInsight": "COMMENT"
              },
              {
                "_id": "166513d3-a43d-4157-bbc5-eaded2f41afd",
                "insightID": "db6d476a-ae1e-b0bf-fdb8-cb8366b61f8f",
                "active": true,
                "createdAt": "2022-08-08 13:48:25",
                "updatedAt": "2022-08-08 13:48:25",
                "mate": "ilhamarahman97@gmail.com",
                "postID": "b40d0927-b41d-4702-8da6-f99138675c96",
                "eventInsight": "COMMENT"
              },
              {
                "_id": "f78f64f2-ec5b-40ec-b10f-7ec8e0dd116d",
                "insightID": "db6d476a-ae1e-b0bf-fdb8-cb8366b61f8f",
                "active": true,
                "createdAt": "2022-08-08 13:51:46",
                "updatedAt": "2022-08-08 13:51:46",
                "mate": "ilhamarahman97@gmail.com",
                "postID": "b40d0927-b41d-4702-8da6-f99138675c96",
                "eventInsight": "COMMENT"
              },
              {
                "_id": "9e43963f-6a3a-48b9-b5d7-5ed9c84bd7fe",
                "insightID": "db6d476a-ae1e-b0bf-fdb8-cb8366b61f8f",
                "active": true,
                "createdAt": "2022-08-08 13:52:16",
                "updatedAt": "2022-08-08 13:52:16",
                "mate": "ilhamarahman97@gmail.com",
                "postID": "b40d0927-b41d-4702-8da6-f99138675c96",
                "eventInsight": "COMMENT"
              },
              {
                "_id": "1f800fd1-18ab-4235-8c0c-2171b465b0a1",
                "insightID": "db6d476a-ae1e-b0bf-fdb8-cb8366b61f8f",
                "active": true,
                "createdAt": "2022-08-08 13:53:17",
                "updatedAt": "2022-08-08 13:53:17",
                "mate": "ilhamarahman97@gmail.com",
                "postID": "b40d0927-b41d-4702-8da6-f99138675c96",
                "eventInsight": "COMMENT"
              }
            ],
            "follower": 10,
            "comments": 6,
            "following": 9,
            "reactions": 0,
            "views": 1,
            "likes": 1
          },
          "cats": [
            {
              "_id": "613bc4da9ec319617aa6c38e",
              "interestName": "Entertainment",
              "langIso": "en",
              "icon": "https://prod.hyppe.app/images/icon_interest/entertainment.svg",
              "createdAt": "2021-09-11 03:49:30",
              "updatedAt": "2021-09-11 03:49:30"
            },
            {
              "_id": "613bc4da9ec319617aa6c397",
              "interestName": "Hobby",
              "langIso": "en",
              "icon": "https://prod.hyppe.app/images/icon_interest/hobby.svg",
              "createdAt": "2021-09-11 03:49:30",
              "updatedAt": "2021-09-11 03:49:30"
            }
          ],
          "tagPeople": [
            {
              "avatar": {
                "mediaBasePath": "62bc0ee11140b677c847cf1c/profilepict/",
                "mediaUri": "5565285e-bfa4-485b-8c44-833084ff8c45_0001.jpeg",
                "mediaType": "image",
                "mediaEndpoint": "/profilepict/5565285e-bfa4-485b-8c44-833084ff8c45"
              },
              "email": "ilhamarahman97@gmail.com",
              "username": "testinglagi12",
              "status": "FOLLOWING"
            },
            {
              "avatar": {
                "mediaBasePath": "62a6a0b4547ff22190452520/profilepict/",
                "mediaUri": "b54ba9c6-fbe7-4489-86ce-6da90de2bd40_0001.jpeg",
                "mediaType": "image",
                "mediaEndpoint": "/profilepict/b54ba9c6-fbe7-4489-86ce-6da90de2bd40"
              },
              "email": "taslimahmad0708@gmail.com",
              "username": "taslimahmad0708",
              "status": "FOLLOWING"
            }
          ],
          "mediaThumbUri": "784a719c-f67e-46d6-b601-2ee49687655a_thumb.jpeg",
          "location": "Jakarta, Daerah Khusus Ibukota Jakarta, Indonesia",
          "mediaEndpoint": "/stream/784a719c-f67e-46d6-b601-2ee49687655a.m3u8",
          "username": "movaz"
        },
      ]
    };

    _vidData = (jsonDataAsString['data'] as List<dynamic>?)?.map((e) => ContentData.fromJson(e as Map<String, dynamic>)).toList();

    print('_vidData');
    print(_vidData);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final _language = context.watch<TranslateNotifierV2>().translate;
    return Container(
      decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(8.0)),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: VideoPlayerPage(
          onDetail: false,
          videoData: _vidData?[0],
          key: ValueKey(PostsState.postContentsSuccess),
          afterView: () => System().increaseViewCount(context, _vidData![0]),
        ),
      ),
      // Image.network(
      //   'https://www.pocarisweat.com.sg//assets/uploads/2020/11/3aaf07f26dc43575fb5406f4901dac63.jpg',
      //   fit: BoxFit.contain,
      // ),
    );
  }

  Widget _buildButton({required ThemeData theme, required String caption, required Function function, required Color color, Color? textColor}) {
    return CustomElevatedButton(
      child: CustomTextWidget(textToDisplay: caption, textStyle: theme.textTheme.button!.copyWith(color: textColor)),
      width: 220,
      height: 42,
      function: () async {
        if (Platform.isAndroid || Platform.isIOS) {
          final appId = Platform.isAndroid ? 'com.hyppe.hyppeapp' : 'id1545595684';
          final url = Uri.parse(
            Platform.isAndroid ? "market://details?id=$appId" : "https://apps.apple.com/app/id$appId",
          );
          launchUrl(
            url,
            mode: LaunchMode.externalApplication,
          );
        }
      },
      buttonStyle: theme.elevatedButtonTheme.style!.copyWith(
        backgroundColor: MaterialStateProperty.all(color),
      ),
    );
  }
}
