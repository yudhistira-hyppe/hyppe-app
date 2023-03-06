import 'package:flutter/material.dart';
import 'package:hyppe/core/bloc/repos/repos.dart';
import 'package:hyppe/core/bloc/search_content/state.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/status_code.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/services/shared_preference.dart';

import 'package:hyppe/core/response/generic_response.dart';

class SearchContentBloc {
  SearchContentFetch _searchContentFetch = SearchContentFetch(SearchContentState.init);
  SearchContentFetch get searchContentFetch => _searchContentFetch;
  setSearchContentFetch(SearchContentFetch val) => _searchContentFetch = val;

  Future getSearchContent(BuildContext context, param) async {
    String email = SharedPreference().readStorage(SpKeys.email);

    await Repos().reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
          setSearchContentFetch(SearchContentFetch(SearchContentState.getSearchContentBlocError));
        } else {
          setSearchContentFetch(SearchContentFetch(
            SearchContentState.getSearchContentBlocSuccess,
            data: GenericResponse.fromJson(onResult.data).responseData,
          ));
        }
      },
      (errorData) {
        setSearchContentFetch(SearchContentFetch(SearchContentState.getSearchContentBlocError));
      },
      data: param,
      headers: {
        "x-auth-user": email,
      },
      withAlertMessage: true,
      withCheckConnection: true,
      host: UrlConstants.getSearchContentV4,
      methodType: MethodType.post,
    );
  }
}
