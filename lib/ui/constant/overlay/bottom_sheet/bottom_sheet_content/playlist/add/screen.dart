import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/constant/entities/playlist/notifier.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/playlist/add/widget/dropdown_design.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class AddPlaylist extends StatefulWidget {
  @override
  _AddPlaylistState createState() => _AddPlaylistState();
}

class _AddPlaylistState extends State<AddPlaylist> {
  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistNotifier>(
      builder: (_, notifier, __) => WillPopScope(
        onWillPop: () async {
          notifier.onExit();
          return false;
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 15, right: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: CustomIconWidget(iconData: "${AssetPath.vectorPath}handler.svg"),
              ),
              CustomTextWidget(
                textToDisplay: notifier.language.newFavorite!,
                textStyle: Theme.of(context).textTheme.headline5!.copyWith(fontWeight: FontWeight.w500),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextWidget(
                    textToDisplay: notifier.language.name!,
                    textStyle: Theme.of(context).textTheme.bodyText1,
                  ),
                  SizedBox(height: 10 * SizeConfig.scaleDiagonal),
                  TextFormField(
                    maxLines: 1,
                    maxLength: 150,
                    focusNode: notifier.focusNode,
                    onChanged: (v) => notifier.color = v.isNotEmpty ? true : false,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xff1B1F23),
                      hintText: notifier.language.name!,
                      hintStyle: TextStyle(
                          fontFamily: "Roboto", fontWeight: FontWeight.w400, fontSize: 18 * SizeConfig.scaleDiagonal, color: const Color(0xff505558)),
                      contentPadding: const EdgeInsets.only(left: 15, right: 15),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(7.0), borderSide: const BorderSide(color: Color(0xff3F4347))),
                      enabledBorder:
                          OutlineInputBorder(borderRadius: BorderRadius.circular(7.0), borderSide: const BorderSide(color: Color(0xff3F4347))),
                      focusedBorder:
                          OutlineInputBorder(borderRadius: BorderRadius.circular(7.0), borderSide: const BorderSide(color: Color(0xff3F4347))),
                    ),
                    controller: notifier.newPlaylistController,
                    keyboardAppearance: Brightness.dark,
                    cursorColor: const Color(0xffDA25F5),
                    inputFormatters: [LengthLimitingTextInputFormatter(150)],
                  )
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextWidget(
                    textToDisplay: notifier.language.selectPrivacy!,
                    textStyle: Theme.of(context).textTheme.bodyText1,
                  ),
                  SizedBox(height: 10 * SizeConfig.scaleDiagonal),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                        color: const Color(0xff1B1F23),
                        border: Border.all(color: const Color(0xff3F4347), width: 1.0),
                        borderRadius: const BorderRadius.all(Radius.circular(7.0))),
                    child: DropdownButton(
                      value: notifier.dropDownValue,
                      items: notifier.listPrivacy
                          .map<DropdownMenuItem<String>>((String value) => DropdownMenuItem<String>(
                                child: DropdownDesign(value: value),
                                value: value,
                              ))
                          .toList(),
                      icon: const RotatedBox(
                        quarterTurns: 3,
                        child: CustomIconWidget(iconData: '${AssetPath.vectorPath}back-arrow.svg'),
                      ),
                      onChanged: (dynamic v) => notifier.dropDownValue = v,
                      isExpanded: true,
                      autofocus: false,
                      onTap: () => notifier.focusNode.unfocus(),
                      underline: const SizedBox.shrink(),
                    ),
                  )
                ],
              ),
              SizedBox(height: 10 * SizeConfig.scaleDiagonal),
              Column(
                children: [
                  Container(
                    alignment: Alignment.bottomCenter,
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            CustomElevatedButton(
                              child: notifier.loading
                                  ? const CustomLoading()
                                  : CustomTextWidget(
                                      textToDisplay: notifier.language.createNew ?? '',
                                      textStyle: Theme.of(context).textTheme.button,
                                    ),
                              buttonStyle: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<Color>(notifier.color ? const Color(0xff822E6E) : const Color(0xff373A3C)),
                                overlayColor: MaterialStateProperty.all<Color>(Colors.transparent),
                              ),
                              width: 375.0 * SizeConfig.scaleDiagonal,
                              height: 56.0 * SizeConfig.scaleDiagonal,
                              function: notifier.loading ? null : () => notifier.onCreatePlaylist(context, notifier.newPlaylistController.text),
                            ),
                            SizedBox(height: 5 * SizeConfig.scaleDiagonal),
                            CustomElevatedButton(
                              child: notifier.loading
                                  ? const SizedBox.shrink()
                                  : CustomTextWidget(
                                      textToDisplay: notifier.language.cancel ?? '',
                                      textStyle: Theme.of(context).textTheme.button,
                                    ),
                              buttonStyle: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent)),
                              width: 375.0 * SizeConfig.scaleDiagonal,
                              height: 56.0 * SizeConfig.scaleDiagonal,
                              function: notifier.loading ? null : () => notifier.onExit(),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
