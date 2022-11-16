import 'package:flutter/cupertino.dart';
import 'package:hyppe/core/bloc/music/state.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/response/generic_response.dart';

import '../../constants/shared_preference_keys.dart';
import '../../constants/status_code.dart';
import '../../services/shared_preference.dart';
import '../repos/repos.dart';

class MusicDataBloc{
  MusicDataFetch _musicDataFetch = MusicDataFetch(MusicState.init);
  MusicDataFetch get musicDataFetch => _musicDataFetch;
  setCommentFetch(MusicDataFetch val) => _musicDataFetch = val;

  Future getTypeMusic(BuildContext context, MusicEnum type, {String keyword = '', int pageNumber = 0, int pageRow = 10}) async{
    setCommentFetch(MusicDataFetch(MusicState.loading));
    final email = SharedPreference().readStorage(SpKeys.email);
    final token = SharedPreference().readStorage(SpKeys.userToken);
    final param = keyword.isEmpty ? '?pageNumber=$pageNumber&pageRow=$pageRow' : '?pageNumber=$pageNumber&pageRow=$pageRow&search=$keyword';
    await Repos().reposPost(context, (onResult){
      if ((onResult.statusCode ?? 300)  > HTTP_CODE) {
        setCommentFetch(MusicDataFetch(MusicState.getMusicBlocError));
      } else {
        print('data: ${onResult.data}');
        final response = GenericResponse.fromJson(onResult.data);
        setCommentFetch(MusicDataFetch(MusicState.getMusicsBlocSuccess,
            data: response.responseData));
      }
    }, (errorData) => setCommentFetch(MusicDataFetch(MusicState.getMusicBlocError, data: errorData)),
        host: type == MusicEnum.genre ? '${UrlConstants.getMusicGenre}$param' : type == MusicEnum.mood ? '${UrlConstants.getMusicMood}$param' : '${UrlConstants.getMusicTheme}$param',
        withAlertMessage: false,
        methodType: MethodType.get,
        withCheckConnection: false,
        headers: {
          'x-auth-user': email,
          'x-auth-token': token,
        });
  }

  Future getMusics(BuildContext context, {String keyword = '', String idGenre = '', String idTheme = '', String idMood ='', int pageNumber = 0, int pageRow = 10}) async{
    setCommentFetch(MusicDataFetch(MusicState.loading));
    final email = SharedPreference().readStorage(SpKeys.email);
    final token = SharedPreference().readStorage(SpKeys.userToken);

    final paramGenre = '&genre=$idGenre';
    final paramTheme = '&theme=$idTheme';
    final paramMood = '&mood=$idMood';
    final paramKeyword = keyword.isEmpty ? '?pageNumber=$pageNumber&pageRow=$pageRow${idGenre.isNotEmpty ? paramGenre : ''}${idTheme.isNotEmpty ? paramTheme : ''}${idMood.isNotEmpty ? paramMood : ''}'
        : '?pageNumber=$pageNumber&pageRow=$pageRow&search=$keyword${idGenre.isNotEmpty ? paramGenre : ''}${idTheme.isNotEmpty ? paramTheme : ''}${idMood.isNotEmpty ? paramMood : ''}';
    await Repos().reposPost(context, (onResult){
      if ((onResult.statusCode ?? 300)  > HTTP_CODE) {
        setCommentFetch(MusicDataFetch(MusicState.getMusicBlocError));
      } else {
        print('data: ${onResult.data}');
        final response = GenericResponse.fromJson(onResult.data);
        setCommentFetch(MusicDataFetch(MusicState.getMusicsBlocSuccess,
            data: response.responseData));
      }
    }, (errorData) => setCommentFetch(MusicDataFetch(MusicState.getMusicBlocError, data: errorData)),
        host: '${UrlConstants.getMusics}$paramKeyword',
        withAlertMessage: false,
        methodType: MethodType.get,
        withCheckConnection: false,
        headers: {
          'x-auth-user': email,
          'x-auth-token': token,
        });
  }
}