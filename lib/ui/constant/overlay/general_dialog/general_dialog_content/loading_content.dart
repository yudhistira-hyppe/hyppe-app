import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/widget/process_upload_component.dart';

class LoadingDialog extends StatelessWidget {
  final bool uploadProses;
  const LoadingDialog({Key? key, this.uploadProses = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(8.0)),
      height: 100,
      width: size.width * 0.9,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          !uploadProses ? const CustomLoading() : const ProcessUploadComponent(),
          GestureDetector(
            // onTap: () => Routing().moveBack(),
            child: CustomTextWidget(
              textToDisplay: 'Please Wait',
              textStyle: theme.textTheme.subtitle1!.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
