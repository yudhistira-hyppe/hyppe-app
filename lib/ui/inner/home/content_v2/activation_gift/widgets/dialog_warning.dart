import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/inner/main/notifier.dart';
import 'package:provider/provider.dart';

class DialogWarningWidget extends StatelessWidget {
  final LocalizationModelV2? lang;
  const DialogWarningWidget({super.key, required this.lang});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      maxChildSize: .9,
      initialChildSize: .3,
      builder: (_, controller) {
        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
          ),
          child: Column(
            children: [
              FractionallySizedBox(
                widthFactor: 0.15,
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 12.0,
                  ),
                  child: Container(
                    height: 5.0,
                    decoration: const BoxDecoration(
                      color: kHyppeBurem,
                      borderRadius: BorderRadius.all(Radius.circular(2.5)),
                    ),
                  ),
                ),
              ),
              Center(
                child: Text(
                  lang!.localeDatetime == 'id' ? 'Kamu Belum Memiliki Postingan' : 'You don\'t have any posts yet',
                  style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              tenPx,
              const Divider(color: kHyppeBurem, thickness: .5,),
              tenPx,
              SizedBox(
                width: MediaQuery.of(context).size.width * .9,
                child: Center(
                  child: Text(
                    lang!.localeDatetime == 'id' ? 'Untuk mengaktifkan fitur ini kamu setidaknya kamu harus memiliki satu postingan dengan label konten ownership' :'To enable this feature, you need to have at least one post with the content ownership label.',
                    maxLines: 5,
                  ),
                ),
              ),
              Container(
              margin: const EdgeInsets.symmetric(vertical: 22, horizontal: 18.0),
              height: kToolbarHeight,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  Navigator.of(context)..pop()..pop();
                  var main = Provider.of<MainNotifier>(context, listen: false);
                  main.setPageIndex(0);
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  backgroundColor: kHyppePrimary
                ),
                child: Center(
                    child: Text(lang?.localeDatetime == 'id' ? 'Buat Postingan Sekarang' : 'Create a Post Now',
                        textAlign: TextAlign.center,),
                  ),
              ),
            ),
            ],
          ),
        );
      },
    );
  }
}