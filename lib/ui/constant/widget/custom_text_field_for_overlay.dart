import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/services/overlay_service/overlay_handler.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/inner/upload/preview_content/notifier.dart';
import 'package:hyppe/ui/inner/upload/preview_content/widget/build_text_element.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomTextFieldForOverlay extends StatefulWidget {
  const CustomTextFieldForOverlay({Key? key}) : super(key: key);

  @override
  _CustomTextFieldForOverlayState createState() =>
      _CustomTextFieldForOverlayState();
}

class _CustomTextFieldForOverlayState extends State<CustomTextFieldForOverlay> {
  final FocusNode focusNode = FocusNode();
  final TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    focusNode.requestFocus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.5),
      child: Stack(
        children: [
          Align(
            alignment: const Alignment(-0.9, -0.85),
            child: CustomTextButton(
                onPressed: () {
                  textEditingController.clear();
                  context.read<OverlayHandlerProvider>().removeOverlay(context);
                },
                child: const CustomIconWidget(
                  iconData: "${AssetPath.vectorPath}close.svg",
                  defaultColor: false,
                  height: 30,
                  width: 30,
                )),
          ),
          Align(
            alignment: const Alignment(0.9, -0.85),
            child: CustomTextButton(
                onPressed: () {
                  if (textEditingController.text.isNotEmpty) {
                    context.read<PreviewContentNotifier>().addAdditionalItem(
                        widgetItem:
                            TextElement(caption: textEditingController.text),
                        offsetItem: Offset(
                            0.0, MediaQuery.of(context).size.height / 2));
                    textEditingController.clear();
                    context.read<PreviewContentNotifier>().addTextItemMode =
                        true;
                  }
                  context.read<OverlayHandlerProvider>().removeOverlay(context);
                },
                child: const CustomIconWidget(
                  iconData: "${AssetPath.vectorPath}checkmark.svg",
                  defaultColor: false,
                  height: 20,
                  width: 20,
                )),
          ),
          Center(
            child: TextFormField(
              maxLines: null,
              autofocus: true,
              cursorWidth: 1,
              cursorHeight: 42,
              focusNode: focusNode,
              textAlign: TextAlign.center,
              controller: textEditingController,
              textInputAction: TextInputAction.newline,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium!
                  .copyWith(fontWeight: FontWeight.w600),
              decoration: const InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
