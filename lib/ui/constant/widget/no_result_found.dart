import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:provider/provider.dart';

class NoResultFound extends StatelessWidget {
  const NoResultFound({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TranslateNotifierV2>(
      builder: (_, value, __) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Theme.of(context).colorScheme.surface),
          height: 350,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    image: DecorationImage(image: AssetImage('${AssetPath.pngPath}content-zero.png'), fit: BoxFit.fill),
                  ),
                ),
              ),
              Text("${value.translate.noResultsFoundTryAnother}")
            ],
          ),
        ),
      ),
    );
  }
}
