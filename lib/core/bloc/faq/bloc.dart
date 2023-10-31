import 'package:flutter/material.dart';
import 'package:hyppe/core/bloc/faq/state.dart';
import 'package:hyppe/core/models/collection/faq/faq_request.dart';

import '../../../ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import '../../config/url_constants.dart';
import '../../constants/enum.dart';
import '../../constants/status_code.dart';
import '../../response/generic_response.dart';
import '../repos/repos.dart';

class FAQBloc{
  FAQFetch _faqFetch = FAQFetch(FAQState.init);
  FAQFetch get faqFetch  => _faqFetch;
  setFAQFetch(FAQFetch fetch) => _faqFetch = fetch;

  Future getAllFAQs(
      BuildContext context, {required FAQRequest arg}) async {
    setFAQFetch(FAQFetch(FAQState.loading));
    // final formData = FormData();
    // final email = SharedPreference().readStorage(SpKeys.email);
    print('request getAllFAQs ${FAQRequest.fromJson(arg.toJson())}');

    await Repos().reposPost(
      context,
          (onResult) {
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
          setFAQFetch(FAQFetch(FAQState.faqError, data: 'Error Code ${onResult.statusCode}'));
        } else {
          final _response = GenericResponse.fromJson(onResult.data).responseData;
          setFAQFetch(FAQFetch(FAQState.faqSuccess, data: _response));
        }
      },
          (errorData) {
        ShowBottomSheet.onInternalServerError(context, statusCode: errorData.response?.statusCode);
        setFAQFetch(FAQFetch(FAQState.faqError, data: '$errorData'));
      },
      data: arg.toJson(),
      host: UrlConstants.faqList,
      withAlertMessage: false,
      withCheckConnection: false,
      methodType: MethodType.post,
    );
  }
}