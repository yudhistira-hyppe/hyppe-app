import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/constant/entities/playlist/notifier.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ListBookmark extends StatefulWidget {
  @override
  _ListBookmarkState createState() => _ListBookmarkState();
}

class _ListBookmarkState extends State<ListBookmark> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    final notifier = Provider.of<PlaylistNotifier>(context, listen: false);
    _scrollController.addListener(() => notifier.addScrollListenerPlaylist(context, _scrollController));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistNotifier>(
      builder: (_, notifier, __) => Expanded(
        child: notifier.playlistData.isEmpty
            ? Center(
                child: Container(
                    height: 50,
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: CustomTextWidget(maxLines: 1, textToDisplay: notifier.language.noData!, textStyle: Theme.of(context).textTheme.subtitle1),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.0), color: Theme.of(context).colorScheme.surface)))
            : Column(
                children: [
                  Flexible(
                    flex: 7,
                    child: ListView.separated(
                      shrinkWrap: true,
                      controller: _scrollController,
                      itemCount: notifier.playlistData.length,
                      itemBuilder: (context, index) {
                        return Row(
                          children: [
                            Flexible(
                              flex: 11,
                              child: RadioListTile(
                                value: index,
                                contentPadding: const EdgeInsets.only(left: 5),
                                toggleable: true,
                                title: Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: CustomTextWidget(
                                    textToDisplay: notifier.playlistData[index].playlistName!,
                                    textStyle: Theme.of(context).textTheme.headline6,
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                                groupValue: notifier.indexList,
                                activeColor: const Color(0xff7F2D6C),
                                controlAffinity: ListTileControlAffinity.leading,
                                onChanged: (dynamic v) => notifier.indexList = v,
                              ),
                            ),
                            const Flexible(
                              flex: 3,
                              child: SizedBox(),
                            )
                          ],
                        );
                      },
                      scrollDirection: Axis.vertical,
                      physics: const BouncingScrollPhysics(),
                      separatorBuilder: (context, index) => const Divider(thickness: 0.25, color: Color(0xff7D8389)),
                    ),
                  ),
                  Flexible(
                    flex: 5,
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              CustomElevatedButton(
                                child: CustomTextWidget(
                                  textToDisplay: notifier.language.save!,
                                  textStyle: Theme.of(context).textTheme.button,
                                ),
                                buttonStyle: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all<Color>(
                                        notifier.indexList != null ? const Color(0xff822E6E) : const Color(0xff373A3C))),
                                width: 375.0 * SizeConfig.scaleDiagonal,
                                height: 56.0 * SizeConfig.scaleDiagonal,
                                function: () => notifier.addToBookmark(context, playlistID: notifier.playlistData[notifier.indexList!].playlistID),
                              ),
                              SizedBox(height: 5 * SizeConfig.scaleDiagonal),
                              CustomElevatedButton(
                                child: CustomTextWidget(
                                  textToDisplay: notifier.language.cancel!,
                                  textStyle: Theme.of(context).textTheme.button,
                                ),
                                buttonStyle: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent)),
                                width: 375.0 * SizeConfig.scaleDiagonal,
                                height: 56.0 * SizeConfig.scaleDiagonal,
                                function: () => Routing().moveBack(),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
