import 'package:hyppe/core/bloc/repos/repos.dart';
import 'package:hyppe/core/bloc/sticker/state.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/status_code.dart';
import 'package:hyppe/core/response/generic_response.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/enum.dart';

class StickerBloc {
  static final _repos = Repos();

  StickerFetch _stickerFetch = StickerFetch(StickerState.init);
  StickerFetch get stickerFetch => _stickerFetch;
  setStickerFetch(StickerFetch val) => _stickerFetch = val;

  Future getStickers(BuildContext context, String type) async {
    setStickerFetch(StickerFetch(StickerState.loading));

    final email = SharedPreference().readStorage(SpKeys.email);
    final token = SharedPreference().readStorage(SpKeys.userToken);
    await _repos.reposPost(context, (onResult) {
      if ((onResult.statusCode ?? 300) > HTTP_CODE) {
        setStickerFetch(StickerFetch(StickerState.getStickerError));
      } else {
        setStickerFetch(
          StickerFetch(
            StickerState.getStickerSuccess,
            data: GenericResponse.fromJson(onResult.data).responseData,
          ),
        );
      }
    }, (errorData) {
      ShowBottomSheet.onInternalServerError(context);
      setStickerFetch(StickerFetch(StickerState.getStickerError));
    },
        errorServiceType: ErrorType.getSticker,
        host: UrlConstants.getStickers,
        withAlertMessage: false,
        methodType: MethodType.post,
        withCheckConnection: false,
        data: {
          // "keyword":"happy", // opsional
          "tipestiker": type
        },
        headers: {
          'x-auth-user': email,
          'x-auth-token': token,
        });
  }
}
