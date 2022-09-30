import 'package:flutter/cupertino.dart';

import '../../../../core/models/collection/localization_v2/localization_model.dart';

class HashtagNotifier with ChangeNotifier{
  LocalizationModelV2 language = LocalizationModelV2();
  translate(LocalizationModelV2 translate) {
    language = translate;
    notifyListeners();
  }

  List<Hashtag>? _listHashtag;
  bool? _isLoading;

  List<Hashtag>? get listHashtag => _listHashtag;
  bool? get isLoading => _isLoading;

  set listHashtag(List<Hashtag>? val) {
    _listHashtag = val;
    notifyListeners();
  }

  set isLoading(bool? state){
    _isLoading = state;
    notifyListeners();
  }

  initHashTag(BuildContext context){
    getHashtag();
  }
  
  void getHashtag() async{
    listHashtag = [];
    isLoading = true;
    Future.delayed(const Duration(seconds: 2), (){
      isLoading = false;
      listHashtag = [Hashtag("#WisataIndonesia", 600), Hashtag('#WisataJakarta', 700), Hashtag('#WisataBandung', 300)];
    });
  }

}

class Hashtag{
  String? name;
  int? count;

  Hashtag(this.name, this.count);
}