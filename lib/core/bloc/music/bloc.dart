import 'package:flutter/cupertino.dart';
import 'package:hyppe/core/bloc/music/state.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/models/collection/music/music_type.dart';
import 'package:hyppe/core/response/generic_response.dart';

import '../../constants/shared_preference_keys.dart';
import '../../constants/status_code.dart';
import '../../services/shared_preference.dart';
import '../repos/repos.dart';

class MusicDataBloc{
  MusicDataFetch _musicDataFetch = MusicDataFetch(MusicState.init);
  MusicDataFetch get musicDataFetch => _musicDataFetch;
  setCommentFetch(MusicDataFetch val) => _musicDataFetch = val;

  Future getTypeMusic(BuildContext context, MusicEnum type) async{
    setCommentFetch(MusicDataFetch(MusicState.loading));
    final email = SharedPreference().readStorage(SpKeys.email);
    final token = SharedPreference().readStorage(SpKeys.userToken);
    await Repos().reposPost(context, (onResult){
      if ((onResult.statusCode ?? 300)  > HTTP_CODE) {
        setCommentFetch(MusicDataFetch(MusicState.getMusicBlocError));
      } else {
        print('data: ${onResult.data}');
        final response = GenericResponse.fromJson(onResult.data);
        setCommentFetch(MusicDataFetch(MusicState.getMusicsBlocSuccess,
            data: response));
      }
    }, (errorData) => setCommentFetch(MusicDataFetch(MusicState.getMusicBlocError)),
        host: type == MusicEnum.genre ? '${UrlConstants.getMusicGenre}?pageNumber=0&pageRow=20' : type == MusicEnum.mood ? '${UrlConstants.getMusicMood}?pageNumber=0&pageRow=20' : '${UrlConstants.getMusicTheme}?pageNumber=0&pageRow=20',
        withAlertMessage: false,
        methodType: MethodType.get,
        withCheckConnection: false,
        headers: {
          'x-auth-user': email,
          'x-auth-token': token,
        });
  }

  Future getMusics(BuildContext context, MusicEnum type) async{
    setCommentFetch(MusicDataFetch(MusicState.loading));
    final email = SharedPreference().readStorage(SpKeys.email);
    final token = SharedPreference().readStorage(SpKeys.userToken);
    await Repos().reposPost(context, (onResult){
      if ((onResult.statusCode ?? 300)  > HTTP_CODE) {
        setCommentFetch(MusicDataFetch(MusicState.getMusicBlocError));
      } else {
        print('data: ${onResult.data}');
        final response = GenericResponse.fromJson(onResult.data);
        setCommentFetch(MusicDataFetch(MusicState.getMusicsBlocSuccess,
            data: response));
      }
    }, (errorData) => setCommentFetch(MusicDataFetch(MusicState.getMusicBlocError)),
        host: '${UrlConstants.getMusics}?pageNumber=0&pageRow=20',
        withAlertMessage: false,
        methodType: MethodType.get,
        withCheckConnection: false,
        headers: {
          'x-auth-user': email,
          'x-auth-token': token,
        });
  }
}