import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_aliplayer/flutter_aliplayer.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/live_stream/link_stream_model.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/view_streaming/notifier.dart';
import 'package:provider/provider.dart';

import '../../../../../../../core/constants/asset_path.dart';
import '../../../../../../../core/services/system.dart';
import '../../../../../../../ux/routing.dart';
import '../../../../../../constant/widget/custom_icon_widget.dart';
import '../../../../../../constant/widget/custom_loading.dart';
import '../../../../../../constant/widget/custom_spacer.dart';
import '../../../../../../constant/widget/custom_text_widget.dart';

class OverLiveStreaming extends StatefulWidget {
  final LinkStreamModel data;
  final ViewStreamingNotifier notifier;
  final FlutterAliplayer? fAliplayer;
  const OverLiveStreaming({super.key, required this.data, required this.notifier, this.fAliplayer});

  @override
  State<OverLiveStreaming> createState() => _OverLiveStreamingState();
}

class _OverLiveStreamingState extends State<OverLiveStreaming> {
  bool isErrorImage = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      isErrorImage = false;
    });
  }

  String? displayPhotoProfileOriginal(String url) {
    try {
      var orginial = url.split('/');
      var endpoint = "/profilepict/orignal/${orginial.last}";
      return System().showUserPicture(endpoint);
    } catch (e) {
      return null;
    }
  }

  Widget streamerImage(String image) {
    return Stack(
      children: [
        const Align(
          alignment: Alignment.center,
          child: CustomLoading(),
        ),
        Positioned.fill(
            child: Image.network(
          image,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            if (!isErrorImage) {
              setState(() {
                isErrorImage = true;
              });
            }

            return Image.asset('${AssetPath.pngPath}profile-error.jpg', fit: BoxFit.fitWidth);
          },
        )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ViewStreamingNotifier>(
      builder: (_, notifier, __) => Stack(
        children: [
          Positioned.fill(
            child: Container(
              width: double.infinity,
              height: context.getHeight(),
              decoration: BoxDecoration(
                image: isErrorImage
                    ? const DecorationImage(image: AssetImage('${AssetPath.pngPath}profile-error.jpg'), fit: BoxFit.cover)
                    : DecorationImage(
                        image: NetworkImage(
                          displayPhotoProfileOriginal(
                                widget.data.avatar?.mediaEndpoint ?? (notifier.dataStreaming.user?.avatar?.mediaEndpoint ?? ''),
                              ) ??
                              '',
                        ),
                        fit: BoxFit.cover),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.0)),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () async {
                  widget.fAliplayer?.stop();
                  widget.fAliplayer?.destroy();
                  widget.fAliplayer?.clearScreen();
                  Routing().moveBack();
                  // await notifier.exitStreaming(context, widget.args.data);
                  await widget.notifier.destoryPusher();
                },
                child: const Padding(
                  padding: EdgeInsets.only(right: 30.0),
                  child: CustomIconWidget(
                    iconData: "${AssetPath.vectorPath}close.svg",
                    defaultColor: false,
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomTextWidget(
                  textToDisplay: widget.notifier.language.liveStreamingIsOver ?? '',
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                twelvePx,
                CustomTextWidget(
                  textToDisplay: '${notifier.totViewsEnd} ${widget.notifier.language.viewers}',
                  textStyle: const TextStyle(fontSize: 14, color: Color(0xffdadada)),
                ),
                twelvePx,
                SizedBox(
                  width: 80,
                  height: 80,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: streamerImage(displayPhotoProfileOriginal(
                          widget.data.avatar?.mediaEndpoint ?? (notifier.dataStreaming.user?.avatar?.mediaEndpoint ?? ''),
                        ) ??
                        ''),
                  ),
                ),
                twelvePx,
                CustomTextWidget(
                  textToDisplay: '@${widget.data.username ?? notifier.dataStreaming.user?.username}',
                  textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
