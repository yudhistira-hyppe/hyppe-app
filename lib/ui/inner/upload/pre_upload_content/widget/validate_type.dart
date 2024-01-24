import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/services/system.dart';
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

class _ValidateTypeState extends State<ValidateType> {
  bool isEditingOverlay = false;
  bool? _isImage;
  bool isLoading = true;
  // ignore: prefer_typing_uninitialized_variables
  var isEditingContent;


  @override
  void initState() {
    afterFirstLayout();
    isLoading = false;
    super.initState();
  }

  void afterFirstLayout() {
    context.read<PreUploadContentNotifier>().initThumbnail().then((value) => getThumbnail());
  }
  Future getThumbnail() async {
    // await Future.delayed(Duration(milliseconds: 200),(){});
    final notifier =
          Provider.of<PreUploadContentNotifier>(context, listen: false);

      _isImage = System()
          .lookupContentMimeType(
              notifier.fileContent?[0]?.split('/').reversed.elementAt(0) ?? '')
          ?.contains('image');

      isEditingOverlay = widget.editContent
          ? notifier.featureType == FeatureType.pic
          : (_isImage ?? false) || _isImage == null;
      print('Thumbnail ${notifier.thumbNail}');
      // notifier.initThumbnail();
      
      isEditingContent = widget.editContent
          ? CachedNetworkImage(
              imageUrl: notifier.thumbNail ?? '',
            )
          : (_isImage ?? false) || _isImage == null
              ? notifier.featureType == FeatureType.pic
                  ? MemoryImage(
                      File(notifier.fileContent?[0] ?? '').readAsBytesSync())
                  : FileImage(File(notifier.fileContent?[0] ?? ''))
              : notifier.thumbNail != null
                  ? MemoryImage(notifier.thumbNail!)
                  : const AssetImage('${AssetPath.pngPath}content-error.png');
      setState(() {
        
      });
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topRight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        image: isEditingContent == null
            ? const DecorationImage(
                scale: 1,
                image: AssetImage('${AssetPath.pngPath}content-error.png'),
                fit: BoxFit.cover,
              )
            : DecorationImage(
                scale: 1,
                image: isEditingContent as ImageProvider,
                fit: BoxFit.cover,
                onError: (error, stackTrace) => Container(
                      width: 40 * SizeConfig.scaleDiagonal,
                      height: 40 * SizeConfig.scaleDiagonal,
                      decoration: BoxDecoration(
                        image: const DecorationImage(
                          image: AssetImage(
                              '${AssetPath.pngPath}content-error.png'),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    )),
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
