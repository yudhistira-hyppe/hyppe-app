import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/core/arguments/contents/diary_detail_screen_argument.dart';
import 'package:hyppe/core/arguments/contents/pic_detail_screen_argument.dart';
import 'package:hyppe/core/arguments/contents/story_detail_screen_argument.dart';
import 'package:hyppe/core/arguments/contents/vid_detail_screen_argument.dart';
import 'package:hyppe/core/bloc/posts_v2/bloc.dart';
import 'package:hyppe/core/bloc/posts_v2/state.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/notification_v2/notification.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/custom_base_cache_image.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class ImageComponent extends StatefulWidget {
  final double width;
  final double height;
  final Content? data;
  final String? postType;
  final String? postID;

  final BorderRadiusGeometry? borderRadiusGeometry;
  const ImageComponent({Key? key, required this.data, this.width = 50, this.height = 50, this.borderRadiusGeometry, this.postType, this.postID}) : super(key: key);

  @override
  State<ImageComponent> createState() => _ImageComponentState();
}

class _ImageComponentState extends State<ImageComponent> {

  Future onGetContentData(BuildContext context, FeatureType featureType, Function(dynamic) callback) async {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'ImageComponent');
    print('ini imagecomponen');
    final getStory = PostsBloc();
    final List<ContentData> _listContentData = [];
    await getStory.getContentsBlocV2(context, pageNumber: 0, type: featureType, postID: widget.postID ?? '');
    final fetch = getStory.postsFetch;
    if (fetch.postsState == PostsState.getContentsSuccess) {
      if (fetch.data.isNotEmpty) {
        fetch.data.forEach((v) => _listContentData.add(ContentData.fromJson(v)));
        if (featureType == FeatureType.pic || featureType == FeatureType.vid) {
          callback(_listContentData[0]);
        }
        callback(_listContentData);
      } else {
        callback(null);
      }
    }
  }

  var isLoading = false;

  @override
  Widget build(BuildContext context) {

    FirebaseCrashlytics.instance.setCustomKey('layout', 'ComponentShimmer');
    SizeConfig().init(context);
    print('notifikasi data ${widget.data}');
    if (widget.data != null) {
      return isLoading ? const CircularProgressIndicator() : InkWell(
        onTap: () async {
          print('klklklklkl');
          final language = context.read<TranslateNotifierV2>().translate;
          final featureType = System().getFeatureTypeV2(widget.postType ?? '');
          print(featureType);
          if(!isLoading){
            setState(() => isLoading = true);
            switch (featureType) {
              case FeatureType.vid:
                onGetContentData(context, featureType, (v) async{
                  if (v != null) {
                    await Routing().move(Routes.vidDetail, argument: VidDetailScreenArgument(vidData: v));
                  } else {
                    ShowBottomSheet().onShowColouredSheet(context, language.contentNotAvailable ?? '', color: kHyppeLightDanger, iconSvg: "${AssetPath.vectorPath}remove.svg");
                  }
                  setState(() => isLoading = false);
                });

                break;
              case FeatureType.diary:
                onGetContentData(context, featureType, (v) async{
                  if (v != null) {
                    await Routing().move(Routes.diaryDetail, argument: DiaryDetailScreenArgument(diaryData: v, type: TypePlaylist.none));
                  } else {
                    ShowBottomSheet().onShowColouredSheet(context, language.contentNotAvailable ?? '', color: kHyppeLightDanger, iconSvg: "${AssetPath.vectorPath}remove.svg");
                  }
                  setState(() => isLoading = false);
                });

                break;
              case FeatureType.pic:
                onGetContentData(context, featureType, (v) async{
                  if (v != null) {
                    Routing().move(Routes.picDetail, argument: PicDetailScreenArgument(picData: v));
                  } else {
                    ShowBottomSheet().onShowColouredSheet(context, language.contentNotAvailable ?? '', color: kHyppeLightDanger, iconSvg: "${AssetPath.vectorPath}remove.svg");
                  }
                  setState(() => isLoading = false);
                });
                // context.read<PreviewPicNotifier>().navigateToSlidedDetailPic(context, 0);
                break;
              case FeatureType.story:
                onGetContentData(context, featureType, (v) async {
                  if (v != null) {
                    Routing().move(Routes.vidDetail, argument: StoryDetailScreenArgument(storyData: v));
                  } else {
                    ShowBottomSheet().onShowColouredSheet(context, language.contentNotAvailable ?? '', color: kHyppeLightDanger, iconSvg: "${AssetPath.vectorPath}remove.svg");
                  }
                  setState(() => isLoading = false);
                });
                break;
              case FeatureType.txtMsg:
                // return;
              case FeatureType.other:
                return;
            }
          }


        },
        child: CustomBaseCacheImage(
          imageUrl: (widget.data?.isApsara ?? false) ? '${widget.data?.mediaThumbEndpoint ?? ''}' : '${widget.data?.fullThumbPath ?? ''}',
          errorWidget: (_, __, ___) {
            return Container(
                width: widget.width * SizeConfig.scaleDiagonal,
                height: widget.height * SizeConfig.scaleDiagonal,
                decoration: BoxDecoration(image: const DecorationImage(image: AssetImage('${AssetPath.pngPath}content-error.png'), fit: BoxFit.cover), borderRadius: widget.borderRadiusGeometry));
          },
          imageBuilder: (_, imageProvider) {
            return Container(
                width: widget.width * SizeConfig.scaleDiagonal,
                height: widget.height * SizeConfig.scaleDiagonal,
                decoration: BoxDecoration(image: DecorationImage(image: imageProvider, fit: BoxFit.cover), borderRadius: widget.borderRadiusGeometry));
          },
          emptyWidget: Container(
              width: widget.width * SizeConfig.scaleDiagonal,
              height: widget.height * SizeConfig.scaleDiagonal,
              decoration: BoxDecoration(image: const DecorationImage(image: AssetImage('${AssetPath.pngPath}content-error.png'), fit: BoxFit.cover), borderRadius: widget.borderRadiusGeometry)),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

