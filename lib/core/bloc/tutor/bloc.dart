import 'package:hyppe/core/bloc/challange/state.dart';
import 'package:hyppe/core/bloc/repos/repos.dart';
import 'package:hyppe/core/bloc/tutor/state.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/status_code.dart';
import 'package:hyppe/core/response/generic_response.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class TutorBloc {
  TutorFetch _tutorFetch = TutorFetch(TutorState.init);
  TutorFetch get tutorFetch => _tutorFetch;
  setTutorFetch(TutorFetch val) => _tutorFetch = val;

  Future postTutorBloc(
    BuildContext context, {
    required String key,
  }) async {
    setTutorFetch(TutorFetch(TutorState.loading));
    Map data = {'key': key, 'value': true};

    await Repos().reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
          setTutorFetch(TutorFetch(TutorState.getPostError, data: onResult.data));
        } else {
          setTutorFetch(TutorFetch(TutorState.getPostSuccess, data: GenericResponse.fromJson(onResult.data).responseData));
        }
      },
      (errorData) {
        ShowBottomSheet.onInternalServerError(context);
        setTutorFetch(TutorFetch(TutorState.getPostError));
        Dio().close(force: true);
      },
      onNoInternet: () {
        Routing().moveBack();
      },
      data: data,
      withAlertMessage: false,
      withCheckConnection: false,
      host: UrlConstants.tutorPost,
      methodType: MethodType.post,
    );
  }
}
