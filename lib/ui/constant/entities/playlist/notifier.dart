import 'package:hyppe/core/bloc/bookmark/bloc.dart';
import 'package:hyppe/core/bloc/bookmark/state.dart';
import 'package:hyppe/core/bloc/playlist/bloc.dart';
import 'package:hyppe/core/bloc/playlist/state.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/models/collection/bookmark/bookmark.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/playlist/playlist.dart';
import 'package:hyppe/core/models/collection/playlist/playlist_data.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlaylistNotifier with ChangeNotifier {
  String? _featureType;
  ContentData? _data;
  int? _index;

  /// For Content Purposes
  showMyPlaylistBottomSheet(BuildContext context, {FeatureType? featureType, ContentData? data, int? index}) async {
    _featureType = System().validatePostTypeV2(featureType);
    _data = data;
    _index = index;
    ShowBottomSheet.onShowPlaylist(context, data: _data, feature: _featureType, index: _index);
  }

  LocalizationModelV2 language = LocalizationModelV2();
  translate(LocalizationModelV2 translate) {
    language = translate;
    notifyListeners();
  }

  // LIST
  ///////////////////////////////////////////////////////////////////////////////////////////////////////
  int? _indexList;
  int? _pagePlaylist;
  int? _pageBookmark;
  int? _playlistGroupValueIndex;
  bool _screen = false;
  Playlist? _result;
  List<PlaylistData> _playlistData = [];
  List<String> _listPrivacy = [];

  int? get indexList => _indexList;
  int? get pagePlaylist => _pagePlaylist;
  int? get pageBookmark => _pageBookmark;
  int? get playlistGroupValueIndex => _playlistGroupValueIndex;
  bool get screen => _screen;
  List<PlaylistData> get playlistData => _playlistData;
  List<String> get listPrivacy => _listPrivacy;

  set indexList(int? val) {
    _indexList = val;
    notifyListeners();
  }

  set playlistGroupValueIndex(int? val) {
    _playlistGroupValueIndex = val;
    notifyListeners();
  }

  set screen(bool val) {
    _screen = val;
    notifyListeners();
  }

  set playlistData(List<PlaylistData> val) {
    _playlistData = val;
    notifyListeners();
  }

  onExit() {
    _pagePlaylist = 0;
    _pageBookmark = 0;
    indexList = null;
    screen = false;
    playlistData.clear();
  }

  initialMyPlaylistData(BuildContext context) async {
    final translate = context.read<TranslateNotifierV2>().translate;
    _listPrivacy = [translate.public!, translate.friends!, translate.onlyMe!];
    _pagePlaylist = 0;
    _pageBookmark = 0;
    _playlistData.clear();
    initialFetch(context);
  }

  initialFetch(BuildContext context) async {
    final notifier = PlaylistBloc();
    await notifier.getAllPlaylistBloc(context, page: _pagePlaylist);
    final fetch = notifier.playlistFetch!;
    if (fetch.playlistState == PlaylistState.getAllPlaylistBlocSuccess) {
      _result = fetch.data;
      if (_result!.listPlaylistData.isNotEmpty) {
        final notifier2 = BookmarkBloc();
        for (int i = 0; i < _result!.listPlaylistData.length; i++) {
          await notifier2.getBookmarkBloc(context, playlistID: _result!.listPlaylistData[i].playlistID!);
          final fetch2 = notifier2.bookmarkFetch;
          if (fetch2.bookmarkState == BookmarkState.getBookmarkBlocSuccess) {
            Bookmark result = fetch2.data;
            for (int v = 0; v < result.data.length; v++) {
              if (result.data[v].contentID == _data!.postID) _indexList = i;
            }
          }
        }
        _pagePlaylist = _pagePlaylist! + 1;
        _playlistData.addAll(_result!.listPlaylistData);
        notifyListeners();
      } else {
        print("BookMark Dah Mentok");
      }
    }
  }

  addScrollListenerPlaylist(BuildContext context, ScrollController scrollController) async {
    if (scrollController.offset >= scrollController.position.maxScrollExtent && !scrollController.position.outOfRange) {
      initialFetch(context);
    }
  }

  void addToBookmark(BuildContext context, {String? playlistID}) async {
    final notifier = BookmarkBloc();
    print(playlistID);
    await notifier.addBookmarkBloc(context,
        data: Bookmark(featureType: _featureType, contentID: _data!.postID, playlistID: playlistID));
    final fetch = notifier.bookmarkFetch;
    if (fetch.bookmarkState == BookmarkState.addBookmarkBlocSuccess) {
      Future.delayed(const Duration(milliseconds: 300), () {
        onExit();
        Routing().moveBack();
      });
    }
  }

  // ADD
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  String? _dropDownValue;
  Color? _sendButtonColor;
  bool _color = false;
  bool _loading = false;
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _newPlaylistController = TextEditingController();

  String? get dropDownValue => _dropDownValue;
  Color? get sendButtonColor => _sendButtonColor;
  bool get color => _color;
  bool get loading => _loading;
  FocusNode get focusNode => _focusNode;
  TextEditingController get newPlaylistController => _newPlaylistController;

  set loading(bool val) {
    _loading = val;
    notifyListeners();
  }

  set color(bool val) {
    _color = val;
    notifyListeners();
  }

  set dropDownValue(String? val) {
    _dropDownValue = val;
    notifyListeners();
  }

  set sendButtonColor(Color? val) {
    _sendButtonColor = val;
    notifyListeners();
  }

  Future onCreatePlaylist(BuildContext context, String textEditing) async {
    loading = true;
    color = false;
    focusNode.unfocus();
    if (textEditing.isNotEmpty) {
      final notifier = PlaylistBloc();
      await notifier.createNewPlaylistBloc(context, data: Playlist(visibility: dropDownValue, playlistName: textEditing));
      final fetch = notifier.playlistFetch!;
      if (fetch.playlistState == PlaylistState.createNewPlaylistBlocSuccess) {
        loading = false;
        onExit();
      }
      if (fetch.playlistState == PlaylistState.createNewPlaylistBlocError) {
        color = true;
      }
    }
  }
}
