import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_error_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';

class UserOverviewGenderContent extends StatefulWidget {
  final String value;
  final Function() onSave;
  final Function() onCancel;
  final Future<dynamic> initFuture;
  final Function(String value) onChange;

  const UserOverviewGenderContent({
    Key? key,
    required this.value,
    required this.onSave,
    required this.onChange,
    required this.onCancel,
    required this.initFuture,
  }) : super(key: key);

  @override
  State<UserOverviewGenderContent> createState() => _UserOverviewGenderContentState();
}

class _UserOverviewGenderContentState extends State<UserOverviewGenderContent> {
  String _value = '';
  late Future<dynamic> _future;

  @override
  void initState() {
    _future = widget.initFuture;
    if (widget.value.isNotEmpty) {
      _value = widget.value;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final translateNotifier = context.watch<TranslateNotifierV2>();

    return FutureBuilder<dynamic>(
      initialData: const [],
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: CustomErrorWidget(
              function: () {
                setState(() {
                  _future = widget.initFuture;
                });
              },
              errorType: ErrorType.getGender,
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.done) {
          String _gendersResult = '${snapshot.data}'.replaceAll("[", "").replaceAll("]", "");
          final _genders = List<String>.from(_gendersResult.split(','));

          return Column(
            children: [
              CustomTextWidget(
                textAlign: TextAlign.center,
                textToDisplay: translateNotifier.translate.gender!,
                textStyle: Theme.of(context).textTheme.subtitle1?.copyWith(fontSize: 18),
              ),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _genders.length,
                  padding: const EdgeInsets.all(0),
                  itemBuilder: (context, index) {
                    return RadioListTile<String>(
                      groupValue: _genders[index],
                      value: _value,
                      onChanged: (value) {
                        setState(() {
                          _value = _genders[index];
                          widget.onChange(_genders[index]);
                        });
                      },
                      toggleable: true,
                      activeColor: Theme.of(context).colorScheme.primaryVariant,
                      title: CustomTextWidget(
                        textAlign: TextAlign.left,
                        textToDisplay: _genders[index],
                        textStyle: Theme.of(context).primaryTextTheme.bodyText1,
                      ),
                      controlAffinity: ListTileControlAffinity.trailing,
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: CustomElevatedButton(
                  height: 50,
                  width: SizeConfig.screenWidth,
                  buttonStyle: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Theme.of(context).colorScheme.primaryVariant,
                    ),
                  ),
                  // function: () => Routing().moveBack(),
                  function: () {
                    widget.onSave();
                  },
                  child: CustomTextWidget(
                    textToDisplay: translateNotifier.translate.save!,
                    textStyle: Theme.of(context).textTheme.button!.copyWith(color: kHyppeLightButtonText),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: CustomElevatedButton(
                  height: 50,
                  width: SizeConfig.screenWidth,
                  function: () {
                    widget.onCancel();
                    // notifier.resetGender();
                    // FocusScope.of(context).unfocus();
                  },
                  buttonStyle: ButtonStyle(
                    overlayColor: MaterialStateProperty.all<Color>(Colors.transparent),
                  ),
                  child: CustomTextWidget(
                    textToDisplay: translateNotifier.translate.cancel!,
                    textStyle: Theme.of(context).textTheme.button!,
                  ),
                ),
              ),
            ],
          );
        } else {
          return const Center(
            child: CustomLoading(),
          );
        }
      },
    );

    // if (context.read<ErrorService>().isInitialError(error, notifier.genders.isEmpty ? null : notifier.genders.isEmpty)) {
    //   return Center(
    //     child: CustomErrorWidget(
    //       function: () => notifier.onGenderTypeShowDropDown(context),
    //       errorType: ErrorType.getGender,
    //     ),
    //   );
    // }

    // if (notifier.genders.isEmpty) {
    //   return const Center(child: CustomLoading());
    // }

    // return Column(
    //   children: [
    //     CustomTextWidget(
    //       textAlign: TextAlign.center,
    //       textToDisplay: translateNotifier.translate.gender!,
    //       textStyle: Theme.of(context).textTheme.subtitle1?.copyWith(fontSize: 18),
    //     ),
    //     Expanded(
    //       child: ListView.builder(
    //         itemCount: notifier.genders.length,
    //         shrinkWrap: true,
    //         padding: EdgeInsets.all(0),
    //         itemBuilder: (context, index) {
    //           return RadioListTile<String>(
    //             value: notifier.genderController.text,
    //             groupValue: notifier.genders[index],
    //             onChanged: (value) {
    //               notifier.genderListSelected(index);
    //             },
    //             toggleable: true,
    //             activeColor: Theme.of(context).colorScheme.primaryVariant,
    //             title: CustomTextWidget(
    //               textAlign: TextAlign.left,
    //               textToDisplay: notifier.genders[index],
    //               textStyle: Theme.of(context).primaryTextTheme.bodyText1,
    //             ),
    //             controlAffinity: ListTileControlAffinity.trailing,
    //           );
    //         },
    //       ),
    //     ),
    //     Padding(
    //       padding: const EdgeInsets.symmetric(horizontal: 15),
    //       child: CustomElevatedButton(
    //         height: 50,
    //         width: SizeConfig.screenWidth,
    //         buttonStyle: ButtonStyle(
    //           backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.primaryVariant),
    //         ),
    //         function: () => Routing().moveBack(),
    //         child: CustomTextWidget(
    //           textToDisplay: translateNotifier.translate.save!,
    //           textStyle: Theme.of(context).textTheme.button!,
    //         ),
    //       ),
    //     ),
    //     Padding(
    //       padding: const EdgeInsets.symmetric(horizontal: 15),
    //       child: CustomElevatedButton(
    //         height: 50,
    //         width: SizeConfig.screenWidth,
    //         function: () {
    //           notifier.resetGender();
    //           FocusScope.of(context).unfocus();
    //         },
    //         buttonStyle: ButtonStyle(overlayColor: MaterialStateProperty.all<Color>(Colors.transparent)),
    //         child: CustomTextWidget(
    //           textToDisplay: translateNotifier.translate.cancel!,
    //           textStyle: Theme.of(context).textTheme.button!,
    //         ),
    //       ),
    //     ),
    //   ],
    // );
  }
}
