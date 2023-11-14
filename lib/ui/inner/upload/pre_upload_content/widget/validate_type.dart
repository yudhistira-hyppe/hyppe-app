import 'dart:io';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ValidateType extends StatefulWidget {
  final bool editContent;
  const ValidateType({Key? key, required this.editContent}) : super(key: key);

  @override
  State<ValidateType> createState() => _ValidateTypeState();
}

class _ValidateTypeState extends State<ValidateType> with AfterFirstLayoutMixin{

  @override
  void afterFirstLayout(BuildContext context) {
    context.read<PreUploadContentNotifier>().initThumbnail();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<PreUploadContentNotifier>(context);

    final _isImage = System().lookupContentMimeType(notifier.fileContent?[0]?.split('/').reversed.elementAt(0) ?? '')?.contains('image');

    final bool isEditingOverlay = widget.editContent ? notifier.featureType == FeatureType.pic : (_isImage ?? false) || _isImage == null;

    // notifier.initThumbnail();
    final isEditingContent = widget.editContent
        ? NetworkImage(notifier.thumbNail ?? '')
        : (_isImage ?? false) || _isImage == null
        ? notifier.featureType == FeatureType.pic
        ? MemoryImage(File(notifier.fileContent?[0] ?? '').readAsBytesSync())
        : FileImage(File(notifier.fileContent?[0] ?? ''))
        : notifier.thumbNail != null
        ? MemoryImage(notifier.thumbNail!)
        : const AssetImage('${AssetPath.pngPath}content-error.png');

    return Container(
      alignment: Alignment.topRight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        image: DecorationImage(
          scale: 1,
          image: isEditingContent as ImageProvider,
          fit: BoxFit.cover,
        ),
      ),
      width: 40 * SizeConfig.scaleDiagonal,
      height: 40 * SizeConfig.scaleDiagonal,
      child: isEditingOverlay
          ? const SizedBox.shrink()
          : Center(
        child: CustomIconWidget(
          defaultColor: false,
          iconData: '${AssetPath.vectorPath}pause.svg',
          width: 24 * SizeConfig.scaleDiagonal,
          height: 24 * SizeConfig.scaleDiagonal,
        ),
      ),
    );
  }
}

