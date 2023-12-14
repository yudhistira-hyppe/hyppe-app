import 'dart:ui';

import 'package:flutter/scheduler.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/models/collection/sticker/sticker_category_model.dart';
import 'package:hyppe/core/models/collection/sticker/sticker_model.dart';
import 'package:hyppe/core/models/collection/sticker/sticker_tab.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_form_field.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/constant/widget/icon_button_widget.dart';
import 'package:hyppe/ui/inner/upload/preview_content/notifier.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../widget/custom_gif_widget.dart';

class OnShowSticker extends StatelessWidget {
  const OnShowSticker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<PreviewContentNotifier>(
      builder: (context, notifier, child) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(12),
            topLeft: Radius.circular(12),
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.78,
                  ),
                ),
              ),
            ),
            Column(
              children: [
                twelvePx,
                Container(
                  height: 4,
                  width: 36,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                twelvePx,
                Padding(
                  padding: const EdgeInsets.only(left: 14.0, right: 14.0),
                  child: Row(
                    children: [
                      Visibility(
                        visible: notifier.stickerSearchActive,
                        child: InkWell(
                          onTap: () {
                            notifier.stickerSearchActive = false;
                            notifier.stickerTextController.text = '';
                            notifier.stickerSearchText = '';
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                          child: const Padding(
                            padding: EdgeInsets.fromLTRB(0.0, 8.0, 8.0, 8.0),
                            child: Icon(Icons.arrow_back, color: Colors.white),
                          ),
                        ),
                      ),
                      Expanded(
                        child: CustomTextFormField(
                          onTap: () {
                            notifier.stickerSearchActive = true;
                          },
                          containerColor: Colors.white,
                          inputAreaWidth: double.infinity,
                          inputAreaHeight: 46.0 * SizeConfig.scaleDiagonal,
                          textEditingController: notifier.stickerTextController,
                          cursorColor: Colors.white,
                          inputDecoration: InputDecoration(
                            prefixIcon: notifier.stickerSearchActive
                                ? null
                                : const CustomIconButtonWidget(
                                    height: 24,
                                    defaultColor: false,
                                    onPressed: null,
                                    iconData: "${AssetPath.vectorPath}search.svg",
                                    color: Colors.white,
                                  ),
                            suffixIcon: notifier.stickerSearchActive
                                ? CustomIconButtonWidget(
                                    height: 24,
                                    defaultColor: false,
                                    onPressed: () {
                                      notifier.stickerTextController.text = '';
                                      notifier.stickerSearchText = '';
                                    },
                                    iconData:"${AssetPath.vectorPath}close.svg",
                                    color: Colors.white,
                                  )
                                : null,
                            hintText: notifier.stickerSearchActive ? '' : 'Cari ${notifier.stickerTab[notifier.stickerTabIndex].name} seru',
                            contentPadding: const EdgeInsets.all(16),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(color: kHyppeTextLightPrimary),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: kHyppeTextLightPrimary),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: kHyppeTextLightPrimary),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            fillColor: kHyppeTextLightPrimary,
                            filled: true,
                            hintStyle: const TextStyle(color: kHyppeLightButtonText),
                          ),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: kHyppeLightButtonText),
                          onChanged: (text) {
                            notifier.stickerSearchText = text;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                twelvePx,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (var tab in notifier.stickerTab)
                      menu(context, notifier: notifier, tab: tab)
                  ],
                ),
                // twelvePx,
                Builder(builder: (context) {
                  var allSticker = '';
                  for (StickerCategoryModel cat in notifier.stickerTab[notifier.stickerTabIndex].data) {
                    allSticker = '$allSticker - ${cat.queryname}';
                  }
                  if (!allSticker.toLowerCase().contains(notifier.stickerSearchText.toLowerCase())) {
                    return Container(
                      padding: const EdgeInsets.only(top: 80),
                      child: Column(
                        children: [
                          Text(
                            'Hasil Tidak Ditemukan',
                            style: Theme.of(context).textTheme.headline5?.copyWith(
                                      color: kHyppeBorderTab,
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                          twelvePx,
                          Text(
                            'Coba gunakan kata kunci lain.',
                            style:Theme.of(context).textTheme.bodyText2?.copyWith(color: kHyppeBorderTab),
                          ),
                        ],
                      ),
                    );
                  }
                  return Container();
                }),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          controller: notifier.stickerScrollController,
                          itemCount: notifier.stickerTab[notifier.stickerTabIndex].data.length,
                          itemBuilder: (context, index) {
                            var category = notifier.stickerTab[notifier.stickerTabIndex].data[index];
                            if (notifier.stickerSearchActive) {
                              if (notifier.stickerSearchText == '') {
                                return Container();
                              } else {
                                if (category.id == '' || category.queryname.toLowerCase().contains(notifier.stickerSearchText.toLowerCase())) {
                                  List<StickerModel> popular = [];
                                  popular.addAll(category.data ?? []);
                                  popular.sort((a, b) => (b.countused ?? 0).compareTo(a.countused ?? 0));
                                  return gridView(
                                    context,
                                    notifier: notifier,
                                    tab: notifier.stickerTab[notifier.stickerTabIndex],
                                    categoryIndex: index,
                                    stickers: popular,
                                  );
                                } else {
                                  return Container();
                                }  
                              }
                            }
                            return gridView(
                              context,
                              notifier: notifier,
                              tab: notifier.stickerTab[notifier.stickerTabIndex],
                              categoryIndex: index,
                              stickers: notifier.stickerTab[notifier.stickerTabIndex].data[index].data ?? []
                            );
                          },
                        ),
                      ),
                      bottomCategories(
                        context,
                        notifier: notifier,
                        tab: notifier.stickerTab[notifier.stickerTabIndex],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget menu(
    BuildContext context, {
    required PreviewContentNotifier notifier,
    required StickerTab tab,
  }) {
    return InkWell(
      onTap: () async {
        notifier.stickerTabIndex = tab.index;
        await notifier.getSticker(context, index: tab.index);
        notifier.stickerScrollController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
        notifier.stickerScrollPosition = 0.0;
      },
      child: Column(
        children: [
          Container(
            height: 36,
            margin: const EdgeInsets.symmetric(horizontal: 32),
            decoration: BoxDecoration(
              border: Border(
                bottom: tab.index == notifier.stickerTabIndex
                    ? const BorderSide(color: Colors.white)
                    : const BorderSide(color: Colors.transparent),
              ),
            ),
            child: Center(
              child: CustomTextWidget(
                textToDisplay: tab.name,
                textStyle: Theme.of(context).textTheme.bodyText2?.copyWith(
                      fontWeight: notifier.stickerTabIndex == tab.index
                          ? FontWeight.w700
                          : FontWeight.w400,
                      color: tab.index == notifier.stickerTabIndex
                          ? Colors.white
                          : const Color(0xffcecece),
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget bottomCategories(
    BuildContext context, {
    required PreviewContentNotifier notifier,
    required StickerTab tab,
  }) {
    if (!notifier.stickerSearchActive && tab.data.length > 1) {
      var itemHeight = (MediaQuery.of(context).size.width - 32) / tab.column;
      return SizedBox(
        height: 56,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: tab.data.length,
          itemBuilder: (ctx, index) {
            var cat = tab.data[index];
            return InkWell(
              onTap: () {
                double position = 0.0;
                for (int i = 0; i < index; i++) {
                  position = position + 40.0; // 40 is height of category title
                  int rowCount = ((tab.data[i].data?.length ?? 0) / tab.column).ceil();
                  position = position + (rowCount * itemHeight);  
                }
                notifier.stickerScrollController.animateTo(
                  position,
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.easeIn,
                );
              },
              child: Container(
                decoration:  BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(45)),
                  color: highlight(context, notifier, cat)
                ),
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(8),
                child: SizedBox(height: 24, width: 24, child: CachedNetworkImage(imageUrl: cat.kategoriicon ?? '',)),
              ),
            );
          },
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Color highlight(BuildContext context, PreviewContentNotifier notifier, StickerCategoryModel cat) {
    if (notifier.stickerScrollPosition + 50 >= cat.heightStart && notifier.stickerScrollPosition + 50 <= cat.heightEnd) {
      return Colors.black;
    }
    return Colors.transparent;
  }

  Widget gridView(
    BuildContext context, {
    required PreviewContentNotifier notifier,
    required StickerTab tab,
    required int categoryIndex,
    required List<StickerModel> stickers,
  }) {
    return WidgetSize(
      onChange: (Size size) {
        if (!notifier.stickerSearchActive) {
          notifier.stickerTab[notifier.stickerTabIndex].data[categoryIndex].height = size.height;
          if (categoryIndex == 0) {
            notifier.stickerTab[notifier.stickerTabIndex].data[categoryIndex].heightStart = 0.0;
            notifier.stickerTab[notifier.stickerTabIndex].data[categoryIndex].heightEnd = notifier.stickerTab[notifier.stickerTabIndex].data[categoryIndex].height;
          } else {
            notifier.stickerTab[notifier.stickerTabIndex].data[categoryIndex].heightStart = notifier.stickerTab[notifier.stickerTabIndex].data[categoryIndex - 1].heightEnd;
            notifier.stickerTab[notifier.stickerTabIndex].data[categoryIndex].heightEnd = notifier.stickerTab[notifier.stickerTabIndex].data[categoryIndex - 1].heightEnd + notifier.stickerTab[notifier.stickerTabIndex].data[categoryIndex].height;
          }
          // adding this code below to trigger highlight on first render
          if (categoryIndex == 0 && notifier.stickerScrollPosition == 0.0) {
            notifier.stickerScrollController.animateTo(1, duration: const Duration(milliseconds: 50), curve: Curves.easeIn);
          }
          size.loggerV2();
        }
      },
      child: Container(
        constraints: BoxConstraints(minHeight: categoryIndex + 1 == tab.data.length ? (MediaQuery.of(context).size.height * 0.8) - 175 : 0),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (tab.data[categoryIndex].id != '')
              SizedBox(
                height: 40,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    tab.data[categoryIndex].id,
                    style: const TextStyle(color: Color(0xffcecece)),
                  ),
                ),
              ),
            Wrap(
              children: [
                for (StickerModel sticker in stickers)
                  renderSticker(context, notifier: notifier, tab: tab, sticker: sticker),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget renderSticker(
    BuildContext context, {
    required PreviewContentNotifier notifier,
    required StickerTab tab,
    required StickerModel sticker,
  }) {
    return Visibility(
      visible: (sticker.name ?? '')
              .toLowerCase()
              .contains(notifier.stickerSearchText.toLowerCase()) ||
          (sticker.kategori ?? '')
              .toLowerCase()
              .contains(notifier.stickerSearchText.toLowerCase()),
      child: InkWell(
        onTap: () {
          notifier.addSticker(context, sticker);
        },
        child: Container(
          width: (MediaQuery.of(context).size.width - 32) / tab.column,
          height: (MediaQuery.of(context).size.width - 32) / tab.column,
          padding: const EdgeInsets.all(8),
          child: (sticker.image ?? '').toLowerCase().endsWith('.gif') ? CustomGifWidget(
            url: sticker.image ?? '',
            isPause: false,
          ) : CachedNetworkImage(
            imageUrl: sticker.image ?? '',
            progressIndicatorBuilder: (context, url, downloadProgress) => 
               Padding(
                 padding: EdgeInsets.all(60 / tab.column),
                 child: CircularProgressIndicator(
                    value: downloadProgress.progress ?? 0.0,
                    strokeWidth: 1,
                    color: kHyppeDisabled,
                    backgroundColor: kHyppeTextLightPrimary,
                  )
               ),
          ),
        ),
      ),
    );
  }
}

class WidgetSize extends StatefulWidget {
  final Widget child;
  final Function onChange;

  const WidgetSize({
    Key? key,
    required this.onChange,
    required this.child,
  }) : super(key: key);

  @override
  State<WidgetSize> createState() => _WidgetSizeState();
}

class _WidgetSizeState extends State<WidgetSize> {
  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback(postFrameCallback);
    return Container(
      key: widgetKey,
      child: widget.child,
    );
  }

  var widgetKey = GlobalKey();
  var oldSize;

  void postFrameCallback(_) {
    var context = widgetKey.currentContext;
    if (context == null) return;

    var newSize = context.size;
    if (oldSize == newSize) return;

    oldSize = newSize;
    widget.onChange(newSize);
  }
}
