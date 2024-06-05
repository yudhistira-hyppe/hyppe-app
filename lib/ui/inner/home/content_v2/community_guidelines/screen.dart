import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:hyppe/core/arguments/general_argument.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/community_guidelines/notifier.dart';
import 'package:provider/provider.dart';

class CommunityGuidelinesScreen extends StatefulWidget {
  final GeneralArgument arguments;
  const CommunityGuidelinesScreen({super.key, required this.arguments});

  @override
  State<CommunityGuidelinesScreen> createState() => _CommunityGuidelinesScreenState();
}

class _CommunityGuidelinesScreenState extends State<CommunityGuidelinesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var notifier = Provider.of<CommunityGuidelinesNotifier>(context, listen: false);
      notifier.getGuidelines(context, mounted, widget.arguments.id ?? '');
    });
  }

  @override
  Widget build(BuildContext context) {
    var trans = context.read<TranslateNotifierV2>().translate;
    return Consumer<CommunityGuidelinesNotifier>(
      builder: (_, notifier, __) {
        return Scaffold(
          appBar: AppBar(
            leading: const BackButton(),
            title: CustomTextWidget(
              textStyle: Theme.of(context).textTheme.titleMedium,
              textToDisplay: widget.arguments.title ?? '',
            ),
          ),
          body: notifier.isloading
              ? const Center(
                  child: CustomLoading(),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                    ),
                    child: Html(
                      data: trans.localeDatetime == 'id' ? notifier.cguidelineData?.valueId : notifier.cguidelineData?.valueEn,
                    ),
                  ),
                ),
        );
      },
    );
  }
}
