import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/constant/widget/custom_rich_text_widget.dart';

import '../../../core/constants/enum.dart';


class CustomDescContent extends StatefulWidget {
  final String desc;
  TextStyle? hrefStyle;
  TextStyle? normStyle;
  TextStyle? expandStyle;
  String? seeMore;
  String? seeLess;

  CustomDescContent({Key? key, required this.desc, this.hrefStyle, this.normStyle, this.seeMore}) : super(key: key);

  @override
  State<CustomDescContent> createState() => _CustomDescContentState();
}

class _CustomDescContentState extends State<CustomDescContent> {
  @override
  Widget build(BuildContext context) {
    final splitDesc = widget.desc.split(' ');
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
    // descItems.add(ItemDesc())
    return CustomRichTextWidget(textSpan: TextSpan(children: collectDescItems(context, descItems)));
  }

  List<TextSpan> collectDescItems(BuildContext context, List<ItemDesc> items){
    List<TextSpan> results = [];
    for(var item in items){
      results.add(TextSpan(
          text: item.desc,
          style: (item.type == CaptionType.seeMore || item.type == CaptionType.seeLess) ? (widget.expandStyle ?? Theme.of(context).textTheme.bodyText1!.copyWith(color: Theme.of(context).colorScheme.primaryVariant)) : item.type == CaptionType.mention ? (widget.hrefStyle ?? Theme.of(context).textTheme.bodyText2!.copyWith(color: Theme.of(context).colorScheme.primaryVariant)) : (widget.normStyle ?? Theme.of(context).textTheme.bodyText2!.copyWith()),
          recognizer: item.type == CaptionType.normal ? null : (TapGestureRecognizer()..onTap = (){
            if(item.type == CaptionType.mention){
              print('test click mention');
            }else if(item.type == CaptionType.seeMore){
              print('test click seeMore');
            }else if(item.type == CaptionType.seeLess){
              print('test click seeLess');
            }
          })
      ));
    }



    return results;
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
