import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/app.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:provider/provider.dart';

import '../../../../../../inner/upload/preview_content/notifier.dart';
import '../../../../../widget/no_result_found.dart';
import 'music_item.dart';

class ExplorerMusicsScreen extends StatefulWidget {

  const ExplorerMusicsScreen({Key? key}) : super(key: key);

  @override
  State<ExplorerMusicsScreen> createState() => _ExplorerMusicsScreenState();
}

class _ExplorerMusicsScreenState extends State<ExplorerMusicsScreen> {

  @override
  void initState() {
    final notifier = materialAppKey.currentContext!.read<PreviewContentNotifier>();
    notifier.scrollController = ScrollController();
    notifier.audioPlayer = AudioPlayer();
    notifier.scrollExpController.addListener(() {
      notifier.onScrollExpMusics(materialAppKey.currentContext!);
    });
    super.initState();
  }


  @override
  void dispose() {
    final notifier = materialAppKey.currentContext!.read<PreviewContentNotifier>();
    notifier.scrollController.dispose();
    notifier.disposeMusic();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<PreviewContentNotifier>(context);
    return notifier.listExpMusics.isNotEmpty ? ListView.builder(
      itemCount: !notifier.isNextExpMusic ? notifier.listExpMusics.length : notifier.listExpMusics.length + 1,
      controller: notifier.scrollExpController,
      scrollDirection: Axis.vertical,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 10),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemBuilder: (context, index) {
        if (index == notifier.listExpMusics.length && notifier.isNextExpMusic) {
          return Container(
            width: double.infinity,
            height: 30,
            alignment: Alignment.center,
            child: const CustomLoading(),
          );
        }
        return MusicItemScreen(music: notifier.listExpMusics[index], index: index, isExplored: true,);
      },
    ): const NoResultFound();
  }
}
