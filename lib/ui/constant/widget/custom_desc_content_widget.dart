import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:provider/provider.dart';

import '../../../app.dart';
import '../../../core/constants/enum.dart';
import '../../inner/notification/notifier.dart';

class CustomDescContent extends StatefulWidget {
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

  CustomDescContent(
      {Key? key,
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
  State<CustomDescContent> createState() => _CustomDescContentState();
}

class _CustomDescContentState extends State<CustomDescContent> {
  bool _readMore = true;

  final String _kLineSeparator = '\u2028';

  void _onSeeMore() {
    (_readMore ? 'test click seeMore' : 'test click seeLess ').logger();
    setState(() {
      _readMore = !_readMore;
    });
  }

  @override
  Widget build(BuildContext context) {
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

    final colorClickableText = Theme.of(context).colorScheme.secondary;
    final _defaultMoreLessStyle = widget.expandStyle ?? effectiveTextStyle?.copyWith(color: colorClickableText);
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

    print('desc ${widget.desc}');
    Widget result = LayoutBuilder(builder: (context, constraints) {
      assert(constraints.hasBoundedWidth);
      final maxWidth = constraints.maxWidth;

      final text = TextSpan(
        children: [TextSpan(text: widget.desc, style: effectiveTextStyle)],
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
          children: collectDescItems(
            context,
            getDescItems(lastIndex: endIndex, linkLongerThanLine: linkLongerThanLine),
            spanTrim: link,
          ),
        );
        return Text.rich(
          textSpan,
          textAlign: textAlign,
          textDirection: textDirection,
          softWrap: true,
          overflow: widget.textOverflow ?? TextOverflow.clip,
          textScaleFactor: textScaleFactor,
        );
      } else {
        var textSpan = TextSpan(
          style: effectiveTextStyle,
          children: collectDescItems(context, getDescItems(lastIndex: null, linkLongerThanLine: linkLongerThanLine)),
        );
        return Text.rich(
          textSpan,
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

  List<TextSpan> collectDescItems(BuildContext context, List<ItemDesc> items, {TextSpan? spanTrim}) {
    List<TextSpan> results = [];
    for (var item in items) {
      if (item.type == CaptionType.seeMore || item.type == CaptionType.seeLess) {
        if (spanTrim != null) {
          results.add(spanTrim);
        }
      } else {
        results.add(TextSpan(
            text: item.desc,
            style: item.type == CaptionType.mention
                ? (widget.hrefStyle ?? Theme.of(context).textTheme.bodyText2!.copyWith(color: Theme.of(context).colorScheme.primaryVariant))
                : (widget.normStyle ?? Theme.of(context).textTheme.bodyText2!.copyWith()),
            recognizer: item.type == CaptionType.normal
                ? null
                : (TapGestureRecognizer()
                  ..onTap = () {
                    final fixUsername = item.desc[0] == '@' ? item.desc.substring(1, item.desc.length) : item.desc;
                    materialAppKey.currentContext!.read<NotificationNotifier>().checkAndNavigateToProfile(context, fixUsername);
                  })));
      }
    }
    return results;
  }

  List<ItemDesc> getDescItems({int? lastIndex, required bool linkLongerThanLine}) {
    print('readmore $_readMore');
    var fixDesc = _readMore
        ? lastIndex != null
            ? widget.desc.substring(0, lastIndex + 1) + (linkLongerThanLine ? _kLineSeparator : '')
            : widget.desc
        : widget.desc;
    fixDesc = fixDesc.replaceAll('\n@', '\n @');

    var splitDesc = fixDesc.split(' ');
    splitDesc.removeWhere((e) => e == '');
    for(final desc in splitDesc){
      'Fix Desc: $desc'.logger();
    }
    final List<ItemDesc> descItems = [];
    var tempDesc = '';

    // print('check descItems3 ${fixDesc}');
    for(var i = 0; splitDesc.length > i; i++){
      if (splitDesc[i].isNotEmpty) {
        final firstChar = splitDesc[i].substring(0,1);
        if (firstChar == '@') {
          if (tempDesc.isNotEmpty) {
            descItems.add(ItemDesc(desc: '$tempDesc ', type: CaptionType.normal));
            tempDesc = '';
          }
          print('hit prepare username: ${splitDesc[i].substring(0, 1)} , ${splitDesc[i].substring(1, splitDesc[i].length)}');
          descItems.add(ItemDesc(desc: '${splitDesc[i]} ', type: CaptionType.mention));
        } else {
          tempDesc = '$tempDesc ${splitDesc[i]}';
          if (i == (splitDesc.length - 1)) {
            descItems.add(ItemDesc(desc: tempDesc, type: CaptionType.normal));
          }
        }
      }
    }

    if (widget.seeMore != null && widget.seeLess != null) {
      descItems.add(ItemDesc(desc: _readMore ? (widget.seeMore ?? '') : (widget.seeLess ?? ''), type: _readMore ? CaptionType.seeMore : CaptionType.seeLess));
    }

    for (var check in descItems) {
      print('CaptionType.seeMore ${check.type}');
      print('check descItems ${check.desc}');
    }
    return descItems;
  }
}

class ItemDesc {
  final String desc;
  final CaptionType type;
  const ItemDesc({required this.desc, required this.type});
}
