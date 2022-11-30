import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/app.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:provider/provider.dart';

import '../../../../../../inner/upload/preview_content/notifier.dart';
import '../../../../../widget/custom_text_widget.dart';
import 'music_item.dart';

class PopularMusicTab extends StatefulWidget {

  const PopularMusicTab({Key? key}) : super(key: key);

  @override
  State<PopularMusicTab> createState() => _PopularMusicTabState();
}

class _PopularMusicTabState extends State<PopularMusicTab> {

  @override
  void initState() {
    final notifier = materialAppKey.currentContext!.read<PreviewContentNotifier>();
    notifier.scrollController = ScrollController();
    notifier.audioPlayer = AudioPlayer();
    notifier.scrollController.addListener(() {
      notifier.onScrollMusics(materialAppKey.currentContext!);
    });
    super.initState();
  }

  @override
  void dispose() {
    final notifier = materialAppKey.currentContext!.read<PreviewContentNotifier>();
    notifier.disposeMusic();
    notifier.scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<PreviewContentNotifier>(context);
    return notifier.listMusics.isNotEmpty ? ListView.builder(
      itemCount: !notifier.isNextMusic ? notifier.listMusics.length : notifier.listMusics.length + 1 ,
      controller: notifier.scrollController,
      scrollDirection: Axis.vertical,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 10),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemBuilder: (context, index) {
        if (index == notifier.listMusics.length && notifier.isNextMusic) {
          return Container(
            width: double.infinity,
            height: 30,
            alignment: Alignment.center,
            child: const CustomLoading(),
          );
        }
        return MusicItemScreen(music: notifier.listMusics[index], index: index);
      },
    ): Center(
      child: CustomTextWidget(textToDisplay: notifier.language.noData ?? ''),
    );
  }
}
