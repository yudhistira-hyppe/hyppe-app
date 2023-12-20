import 'package:flutter/material.dart';
import 'package:hyppe/core/bloc/live_stream/state.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/core/bloc/repos/repos.dart';
import 'package:hyppe/core/constants/status_code.dart';
import 'package:hyppe/core/response/generic_response.dart';

class LiveStreamBloc {
  final _repos = Repos();

  LiveStreamFetch _liveStreamFetch = LiveStreamFetch(LiveStreamState.init);
  LiveStreamFetch get liveStreamFetch => _liveStreamFetch;
  setTransactionFetch(LiveStreamFetch val) => _liveStreamFetch = val;

  Future getLinkStream(BuildContext context, Map data, String url) async {
    var type = FeatureType.other;
    setTransactionFetch(LiveStreamFetch(LiveStreamState.loading));
    await _repos.reposPost(
      context,
      (onResult) {
        print(onResult.statusCode);
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
          setTransactionFetch(LiveStreamFetch(LiveStreamState.getApiError, message: onResult.data['message'], data: onResult.data));
        } else {
          setTransactionFetch(LiveStreamFetch(LiveStreamState.getApiSuccess, message: onResult.data['message'], data: GenericResponse.fromJson(onResult.data).responseData));
        }
      },
      (errorData) {
        setTransactionFetch(LiveStreamFetch(LiveStreamState.getApiError, data: errorData.error));
      },
      headers: {
        'x-auth-user': SharedPreference().readStorage(SpKeys.email),
      },
      data: data,
      withAlertMessage: true,
      withCheckConnection: false,
      host: url,
      methodType: MethodType.post,
      errorServiceType: System().getErrorTypeV2(type),
    );
  }
}
