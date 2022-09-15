import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/ui/constant/widget/custom_base_cache_image.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/preview/widget/bottom_item_view.dart';
// import 'package:hyppe/ui/inner/home/content/diary/preview/widget/top_item_view.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/preview/widget/bottom_user_tag.dart';

class CenterItemView extends StatelessWidget {
  final Function? onTap;
  final ContentData? data;
  const CenterItemView({this.onTap, this.data});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final _scaling = (MediaQuery.of(context).size.width - 16.0 - 16.0 - 8) / 3;
    // double _result = context.read<PreviewDiaryNotifier>().scaleDiary(context) < 100
    //     ? SizeWidget.barShortVideoHomeLarge
    //     : context.read<PreviewDiaryNotifier>().scaleDiary(context);

    return GestureDetector(
      onTap: onTap as void Function()?,
      child: CustomBaseCacheImage(
        widthPlaceHolder: 112,
        heightPlaceHolder: 40,
        imageUrl: data!.isApsara! ? data!.mediaThumbEndPoint! : "${data?.fullThumbPath}",
        imageBuilder: (context, imageProvider) => Container(
          width: _scaling,
          height: 181,
          child: _buildBody(),
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          width: _scaling,
          height: 181,
          child: _buildBody(),
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage('${AssetPath.pngPath}content-error.png'),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // TopItemView(data: data),
        BottomItemView(data: data),
        data!.tagPeople!.isNotEmpty ? BottomUserView(data: data) : const SizedBox(),
      ],
    );
  }
}
