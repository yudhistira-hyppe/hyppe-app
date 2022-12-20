import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/ui/constant/widget/custom_rich_text_widget.dart';

import '../../../core/constants/enum.dart';


class CustomDescContent extends StatefulWidget {
  final String desc;
  final int trimLines;
  final int trimLength;
  final TextAlign? textAlign;
  TextStyle? hrefStyle;
  TextStyle? normStyle;
  TextStyle? expandStyle;
  String? seeMore;
  String? seeLess;
  String? delimiter;

  final Function(bool val)? callback;

  CustomDescContent({
    Key? key,
    required this.desc,
    this.trimLines = 2,
    this.trimLength = 240,
    this.textAlign,
    this.callback,
    this.hrefStyle,
    this.normStyle,
    this.seeMore,
    this.delimiter}) : super(key: key);

  @override
  State<CustomDescContent> createState() => _CustomDescContentState();
}

class _CustomDescContentState extends State<CustomDescContent> {

  bool _readMore = true;

  final String _kLineSeparator = '\u2028';

  void _onSeeMore(){
    (_readMore ? 'test click seeMore' : 'test click seeLess').logger();
    setState(() {
      _readMore = !_readMore;
    });

  }
  @override
  Widget build(BuildContext context) {




    // descItems.add(ItemDesc())
    return fixDescLayout(context);
  }

  Widget fixDescLayout(BuildContext context){

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
    // final _defaultMoreStyle = widget.expandStyle ?? effectiveTextStyle?.copyWith(color: colorClickableText);
    final _defaultDelimiterStyle = widget.normStyle ?? effectiveTextStyle;

    final link = TextSpan(
      text: _readMore ? widget.seeMore : widget.seeLess,
      style: _defaultMoreLessStyle,
      recognizer: TapGestureRecognizer()..onTap = _onSeeMore
    );

    final _delimiter = TextSpan(
        text: _readMore
            ? widget.seeMore != null
            ? widget.seeMore!.isNotEmpty
            ? widget.delimiter
            : ''
            : ''
            : '', style: _defaultDelimiterStyle,
        recognizer: TapGestureRecognizer()..onTap = _onSeeMore);



    return LayoutBuilder(
      builder: (context, constraints) {
        assert(constraints.hasBoundedWidth);
        final maxWidth = constraints.maxWidth;

        final text = TextSpan(
          children: collectDescItems(context, getDescItems(linkLongerThanLine: false), link),
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

        if (linkSize.width < maxWidth){
          final readMoreSize = linkSize.width + delimiterSize.width;
          final pos = textPainter.getPositionForOffset(
              Offset(
                  textDirection == TextDirection.rtl
                      ? readMoreSize
                      : textSize.width - readMoreSize,
                  textSize.height,
              )
          );
          endIndex = textPainter.getOffsetBefore(pos.offset) ?? 0;
        }else{
          var pos = textPainter.getPositionForOffset(
              textSize.bottomLeft(
                  Offset.zero
              )
          );
          endIndex = pos.offset;
          linkLongerThanLine = true;
        }

        var textSpan = TextSpan(
          children: collectDescItems(context, getDescItems(lastIndex: endIndex, linkLongerThanLine: linkLongerThanLine), link,),
        );


        return CustomRichTextWidget(textSpan: textSpan);
      }
    );
  }

  List<TextSpan> collectDescItems(BuildContext context, List<ItemDesc> items, TextSpan spanTrim){
    List<TextSpan> results = [];
    var tempIndex = 0;
    for(var item in items){
      if(item.type == CaptionType.seeMore || item.type == CaptionType.seeLess){
        results.add(spanTrim);
      }else{
        results.add(TextSpan(
            text: item.desc,
            style: item.type == CaptionType.mention ? (widget.hrefStyle ?? Theme.of(context).textTheme.bodyText2!.copyWith(color: Theme.of(context).colorScheme.primaryVariant)) : (widget.normStyle ?? Theme.of(context).textTheme.bodyText2!.copyWith()),
            recognizer: item.type == CaptionType.normal ? null : (TapGestureRecognizer()..onTap = (){
              print('test click mention');
            })
        ));
      }
    }
    return results;
  }

  List<ItemDesc> getDescItems({int? lastIndex, required bool linkLongerThanLine}){
    final fixDesc = _readMore ? lastIndex != null ? widget.desc.substring(0, lastIndex) + (linkLongerThanLine ? _kLineSeparator : '') : widget.desc : widget.desc;
    final splitDesc = fixDesc.split(' ');
    final List<ItemDesc> descItems = [];
    var tempDesc = '';
    for(var item in splitDesc){
      print('my description $item');
      if(item.isNotEmpty){
        final firstChar = item[0];
        if(firstChar == '@'){
          if(tempDesc.isNotEmpty){
            descItems.add(ItemDesc(desc: '$tempDesc ', type: CaptionType.mention));
            tempDesc = '';
          }
          descItems.add(ItemDesc(desc: item, type: CaptionType.normal));
        }else{
          tempDesc = '$tempDesc $item';
        }
      }
    }

    return descItems;
  }
}


// class CustomDescContent extends StatelessWidget {
//   final String desc;
//   TextStyle? hrefStyle;
//   TextStyle? normStyle;
//   TextStyle? expandStyle;
//   CustomDescContent({Key? key, required this.desc, this.hrefStyle, this.normStyle}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final splitDesc = desc.split(' ');
//     final List<ItemDesc> descItems = [];
//     var tempDesc = '';
//     for(var item in splitDesc){
//       print('my description $item');
//       if(item.isNotEmpty){
//         final firstChar = item[0];
//         if(firstChar == '@'){
//           if(tempDesc.isNotEmpty){
//             descItems.add(ItemDesc(desc: '$tempDesc ', type: CaptionType.mention));
//             tempDesc = '';
//           }
//           descItems.add(ItemDesc(desc: item, type: CaptionType.normal));
//         }else{
//           tempDesc = '$tempDesc $item';
//         }
//       }
//     }
//     return CustomRichTextWidget(textSpan: TextSpan(children: collectDescItems(context, descItems)));
//   }
//
//   List<TextSpan> collectDescItems(BuildContext context, List<ItemDesc> items){
//     List<TextSpan> results = [];
//     for(var item in items){
//       results.add(TextSpan(
//         text: item.desc,
//         style: (item.type == CaptionType.seeMore || item.type == CaptionType.seeLess) ? (expandStyle ?? Theme.of(context).textTheme.bodyText1!.copyWith(color: Theme.of(context).colorScheme.primaryVariant)) : item.type == CaptionType.mention ? (hrefStyle ?? Theme.of(context).textTheme.bodyText2!.copyWith(color: Theme.of(context).colorScheme.primaryVariant)) : ( normStyle ?? Theme.of(context).textTheme.bodyText2!.copyWith()),
//         recognizer: item.type == CaptionType.normal ? null : (TapGestureRecognizer()..onTap = (){
//           print('test click');
//         })
//       ));
//     }
//     return results;
//   }
// }

class ItemDesc{
  final String desc;
  final CaptionType type;
  const ItemDesc({
    required this.desc, required this.type
  });
}
