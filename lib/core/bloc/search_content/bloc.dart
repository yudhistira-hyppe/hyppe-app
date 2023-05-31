import 'package:flutter/material.dart';
import 'package:hyppe/core/bloc/repos/repos.dart';
import 'package:hyppe/core/bloc/search_content/state.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/status_code.dart';

import 'package:hyppe/core/response/generic_response.dart';
import 'package:hyppe/core/services/system.dart';

class SearchContentBloc {
  SearchContentFetch _searchContentFetch = SearchContentFetch(SearchContentState.init);
  SearchContentFetch get searchContentFetch => _searchContentFetch;
  setSearchContentFetch(SearchContentFetch val) => _searchContentFetch = val;

  Future getSearchContent(BuildContext context, param, {TypeApiSearch type = TypeApiSearch.normal}) async {
    // String email = SharedPreference().readStorage(SpKeys.email);
    final isNormal = type == TypeApiSearch.normal;
    print('_hitApiGetSearchData#2 ${System().getCurrentDate()}');
    await Repos().reposPost(
      context,
      (onResult) {
        print('_hitApiGetSearchData#5 ${System().getCurrentDate()}');
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
      withAlertMessage: true,
      withCheckConnection: true,
      host: isNormal ? UrlConstants.getSearchContentV4 : type == TypeApiSearch.detailHashTag ? UrlConstants.getDetailHashtag : UrlConstants.getDetailInterest,
      methodType: MethodType.post,
    );
  }

  Future getDetailContents(BuildContext context, param, {TypeApiSearch type = TypeApiSearch.normal}) async {
    print('_hitApiGetSearchData#2 ${System().getCurrentDate()}');
    final isNormal = type == TypeApiSearch.normal;
    await Repos().reposPost(
      context,
          (onResult) {
        print('_hitApiGetSearchData#5 ${System().getCurrentDate()}');
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
      withAlertMessage: true,
      withCheckConnection: true,
      host: isNormal ? UrlConstants.getSearchContentV5 : type == TypeApiSearch.detailHashTag ? UrlConstants.getDetailHashtagV2 : UrlConstants.getDetailInterestV2,
      methodType: MethodType.post,
    );
  }

  Future landingPageSearch(BuildContext context) async {
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
      data: {
        'page': 0,
        'limit': 10
      },
      withAlertMessage: true,
      withCheckConnection: true,
      host: UrlConstants.landingPageSearch,
      methodType: MethodType.post,
    );
  }
}
