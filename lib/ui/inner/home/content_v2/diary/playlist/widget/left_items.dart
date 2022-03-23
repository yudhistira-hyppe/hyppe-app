import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';

import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';

class LeftItems extends StatefulWidget {
  final String? userName;
  final String? description;
  final String? musicName;
  final String? authorName;

  const LeftItems({
    Key? key,
    this.userName,
    this.description,
    this.musicName,
    this.authorName,
  }) : super(key: key);

  @override
  _LeftItemsState createState() => _LeftItemsState();
}

class _LeftItemsState extends State<LeftItems> with SingleTickerProviderStateMixin {
  // AnimationController? _controller;
  // Animation<Offset>? _offsetAnimation;

  @override
  void initState() {
    super.initState();
    // _controller = AnimationController(
    //   duration: const Duration(seconds: 3),
    //   vsync: this,
    // )..repeat();
    // _offsetAnimation = Tween<Offset>(
    //   begin: Offset.zero,
    //   end: const Offset(-2.0, 0.0),
    // ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    // _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      width: SizeConfig.screenWidth! / 1.5,
      alignment: const Alignment(-1.0, 0.75),
      padding: const EdgeInsets.only(left: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
            child: SingleChildScrollView(
              child: ReadMoreText(
                "${widget.description}",
                trimLines: 5,
                trimMode: TrimMode.Line,
                textAlign: TextAlign.left,
                trimExpandedText: 'Show less',
                trimCollapsedText: 'Show more',
                colorClickableText: Theme.of(context).colorScheme.primaryVariant,
                style: Theme.of(context).textTheme.bodyText1!.copyWith(color: kHyppeLightButtonText),
                moreStyle: Theme.of(context).textTheme.bodyText1!.copyWith(color: Theme.of(context).colorScheme.primaryVariant),
                lessStyle: Theme.of(context).textTheme.bodyText1!.copyWith(color: Theme.of(context).colorScheme.primaryVariant),
              ),
            ),
          ),
          // SizedBox(height: 40.0 * SizeConfig.scaleDiagonal),
          // _musicInfo(),
        ],
      ),
    );
  }

  // Widget _musicInfo() {
  //   return Row(
  //     children: <Widget>[
  //       CustomIconWidget(
  //         defaultColor: false,
  //         iconData: "${AssetPath.vectorPath}music.svg",
  //       ),
  //       SizedBox(width: 5.0 * SizeConfig.scaleDiagonal),
  //       Flexible(
  //         /// Xulu Code => [Wrap SlideTransition Widget with Flexible Widget & add overflow property into Text Widget]
  //         child: SlideTransition(
  //           position: _offsetAnimation,
  //           child: Center(
  //             child: Text(
  //               "${widget.musicName} - ${widget.authorName}",
  //               overflow: TextOverflow.ellipsis,
  //               style: TextStyle(
  //                   color: Colors.white,
  //                   fontFamily: "Roboto",
  //                   fontSize: 18 * SizeConfig.scaleDiagonal,
  //                   fontWeight: FontWeight.w400),
  //             ),
  //           ),
  //         ),
  //       )
  //     ],
  //   );
  // }
}
