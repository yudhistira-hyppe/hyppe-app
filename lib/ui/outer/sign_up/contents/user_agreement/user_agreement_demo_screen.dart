import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:url_launcher/url_launcher.dart';

class UserAgreementDemoScreen extends StatelessWidget {
  const UserAgreementDemoScreen({Key? key}) : super(key: key);

  Future<String> initDummyEula() async {
    String _result = '';
    try {
      String? isoCode = SharedPreference().readStorage(SpKeys.isoCode) ?? 'en';
      _result = await rootBundle.loadString('${AssetPath.dummyMdPath}terms_of_use_$isoCode.md');
    } catch (e) {
      print(e);
    }
    return _result;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: initDummyEula(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Markdown(
            data: snapshot.data ?? '',
            onTapLink: (text, href, title) async{
              try{
                print('markdown  $text, $href, $title');
                await launchUrl(Uri.parse(text), mode: LaunchMode.externalApplication);
              }catch(e){
                'error href : $e'.logger();
              }

            },
          );
        } else {
          return const Center(
            child: CustomLoading(),
          );
        }
      },
    );
  }
}
