import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/arguments/hashtag_argument.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/search/search_content.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

import '../../../app.dart';
import '../../../core/constants/enum.dart';
import '../../../core/services/system.dart';
import '../../inner/notification/notifier.dart';

class CustomNewDescContent extends StatefulWidget {
  final String? email;
  final String username;
  final String desc;
  final int trimLines;
  final int trimLength;
  final TextAlign? textAlign;
  final TextOverflow? textOverflow;
  final TextStyle? hrefStyle;
  final TextStyle? normStyle;
  final TextStyle? expandStyle;
  final String? seeMore;
  final String? seeLess;
  final String? delimiter;

  final Function(bool val)? callback;

  CustomNewDescContent(
      {Key? key,
      this.email,
      required this.username,
      required this.desc,
      this.trimLines = 2,
      this.trimLength = 240,
      this.textAlign,
      this.callback,
      this.hrefStyle,
      this.normStyle,
      this.expandStyle,
      this.seeMore,
      this.seeLess,
      this.textOverflow,
      this.delimiter = '\u2026 '})
      : super(key: key);

  @override
  State<CustomNewDescContent> createState() => _CustomNewDescContentState();
}

class _CustomNewDescContentState extends State<CustomNewDescContent> {
  bool _readMore = true;
  bool isClicked = false;

  final String _kLineSeparator = '\u2028';
  var desc = '';

  void _onSeeMore() {
    (_readMore ? 'test click seeMore' : 'test click seeLess ').logger();
    setState(() {
      _readMore = !_readMore;
    });
  }

  @override
  Widget build(BuildContext context) {
    desc = widget.desc;
    final values = desc.split('\n');
    for (var i = 0; i < values.length; i++) {
      try {
        final last = values[i].split(' ').last;
        // print('has Emoji: $last');
        if (last.hasEmoji()) {
          // print('has Emoji ini');
          values[i] += ' ';
        }
      } catch (e) {
        e.logger();
      }
    }
    if (values.isNotEmpty) {
      desc = '';
      for (var i = 0; i < values.length; i++) {
        if (i == (values.length - 1)) {
          desc += values[i];
        } else {
          desc += '${values[i]}\n';
        }
      }
    }

    // descItems.add(ItemDesc())
    return fixDescLayout(context);
  }

