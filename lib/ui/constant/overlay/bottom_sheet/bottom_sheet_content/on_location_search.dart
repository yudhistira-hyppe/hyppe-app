import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/constant/widget/custom_search_bar.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
// import 'package:google_places_flutter/address_search.dart';

class OnLocationSearchBottomSheet extends StatefulWidget {
  final String value;
  final Function() onSave;
  final Function() onCancel;

  final Function(String value) onChange;

  const OnLocationSearchBottomSheet({
    Key? key,
    required this.value,
    required this.onSave,
    required this.onChange,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<OnLocationSearchBottomSheet> createState() => _OnLocationSearchBottomSheetState();
}

class _OnLocationSearchBottomSheetState extends State<OnLocationSearchBottomSheet> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

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
            textToDisplay: notifier.language.selectLocation!,
            textStyle: textTheme.headline6?.copyWith(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.transparent,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              CustomSearchBar(
                hintText: notifier.language.search,
                contentPadding: EdgeInsets.symmetric(vertical: 16 * SizeConfig.scaleDiagonal),
                controller: notifier.location,
                onChanged: (val) => notifier.searchLocation(context, input: val),
              ),
              Expanded(
                child: notifier.modelGoogleMapPlace != null
                    ? ListView.builder(
                        shrinkWrap: true,
                        itemCount: notifier.modelGoogleMapPlace?.predictions!.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            onTap: () {
                              // widget.onSave;
                              Routing().moveBack();
                              notifier.locationName = notifier.modelGoogleMapPlace!.predictions![index].description!;
                            },
                            title: CustomTextWidget(
                              textAlign: TextAlign.start,
                              textToDisplay: notifier.modelGoogleMapPlace!.predictions![index].structuredFormatting!.mainText!,
                            ),
                            subtitle: CustomTextWidget(
                              textAlign: TextAlign.start,
                              maxLines: 2,
                              textToDisplay: notifier.modelGoogleMapPlace!.predictions![index].structuredFormatting!.secondaryText!,
                            ),
                          );
                        },
                      )
                    : Container(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
