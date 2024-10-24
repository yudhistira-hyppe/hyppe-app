import 'package:hyppe/core/bloc/repos/repos.dart';
import 'package:hyppe/core/bloc/utils_v2/state.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/status_code.dart';
import 'package:hyppe/core/models/collection/utils/eula/eula.dart';
import 'package:hyppe/core/models/collection/utils/reaction/reaction.dart';
import 'package:hyppe/core/models/collection/utils/welcome/welcome.dart';
import 'package:hyppe/core/response/generic_response.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:flutter/material.dart';

class UtilsBlocV2 {
  UtilsFetch _utilsFetch = UtilsFetch(UtilsState.init);
  UtilsFetch get utilsFetch => _utilsFetch;
  setUtilsFetch(UtilsFetch val) => _utilsFetch = val;

  final String? _langIso = SharedPreference().readStorage(SpKeys.isoCode) ?? "en";

  Future getWelcomeNotesBloc(BuildContext context) async {
    setUtilsFetch(UtilsFetch(UtilsState.loading));
    await Repos().reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
          setUtilsFetch(UtilsFetch(UtilsState.welcomeNotesError));
        } else {
          final response = GenericResponse.fromJson(onResult.data).responseData;
          final Welcome result = Welcome.fromJSON(response);
          setUtilsFetch(UtilsFetch(UtilsState.welcomeNotesSuccess, data: result));
        }
      },
      (errorData) {
        ShowBottomSheet.onInternalServerError(context, statusCode: errorData.response?.statusCode);
        setUtilsFetch(UtilsFetch(UtilsState.welcomeNotesError));
      },
      host: "${UrlConstants.welcomeNotes}?langIso=$_langIso&countryCode=ID&pageNumber=0&pageRow=100",
      methodType: MethodType.get,
      withAlertMessage: true,
      withCheckConnection: false,
      errorServiceType: ErrorType.getWelcomeNotes,
    );
  }

  Future getGenderBloc(BuildContext context) async {
    setUtilsFetch(UtilsFetch(UtilsState.loading));
    await Repos().reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
          setUtilsFetch(UtilsFetch(UtilsState.getGenderError));
        } else {
          setUtilsFetch(UtilsFetch(UtilsState.getGenderSuccess, data: GenericResponse.fromJson(onResult.data).responseData));
        }
      },
      (errorData) {
        setUtilsFetch(UtilsFetch(UtilsState.getGenderError));
      },
      errorServiceType: ErrorType.getGender,
      host: "${UrlConstants.gender}?langIso=$_langIso",
      withAlertMessage: false,
      methodType: MethodType.get,
      withCheckConnection: false,
    );
    return _utilsFetch.data;
  }

  Future getInterestBloc(BuildContext context) async {
    setUtilsFetch(UtilsFetch(UtilsState.loading));
    await Repos().reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
          setUtilsFetch(UtilsFetch(UtilsState.getInterestsError));
        } else {
          setUtilsFetch(UtilsFetch(UtilsState.getInterestsSuccess, data: GenericResponse.fromJson(onResult.data).responseData));
        }
      },
      (errorData) {
        ShowBottomSheet.onInternalServerError(context, statusCode: errorData.response?.statusCode);
        setUtilsFetch(UtilsFetch(UtilsState.getInterestsError));
      },
      errorServiceType: ErrorType.getGender,
      host: "${UrlConstants.interest}?langIso=$_langIso&pageNumber=0&pageRow=100",
      withAlertMessage: false,
      methodType: MethodType.get,
      withCheckConnection: false,
    );
    return _utilsFetch.data;
  }

  Future getEulaBloc(BuildContext context) async {
    setUtilsFetch(UtilsFetch(UtilsState.loading));
    await Repos().reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
          setUtilsFetch(UtilsFetch(UtilsState.getEulaError));
        } else {
          final response = GenericResponse.fromJson(onResult.data).responseData;
          Eula result = Eula.fromJSON(response);
          setUtilsFetch(UtilsFetch(UtilsState.getEulaSuccess, data: result));
        }
      },
      (errorData) {
        ShowBottomSheet.onInternalServerError(context, statusCode: errorData.response?.statusCode);
        setUtilsFetch(UtilsFetch(UtilsState.getEulaError));
      },
      host: "${UrlConstants.eula}?langIso=$_langIso",
      methodType: MethodType.get,
      withAlertMessage: true,
      withCheckConnection: false,
    );
  }

  Future getCountryBloc(BuildContext context, {int pageNumber = 0, int pageRow = 20, String? search}) async {
    setUtilsFetch(UtilsFetch(UtilsState.loading));
    await Repos().reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
          setUtilsFetch(UtilsFetch(UtilsState.loadCountryError));
        } else {
          setUtilsFetch(UtilsFetch(UtilsState.loadCountrySuccess, data: GenericResponse.fromJson(onResult.data).responseData));
        }
      },
      (errorData) {
        ShowBottomSheet.onInternalServerError(context, statusCode: errorData.response?.statusCode);
        setUtilsFetch(UtilsFetch(UtilsState.loadCountryError));
      },
      host: "${UrlConstants.country}${search != null ? "?search=$search&" : "?"}pageNumber=$pageNumber&pageRow=$pageRow",
      withAlertMessage: false,
      methodType: MethodType.get,
      withCheckConnection: false,
      errorServiceType: ErrorType.getCountry,
    );
  }

  Future getProvinceBloc(BuildContext context, {String? countryID, int pageNumber = 0, int pageRow = 40, String? search}) async {
    setUtilsFetch(UtilsFetch(UtilsState.loading));
    await Repos().reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
          setUtilsFetch(UtilsFetch(UtilsState.loadAreaError));
        } else {
          setUtilsFetch(UtilsFetch(UtilsState.loadAreaSuccess, data: GenericResponse.fromJson(onResult.data).responseData));
        }
      },
      (errorData) {
        ShowBottomSheet.onInternalServerError(context, statusCode: errorData.response?.statusCode);
        setUtilsFetch(UtilsFetch(UtilsState.loadAreaError));
      },
      errorServiceType: ErrorType.getStates,
      host: "${UrlConstants.area}${search != null ? "?search=$search" : "?countryID=$countryID"}&pageNumber=$pageNumber&pageRow=$pageRow",
      withAlertMessage: false,
      methodType: MethodType.get,
      withCheckConnection: false,
    );
  }

  Future getCityBloc(BuildContext context, {required String? provinceID, required int pageNumber, int pageRow = 20}) async {
    setUtilsFetch(UtilsFetch(UtilsState.loading));
    await Repos().reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
          setUtilsFetch(UtilsFetch(UtilsState.loadCityError));
        } else {
          setUtilsFetch(UtilsFetch(UtilsState.loadCitySuccess, data: GenericResponse.fromJson(onResult.data).responseData));
        }
      },
      (errorData) {
        ShowBottomSheet.onInternalServerError(context, statusCode: errorData.response?.statusCode);
        setUtilsFetch(UtilsFetch(UtilsState.loadCityError));
      },
      errorServiceType: ErrorType.getCities,
      host: "${UrlConstants.city}?stateID=$provinceID&pageNumber=$pageNumber&pageRow=$pageRow",
      withAlertMessage: false,
      methodType: MethodType.get,
      withCheckConnection: false,
    );
  }

  Future getLanguages(BuildContext context, {required int pageNumber, int pageRow = 20}) async {
    setUtilsFetch(UtilsFetch(UtilsState.loading));
    await Repos().reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
          setUtilsFetch(UtilsFetch(UtilsState.languagesError));
        } else {
          setUtilsFetch(UtilsFetch(UtilsState.languagesSuccess, data: GenericResponse.fromJson(onResult.data).responseData));
        }
      },
      (errorData) {
        setUtilsFetch(UtilsFetch(UtilsState.languagesError));
      },
      errorServiceType: ErrorType.getLanguage,
      host: "${UrlConstants.languages}?pageNumber=$pageNumber&pageRow=$pageRow",
      withAlertMessage: false,
      methodType: MethodType.get,
      withCheckConnection: false,
    );
  }

  Future updateLanguages(BuildContext context, {required String lang}) async {
    setUtilsFetch(UtilsFetch(UtilsState.loading));
    await Repos().reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
          setUtilsFetch(UtilsFetch(UtilsState.updateLanguagesError));
        } else {
          setUtilsFetch(UtilsFetch(UtilsState.updateLanguagesSuccess, data: GenericResponse.fromJson(onResult.data).responseData));
        }
      },
      (errorData) {
        setUtilsFetch(UtilsFetch(UtilsState.updateLanguagesError));
      },
      data: {'langIso': lang},
      headers: {
        "x-auth-token": SharedPreference().readStorage(SpKeys.userToken),
        "x-auth-user": SharedPreference().readStorage(SpKeys.email),
      },
      errorServiceType: ErrorType.getLanguage,
      host: UrlConstants.updateLanguage,
      withAlertMessage: false,
      methodType: MethodType.post,
      withCheckConnection: false,
    );
  }

  Future getReactionBloc(BuildContext context) async {
    setUtilsFetch(UtilsFetch(UtilsState.loading));
    await Repos().reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
          setUtilsFetch(UtilsFetch(UtilsState.getReactionError));
        } else {
          final response = GenericResponse.fromJson(onResult.data).responseData;
          Reaction result = Reaction.fromJson(response);
          setUtilsFetch(UtilsFetch(UtilsState.getReactionSuccess, data: result));
        }
      },
      (errorData) {
        setUtilsFetch(UtilsFetch(UtilsState.getReactionError));
      },
      host: UrlConstants.reaction,
      withAlertMessage: false,
      methodType: MethodType.get,
      withCheckConnection: false,
      errorServiceType: ErrorType.getReactions,
    );
  }

  Future getSearchPeopleBloc(BuildContext context, String? keyword, int skip, int limit) async {
    setUtilsFetch(UtilsFetch(UtilsState.loading));
    await Repos().reposPost(
      context,
      (onResult) {
        print('status getSearchPeopleBloc ${onResult.statusCode}');
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
          setUtilsFetch(UtilsFetch(UtilsState.searchPeopleError));
        } else {
          setUtilsFetch(UtilsFetch(UtilsState.searchPeopleSuccess, data: GenericResponse.fromJson(onResult.data).responseData));
          // setUtilsFetch(UtilsFetch(UtilsState.searchPeopleSuccess, data: _response.toJson()));
        }
      },
      (errorData) {
        setUtilsFetch(UtilsFetch(UtilsState.getReactionError));
      },
      host: UrlConstants.getSearchPeople,
      withAlertMessage: false,
      methodType: MethodType.post,
      withCheckConnection: false,
      errorServiceType: ErrorType.getReactions,
      data: {
        "username": keyword,
        "skip": skip,
        "limit": limit,
      },
    );
  }

  Future<void> deleteTagUsersBloc(BuildContext context, String? postId) async {
    setUtilsFetch(UtilsFetch(UtilsState.loading));
    print('sdsdfsd');
    final email = SharedPreference().readStorage(SpKeys.email);
    print(email);
    await Repos().reposPost(
      context,
      (onResult) {
        print(onResult);
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
          setUtilsFetch(UtilsFetch(UtilsState.deleteUserTagError));
        } else {
          setUtilsFetch(UtilsFetch(UtilsState.deleteUserTagSuccess, data: GenericResponse.fromJson(onResult.data).responseData));
          // setUtilsFetch(UtilsFetch(UtilsState.searchPeopleSuccess, data: _response.toJson()));
        }
      },
      (errorData) {
        setUtilsFetch(UtilsFetch(UtilsState.deleteUserTagError));
        print(errorData);
      },
      host: UrlConstants.deletTagUser,
      headers: {
        "x-auth-token": SharedPreference().readStorage(SpKeys.userToken),
      },
      data: {"email": email, 'postID': postId},
      withCheckConnection: false,
      methodType: MethodType.post,
      withAlertMessage: false,
    );
  }

  Future<void> settingAppsBloc(BuildContext context) async {
    setUtilsFetch(UtilsFetch(UtilsState.loading));
    final email = SharedPreference().readStorage(SpKeys.email);
    final token = SharedPreference().readStorage(SpKeys.userToken);
    await Repos().reposPost(
      context,
      (onResult) {
        print(onResult);
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
          setUtilsFetch(UtilsFetch(UtilsState.getSettingError));
        } else {
          setUtilsFetch(UtilsFetch(UtilsState.getSettingSuccess, data: GenericResponse.fromJson(onResult.data).responseData));
        }
      },
      (errorData) {
        setUtilsFetch(UtilsFetch(UtilsState.getSettingError));
        print(errorData);
      },
      host: UrlConstants.settingApps,
      headers: {
        "x-auth-token": token,
        "x-auth-user": email,
      },
      withCheckConnection: false,
      methodType: MethodType.get,
      withAlertMessage: false,
    );
  }

  Future<void> getMasterBoost(BuildContext context) async {
    setUtilsFetch(UtilsFetch(UtilsState.loading));
    final email = SharedPreference().readStorage(SpKeys.email);
    final token = SharedPreference().readStorage(SpKeys.userToken);
    await Repos().reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
          setUtilsFetch(UtilsFetch(UtilsState.getMasterBoostError));
        } else {
          setUtilsFetch(UtilsFetch(UtilsState.getMasterBoostSuccess, data: GenericResponse.fromJson(onResult.data).responseData));
        }
      },
      (errorData) {
        setUtilsFetch(UtilsFetch(UtilsState.getMasterBoostError));
        print(errorData);
      },
      host: UrlConstants.getBoostMaster,
      headers: {
        "x-auth-token": token,
        "x-auth-user": email,
      },
      withCheckConnection: false,
      methodType: MethodType.get,
      withAlertMessage: false,
    );
  }

  Future<void> postBostContentPre(BuildContext context, {Map? data}) async {
    setUtilsFetch(UtilsFetch(UtilsState.loading));
    final email = SharedPreference().readStorage(SpKeys.email);
    final token = SharedPreference().readStorage(SpKeys.userToken);
    await Repos().reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
          setUtilsFetch(UtilsFetch(UtilsState.getMasterBoostError, data: onResult.data));
        } else {
          setUtilsFetch(UtilsFetch(UtilsState.getMasterBoostSuccess, data: GenericResponse.fromJson(onResult.data).responseData));
        }
      },
      (errorData) {
        setUtilsFetch(UtilsFetch(UtilsState.getMasterBoostError));
      },
      host: UrlConstants.boostContentNew,
      // host: UrlConstants.boostContent,
      headers: {
        "x-auth-token": token,
        "x-auth-user": email,
      },
      data: data,
      withCheckConnection: false,
      methodType: MethodType.post,
      withAlertMessage: false,
    );
  }

  Future<void> getListBoost(BuildContext context, String param) async {
    setUtilsFetch(UtilsFetch(UtilsState.loading));
    final email = SharedPreference().readStorage(SpKeys.email);
    final token = SharedPreference().readStorage(SpKeys.userToken);
    await Repos().reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
          setUtilsFetch(UtilsFetch(UtilsState.getMasterBoostError));
        } else {
          setUtilsFetch(UtilsFetch(UtilsState.getMasterBoostSuccess, data: GenericResponse.fromJson(onResult.data).responseData));
        }
      },
      (errorData) {
        setUtilsFetch(UtilsFetch(UtilsState.getMasterBoostError));
      },
      host: UrlConstants.getListMyBoost + param,
      headers: {
        "x-auth-token": token,
        "x-auth-user": email,
      },
      withCheckConnection: false,
      methodType: MethodType.get,
      withAlertMessage: false,
    );
  }
}
