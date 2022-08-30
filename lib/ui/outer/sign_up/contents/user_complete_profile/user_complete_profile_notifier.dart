import 'package:hyppe/core/bloc/utils_v2/bloc.dart';
import 'package:hyppe/core/bloc/utils_v2/state.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/core/services/error_service.dart';
import 'package:hyppe/core/models/collection/utils/city/city_data.dart';
import 'package:hyppe/core/models/collection/utils/country/country_data.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/core/models/collection/utils/province/province_data.dart';

class UserCompleteProfileNotifier extends ChangeNotifier {
  LocalizationModelV2 language = LocalizationModelV2();
  translate(LocalizationModelV2 translate) {
    language = translate;
    notifyListeners();
  }

  final TextEditingController countryController = TextEditingController();
  final TextEditingController provinceController = TextEditingController();
  final TextEditingController cityController = TextEditingController();

  final List<CountryData> _countryData = [];
  final List<ProvinceData> _provinceData = [];
  final List<CityData> _cityData = [];
  bool _required = false;
  int _page = 0;
  bool _hasNext = true;
  bool _loadMore = false;

  List<ProvinceData> get provinceData => _provinceData;
  List<CountryData> get countryData => _countryData;
  List<CityData> get cityData => _cityData;
  bool get required => _required;
  int get page => _page;
  bool get hasNext => _hasNext;
  bool get loadMore => _loadMore;

  set required(bool val) {
    _required = val;
    notifyListeners();
  }

  set hasNext(bool val) {
    _hasNext = val;
    notifyListeners();
  }

  set page(int val) {
    _page = val;
    notifyListeners();
  }

  set loadMore(bool val) {
    _loadMore = val;
    notifyListeners();
  }

  void _checkRequirement() {
    required = countryController.text.isNotEmpty && provinceController.text.isNotEmpty && cityController.text.isNotEmpty;
  }

