import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/outer/sign_up/contents/user_complete_profile/user_complete_profile_notifier.dart';
import 'package:hyppe/ui/outer/sign_up/widget/sign_up_load_more_list.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/services/error_service.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_error_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';

class UserCompleteProfileLocationCityContent extends StatefulWidget {
  final String province;
  final Function(String) onSelected;
  const UserCompleteProfileLocationCityContent({Key? key, required this.onSelected, required this.province}) : super(key: key);
  @override
  _UserCompleteProfileLocationCityContentState createState() => _UserCompleteProfileLocationCityContentState();
}

class _UserCompleteProfileLocationCityContentState extends State<UserCompleteProfileLocationCityContent> {
  final ScrollController _scroll = ScrollController();
  @override
  void initState() {
    final notifier = Provider.of<UserCompleteProfileNotifier>(context, listen: false);
    notifier.cityData.clear();
    notifier.initPageLength();
    notifier.initCity(context, province: widget.province, reload: true);
    _scroll.addListener(() {
      if (_scroll.offset >= _scroll.position.maxScrollExtent && !_scroll.position.outOfRange) {
        if (notifier.hasNext) {
          notifier.loadMore = !notifier.loadMore;
          notifier.page++;
          notifier.initCity(context, province: widget.province, reload: false);
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<UserCompleteProfileNotifier>();
    final error = context.select((ErrorService value) => value.getError(ErrorType.getCities));

    '${notifier.cityData.isNotEmpty}'.logger();

    if (context.read<ErrorService>().isInitialError(error, notifier.cityData.isEmpty ? null : notifier.cityData.isEmpty)) {
      return Center(
        child: SizedBox(
          height: SizeConfig.screenHeight! * 0.8,
          child: CustomErrorWidget(
            function: () => notifier.initCity(context, province: widget.province, reload: true),
            errorType: ErrorType.getCities,
          ),
        ),
      );
    }

    return SizedBox(
      height: SizeConfig.screenHeight! * 0.8,
      width: SizeConfig.screenWidth,
      child: Center(
        child: notifier.cityData.isNotEmpty
            ? Column(
                children: [
                  const RotatedBox(
                    quarterTurns: 1,
                    child: CustomIconWidget(iconData: '${AssetPath.vectorPath}back-arrow.svg'),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: notifier.cityData.length,
                      shrinkWrap: true,
                      controller: _scroll,
                      scrollDirection: Axis.vertical,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.all(11),
                        child: CustomElevatedButton(
                          height: 42,
                          width: SizeConfig.screenWidth,
                          function: () => widget.onSelected(notifier.cityData[index].cityName ?? ''),
                          child: CustomTextWidget(
                            textToDisplay: notifier.cityData[index].cityName ?? '',
                            textStyle: Theme.of(context).textTheme.bodyText1,
                          ),
                        ),
                      ),
                    ),
                  ),
                  notifier.loadMore
                      ? SignUpLoadMoreList(caption: "${notifier.language.loadMore} ${notifier.language.locationInThisCountryRegion}")
                      : const SizedBox.shrink(),
                  const RotatedBox(
                    quarterTurns: 3,
                    child: CustomIconWidget(iconData: '${AssetPath.vectorPath}back-arrow.svg'),
                  ),
                ],
              )
            : const CustomLoading(),
      ),
    );
  }
}
