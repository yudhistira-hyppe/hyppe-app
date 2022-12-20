import 'package:flutter/material.dart';
import 'package:hyppe/core/arguments/faq_argument.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

import '../../../../../constant/widget/custom_search_bar.dart';

class FAQDetailScreen extends StatefulWidget {

  FAQArgument data;

  FAQDetailScreen({Key? key, required this.data}) : super(key: key);

  @override
  State<FAQDetailScreen> createState() => _FAQDetailScreenState();
}

class _FAQDetailScreenState extends State<FAQDetailScreen> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<TranslateNotifierV2>(
      builder: (_, notifier, __) => Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          title: CustomTextWidget(
            textStyle: Theme.of(context).textTheme.subtitle1,
            textToDisplay: ' ${notifier.translate.help}',
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CustomSearchBar(
                hintText: notifier.translate.searchtopic,
                contentPadding: EdgeInsets.symmetric(vertical: 16),
                controller: controller,
                onSubmitted: (value){
                  setState(() {
                    controller.text;
                  });
                },
                // onSubmitted: (v) => notifier.onSearchPost(context, value: v),
                // onPressedIcon: () => notifier.onSearchPost(context),
                // onTap: () => notifier.moveSearchMore(),
                // onTap: () => _scaffoldKey.currentState.openEndDrawer(),
              ),
              eightPx,
              if(widget.data.details.isNotEmpty)
                Expanded(child:
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  child: ListView.builder(
                      itemCount: widget.data.details.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(onTap: (){
                          if(widget.data.details[index].detail.isNotEmpty){
                            Routing().move(Routes.faqDetail, argument: FAQArgument(details: widget.data.details[index].detail));
                          }
                        }, child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only( top: 10, bottom: 10, right: 10),
                          child: textSearched(context, widget.data.details[index].description ?? '', controller.text),));
                      }),
                )),
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: Colors.black.withOpacity(0.12),
                  ),
                  borderRadius: BorderRadius.circular(16),
                  color: kHyppeLightSurface,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CustomTextWidget(
                      textToDisplay: notifier.translate.doesThisHelpsyou ?? '',
                      maxLines: 2,
                      textAlign: TextAlign.start,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomTextButton(
                          onPressed: () {
                            Routing().moveAndPop(Routes.supportTicket);
                          },
                          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(kHyppeLightSurface)),
                          child: CustomTextWidget(
                            textToDisplay: notifier.translate.no ?? '',
                            textStyle: Theme.of(context).textTheme.button?.copyWith(color: kHyppePrimary),
                          ),
                        ),
                        sixPx,
                        CustomTextButton(
                          onPressed: () {
                            // notifier.navigateToBankAccount();
                          },
                          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(kHyppePrimary)),
                          child: CustomTextWidget(
                            textToDisplay: notifier.translate.yes ?? 'yes',
                            textStyle: Theme.of(context).textTheme.button?.copyWith(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget textSearched(BuildContext context, String text, String key){
    if(key.isNotEmpty){
      final List<String> splits = text.split(' ').where((element) => element.isNotEmpty).toList();
      final List<TextSpan> spans = [];
      for(var i = 0; i < splits.length; i++){
        final data = splits[i];
        final keyLength = key.length;
        final dataLength = data.length;
        print('compare text search : $key : ${dataLength > keyLength ? data.substring(0, (keyLength)) : 'skip scan'} : ${dataLength > keyLength ? data.substring((keyLength), (dataLength)) : 'skip scan'}');
        if(dataLength > keyLength){
          if(data.substring(0, keyLength).toLowerCase() == key.toLowerCase()){
            if(i == splits.length){
              spans.add(TextSpan(text: key, style: Theme.of(context).primaryTextTheme.bodyText2?.copyWith().copyWith(color: kHyppePrimary, backgroundColor: kHyppeLightWarning)));
              spans.add(TextSpan(text: data.substring(keyLength, dataLength), style: Theme.of(context).primaryTextTheme.bodyText2?.copyWith()),);
            }else{
              spans.add(TextSpan(text: key, style: Theme.of(context).primaryTextTheme.bodyText2?.copyWith().copyWith(color: kHyppePrimary, backgroundColor: kHyppeLightWarning)));
              spans.add(TextSpan(text: '${data.substring(keyLength, dataLength)} ', style: Theme.of(context).primaryTextTheme.bodyText2?.copyWith()),);
            }

          }else{
            if(i == splits.length){
              spans.add(TextSpan(text: data, style: Theme.of(context).primaryTextTheme.bodyText2?.copyWith()));
            }else{
              spans.add(TextSpan(text: '$data ', style: Theme.of(context).primaryTextTheme.bodyText2?.copyWith()));
            }
          }
        }else{
          if(i == splits.length){
            spans.add(TextSpan(text: data, style: Theme.of(context).primaryTextTheme.bodyText2?.copyWith()));
          }else{
            spans.add(TextSpan(text: '$data ', style: Theme.of(context).primaryTextTheme.bodyText2?.copyWith()));
          }
        }

      }

      return Text.rich(TextSpan(children: spans));
    }else{
      return Text(text, style: Theme.of(context).primaryTextTheme.bodyText2?.copyWith());
    }

  }
}


