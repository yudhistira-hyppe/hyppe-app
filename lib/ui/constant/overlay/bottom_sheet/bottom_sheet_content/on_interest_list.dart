import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class OnInterestListBottomSheet extends StatefulWidget {
  final String value;
  final Function() onSave;
  final Function() onCancel;

  final Function(String value) onChange;

  const OnInterestListBottomSheet({
    Key? key,
    required this.value,
    required this.onSave,
    required this.onChange,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<OnInterestListBottomSheet> createState() => _OnInterestListBottomSheetState();
}

class _OnInterestListBottomSheetState extends State<OnInterestListBottomSheet> {
  var privacy = [];
  final _language = TranslateNotifierV2();
  String _currentPrivacy = "";
  static final _routing = Routing();
  TextEditingController controller = TextEditingController();
  BuildContext? scaffoldContext;
  var _notifier;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('dsd');
    // Provider.of<PreUploadContentNotifier>(context, listen: false).onGetInterest(context);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    scaffoldContext = context;
    final textTheme = Theme.of(context).textTheme;
    return Consumer<PreUploadContentNotifier>(
      builder: (context, notifier, child) => Scaffold(
        appBar: AppBar(
          elevation: 0,
          centerTitle: false,
          leading: GestureDetector(
              onTap: widget.onSave,
              child: Icon(
                Icons.clear_rounded,
                color: Theme.of(context).colorScheme.onSurface,
              )),
          title: CustomTextWidget(
            textToDisplay: 'Categories  ',
            textStyle: textTheme.headline6?.copyWith(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.transparent,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: notifier.interestList.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            onTap: () => notifier.insertInterestList(context, index),
                            title: CustomTextWidget(
                              textAlign: TextAlign.left,
                              textToDisplay: notifier.interestList[index].interestName!,
                              // textStyle: Theme.of(context).primaryTextTheme.titleMedium,
                            ),
                            trailing: notifier.pickedInterest(notifier.interestList[index].interestName)
                                ? Icon(
                                    Icons.check_box,
                                    color: kHyppePrimary,
                                  )
                                : Icon(
                                    Icons.check_box_outline_blank,
                                    color: kHyppePrimary,
                                  ),
                          );
                        },
                      ),
                      CustomElevatedButton(
                        width: 375.0 * SizeConfig.scaleDiagonal,
                        height: 44.0 * SizeConfig.scaleDiagonal,
                        function: widget.onSave,
                        child: CustomTextWidget(
                          textToDisplay: notifier.language.save!,
                          textStyle: textTheme.button?.copyWith(color: kHyppeLightButtonText),
                        ),
                        buttonStyle: ButtonStyle(
                          foregroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primaryVariant),
                          shadowColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primaryVariant),
                          overlayColor: MaterialStateProperty.all(kHyppeLightExtended4),
                          backgroundColor: MaterialStateProperty.all(kHyppePrimary),
                        ),
                      ),
                    ],
                  ),
                ],
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
