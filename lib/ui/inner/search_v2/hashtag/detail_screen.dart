import 'package:flutter/material.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/search_v2/notifier.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/asset_path.dart';
import '../../../../core/models/collection/search/hashtag.dart';
import '../../../constant/widget/icon_button_widget.dart';

class DetailHashtagScreen extends StatefulWidget {
  Hashtag hashtag;
  DetailHashtagScreen({Key? key, required this.hashtag}) : super(key: key);

  @override
  State<DetailHashtagScreen> createState() => _DetailHashtagScreenState();
}

class _DetailHashtagScreenState extends State<DetailHashtagScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<SearchNotifier>(
      builder: (context, notifier, _) {
        return Scaffold(
          appBar: AppBar(
            leading: CustomIconButtonWidget(
              onPressed: () => notifier.backFromSearchMore(),
              defaultColor: false,
              iconData: "${AssetPath.vectorPath}back-arrow.svg",
              color: Theme.of(context).colorScheme.onSurface,
            ),
            title: CustomTextWidget(
                textToDisplay: widget.hashtag.name ?? '',
              textStyle: context.getTextTheme().bodyText1?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          body: const SafeArea(
            child: Center(
              child: Text('detail hashtag'),
            ),
          ),
        );
      }
    );
  }
}
