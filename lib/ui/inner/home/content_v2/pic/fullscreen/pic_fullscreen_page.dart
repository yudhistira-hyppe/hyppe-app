import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyppe/core/arguments/pic_fullscreen_argument.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:provider/provider.dart';

import '../screen.dart';

class PicFullscreenPage extends StatefulWidget {
  final PicFullscreenArgument? argument;
  const PicFullscreenPage({super.key, this.argument});

  @override
  State<PicFullscreenPage> createState() => _PicFullscreenPageState();
}

class _PicFullscreenPageState extends State<PicFullscreenPage> {
  ContentData? picData;
  late ImageProvider<Object> imageProvider;

  @override
  void didChangeDependencies() {
    picData = widget.argument?.picData;
    imageProvider = widget.argument!.imageProvider;
    print('data pic ${picData?.avatar}');

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Stack(
          children: [
            Center(
              child: ImageSize(
                onChange: (Size size) {
                  if ((picData?.imageHeightTemp ?? 0) == 0) {
                    setState(() {
                      picData?.imageHeightTemp = size.height;
                    });
                  }
                },
                child: picData?.reportedStatus == 'BLURRED'
                    ? ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                        child: Image(
                          image: imageProvider,
                          fit: BoxFit.fitHeight,
                          width: SizeConfig.screenWidth,
                          // height: picData?.imageHeightTemp == 0 ? null : picData?.imageHeightTemp,
                        ),
                      )
                    : Image(
                        image: imageProvider,
                        fit: BoxFit.fitHeight,
                        width: SizeConfig.screenWidth,
                        // height: picData?.imageHeightTemp == 0 || (picData?.imageHeightTemp ?? 0) <= 100 ? null : picData?.imageHeightTemp,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}