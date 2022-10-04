import 'package:flutter/cupertino.dart';

import '../../../../core/constants/asset_path.dart';
import '../../../../core/models/collection/localization_v2/localization_model.dart';

class InterestNotifier with ChangeNotifier{
  LocalizationModelV2 language = LocalizationModelV2();
  translate(LocalizationModelV2 translate) {
    language = translate;
    notifyListeners();
  }
  
  final interests = [
    InterestSearch('Hiburan', '${AssetPath.pngPath}hiburan_interest.png'),
    InterestSearch('Berita', '${AssetPath.pngPath}berita_interest.png'),
    InterestSearch('Film', '${AssetPath.pngPath}film_interest.png'),
    InterestSearch('Fashion', '${AssetPath.pngPath}fashion_interest.png'),
    InterestSearch('Akun Selebriti', '${AssetPath.pngPath}celeb_interest.png'),
    InterestSearch('Travel', '${AssetPath.pngPath}travel_interest.png'),
    InterestSearch('Gaming', '${AssetPath.pngPath}gaming_interest.png'),
    InterestSearch('Hobi', '${AssetPath.pngPath}hobby_interest.png'),
  ];

  bool? _isLoading;
  List<InterestSearch>? _listInterests;

  bool? get isLoading => _isLoading;
  List<InterestSearch>? get listInterests => _listInterests;

  initInterest(BuildContext context){

  }

  getInterests(){
    _listInterests = [];
    _isLoading = false;

    try{

    }catch(e){

    }

  }

}

class InterestSearch{
  String? title;
  String? linkImage;

  InterestSearch(this.title, this.linkImage);
}