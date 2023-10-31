import 'package:hyppe/core/bloc/playlist/state.dart';
import 'package:hyppe/core/bloc/repos/repos.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/status_code.dart';
import 'package:hyppe/core/models/collection/playlist/playlist.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:flutter/material.dart';

class PlaylistBloc {
  PlaylistFetch? _playlistFetch;
  PlaylistFetch? get playlistFetch => _playlistFetch;
  setPlaylistFetch(PlaylistFetch val) => _playlistFetch = val;

  Future createNewPlaylistBloc(BuildContext context, {required Playlist data}) async {
    setPlaylistFetch(PlaylistFetch(PlaylistState.loading));
    await Repos().reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) != HTTP_OK) {
          setPlaylistFetch(PlaylistFetch(PlaylistState.createNewPlaylistBlocError));
        } else {
          final Playlist _result = Playlist.fromJsonResponsePost(onResult.data);
          setPlaylistFetch(PlaylistFetch(PlaylistState.createNewPlaylistBlocSuccess, data: _result));
        }
      },
      (errorData) {
        ShowBottomSheet.onInternalServerError(context, statusCode: errorData.response?.statusCode);
        setPlaylistFetch(PlaylistFetch(PlaylistState.createNewPlaylistBlocError));
      },
      host: UrlConstants.createNewPlaylist,
      data: data.toMapPlaylistPost(),
      withAlertMessage: false,
      methodType: MethodType.post,
      withCheckConnection: false,
    );
  }

  Future getAllPlaylistBloc(BuildContext context, {required int? page}) async {
    setPlaylistFetch(PlaylistFetch(PlaylistState.loading));
    await Repos().reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) != HTTP_OK) {
          setPlaylistFetch(PlaylistFetch(PlaylistState.getAllPlaylistBlocBlocError));
        } else {
          Playlist _result = Playlist.fromJsonResponseGet(onResult.data);
          setPlaylistFetch(PlaylistFetch(PlaylistState.getAllPlaylistBlocSuccess, data: _result));
        }
      },
      (errorData) {
        ShowBottomSheet.onInternalServerError(context, statusCode: errorData.response?.statusCode);
        setPlaylistFetch(PlaylistFetch(PlaylistState.getAllPlaylistBlocBlocError));
      },
      host: UrlConstants.getAllPlaylist + "?pageNumber=$page",
      withAlertMessage: false,
      methodType: MethodType.get,
      withCheckConnection: false,
    );
  }
}
