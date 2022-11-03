import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/ui/constant/entities/playlist/notifier.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'widget/list_bookmark.dart';

class ListMyPlaylist extends StatefulWidget {
  final String? postID;
  final String? featureType;
  final String? contentID;

  const ListMyPlaylist({Key? key, required this.postID, required this.featureType, required this.contentID}) : super(key: key);

  @override
  _ListMyPlaylistState createState() => _ListMyPlaylistState();
}

class _ListMyPlaylistState extends State<ListMyPlaylist> {

  @override
  void initState() {
    final notifier = Provider.of<PlaylistNotifier>(context, listen: false);
    notifier.initialMyPlaylistData(context);
    super.initState();
  }

  @override
  Widget build(BuildContext rootContext) {
    SizeConfig().init(rootContext);
    return Consumer<PlaylistNotifier>(
      builder: (_, notifier, __) => Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(
            width: SizeConfig.screenWidth,
            height: 70 * SizeConfig.scaleDiagonal,
            child: Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: SizeConfig.screenWidth ?? context.getWidth() / 9,
                    height: 3.5,
                    child: Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(25)),
                        color: Color(0xff7D8389),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CustomTextWidget(
                        textToDisplay: notifier.language.saveTo ?? '',
                        textStyle: Theme.of(context).textTheme.headline6?.copyWith(fontWeight: FontWeight.normal),
                      ),
                      GestureDetector(
                        onTap: () {
                          notifier.dropDownValue = notifier.listPrivacy[0];
                          notifier.screen = true;
                        },
                        child: Row(
                          children: [
                            // SvgPicture.string(
                            //   SvgAssets.icPlaylistAdd,
                            //   allowDrawingOutsideViewBox: true,
                            //   width: 18 * SizeConfig.scaleDiagonal,
                            //   height: 18 * SizeConfig.scaleDiagonal,
                            //   color: Color(0xff7D8389),
                            // ),
                            SizedBox(width: 12 * SizeConfig.scaleDiagonal),
                            CustomTextWidget(
                              textToDisplay: notifier.language.createNew ?? '',
                              textStyle: Theme.of(context).textTheme.button,
                            ),
                          ],
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
          ListBookmark()
        ],
      ),
    );
  }
}
