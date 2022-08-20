import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hyppe/core/bloc/buy/bloc.dart';
import 'package:hyppe/core/bloc/buy/state.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/error/error_model.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/buy_data.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_coloured_sheet.dart';
import 'package:hyppe/ux/routing.dart';

enum IntialBankSelect { vaBca, hyppeWallet }

class ReviewBuyNotifier extends ChangeNotifier {
  ContentData? _routeArgument;

  BuyData? _data;

  LocalizationModelV2 language = LocalizationModelV2();
  translate(LocalizationModelV2 translate) {
    language = translate;
    notifyListeners();
  }

  BuyData? get data => _data;
  set data(BuyData? value) {
    _data = value;
    print(value);
    notifyListeners();
  }

  void initState(BuildContext context, ContentData? routeArgument) {
    _routeArgument = routeArgument;

    if (_routeArgument?.postID != null) {
      _initFetchBuyDetail(context);
    }
  }

  Future<void> _initFetchBuyDetail(BuildContext context) async {
    final notifier = BuyBloc();
    await notifier.getBuyContent(context, postId: _routeArgument?.postID);
    final fetch = notifier.buyFetch;
    if (fetch.postsState == BuyState.getContentsError) {
      var errorData = ErrorModel.fromJson(fetch.data);
      _showSnackBar(kHyppeDanger, 'Error', '${errorData.message}');

      Future.delayed(const Duration(seconds: 3), () {
        Routing().moveBack();
      });
    } else if (fetch.postsState == BuyState.getContentsSuccess) {
      BuyData? res = BuyData.fromJson(fetch.data);
      data = res;
      notifyListeners();
    }
  }

  void _showSnackBar(Color color, String message, String desc,
      {Function? function}) {
    Routing().showSnackBar(
      snackBar: SnackBar(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        behavior: SnackBarBehavior.floating,
        content: SafeArea(
          child: SizedBox(
            height: 56,
            child: OnColouredSheet(
              maxLines: 2,
              caption: message,
              subCaption: desc,
              fromSnackBar: true,
              iconSvg: "${AssetPath.vectorPath}remove.svg",
              function: function,
            ),
          ),
        ),
        backgroundColor: color,
      ),
    );
  }
}
