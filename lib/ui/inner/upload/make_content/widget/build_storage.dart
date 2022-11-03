import 'dart:io';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/inner/upload/make_content/notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BuildStorage extends StatelessWidget {
  final bool? mounted;
  const BuildStorage({Key? key, this.mounted}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MakeContentNotifier>(
      builder: (_, notifier, __) => SizedBox(
        width: 41 * SizeConfig.scaleDiagonal,
        height: 41 * SizeConfig.scaleDiagonal,
        child: Center(
          child: GestureDetector(
            onTap: () {
              if (!notifier.isRecordingVideo) notifier.onTapOnFrameLocalMedia(context, mounted);
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: _buildIcon(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    if (Platform.isIOS || context.read<MakeContentNotifier>().thumbnailImageLocal == null) {
      return const Icon(Icons.photo_album, color: Colors.white);
    }

    return Container(
        width: 41 * SizeConfig.scaleDiagonal,
        height: 41 * SizeConfig.scaleDiagonal,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2.0),
            border: Border.all(width: 1.0, color: Theme.of(context).textTheme.caption?.color ?? Colors.white),
            image: DecorationImage(fit: BoxFit.fill, image: FileImage(File(context.read<MakeContentNotifier>().thumbnailImageLocal ?? '')))));
  }
}
