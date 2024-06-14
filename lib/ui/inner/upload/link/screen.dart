import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/show_general_dialog.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_form_field.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/icon_button_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/account_preferences/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/streamer/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

import '../pre_upload_content/notifier.dart';
import 'notifier.dart';

class AddLinkPage extends StatefulWidget {
  const AddLinkPage({super.key});

  @override
  State<AddLinkPage> createState() => _AddLinkPageState();
}

class _AddLinkPageState extends State<AddLinkPage> {
  Timer? _debounce;
  String title = '';

  _onSearchChanged(String query, ExternalLinkNotifier notifier) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      // do something with query
      String patttern = r"((https?:www\.)|(https?:\/\/)|(www\.))[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9]{1,6}(\/[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)?";
      RegExp regExp = RegExp(patttern);
      if (!regExp.hasMatch(query)) {
        notifier.urlValidator(false);
      } else {
        if (query.isEmpty) {
          notifier.urlValidator(false);
        } else {
          notifier.urlValidator(true);
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var res = ModalRoute.of(context)!.settings.arguments as Map;
      final stream = Provider.of<ExternalLinkNotifier>(context, listen: false);
      stream.beforeCurrentRoutes = res['routes'];
      stream.urlValidator(false);
      if (res['urlLink'] != null || res['judulLink'] != null) {
        stream.linkController.text = res['urlLink'] ?? '';
        stream.titleController.text = res['judulLink'] ?? '';
        stream.urlValidator(true);
        stream.setIsEdited(true);
        stream.setselectedPermission(true);
        title = res['judulLink'] ?? '';
      } else {
        stream.setselectedPermission(false);
        stream.setIsEdited(false);
        stream.linkController.clear();
        stream.titleController.clear();
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExternalLinkNotifier>(builder: (context, notifier, _) {
      return WillPopScope(
        onWillPop: () {
          notifier.onWillPop(context);
          return Future.value(true);
        },
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            elevation: 0,
            centerTitle: false,
            leading: CustomIconButtonWidget(
              onPressed: () => notifier.onWillPop(context),
              defaultColor: false,
              iconData: "${AssetPath.vectorPath}back-arrow.svg",
              color: Theme.of(context).colorScheme.onSurface,
            ),
            title: CustomTextWidget(
              textToDisplay: notifier.language.addLink ?? 'Tambahkan Link',
              textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.transparent,
            actions: [
              TextButton(
                onPressed: notifier.urlValid && title != ''
                    ? () {
                        if (notifier.beforeCurrentRoutes == Routes.preUploadContent) {
                          final stream = Provider.of<PreUploadContentNotifier>(context, listen: false);
                          stream.urlLink = notifier.linkController.text;
                          stream.judulLink = notifier.titleController.text;
                        } else if (notifier.beforeCurrentRoutes == Routes.selfProfile) {
                          final stream = Provider.of<AccountPreferencesNotifier>(context, listen: false);
                          stream.urlLinkController.text = notifier.linkController.text;
                          stream.titleLinkController.text = notifier.titleController.text;
                        } else if (notifier.beforeCurrentRoutes == Routes.streamer) {
                          final stream = Provider.of<StreamerNotifier>(context, listen: false);
                          stream.urlLink = notifier.linkController.text;
                          stream.textUrl = notifier.titleController.text;
                        }

                        notifier.onWillPop(context);
                      }
                    : null,
                child: Text(notifier.language.done ?? 'Selesai', style: TextStyle(color: notifier.urlValid && title != '' ? Colors.black87 : Colors.black45)),
              )
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
            child: ListView(
              children: [
                _permissionLink(notifier),
                thirtyTwoPx,
                if (notifier.selectedPermission) _textField(notifier),
                // thirtyTwoPx,
                if (notifier.isEdited)
                  TextButton(
                      onPressed: () {
                        if (notifier.beforeCurrentRoutes == Routes.preUploadContent) {
                          final stream = Provider.of<PreUploadContentNotifier>(context, listen: false);
                          stream.setDefaultExternalLink(context);
                          notifier.onWillPop(context);
                        } else if (notifier.beforeCurrentRoutes == Routes.selfProfile) {
                          final stream = Provider.of<AccountPreferencesNotifier>(context, listen: false);
                          stream.setDefaultExternalLink(context);
                          notifier.onWillPop(context);
                        } else if (notifier.beforeCurrentRoutes == Routes.streamer) {
                          final stream = Provider.of<StreamerNotifier>(context, listen: false);
                          ShowGeneralDialog.generalDialog(
                            _,
                            titleText: notifier.language.localeDatetime == 'id' ? 'Hapus Link' : 'Delete Link',
                            bodyText: notifier.language.localeDatetime == 'id' ? 'Link dapat ditambahkan kembali jika dihapus' : 'Links can be added again if removed',
                            titleButtonPrimary: notifier.language.remove,
                            titleButtonSecondary: notifier.language.cancel,
                            functionPrimary: () {
                              stream.setDefaultExternalLink(context);
                              notifier.onWillPop(context);
                            },
                            functionSecondary: () {
                              Routing().moveBack();
                            },
                            isHorizontal: false,
                            barrierDismissible: true,
                          );
                        }
                      },
                      child: Text(
                        notifier.language.deleteLink ?? 'Hapus Link',
                        style: TextStyle(color: Colors.red),
                      ))
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _textField(ExternalLinkNotifier notifier) {
    return Column(
      children: [
        CustomTextFormField(
          focusNode: notifier.linkFocus,
          inputAreaHeight: 55 * SizeConfig.scaleDiagonal,
          inputAreaWidth: SizeConfig.screenWidth!,
          textEditingController: notifier.linkController,
          style: Theme.of(context).textTheme.bodyLarge,
          textInputType: TextInputType.url,
          inputDecoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.only(right: 16, bottom: 16),
            labelText: 'URL Link',
            hintText: 'URL Link',
            // labelStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
            //     color: Theme.of(context).colorScheme.onPrimary),
            border: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.surface, width: 2)),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.surface, width: 2)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: notifier.linkFocus.hasFocus ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary)),
          ),
          onChanged: (value) => _onSearchChanged(value, notifier),
        ),
        tenPx,
        CustomTextFormField(
          focusNode: notifier.titleFocus,
          inputAreaHeight: 105 * SizeConfig.scaleDiagonal,
          inputAreaWidth: SizeConfig.screenWidth!,
          textEditingController: notifier.titleController,
          style: Theme.of(context).textTheme.bodyLarge,
          textInputType: TextInputType.text,
          maxLength: 30,
          inputDecoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.only(right: 16, bottom: 16),
            labelText: notifier.language.titleLink ?? 'Judul Link',
            hintText: notifier.language.titleLink ?? 'Judul Link',
            border: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.surface, width: 2)),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.surface, width: 2)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: notifier.linkFocus.hasFocus ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary)),
          ),
          onChanged: (value) {
            title = value.replaceAll(' ', '');
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _permissionLink(ExternalLinkNotifier notifier) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Flexible(
        //   child: CustomDescContent(
        //     desc:
        //         "Dengan melanjutkan, saya menyatakan bahwa saya bertanggung jawab penuh atas link yang saya taruh, Dengan melanjutkan, saya menyatakan bahwa saya bertanggung jawab penuh atas link yang saya taruh",
        //     trimLines: 2,
        //     textAlign: TextAlign.start,
        //     callbackIsMore: (val) {},
        //     seeLess: ' ${notifier.language.less ?? 'Sedikit'}',
        //     seeMore: ' ${notifier.language.more ?? 'Selengkapnya'}',
        //     normStyle: const TextStyle(fontSize: 14, color: kHyppeSurface),
        //     hrefStyle: Theme.of(context).textTheme.titleSmall?.copyWith(color: kHyppePrimary),
        //     expandStyle: const TextStyle(fontSize: 14, color: kHyppePrimary, fontWeight: FontWeight.bold),
        //   ),
        // ),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notifier.language.localeDatetime == 'id'
                ? "Saya bertanggung jawab sepenuhnya dan memastikan tautan yang ditambahkan sesuai dengan Panduan Komunitas Hyppe yang berlaku."
                : "I take full responsibility and ensure that any links added comply with the applicable Hyppe Community Guidelines."),
            GestureDetector(
              onTap: () {
                Routing().move(Routes.userAgreement);
              },
              child: Text(
                notifier.language.more ?? '',
                style: const TextStyle(fontSize: 14, color: kHyppePrimary, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        )),

        Checkbox(
            activeColor: Theme.of(context).colorScheme.primary,
            checkColor: Colors.white,
            value: notifier.selectedPermission,
            onChanged: (bool? val) {
              notifier.setselectedPermission(val);
            }),
      ],
    );
  }
}