  ////////////////////////////////////////////////////////////////////////// LOCATION
  Future initCountry(
    BuildContext context, {
    required bool reload,
  }) async {
    bool connection = await System().checkConnections();
    if (connection) {
      // remove error object country from entry
      context.read<ErrorService>().removeErrorObject(ErrorType.getCountry);

      final notifier = UtilsBlocV2();
      await notifier.getCountryBloc(context);
      final fetch = notifier.utilsFetch;
      if (fetch.utilsState == UtilsState.loadCountrySuccess) {
        loadMore = false;
        if (reload) {
          _countryData.clear();
          fetch.data.forEach((v) => _countryData.add(CountryData.fromJson(v)));
        } else {
          fetch.data.forEach((v) => _countryData.add(CountryData.fromJson(v)));
        }
        hasNext = _countryData.isNotEmpty;
        notifyListeners();
      }
      if (fetch.utilsState == UtilsState.loadCountryError) {
        page--;
        loadMore = false;
        ShowBottomSheet.onInternalServerError(context, tryAgainButton: () {
          Routing().moveBack();
          initCountry(context, reload: reload);
        }, backButton: () {
          Routing().moveBack();
        });
      }
    } else {
      ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
        Routing().moveBack();
        initCountry(context, reload: reload);
      }, onBackButton: () {
        Routing().moveBack();
        Routing().moveBack();
      });
    }
  }

  Future initProvince(
    BuildContext context, {
    String? country,
    required bool reload,
  }) async {
    bool connection = await System().checkConnections();
    if (connection) {
      // remove error object province from entry
      context.read<ErrorService>().removeErrorObject(ErrorType.getStates);

      final notifier = UtilsBlocV2();
      await notifier.getCountryBloc(context, search: country);
      final fetch = notifier.utilsFetch;
      if (fetch.utilsState == UtilsState.loadCountrySuccess) {
        String? _countryID = fetch.data[0]["countryID"];
        final notifier2 = UtilsBlocV2();
        await notifier2.getProvinceBloc(context, countryID: _countryID, pageNumber: page);
        final fetch2 = notifier2.utilsFetch;
        if (fetch2.utilsState == UtilsState.loadAreaSuccess) {
          loadMore = false;
          if (reload) {
            _provinceData.clear();
            fetch2.data.forEach((v) => _provinceData.add(ProvinceData.fromJSON(v)));
            _provinceData.sort((a, b) {
              return a.stateName!.compareTo(b.stateName!);
            });
          } else {
            fetch2.data.forEach((v) => _provinceData.add(ProvinceData.fromJSON(v)));
          }
          hasNext = _provinceData.isNotEmpty;
          notifyListeners();
        }
        if (fetch2.utilsState == UtilsState.loadAreaError) {
          page--;
          loadMore = false;
          ShowBottomSheet.onInternalServerError(context, tryAgainButton: () {
            Routing().moveBack();
            initProvince(context, country: country, reload: reload);
          }, backButton: () {
            Routing().moveBack();
          });
        }
      }
      if (fetch.utilsState == UtilsState.loadCountryError) {
        page--;
        loadMore = false;
        ShowBottomSheet.onInternalServerError(context, tryAgainButton: () {
          Routing().moveBack();
          initProvince(context, country: country, reload: reload);
        }, backButton: () {
          Routing().moveBack();
        });
      }
    } else {
      page--;
      loadMore = false;
      ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
        Routing().moveBack();
        initProvince(context, country: country, reload: reload);
      }, onBackButton: () {
        Routing().moveBack();
        Routing().moveBack();
      });
    }
  }

  Future initCity(
    BuildContext context, {
    String? province,
    required bool reload,
  }) async {
    bool connection = await System().checkConnections();
    if (connection) {
      // remove error object province from entry
      context.read<ErrorService>().removeErrorObject(ErrorType.getCities);

      final notifier = UtilsBlocV2();
      await notifier.getProvinceBloc(context, search: province);
      final fetch = notifier.utilsFetch;
      if (fetch.utilsState == UtilsState.loadAreaSuccess) {
        String? _stateID = fetch.data[0]["stateID"];
        final notifier2 = UtilsBlocV2();
        await notifier2.getCityBloc(context, provinceID: _stateID, pageNumber: page);
        final fetch2 = notifier2.utilsFetch;
        if (fetch2.utilsState == UtilsState.loadCitySuccess) {
          loadMore = false;
          if (reload) {
            _cityData.clear();
            fetch2.data.forEach((v) => _cityData.add(CityData.fromJSON(v)));
          } else {
            fetch2.data.forEach((v) => _cityData.add(CityData.fromJSON(v)));
          }
          hasNext = _cityData.isNotEmpty;
          notifyListeners();
        }
        if (fetch2.utilsState == UtilsState.loadCityError) {
          page--;
          loadMore = false;
          ShowBottomSheet.onInternalServerError(context, tryAgainButton: () {
            Routing().moveBack();
            initCity(context, province: province, reload: reload);
          }, backButton: () {
            Routing().moveBack();
          });
        }
      }
      if (fetch.utilsState == UtilsState.loadAreaError) {
        page--;
        loadMore = false;
        ShowBottomSheet.onInternalServerError(context, tryAgainButton: () {
          Routing().moveBack();
          initCity(context, province: province, reload: reload);
        }, backButton: () {
          Routing().moveBack();
        });
      }
    } else {
      page--;
      loadMore = false;
      ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
        Routing().moveBack();
        initCity(context, province: province, reload: reload);
      }, onBackButton: () {
        Routing().moveBack();
        Routing().moveBack();
      });
    }
  }

  void initPageLength() {
    _page = 0;
    _hasNext = true;
  }

  locationCountryListSelected(String data) {
    if (countryController.text != data) {
      provinceController.clear();
      cityController.clear();
    }
    countryController.text = data;
    _checkRequirement();
    notifyListeners();
    Routing().moveBack();
  }

  locationProvinceListSelected(String data) {
    if (provinceController.text != data) {
      cityController.clear();
    }
    provinceController.text = data;
    _checkRequirement();
    notifyListeners();
    Routing().moveBack();
  }

  locationCityListSelected(String data) {
    cityController.text = data;
    _checkRequirement();
    notifyListeners();
    Routing().moveBack();
  }
}
