import 'package:flutter/material.dart';
import 'package:hyppe/app.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:provider/provider.dart';

import '../../../../../../inner/upload/preview_content/notifier.dart';
import '../../../../../widget/custom_text_widget.dart';
import 'music_item.dart';

class PopularMusicTab extends StatefulWidget {
  bool isExplored;

  PopularMusicTab({Key? key, this.isExplored = false}) : super(key: key);

  @override
  State<PopularMusicTab> createState() => _PopularMusicTabState();
}

class _PopularMusicTabState extends State<PopularMusicTab> {

  @override
  void initState() {
    final notifier = materialAppKey.currentContext!.read<PreviewContentNotifier>();
    notifier.scrollController.addListener(() {
      notifier.onScrollMusics(materialAppKey.currentContext!);
    });
    notifier.scrollExpController.addListener(() {
      notifier.onScrollExpMusics(materialAppKey.currentContext!);
    });
    super.initState();
  }


  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<PreviewContentNotifier>(context);
    return !notifier.isLoadingMusic ? (!widget.isExplored ? notifier.listMusics : notifier.listExpMusics).isNotEmpty ? ListView.builder(
      itemCount: !widget.isExplored ? (!notifier.isNextMusic ? notifier.listMusics.length : notifier.listMusics.length + 1 ) : (!notifier.isNextExpMusic ? notifier.listExpMusics.length : notifier.listExpMusics.length + 1),
      controller: !widget.isExplored ? notifier.scrollController : notifier.scrollExpController,
      scrollDirection: Axis.vertical,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 10),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemBuilder: (context, index) {
        if(widget.isExplored){
          if (index == notifier.listExpMusics.length && notifier.isNextExpMusic) {
            return Container(
              width: double.infinity,
              height: 30,
              alignment: Alignment.center,
              child: const CustomLoading(),
            );
          }
        }else{
          if (index == notifier.listMusics.length && notifier.isNextMusic) {
            return Container(
              width: double.infinity,
              height: 30,
              alignment: Alignment.center,
              child: const CustomLoading(),
            );
          }
        }
        return MusicItemScreen(music: !widget.isExplored ? notifier.listMusics[index] : notifier.listExpMusics[index], index: index, isExplored: widget.isExplored,);
      },
    ): Center(
      child: CustomTextWidget(textToDisplay: notifier.language.noData ?? ''),
    ): const Center(
      child: CustomLoading(),
    );
  }
}