  Widget fixDescLayout(BuildContext context) {
    final DefaultTextStyle defaultTextStyle = DefaultTextStyle.of(context);
    TextStyle? effectiveTextStyle = widget.normStyle;
    if (widget.normStyle?.inherit ?? false) {
      effectiveTextStyle = defaultTextStyle.style.merge(widget.normStyle);
    }

    final textAlign = widget.textAlign ?? defaultTextStyle.textAlign ?? TextAlign.start;
    final textDirection = Directionality.of(context);
    final textScaleFactor = MediaQuery.textScaleFactorOf(context);

    final colorClickableText = Theme.of(context).colorScheme.surface;
    final _defaultMoreLessStyle = widget.expandStyle?.copyWith(fontSize: 12) ?? effectiveTextStyle?.copyWith(color: colorClickableText, fontSize: 12);
    final _defaultDelimiterStyle = widget.normStyle ?? effectiveTextStyle;

    final link = TextSpan(text: _readMore ? widget.seeMore : widget.seeLess, style: _defaultMoreLessStyle, recognizer: TapGestureRecognizer()..onTap = _onSeeMore);

    final _delimiter = TextSpan(
        text: _readMore
            ? widget.seeMore != null
                ? widget.seeMore!.isNotEmpty
                    ? widget.delimiter
                    : ''
                : ''
            : '',
        style: _defaultDelimiterStyle,
        recognizer: TapGestureRecognizer()..onTap = _onSeeMore);

    // print('desc ${widget.desc} ');
    Widget result = LayoutBuilder(builder: (context, constraints) {
      assert(constraints.hasBoundedWidth);
      final maxWidth = constraints.maxWidth;

      final text = TextSpan(
        children: [TextSpan(text: desc, style: effectiveTextStyle)],
      );

      final textPainter = TextPainter(
        text: link,
        textAlign: textAlign,
        textDirection: textDirection,
        textScaleFactor: textScaleFactor,
        maxLines: widget.trimLines,
      );

      textPainter.layout(minWidth: 0, maxWidth: maxWidth);
      final linkSize = textPainter.size;

      textPainter.text = _delimiter;
      textPainter.layout(minWidth: 0, maxWidth: maxWidth);
      final delimiterSize = textPainter.size;

      textPainter.text = text;
      textPainter.layout(minWidth: constraints.maxWidth, maxWidth: maxWidth);
      final textSize = textPainter.size;

      var linkLongerThanLine = false;
      int endIndex;

      if (linkSize.width < maxWidth) {
        final readMoreSize = linkSize.width + delimiterSize.width;
        final pos = textPainter.getPositionForOffset(Offset(
          textDirection == TextDirection.rtl ? readMoreSize : textSize.width - readMoreSize,
          textSize.height,
        ));
        endIndex = textPainter.getOffsetBefore(pos.offset) ?? 0;
      } else {
        var pos = textPainter.getPositionForOffset(
          textSize.bottomLeft(Offset.zero),
        );
        endIndex = pos.offset;
        linkLongerThanLine = true;
      }

      if (textPainter.didExceedMaxLines) {
        var textSpan = TextSpan(
          style: effectiveTextStyle,
          children: collectDescItems(context, getDescItems(lastIndex: endIndex, linkLongerThanLine: linkLongerThanLine), spanTrim: link, lastIndex: endIndex),
        );
        return Text.rich(
          TextSpan(
              text: "${widget.username} ",
              recognizer: TapGestureRecognizer()..onTap = () => widget.email != null ? System().navigateToProfile(context, widget.email ?? '') :null,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: kHyppeTextLightPrimary,
              ), // default text style
              children: <TextSpan>[textSpan]),
          textAlign: textAlign,
          textDirection: textDirection,
          softWrap: true,
          overflow: widget.textOverflow ?? TextOverflow.clip,
          textScaleFactor: textScaleFactor,
        );
      } else {
        var textSpan = TextSpan(
          style: effectiveTextStyle,
          children: collectDescItems(context, lastIndex: null, getDescItems(lastIndex: null, linkLongerThanLine: linkLongerThanLine)),
        );
        return Text.rich(
          TextSpan(
              text: "${widget.username} ",
              recognizer: TapGestureRecognizer()..onTap = () => System().navigateToProfile(context, widget.email ?? ''),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: kHyppeTextLightPrimary,
              ), // default te text style
              children: <TextSpan>[textSpan]),
          textAlign: textAlign,
          textDirection: textDirection,
          softWrap: true,
          overflow: widget.textOverflow ?? TextOverflow.clip,
          textScaleFactor: textScaleFactor,
        );
      }
    });

    return result;
  }

  List<TextSpan> collectDescItems(BuildContext context, List<ItemDesc> items, {int? lastIndex, TextSpan? spanTrim}) {
    List<TextSpan> results = [];
    bool isSeeLess = items.where((element) => element.type == CaptionType.seeMore).toList().isNotEmpty;
    for (var item in items) {
      if (item.type == CaptionType.seeMore || item.type == CaptionType.seeLess) {
        if (spanTrim != null) {
          results.add(spanTrim);
        }
      } else {
        bool error = false;
        if (item.type == CaptionType.normal) {
          final lastDesc = item.desc.split(' ').last;
          if (lastDesc.hasEmoji()) {
            error = true;
          }
        }
        // print('state $desc $error && $isSeeLess && ${lastIndex != null}');
        // final fixdesc = item.desc;
        String fixdesc = '';
        if(error && isSeeLess && lastIndex != null){
          final texts = item.desc.split(' ');
          for(final item in texts){
            if(!item.hasEmoji()){
              fixdesc += '$item ';
            }

          }
        }else{
          fixdesc = item.desc;
        }
        if(error){

        }
        results.add(TextSpan(
            text: fixdesc,
            style: item.type == CaptionType.mention || item.type == CaptionType.hashtag
                ? (widget.hrefStyle ?? Theme.of(context).textTheme.bodyText2!.copyWith(color: Theme.of(context).colorScheme.primary))
                : (widget.normStyle ?? Theme.of(context).textTheme.bodyText2!.copyWith()),
            recognizer: item.type == CaptionType.normal
                ? null
                : (TapGestureRecognizer()
                  ..onTap = () async {
                  if(!isClicked){
                    setState(() {
                      isClicked = true;
                    });
                    if (item.type == CaptionType.hashtag) {
                      var fixKeyword = item.desc[0] == '#' ? item.desc.substring(1, item.desc.length) : item.desc;
                      fixKeyword = fixKeyword.replaceAll(',', '');
                      await Routing().move(Routes.hashtagDetail, argument: HashtagArgument(isTitle: false, hashtag: Tags(tag: fixKeyword, id: fixKeyword), fromRoute: true));
                    } else {
                      final fixUsername = item.desc[0] == '@' ? item.desc.substring(1, item.desc.length) : item.desc;
                      await materialAppKey.currentContext!.read<NotificationNotifier>().checkAndNavigateToProfile(context, fixUsername);
                    }
                    setState(() {
                      isClicked = false;
                    });
                  }

                  })));
      }
    }
    return results;
  }

  List<ItemDesc> getDescItems({int? lastIndex, required bool linkLongerThanLine}) {
    var fixDesc = _readMore
        ? lastIndex != null
            ? desc.substring(0, lastIndex + 1) + (linkLongerThanLine ? _kLineSeparator : '')
            : desc
        : desc;
    fixDesc = fixDesc.replaceAll('\n@', '\n @');
    fixDesc = fixDesc.replaceAll('\n#', '\n #');
    fixDesc = fixDesc.replaceAll('\n', ' \n');

    var splitDesc = fixDesc.split(' ');
    splitDesc.removeWhere((e) => e == '');
    // for (final desc in splitDesc) {
    //   // 'Fix Desc: $desc'.logger();
    // }
    final List<ItemDesc> descItems = [];
    var tempDesc = '';

    // print('check descItems3 ${fixDesc}');
    for (var i = 0; splitDesc.length > i; i++) {
      if (splitDesc[i].isNotEmpty) {
        final firstChar = splitDesc[i].substring(0, 1);
        if (firstChar == '@') {
          if (tempDesc.isNotEmpty) {
            descItems.add(ItemDesc(desc: '$tempDesc ', type: CaptionType.normal));
            tempDesc = '';
          }
          // print('hit prepare username: ${splitDesc[i].substring(0, 1)} , ${splitDesc[i].substring(1, splitDesc[i].length)}');
          if(splitDesc[i].contains("@GuestHyppe")){
            descItems.add(ItemDesc(desc: '${splitDesc[i]} ', type: CaptionType.normal));
          }else{
            descItems.add(ItemDesc(desc: '${splitDesc[i]} ', type: CaptionType.mention));
          }
        } else if (firstChar == '#' && splitDesc[i].length > 1) {
          final lenght = splitDesc[i].length;
          final content = splitDesc[i].substring(1, lenght);
          // print('content: $content');
          final isSpecialChar = System().charForTag(content);
          if (!isSpecialChar) {
            tempDesc = '$tempDesc ${splitDesc[i]}';
            if (i == (splitDesc.length - 1)) {
              descItems.add(ItemDesc(desc: getWithoutSpaces(tempDesc), type: CaptionType.normal));
            }
          } else {
            if (tempDesc.isNotEmpty) {
              descItems.add(ItemDesc(desc: '$tempDesc ', type: CaptionType.normal));
              tempDesc = '';
            }
            descItems.add(ItemDesc(desc: '${splitDesc[i]}  ', type: CaptionType.hashtag));
          }
        } else {
          tempDesc = '$tempDesc ${splitDesc[i]}';
          if (i == (splitDesc.length - 1)) {
            descItems.add(ItemDesc(desc: getWithoutSpaces(tempDesc), type: CaptionType.normal));
          }
        }
      }
    }

    if (widget.seeMore != null && widget.seeLess != null) {
      descItems.add(ItemDesc(desc: _readMore ? (widget.seeMore ?? '') : (widget.seeLess ?? ''), type: _readMore ? CaptionType.seeMore : CaptionType.seeLess));
    }

    ///only for check the results
    for (var i = 0; i < descItems.length; i++) {
      // print('CaptionType.seeMore ${descItems[i].type}');
      // print('check descItems ${descItems[i].desc}');
    }
    return descItems;
  }

  String getWithoutSpaces(String s) {
    String tmp = s.substring(1, s.length);
    while (tmp.startsWith(' ')) {
      tmp = tmp.substring(1);
    }

    return tmp;
  }
}

class ItemDesc {
  String desc;
  CaptionType type;
  ItemDesc({required this.desc, required this.type});
}
