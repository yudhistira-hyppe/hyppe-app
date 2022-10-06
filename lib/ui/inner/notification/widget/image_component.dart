import 'package:hyppe/core/arguments/contents/diary_detail_screen_argument.dart';
import 'package:hyppe/core/arguments/contents/pic_detail_screen_argument.dart';
import 'package:hyppe/core/arguments/contents/story_detail_screen_argument.dart';
import 'package:hyppe/core/arguments/contents/vid_detail_screen_argument.dart';
import 'package:hyppe/core/bloc/posts_v2/bloc.dart';
import 'package:hyppe/core/bloc/posts_v2/state.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/models/collection/notification_v2/notification.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_base_cache_image.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';

class ImageComponent extends StatelessWidget {
  final double width;
  final double height;
  final Content? data;
  final BorderRadiusGeometry? borderRadiusGeometry;

  const ImageComponent({Key? key, required this.data, this.width = 50, this.height = 50, this.borderRadiusGeometry}) : super(key: key);

  Future onGetContentData(BuildContext context, FeatureType featureType, Function(dynamic) callback) async {
    print('ini imagecomponen');
    final getStory = PostsBloc();
    final List<ContentData> _listContentData = [];
    await getStory.getContentsBlocV2(context, pageNumber: 0, type: featureType, postID: data!.postID!);
    final fetch = getStory.postsFetch;
    if (fetch.postsState == PostsState.getContentsSuccess) {
      if (fetch.data.isNotEmpty) {
        fetch.data.forEach((v) => _listContentData.add(ContentData.fromJson(v)));
        if (featureType == FeatureType.pic || featureType == FeatureType.vid) {
          callback(_listContentData[0]);
        }
        callback(_listContentData);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    if (data != null) {
      return InkWell(
        onTap: () async {
          final featureType = System().getFeatureTypeV2(data!.postType!);
          switch (featureType) {
            case FeatureType.vid:
              onGetContentData(context, featureType, (v) => Routing().move(Routes.vidDetail, argument: VidDetailScreenArgument(vidData: v)));
              break;
            case FeatureType.diary:
              onGetContentData(context, featureType, (v) => Routing().move(Routes.diaryDetail, argument: DiaryDetailScreenArgument(diaryData: v)));
              break;
            case FeatureType.pic:
              onGetContentData(context, featureType, (v) => Routing().move(Routes.picDetail, argument: PicDetailScreenArgument(picData: v)));
              break;
            case FeatureType.story:
              onGetContentData(context, featureType, (v) => Routing().move(Routes.storyDetail, argument: StoryDetailScreenArgument(storyData: v)));
              break;
            case FeatureType.txtMsg:
              return;
            case FeatureType.other:
              return;
          }
        },
        child: CustomBaseCacheImage(
          imageUrl: '${data!.fullThumbPath}',
          errorWidget: (_, __, ___) {
            return Container(
                width: width * SizeConfig.scaleDiagonal,
                height: height * SizeConfig.scaleDiagonal,
                decoration: BoxDecoration(image: const DecorationImage(image: AssetImage('${AssetPath.pngPath}content-error.png'), fit: BoxFit.cover), borderRadius: borderRadiusGeometry));
          },
          imageBuilder: (_, imageProvider) {
            return Container(
                width: width * SizeConfig.scaleDiagonal,
                height: height * SizeConfig.scaleDiagonal,
                decoration: BoxDecoration(image: DecorationImage(image: imageProvider, fit: BoxFit.cover), borderRadius: borderRadiusGeometry));
          },
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
