import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart' as dio;
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:hyppe/core/arguments/update_contents_argument.dart';
import 'package:hyppe/core/bloc/music/bloc.dart';
import 'package:hyppe/core/bloc/music/state.dart';
import 'package:hyppe/core/bloc/sticker/bloc.dart';
import 'package:hyppe/core/bloc/sticker/state.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/file_extension.dart';
import 'package:hyppe/core/constants/filter_matrix.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/models/collection/sticker/sticker_category_model.dart';
import 'package:hyppe/core/models/collection/sticker/sticker_tab.dart';
import 'package:hyppe/core/models/collection/sticker/sticker_model.dart';
import 'package:hyppe/core/services/overlay_service/overlay_handler.dart';
import 'package:hyppe/core/services/overlay_service/overlay_service.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/entities/camera/notifier.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_coloured_sheet.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/custom_text_field_for_overlay.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/notifier.dart';
import 'package:hyppe/ui/inner/upload/preview_content/widget/build_sticker_widget.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../../../app.dart';
import '../../../../core/arguments/progress_upload_argument.dart';
import '../../../../core/bloc/posts_v2/bloc.dart';
import '../../../../core/config/url_constants.dart';
import '../../../../core/constants/shared_preference_keys.dart';
import '../../../../core/models/collection/music/music.dart';
import '../../../../core/models/collection/music/music_type.dart';
import '../../../../core/services/event_service.dart';
import '../../../../core/services/shared_preference.dart';
import '../video_editor/video_editor.dart';

class PreviewContentNotifier with ChangeNotifier {
  final eventService = EventService();
  dynamic _uploadSuccess;
  LocalizationModelV2 language = LocalizationModelV2();
  translate(LocalizationModelV2 translate) {
    language = translate;
    notifyListeners();
  }

  bool isActivePagePreview = false;

  double? _aspectRatio;
  FeatureType? _featureType;
  List<String?>? _fileContent;
  List<Uint8List?>? _thumbNails;
  int _indexView = 0;
  int _pageMusic = 0;
  int? _height;
  int? get height => _height;
  int? _width;
  int? get width => _width;
  String? _url;
  String? _defaultPath;
  Music? _currentMusic;
  Music? _selectedMusic;
  Music? _fixSelectedMusic;
  SourceFile? _sourceFile;
  int _pageNo = 0;
  bool _nextVideo = false;
  bool _isForcePaused = false;
  bool _showNext = false;
  final List<List<double>> _filterMatrix = [];
  bool _isSheetOpen = false;
  final List<Widget> _additionalItem = [];
  final List<Offset> _positions = [];
  bool _isDraggingItem = false;
  int? _itemKey;
  double _sizeDragTarget = 60;
  Color? _dragTargetColor;
  bool _addTextItemMode = false;
  Duration? _totalDuration;
  Duration? get totalDuration => _totalDuration;
  bool _isLoadingBetterPlayer = false;
  bool get isLoadingBetterPlayer => _isLoadingBetterPlayer;
  bool _isLoadVideo = false;
  bool get isLoadVideo => _isLoadVideo;
  bool _isLoadingMusic = true;
  bool get isLoadingMusic => _isLoadingMusic;
  List<MusicGroupType> _listTypes = [];
  List<MusicGroupType> get listType => _listTypes;
  List<Music> _listMusics = [];
  List<Music> get listMusics => _listMusics;
  bool _isNextMusic = false;
  bool get isNextMusic => _isNextMusic;
  bool _isLoadNextMusic = false;
  bool get isLoadNextMusic => _isLoadNextMusic;
  List<Music> _listExpMusics = [];
  List<Music> get listExpMusics => _listExpMusics;
  bool _isNextExpMusic = false;
  bool get isNextExpMusic => _isNextExpMusic;
  bool _isLoadNextExpMusic = false;
  bool get isLoadNextExpMusic => _isLoadNextExpMusic;
  MusicType? _selectedType;
  MusicType? get selectedType => _selectedType;
  MusicEnum? _selectedMusicEnum;
  MusicEnum? get selectedMusicEnum => _selectedMusicEnum;
  List<MusicType> _listGenres = [];
  List<MusicType> get listGenres => _listGenres;
  List<MusicType> _listThemes = [];
  List<MusicType> get listThemes => _listThemes;
  List<MusicType> _listMoods = [];
  List<MusicType> get listMoods => _listMoods;
  int _errorHit = 0;
  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  VideoPlayerController? _betterPlayerController;
  PersistentBottomSheetController? _persistentBottomSheetController;
  final TransformationController _transformationController = TransformationController();
  var audioPlayer = AudioPlayer();
  var audioPreviewPlayer = AudioPlayer();
  final searchController = TextEditingController();
  var scrollController = ScrollController();
  var scrollExpController = ScrollController();
  final focusNode = FocusNode();

  VideoPlayerController? get betterPlayerController => _betterPlayerController;
  set betterPlayerController(VideoPlayerController? val) {
    _betterPlayerController = val;
    notifyListeners();
  }

  TransformationController get transformationController => _transformationController;
  PersistentBottomSheetController? get persistentBottomSheetController => _persistentBottomSheetController;
  bool get showNext => _showNext;
  List<Uint8List?>? get thumbNails => _thumbNails;
  double get sizeDragTarget => _sizeDragTarget;
  Color? get dragTargetColor => _dragTargetColor;
  bool get addTextItemMode => _addTextItemMode;
  bool get isSheetOpen => _isSheetOpen;
  List<Widget> get additionalItem => _additionalItem;
  List<Offset> get positions => _positions;
  bool get isDraggingItem => _isDraggingItem;
  int? get itemKey => _itemKey;
  int get pageNo => _pageNo;
  bool get nextVideo => _nextVideo;
  bool get isForcePaused => _isForcePaused;
  String? get url => _url;
  String? get defaultPath => _defaultPath;
  Music? get currentMusic => _currentMusic;
  Music? get selectedMusic => _selectedMusic;
  Music? get fixSelectedMusic => _fixSelectedMusic;
  SourceFile? get sourceFile => _sourceFile;
  int get indexView => _indexView;
  int get pageMusic => _pageMusic;
  double? get aspectRation => _aspectRatio;
  FeatureType? get featureType => _featureType;
  List<String?>? get fileContent => _fileContent;
  List<double> filterMatrix(int index) => _filterMatrix[index];

  TextEditingController stickerTextController = TextEditingController();
  ScrollController stickerScrollController = ScrollController();

  double _stickerScrollPosition = 0.0;
  double get stickerScrollPosition => _stickerScrollPosition;
  set stickerScrollPosition(double val) {
    _stickerScrollPosition = val;
    notifyListeners();
  }

  double _stickerMaxScroll = 0.0;
  double get stickerMaxScroll => _stickerMaxScroll;
  set stickerMaxScroll(double val) {
    _stickerMaxScroll = val;
    notifyListeners();
  }

  String _stickerSearchText = '';
  String get stickerSearchText => _stickerSearchText;
  set stickerSearchText(String val) {
    _stickerSearchText = val;
    notifyListeners();
  }

  bool _stickerSearchActive = false;
  bool get stickerSearchActive => _stickerSearchActive;
  set stickerSearchActive(bool val) {
    _stickerSearchActive = val;
    notifyListeners();
  }

  bool _isDragging = false;
  bool get isDragging => _isDragging;
  set isDragging(bool val) {
    _isDragging = val;
    notifyListeners();
  }

  bool _isDeleteButtonActive = false;
  bool get isDeleteButtonActive => _isDeleteButtonActive;
  set isDeleteButtonActive(bool val) {
    _isDeleteButtonActive = val;
    notifyListeners();
  }

  String _messageLimit = '';
  String get messageLimit => _messageLimit;
  set messageLimit(String value) {
    _messageLimit = value;
    notifyListeners();
  }

  bool _showToastLimit = false;
  bool get showToastLimit => _showToastLimit;
  set showToastLimit(bool state) {
    _showToastLimit = state;
    notifyListeners();
  }

  showToast(Duration duration) {
    if (!showToastLimit) {
      showToastLimit = true;
      Future.delayed(duration, () {
        showToastLimit = false;
      });
    }
  }

  List<StickerTab> _stickerTab = [
    StickerTab(index: 0, name: 'Sticker', type: 'STICKER', column: 3, data: []),
    StickerTab(index: 1, name: 'Emoji', type: 'EMOJI', column: 5, data: []),
    StickerTab(index: 2, name: 'GIF', type: 'GIF', column: 3, data: []),
  ];
  List<StickerTab> get stickerTab => _stickerTab;
  set stickerTab(List<StickerTab> val) {
    _stickerTab = val;
    notifyListeners();
  }

  List<StickerModel> _stickers = [];
  List<StickerModel> get stickers => _stickers;
  set stickers(List<StickerModel> val) {
    _stickers = val;
    notifyListeners();
  }

  int _stickerTabIndex = 0;
  int get stickerTabIndex => _stickerTabIndex;
  set stickerTabIndex(val) {
    _stickerTabIndex = val;
    notifyListeners();
  }

  int _stickerCategoryIndex = 0;
  int get stickerCategoryIndex => _stickerCategoryIndex;
  set stickerCategoryIndex(val) {
    _stickerCategoryIndex = val;
    notifyListeners();
  }

  List<Widget> _onScreenStickers = [];
  List<Widget> get onScreenStickers => _onScreenStickers;
  set onScreenStickers(List<Widget> val) {
    _onScreenStickers = val;
    notifyListeners();
  }

  set height(int? val) {
    _height = val;
    notifyListeners();
  }

  setHeight(int? val) {
    _height = val;
  }

  set width(int? val) {
    _width = val;
    notifyListeners();
  }

  setWidth(int? val) {
    _width = val;
  }

  set isLoadVideo(bool val) {
    _isLoadVideo = val;
    notifyListeners();
  }

  set showNext(bool val) {
    _showNext = val;
    notifyListeners();
  }

  set totalDuration(Duration? val) {
    _totalDuration = val;
    notifyListeners();
  }

  set addTextItemMode(bool val) {
    _addTextItemMode = val;
    notifyListeners();
  }

  set persistentBottomSheetController(PersistentBottomSheetController? val) {
    _persistentBottomSheetController = val;
    notifyListeners();
  }

  set isSheetOpen(bool val) {
    _isSheetOpen = val;
    notifyListeners();
  }

  set isDraggingItem(bool val) {
    _isDraggingItem = val;
    notifyListeners();
  }

  set pageNo(int newValue) {
    _pageNo = newValue;
    notifyListeners();
  }

  set nextVideo(bool newValue) {
    _nextVideo = newValue;
    notifyListeners();
  }

  set isForcePaused(bool newValue) {
    _isForcePaused = newValue;
    notifyListeners();
  }

  set url(String? val) {
    _url = val;
    notifyListeners();
  }

  set isLoadingMusic(bool state) {
    _isLoadingMusic = state;
    notifyListeners();
  }

  set sourceFile(SourceFile? val) {
    _sourceFile = val;
    notifyListeners();
  }

  set indexView(int val) {
    _indexView = val;
    notifyListeners();
  }

  set pageMusic(int state) {
    _pageMusic = state;
    _selectedMusic = null;
    _currentMusic = null;
    _selectedType = null;
    audioPlayer.stop();
    for (var music in _listMusics) {
      if (music.isSelected) {
        final index = _listMusics.indexOf(music);
        _listMusics[index].isSelected = false;
      }
    }
    for (var music in _listExpMusics) {
      if (music.isSelected) {
        final index = _listExpMusics.indexOf(music);
        _listExpMusics[index].isSelected = false;
      }
    }
    notifyListeners();
  }

  set aspectRation(double? val) {
    _aspectRatio = val;
    notifyListeners();
  }

  set featureType(FeatureType? val) {
    _featureType = val;
    notifyListeners();
  }

  set fileContent(List<String?>? val) {
    _fileContent = val;
    notifyListeners();
  }

  void setFileContent(String path, int index) {
    _fileContent?[index] = path;
    notifyListeners();
  }

  set listType(List<MusicGroupType> values) {
    _listTypes = values;
    notifyListeners();
  }

  void setMusicGroupState(int index, bool state) {
    _listTypes[index].isSeeAll = state;
    notifyListeners();
  }

  set listMusics(List<Music> values) {
    _listMusics = values;
    _isNextMusic = (values.length % 15 == 0);
    notifyListeners();
  }

  set isNextMusic(bool state) {
    _isNextMusic = state;
    notifyListeners();
  }

  set listExpMusics(List<Music> values) {
    _listExpMusics = values;
    _isNextExpMusic = (values.length % 15 == 0);
    notifyListeners();
  }

  set selectedType(MusicType? type) {
    _selectedType = type;
    notifyListeners();
  }

  set selectedMusicEnum(MusicEnum? val) {
    _selectedMusicEnum = val;
    notifyListeners();
  }

  set listGenres(List<MusicType> types) {
    _listGenres = types;
    notifyListeners();
  }

  set listThemes(List<MusicType> types) {
    _listThemes = types;
    notifyListeners();
  }

  set listMoods(List<MusicType> types) {
    _listMoods = types;
    notifyListeners();
  }

  set currentMusic(Music? music) {
    _currentMusic = music;
    notifyListeners();
  }

  set selectedMusic(Music? music) {
    _selectedMusic = music;
    notifyListeners();
  }

  set fixSelectedMusic(Music? music) {
    _fixSelectedMusic = music;
    notifyListeners();
  }

  set isLoadNextMusic(bool state) {
    _isLoadNextMusic = state;
    notifyListeners();
  }

  set isLoadNextExpMusic(bool state) {
    _isLoadNextExpMusic = state;
    notifyListeners();
  }

  set defaultPath(String? val) {
    _defaultPath = val;
  }

  bool isNoDataTypes() {
    var isNoData = false;
    var count = 0;
    if (_listThemes.isEmpty) {
      count += 1;
    }

    if (_listMoods.isEmpty) {
      count += 1;
    }

    if (_listGenres.isEmpty) {
      count += 1;
    }
    if (count > 2) {
      isNoData = true;
    }

    return isNoData;
  }

  void resumeAudioPreview() {
    if (isActivePagePreview) {
      try {
        audioPreviewPlayer.resume();
      } catch (e) {
        e.logger();
      }
    }
  }

  void pauseAudioPreview() {
    try {
      audioPreviewPlayer.pause();
    } catch (e) {
      e.logger();
    }
  }

  void onScrollExpMusics(
    BuildContext context,
  ) async {
    if (scrollExpController.offset >= scrollExpController.position.maxScrollExtent && !scrollExpController.position.outOfRange) {
      if (!_isLoadNextExpMusic) {
        print('Test onScrollExpMusics');
        if (_isNextExpMusic) {
          try {
            _isLoadNextExpMusic = true;
            final int pageNumber = _listExpMusics.length ~/ 15;
            List<Music> res = [];
            final myId = _selectedType?.id;
            if (myId != null) {
              if (_selectedMusicEnum == MusicEnum.mood) {
                res = await getMusics(context, keyword: searchController.text, idMood: myId, pageNumber: pageNumber);
              } else if (_selectedMusicEnum == MusicEnum.genre) {
                res = await getMusics(context, keyword: searchController.text, idGenre: myId, pageNumber: pageNumber);
              } else {
                res = await getMusics(context, keyword: searchController.text, idTheme: myId, pageNumber: pageNumber);
              }
              _isNextExpMusic = res.isEmpty ? false : res.length % 15 == 0;
              _listExpMusics.addAll(res);
            }
          } catch (e) {
            'Error onScrollMusics : $e'.logger();
          } finally {
            _isLoadNextExpMusic = false;
            notifyListeners();
          }
        }
      }
    }
  }

  void onScrollMusics(BuildContext context) async {
    if (scrollController.offset >= scrollController.position.maxScrollExtent && !scrollController.position.outOfRange) {
      if (!_isLoadNextMusic) {
        if (_isNextMusic) {
          try {
            _isLoadNextMusic = true;
            final int pageNumber = _listMusics.length ~/ 15;
            final res = await getMusics(context, keyword: searchController.text, pageNumber: pageNumber);
            _isNextMusic = res.isEmpty ? false : res.length % 15 == 0;
            _listMusics.addAll(res);
            notifyListeners();
          } catch (e) {
            'Error onScrollMusics : $e'.logger();
          } finally {
            _isLoadNextMusic = false;
          }
        }
      }
    }
  }

  void onChangeSearchMusic(BuildContext context, String value) {
    if (value.length > 2) {
      for (var music in _listMusics) {
        if (music.isSelected) {
          final index = _listMusics.indexOf(music);
          _listMusics[index].isSelected = false;
        }
      }
      for (var music in _listExpMusics) {
        if (music.isSelected) {
          final index = _listExpMusics.indexOf(music);
          _listExpMusics[index].isSelected = false;
        }
      }
      _currentMusic = null;
      _selectedMusic = null;
      _selectedType = null;
      notifyListeners();
      Future.delayed(const Duration(milliseconds: 500), () async {
        final currentValue = searchController.text;
        if (currentValue == value) {
          _isLoadingMusic = true;
          notifyListeners();
          try {
            listMusics = await getMusics(context, keyword: value);
            _listGenres = await getMusicCategories(context, MusicEnum.genre, keyword: value);
            _listThemes = await getMusicCategories(context, MusicEnum.theme, keyword: value);
            _listMoods = await getMusicCategories(context, MusicEnum.mood, keyword: value);
          } catch (e) {
            'Error onChangeSearchMusic : $e'.logger();
          } finally {
            _isLoadingMusic = false;
            FocusScope.of(context).unfocus();
            notifyListeners();
          }
        }
      });
    } else {
      if (value.isEmpty) {
        initListMusics(context);
        FocusScope.of(context).unfocus();
      }
    }
  }

  void forceResetPlayer(bool isChanged) {
    print('forceResetPlayer');
    _currentMusic = null;
    _selectedMusic = null;
    for (var data in _listMusics) {
      if (data.isPlay) {
        data.isPlay = false;
      }
      if (data.isSelected) {
        data.isSelected = false;
      }
    }
    for (var data in _listExpMusics) {
      if (data.isPlay) {
        data.isPlay = false;
      }
      if (data.isSelected) {
        data.isSelected = false;
      }
    }
    try {
      audioPlayer.stop();
      if (isChanged) {
        notifyListeners();
      }
    } catch (e) {
      'forceResetPlayer error: $e'.logger();
    }
  }

  Future initListMusics(BuildContext context) async {
    audioPlayer.onPlayerStateChanged.listen((event) {
      if (event == PlayerState.completed) {
        try {
          if (_currentMusic != null) {
            final index = _listMusics.indexOf(_currentMusic!);
            if (index != -1) {
              _listMusics[index].isPlay = false;
            } else {
              final expIndex = _listExpMusics.indexOf(_currentMusic!);
              if (expIndex != -1) {
                _listExpMusics[_indexView].isPlay = false;
              } else {
                forceResetPlayer(false);
              }
            }
          } else {
            forceResetPlayer(false);
          }
        } catch (e) {
          forceResetPlayer(false);
          e.logger();
        } finally {
          notifyListeners();
        }
      }
    });
    _isLoadingMusic = true;
    try {
      _listTypes = [
        MusicGroupType(group: language.theme ?? 'Theme', isSeeAll: false),
        MusicGroupType(group: language.genre ?? 'Genre', isSeeAll: false),
        MusicGroupType(group: language.mood ?? 'Mood', isSeeAll: false)
      ];
      listMusics = await getMusics(context);
      _listGenres = await getMusicCategories(context, MusicEnum.genre);
      _listThemes = await getMusicCategories(context, MusicEnum.theme);
      _listMoods = await getMusicCategories(context, MusicEnum.mood);
      notifyListeners();
    } catch (e) {
      'Error initListMusics : $e'.logger();
    } finally {
      _isLoadingMusic = false;
    }
  }

  Future getMusicByType(BuildContext context, {String keyword = '', String idGenre = '', String idTheme = '', String idMood = ''}) async {
    listExpMusics = await getMusics(context, keyword: keyword, idGenre: idGenre, idTheme: idTheme, idMood: idMood);
    notifyListeners();
  }

  Future<List<Music>> getMusics(BuildContext context, {String keyword = '', String idGenre = '', String idTheme = '', String idMood = '', int pageNumber = 0, int pageRow = 15}) async {
    List<Music>? res = [];
    _isLoadingMusic = true;
    try {
      final bloc = MusicDataBloc();
      await bloc.getMusics(context, keyword: keyword, idTheme: idTheme, idGenre: idGenre, idMood: idMood, pageNumber: pageNumber, pageRow: pageRow);
      final fetch = bloc.musicDataFetch;
      if (fetch.musicDataState == MusicState.getMusicsBlocSuccess) {
        res = (fetch.data as List<dynamic>?)?.map((item) => Music.fromJson(item as Map<String, dynamic>)).toList();
        print('res length = ${res?.length}');
        return res ?? [];
      } else if (fetch.musicDataState == MusicState.getMusicBlocError) {
        throw '${(fetch.data as dio.DioError).message}';
      }
    } catch (e) {
      print('Error getMusics : $e');
    } finally {
      _isLoadingMusic = false;
    }
    return [];
  }

  Future<List<MusicType>> getMusicCategories(BuildContext context, MusicEnum type, {String keyword = ''}) async {
    List<MusicType>? res = [];
    try {
      final bloc = MusicDataBloc();
      await bloc.getTypeMusic(context, type, keyword: keyword);
      final fetch = bloc.musicDataFetch;
      if (fetch.musicDataState == MusicState.getMusicsBlocSuccess) {
        res = (fetch.data as List<dynamic>?)?.map((item) => MusicType.fromJson(item as Map<String, dynamic>)).toList();
      } else if (fetch.musicDataState == MusicState.getMusicBlocError) {
        throw '${(fetch.data as dio.DioError).message}';
      }
    } catch (e) {
      print('Error getMusicCategories : $e');
    }
    return res ?? [];
  }

  void setFilterMatrix(List<double> val) {
    _filterMatrix[indexView] = val;
    notifyListeners();
  }

  Future<void> encodeVideo(BuildContext context) async {
    try {
      _isLoadVideo = true;
      notifyListeners();
      String outputPath = await System().getSystemPath(params: 'postVideo');
      outputPath = '${outputPath + materialAppKey.currentContext!.getNameByDate()}.mp4';
      String command = '-i "${_fileContent?[0]}" -c:a aac -strict -2 $outputPath';
      print('encode video: $command');
      await FFmpegKit.executeAsync(
        command,
        (session) async {
          final codeSession = await session.getReturnCode();
          if (ReturnCode.isSuccess(codeSession)) {
            print('ReturnCode = Success');
            _fileContent?[0] = outputPath;
            notifyListeners();
          } else if (ReturnCode.isCancel(codeSession)) {
            print('ReturnCode = Cancel');
            _isLoadVideo = false;
            notifyListeners();
            throw 'Merge video is canceled';
            // Cancel
          } else {
            print('ReturnCode = Error');
            _isLoadVideo = false;
            notifyListeners();
            throw 'Merge video is Error';
            // Error
          }
        },
        (log) {
          _isLoadVideo = false;
          notifyListeners();
          print('FFmpegKit ${log.getMessage()}');
        },
      );
    } catch (e) {
      'videoMerger Error : $e'.logger();
      ShowBottomSheet().onShowColouredSheet(context, '$e', color: kHyppeDanger, maxLines: 2);
    }
  }

  Future<void> videoMerger(BuildContext context, String urlAudio, {isInit = false}) async {
    final videoCtrl = VideoPlayerController.file(File(_fileContent?[_indexView] ?? ''));
    try {
      await videoCtrl.initialize();
      final durationVideo = _printDuration(videoCtrl.value.duration);
      if (urlAudio.isNotEmpty) {
        print("masuk mergeerr $durationVideo");
        _isLoadVideo = true;
        notifyListeners();
        print(isLoadVideo);
        String outputPath = await System().getSystemPath(params: 'postVideo');
        outputPath = '${outputPath + materialAppKey.currentContext!.getNameByDate()}.mp4';

        String command = '-stream_loop -1 -i $urlAudio -i ${_fileContent?[_indexView]} ${durationVideo.isNotEmpty ? "-t $durationVideo" : "-shortest"} -c copy $outputPath';
        await FFmpegKit.executeAsync(
          command,
          (session) async {
            final codeSession = await session.getReturnCode();
            if (ReturnCode.isSuccess(codeSession)) {
              print('ReturnCode = Success');
              await restartVideoPlayer(outputPath, context, isInit: isInit);
            } else if (ReturnCode.isCancel(codeSession)) {
              print('ReturnCode = Cancel');
              _isLoadVideo = false;
              notifyListeners();
              throw 'Merge video is canceled';
              // Cancel
            } else {
              print('ReturnCode = Error');
              _isLoadVideo = false;
              notifyListeners();
              throw 'Merge video is Error';
              // Error
            }
          },
          (log) {
            _isLoadVideo = false;
            notifyListeners();
            print('FFmpegKit ${log.getMessage()}');
          },
        );
      } else {
        _isLoadVideo = false;
        notifyListeners();
        throw 'UrlAudio is empty';
      }
    } catch (e) {
      'videoMerger Error : $e'.logger();
      ShowBottomSheet().onShowColouredSheet(context, '$e', color: kHyppeDanger, maxLines: 2);
    } finally {
      _isLoadVideo = false;
      notifyListeners();
      videoCtrl.dispose();
    }
  }

  String _printDuration(Duration duration) {
    String negativeSign = duration.isNegative ? '-' : '';
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60).abs());
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60).abs());
    return "$negativeSign${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  /// split story videos ==Hariyanto Lukman==
  Future postVideos(BuildContext context, Duration totalDuration) async {
    await for (String? file in getSplitVideos(context, totalDuration)) {
      if (file != null) {
        postStoryContent(context, file: file);
      }
    }
  }

  Stream<String?> getSplitVideos(BuildContext context, Duration totalDuration) async* {
    final defaultFile = _fileContent?[0];
    final seconds = totalDuration.inSeconds;
    if (seconds > 15) {
      var start = const Duration(seconds: 0);
      var end = const Duration(seconds: 15);
      var temp = const Duration();

      if (defaultFile != null) {
        for (int i = 0; i < (_fileContent ?? []).length; i++) {
          if (i == 0) {
            if (seconds < 19) {
              end = Duration(seconds: seconds - 4);
            }
            temp = end;
          } else if (i == 1) {
            start = temp;
            end = totalDuration;
          }
          yield await videoSplit(context, defaultFile, start, end, i);
          // if(path != null){
          //   // await Future.delayed(const Duration(seconds: 1));
          //   await postStoryContent(context, file: path ?? '');
          // }
        }
      }
    } else {
      await postStoryContent(
        context,
      );
    }
  }

  Future<String?> videoSplit(BuildContext context, String file, Duration start, Duration end, int index) async {
    try {
      _isLoadVideo = true;
      notifyListeners();
      String outputPath = await System().getSystemPath(params: 'postVideo');
      outputPath = '${outputPath + (Routing.navigatorKey.currentContext ?? context).getNameByDate()}.mp4';

      final strStart = start.detail();
      final strEnd = end.detail();
      String command = '-ss $strStart -to $strEnd -i $file -async 1 $outputPath';
      final session = await FFmpegKit.executeAsync(
        command,
        null,
        (log) {
          _isLoadVideo = false;
          notifyListeners();
          print('FFmpegKit ${log.getMessage()}');
        },
      );
      final codeSession = await session.getReturnCode();
      if (ReturnCode.isSuccess(codeSession)) {
        print('ReturnCode = Success');
        _isLoadVideo = false;
        return outputPath;
        // await restartVideoPlayer(outputPath, context, isInit: true);
      } else if (ReturnCode.isCancel(codeSession)) {
        print('ReturnCode = Cancel');
        _isLoadVideo = false;
        notifyListeners();
        throw 'Merge video is canceled';
        // Cancel
      } else {
        print('ReturnCode = Error');
        _isLoadVideo = false;
        notifyListeners();
        throw 'Merge video is Error';
        // Error
      }
    } catch (e) {
      'videoMerger Error : $e'.logger();
      return null;
    }
  }

  Future restartVideoPlayer(String outputPath, BuildContext context, {bool isInit = true}) async {
    final path = _fileContent?[_indexView] ?? '';
    print('URL now : $path');
    print('URL default 2 : $_defaultPath');
    _fileContent?[_indexView] = outputPath;
    _url = fileContent?[_indexView];
    _sourceFile = SourceFile.local;
    // _betterPlayerController = null;
    notifyListeners();
    if (isInit) {
      initVideoPlayer(context);
    }
    if (path.isNotEmpty) {
      if (path != _defaultPath) {
        await File(path).delete();
      }
    }
  }

  // void setReloadVid()async{
  //   isLoadVideo = true;
  //   // await restartVideoPlayer(_fileContent?[_indexView] ?? _defaultPath ?? '', materialAppKey.currentContext!);
  //   Future.delayed(const Duration(milliseconds: 500),() {
  //     print('state setReloadVid $isLoadVideo');
  //     isLoadVideo = false;
  //     print('state setReloadVid $isLoadVideo');
  //   });
  // }

  void setDefaultVideo(BuildContext context) async {
    try {
      _isLoadVideo = true;
      notifyListeners();
      final _isImage = (_fileContent?[_indexView] ?? '').isImageFormat();
      if (_isImage) {
        _selectedMusic = null;
        _fixSelectedMusic = null;
        _selectedType = null;
        audioPreviewPlayer.stop();
        audioPreviewPlayer.dispose();
        notifyListeners();
      } else {
        if (_defaultPath != null) {
          await restartVideoPlayer(_defaultPath!, context);
          _selectedMusic = null;
          _fixSelectedMusic = null;
          _selectedType = null;
          notifyListeners();
        } else {
          throw 'defaultPath is null';
        }
      }
    } catch (e) {
      e.logger();
      ShowBottomSheet().onShowColouredSheet(context, '$e', color: kHyppeDanger, maxLines: 2);
    } finally {
      _isLoadVideo = false;
      notifyListeners();
    }
  }

  void disposeMusic() async {
    try {
      forceResetPlayer(false);
      await audioPlayer.dispose();
    } catch (e) {
      'disposeMusic error : $e'.logger();
    }
  }

  void dialogDisposesMusic() async {
    try {
      await audioPlayer.stop();
      await audioPlayer.dispose();
    } catch (e) {
      'disposeMusic error : $e'.logger();
    }
  }

  void playExpMusic(BuildContext context, Music music, int index) async {
    try {
      // final currentMusic = notifier.currentMusic;
      _listExpMusics[index].isLoad = true;

      notifyListeners();
      var url = music.apsaraMusicUrl?.playUrl ?? '';
      if (_currentMusic != null) {
        final currentIndex = _listExpMusics.indexOf(_currentMusic!);
        if (music.isPlay) {
          await audioPlayer.stop();
          _listExpMusics[index].isPlay = false;

          currentMusic?.isPlay = false;
          notifyListeners();
        } else {
          await audioPlayer.stop();
          if (url.isNotEmpty) {
            await audioPlayer.play(UrlSource(url));
          } else {
            throw 'url music is null';
          }

          _currentMusic = music;
          currentMusic?.isPlay = true;

          _listExpMusics[currentIndex].isPlay = false;
          _listExpMusics[index].isPlay = true;

          notifyListeners();
        }
      } else {
        await audioPlayer.stop();
        await audioPlayer.play(UrlSource(url));
        _currentMusic = music;
        currentMusic?.isPlay = true;
        _listExpMusics[index].isPlay = true;
        notifyListeners();
      }
    } catch (e) {
      'Error Play Music : $e'.logger();

      _listExpMusics[index].isPlay = false;
      notifyListeners();
    } finally {
      _listExpMusics[index].isLoad = false;
      notifyListeners();
    }
  }

  void playMusic(BuildContext context, Music music, int index) async {
    try {
      // final currentMusic = notifier.currentMusic;
      _listMusics[index].isLoad = true;

      notifyListeners();
      var url = music.apsaraMusicUrl?.playUrl ?? '';
      if (_currentMusic != null) {
        print('playMusic : up');
        final currentIndex = _listMusics.indexOf(_currentMusic!);
        if (music.isPlay) {
          await audioPlayer.stop();
          _listMusics[index].isPlay = false;

          currentMusic?.isPlay = false;
          notifyListeners();
        } else {
          await audioPlayer.stop();
          await audioPlayer.play(UrlSource(url));

          _currentMusic = music;
          currentMusic?.isPlay = true;

          _listMusics[currentIndex].isPlay = false;
          _listMusics[index].isPlay = true;

          notifyListeners();
        }
      } else {
        print('playMusic : down');
        await audioPlayer.stop();
        await audioPlayer.play(UrlSource(url));
        _currentMusic = music;
        currentMusic?.isPlay = true;
        _listMusics[index].isPlay = true;
        notifyListeners();
      }
    } catch (e) {
      'Error Play Music : $e'.logger();

      _listMusics[index].isPlay = false;
      notifyListeners();
    } finally {
      _listMusics[index].isLoad = false;
      notifyListeners();
    }
  }

  void selectExpMusic(Music music, int index) {
    if (_selectedMusic != null) {
      if (_selectedMusic!.id == music.id) {
        _selectedMusic = null;
        notifyListeners();
        _listExpMusics[index].isSelected = false;
      } else {
        _listExpMusics[_listExpMusics.indexOf(_selectedMusic!)].isSelected = false;
        _listExpMusics[index].isSelected = true;
        _selectedMusic = music;
      }
    } else {
      _listExpMusics[index].isSelected = true;
      _selectedMusic = music;
    }
    notifyListeners();
  }

  void selectMusic(Music music, int index) {
    if (_selectedMusic != null) {
      if (_selectedMusic!.id == music.id) {
        _selectedMusic = null;
        notifyListeners();
        _listMusics[index].isSelected = false;
      } else {
        _listMusics[_listMusics.indexOf(_selectedMusic!)].isSelected = false;
        _listMusics[index].isSelected = true;
        _selectedMusic = music;
      }
    } else {
      _listMusics[index].isSelected = true;
      _selectedMusic = music;
    }
    notifyListeners();
  }

  void initialMatrixColor() {
    if (_fileContent != null) {
      _filterMatrix.clear();
      _fileContent?.forEach((_) {
        _filterMatrix.add(NORMAL);
      });
    }
  }

  void initVideoPlayer(BuildContext context, {isSaveDefault = false}) async {
    _isLoadingBetterPlayer = true;
    _errorMessage = '';

    // BetterPlayerConfiguration betterPlayerConfiguration =
    //     const BetterPlayerConfiguration(
    //   autoPlay: false,
    //   fit: BoxFit.contain,
    //   showPlaceholderUntilPlay: true,
    //   controlsConfiguration: BetterPlayerControlsConfiguration(
    //     showControls: false,
    //     enableFullscreen: false,
    //     controlBarColor: Colors.black26,
    //   ),
    // );
    print('_url : $_url');
    if (isSaveDefault) {
      _fixSelectedMusic = null;
      _selectedMusic = null;
      _currentMusic = null;
      _selectedType = null;
      // notifyListeners();
      final _isImage = (_defaultPath ?? '').isImageFormat();
      if (!_isImage) {
        _defaultPath = _url;
      }
    }

    // VideoPlayerController dataSource = BetterPlayerDataSource(
    //   BetterPlayerDataSourceType.file,
    //   _url != null
    //       ? Platform.isIOS
    //           ? _url!.replaceAll(" ", "%20")
    //           : _url!
    //       : '',
    //   bufferingConfiguration: const BetterPlayerBufferingConfiguration(
    //     minBufferMs: BetterPlayerBufferingConfiguration.defaultMinBufferMs,
    //     maxBufferMs: BetterPlayerBufferingConfiguration.defaultMaxBufferMs,
    //     bufferForPlaybackMs:
    //         BetterPlayerBufferingConfiguration.defaultBufferForPlaybackMs,
    //     bufferForPlaybackAfterRebufferMs: BetterPlayerBufferingConfiguration
    //         .defaultBufferForPlaybackAfterRebufferMs,
    //   ),
    // );

    _isLoadVideo = true;
    await _betterPlayerController?.dispose();
    _betterPlayerController = null;

    // await Future.delayed(const Duration(milliseconds: 500));

    _betterPlayerController = VideoPlayerController.file(
      File(
        _url ?? '',
      ),
    );
    try {
      notifyListeners();
      // await _betterPlayerController?.setupDataSource(dataSource).then((_) {
      //   _betterPlayerController?.play();
      //   _betterPlayerController?.setLooping(true);
      //   _betterPlayerController?.setOverriddenAspectRatio(
      //       _betterPlayerController?.videoPlayerController?.value.aspectRatio ??
      //           0.0);
      //   notifyListeners();
      // });

      _betterPlayerController?.addListener(() {
        notifyListeners();
      });
      _betterPlayerController?.setLooping(true);
      print('will initialize');
      await _betterPlayerController?.initialize().whenComplete(() {
        Future.delayed(const Duration(seconds: 1), () {
          if (featureType == FeatureType.story) {
            final videoDuration = betterPlayerController?.value.duration ?? const Duration(seconds: 0);
            // const limitDuration = Duration(seconds: 15, milliseconds: 800);
            messageLimit = (language.messageLimitStory ?? 'Error');
            //Change Limit max jadi 15 Detik
            if (videoDuration >= const Duration(seconds: 16)) {
              showToast(const Duration(seconds: 3));
            }
            // else if (videoDuration < Duration(seconds: storyMin)) {
            //   messageLimit = language.messageLessLimitStory ?? 'Error';
            //   showToast(const Duration(seconds: 3));
            // }
          } else {
            final videoDuration = betterPlayerController?.value.duration ?? const Duration(seconds: 0);
            final limitDuration = featureType == FeatureType.diary
                ? const Duration(minutes: 1, milliseconds: 900)
                : featureType == FeatureType.vid
                    ? const Duration(minutes: 30, milliseconds: 900)
                    : const Duration(seconds: 0);
            print('State Preview Limit: ${videoDuration.inSeconds} ${limitDuration.inSeconds} $featureType');
            print('duration  video $videoDuration');
            if (videoDuration >= limitDuration) {
              messageLimit = featureType == FeatureType.vid
                  ? (language.messageLimitVideo ?? 'Error')
                  : featureType == FeatureType.diary
                      ? (language.messageLimitDiary ?? 'Error')
                      : 'Error';
              showToast(const Duration(seconds: 3));
            } else if (videoDuration < Duration(seconds: 14)) {
              // messageLimit = language.messageLessLimitVideo ?? 'Error';
              // showToast(const Duration(seconds: 3));
            }
          }
          _betterPlayerController?.play();
          notifyListeners();
        });
      });

      // _betterPlayerController?.addEventsListener(
      //   (_) {
      //     _totalDuration = _.parameters?['duration'];
      //
      //     if (_totalDuration != null) {
      //       if (_betterPlayerController?.isVideoInitialized() ??
      //           false) if ((_betterPlayerController
      //                   ?.videoPlayerController?.value.position ??
      //               Duration.zero) >=
      //           (_betterPlayerController
      //                   ?.videoPlayerController?.value.duration ??
      //               Duration.zero)) {
      //         _nextVideo = true;
      //       }
      //     }
      //   },
      // );
      _isLoadingBetterPlayer = false;
      notifyListeners();

      // notifier.setVideoPlayerController(_betterPlayerController);
    } catch (e) {
      _errorHit++;
      "Error Init Video $e".logger();
      if (_errorHit <= 3) {
        initVideoPlayer(context);
      } else {
        _errorHit = 0;
        _isLoadingBetterPlayer = false;
        _errorMessage = language.fileMayBeInErrorChooseAnotherFile ?? '';
        _betterPlayerController?.dispose();
        notifyListeners();
      }
    } finally {
      _isLoadVideo = false;
      _isLoadingBetterPlayer = false;
      notifyListeners();
    }
  }

  void setOnWillAccept() {
    _sizeDragTarget = 70;
    _dragTargetColor = Colors.red;
    notifyListeners();
  }

  void setOnLeave() {
    _sizeDragTarget = 60;
    _dragTargetColor = null;
    if (_additionalItem.isEmpty) _addTextItemMode = false;
    notifyListeners();
  }

  void addAdditionalItem({required Widget widgetItem, required Offset offsetItem}) {
    _additionalItem.add(widgetItem);
    _positions.add(offsetItem);
    notifyListeners();
  }

  void setPositions(int index, Offset offset) {
    _isDraggingItem = false;
    if (_positions.isNotEmpty && _itemKey == index) _positions[index] = offset;
    notifyListeners();
  }

  void removeAdditionalItem() {
    if (_itemKey != null) {
      _additionalItem.removeAt(_itemKey!);
      _positions.removeAt(_itemKey!);
      _itemKey = null;
      setOnLeave();
    }
  }

  void onDragStarted(int index) {
    _isDraggingItem = true;
    _itemKey = index;
    notifyListeners();
  }

  void setVideoPlayerController(VideoPlayerController? val) => _betterPlayerController = val;

  void clearAdditionalItem() {
    _additionalItem.clear();
    _positions.clear();
  }

  bool ableShare() {
    if (featureType == FeatureType.pic) {
      return true;
    } else if (featureType == FeatureType.diary || featureType == FeatureType.vid || featureType == FeatureType.story) {
      final isImage = fileContent?[0]?.isImageFormat() ?? false;
      if (isImage) {
        return true;
      }
      final videoDuration = betterPlayerController?.value.duration ?? const Duration(seconds: 0);
      final limitDuration = featureType == FeatureType.diary
          ? const Duration(minutes: 1, milliseconds: 900)
          : featureType == FeatureType.vid
              ? const Duration(minutes: 30, milliseconds: 900)
              : featureType == FeatureType.story
                  ? const Duration(seconds: 15, milliseconds: 900)
                  : const Duration(seconds: 0);
      print('State Preview Limit Checking: ${videoDuration.inMinutes} ${limitDuration.inMinutes} $featureType');
      if (videoDuration.inSeconds == 0) {
        return false;
      }
      if (videoDuration >= limitDuration) {
        return false;
      }
      if (featureType == FeatureType.diary || featureType == FeatureType.vid) {
        return videoDuration.inMinutes <= limitDuration.inMinutes;
      } else {
        return videoDuration.inSeconds <= limitDuration.inSeconds;
      }
    } else {
      return true;
    }
  }

  Future<bool> onWillPop(BuildContext context) async {
    print("hahahaha");
    _addTextItemMode = false;
    _fixSelectedMusic = null;
    _selectedMusic = null;
    _currentMusic = null;
    _selectedType = null;
    _showNext = false;
    notifyListeners();
    if (_isSheetOpen) closeFilters();
    clearAdditionalItem();
    if (context.read<OverlayHandlerProvider>().overlayActive) {
      context.read<OverlayHandlerProvider>().removeOverlay(context);
    }
    // if (pageController.hasClients) pageController.animateToPage(0, duration: const Duration(milliseconds: 200), curve: Curves.easeInCirc);
    // Routing().moveAndPop(makeContent);
    context.read<CameraNotifier>().orientation = null;
    Routing().moveBack();
    return Future.value(true);
  }

  void animateToPage(int index, PageController pageController) {
    pageController.animateToPage(index, duration: const Duration(milliseconds: 200), curve: Curves.easeInCirc);
    indexView = index;
    notifyListeners();
  }

  void showSnackBar({
    String? icon,
    required Color color,
    required String message,
  }) {
    Routing().showSnackBar(
      snackBar: SnackBar(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
        content: SafeArea(
          child: SizedBox(
            height: 56,
            child: OnColouredSheet(
              maxLines: 2,
              caption: message,
              fromSnackBar: true,
              iconSvg: icon != null ? "${AssetPath.vectorPath}$icon" : null,
            ),
          ),
        ),
      ),
    );
  }

  void navigateToPreUploaded(BuildContext context, [GlobalKey? globalKey]) async {
    if (featureType == FeatureType.diary) {
      final ms = totalDuration?.inMilliseconds;
      if (ms != null) {
        int seconds = ms ~/ 1000;
        if (seconds <= 3) {
          showSnackBar(
            color: kHyppeDanger,
            message: "${language.min4second}",
          );
          return;
        }
      }
    }

    if (_isSheetOpen) closeFilters();
    if (betterPlayerController != null) isForcePaused = true;
    final notifier = Provider.of<PreUploadContentNotifier>(context, listen: false);
    notifier.isEdit = false;
    notifier.featureType = featureType;
    notifier.fileContent = fileContent;
    notifier.thumbNail = _thumbNails != null
        ? _thumbNails!.isNotEmpty
            ? _thumbNails![0]
            : null
        : null;
    notifier.privacyTitle == '' ? notifier.privacyTitle = notifier.language.public ?? 'public' : notifier.privacyTitle = notifier.privacyTitle;
    notifier.locationName == '' ? notifier.locationName = notifier.language.addLocation ?? 'add location' : notifier.locationName = notifier.locationName;
    notifier.musicSelected = _fixSelectedMusic;
    _fixSelectedMusic = null;
    notifier.checkForCompress();
    Routing().move(Routes.preUploadContent, argument: UpdateContentsArgument(onEdit: false)).whenComplete(() => isForcePaused = false);
  }

  //Tag Hariyanto
  Future makeThumbnail(BuildContext context, int index) async {
    if (System().lookupContentMimeType(fileContent?[index] ?? '')?.startsWith('image') ?? false) {
      showNext = true;
    } else {
      _thumbNails = [];
      try {
        for (int i = 0; i <= index; i++) {
          print('adsasdasd asdads');
          print(fileContent![index]!);
          Uint8List? _thumbnail = await VideoThumbnail.thumbnailData(
            video: fileContent?[index] ?? '',
            imageFormat: ImageFormat.JPEG,
            maxWidth: 128, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
            quality: 25,
          );
          _thumbNails?.add(_thumbnail);
        }
      } catch (e) {
        print('makeThumbnail Error $e');
      }

      if (_thumbNails?.isNotEmpty ?? false) {
        showNext = true;
      } else {
        if (betterPlayerController != null) isForcePaused = true;
        // ShowBottomSheet.onShowSomethingWhenWrong(context, onClose: () => onWillPop(context));
      }
    }
  }

  void toDiaryVideoPlayer(int index, SourceFile sourceFile) {
    _url = fileContent?[index];
    _sourceFile = sourceFile;
  }

  void showFilters(BuildContext context, GlobalKey<ScaffoldState> scaffoldState, GlobalKey? globalKey) {
    if (System().extensionFiles(_fileContent?[indexView] ?? '') == '.$PNG' ||
        System().extensionFiles(_fileContent?[indexView] ?? '') == '.$JPG' ||
        System().extensionFiles(_fileContent?[indexView] ?? '') == '.$JPEG') {
      isSheetOpen = true;
      persistentBottomSheetController = ShowBottomSheet().onShowFilters(context, scaffoldState, fileContent?[indexView] ?? '', globalKey);

      // listen to Scaffold status
      persistentBottomSheetController?.closed.whenComplete(() => isSheetOpen = false);
    } else {
      ShowBottomSheet().onShowColouredSheet(context, language.filterIsOnlySupportedForImage ?? '', color: kHyppeTextWarning, maxLines: 2);
    }
  }

  Future<void> getSticker(BuildContext context, {required int index}) async {
    if (stickerTab[index].data.isEmpty) {
      try {
        final notifier = StickerBloc();
        await notifier.getStickers(context, stickerTab[index].type);
        final fetch = notifier.stickerFetch;
        if (fetch.state == StickerState.getStickerSuccess) {
          List<StickerCategoryModel>? res = (fetch.data as List<dynamic>?)?.map((e) => StickerCategoryModel.fromJson(e as Map<String, dynamic>)).toList();
          stickerTab[index].data.addAll(res ?? []);
        }
        notifyListeners();
      } catch (e) {
        'get sticker: ERROR: $e'.logger();
      }
    }
  }

  initStickerScroll(BuildContext context) {
    stickerScrollController.addListener(() {
      stickerScrollPosition = stickerScrollController.offset;
      if (stickerScrollController.position.maxScrollExtent != stickerMaxScroll) {
        stickerMaxScroll = stickerScrollController.position.maxScrollExtent;
      }
    });
  }

  removeStickerScroll(BuildContext context) {
    stickerScrollController.removeListener(() => this);
  }

  void addSticker(BuildContext context, StickerModel? sticker) {
    var datetime = DateTime.now();
    stickers.add(StickerModel(
      key: Key(datetime.toString()),
      id: sticker?.id,
      type: sticker?.type,
      image: sticker?.image,
      matrix: Matrix4.identity().scaled(SizeWidget.stickerScale)
        ..setTranslationRaw(
          (MediaQuery.of(context).size.width - (MediaQuery.of(context).size.width * SizeWidget.stickerScale)) / 2,
          MediaQuery.of(context).size.height / 5,
          0,
        ),
    ));
    onScreenStickers.add(BuildStickerWidget(
      key: Key(datetime.toString()),
      image: sticker?.image ?? '',
      onDragStart: () {
        if (!isDragging) {
          isDragging = true;
          notifyListeners();
        }
      },
      onDragEnd: (matrix, offset, key) {
        isDragging = false;
        isDeleteButtonActive = false;
        stickers.where((element) => element.key == key).first.matrix = matrix;
        notifyListeners();
        if (offset.dy > (MediaQuery.of(Routing.navigatorKey.currentContext ?? context).size.height - 160) &&
            offset.dy < (MediaQuery.of(Routing.navigatorKey.currentContext ?? context).size.height - 80) &&
            offset.dx > ((MediaQuery.of(Routing.navigatorKey.currentContext ?? context).size.width / 2) - 30) &&
            offset.dx < ((MediaQuery.of(Routing.navigatorKey.currentContext ?? context).size.width / 2) + 30)) {
          stickers.removeWhere((element) => element.key == key);
          onScreenStickers.removeWhere((element) => element.key == key);
          notifyListeners();
        }
      },
      onDragUpdate: (matrix, offset, key) {
        if (offset.dy > (MediaQuery.of(Routing.navigatorKey.currentContext ?? context).size.height - 160) &&
            offset.dy < (MediaQuery.of(Routing.navigatorKey.currentContext ?? context).size.height - 80) &&
            offset.dx > ((MediaQuery.of(Routing.navigatorKey.currentContext ?? context).size.width / 2) - 30) &&
            offset.dx < ((MediaQuery.of(Routing.navigatorKey.currentContext ?? context).size.width / 2) + 30)) {
          if (!isDeleteButtonActive) {
            isDeleteButtonActive = true;
            notifyListeners();
          }
        } else {
          if (_isDeleteButtonActive) {
            isDeleteButtonActive = false;
            notifyListeners();
          }
        }
      },
    ));
    Navigator.pop(context);
    notifyListeners();
  }

  Future<void> postStoryContent(BuildContext context, {String? file}) async {
    final _orientation = context.read<CameraNotifier>().orientation;
    final homeNotifier = context.read<HomeNotifier>();
    try {
      // _connectAndListenToSocket(context);
      SharedPreference().writeStorage(SpKeys.uploadContent, true);
      final notifier = PostsBloc();
      print('featureType : $featureType');
      notifier.postContentsBlocV2(
        context,
        width: width,
        height: height,
        type: featureType ?? FeatureType.other,
        visibility: 'PUBLIC',
        tags: [],
        tagDescription: [],
        allowComment: true,
        certified: false,
        fileContents: file != null ? [file] : (fileContent ?? []),
        description: '',
        cats: [],
        tagPeople: [],
        idMusic: fixSelectedMusic?.id,
        saleAmount: "0",
        saleLike: false,
        saleView: false,
        rotate: _orientation ?? NativeDeviceOrientation.portraitUp,
        location: '',
        stickers: _stickers,
        onReceiveProgress: (count, total) async {
          await eventService.notifyUploadReceiveProgress(ProgressUploadArgument(count: count.toDouble(), total: total.toDouble()));
        },
        onSendProgress: (received, total) async {
          await eventService.notifyUploadSendProgress(ProgressUploadArgument(count: received.toDouble(), total: total.toDouble()));
        },
      ).then((value) {
        _uploadSuccess = value;
        'Create post content with value $value'.logger();
        SharedPreference().writeStorage(SpKeys.uploadContent, false);
        eventService.notifyUploadSuccess(_uploadSuccess);
        // _eventService.notifyUploadFinishingUp(_uploadSuccess);
        if (value is dio.Response) {
          dio.Response res = value;
          "return data ${jsonEncode(res.data['data'])}".loggerV2();
          ContentData uploadedData = ContentData.fromJson(res.data['data']);
          (Routing.navigatorKey.currentContext ?? context).read<HomeNotifier>().onUploadedSelfUserContent(context: context, contentData: uploadedData);
        }
      });

      homeNotifier.preventReloadAfterUploadPost = true;
      homeNotifier.uploadedPostType = FeatureType.story;
      Routing().moveAndRemoveUntil(Routes.lobby, Routes.root);
    } catch (e) {
      print('Error create post : $e');
      SharedPreference().writeStorage(SpKeys.uploadContent, false);
      eventService.notifyUploadFailed(
        dio.DioError(
          requestOptions: dio.RequestOptions(
            path: UrlConstants.createuserposts,
          ),
          error: e,
        ),
      );
      'e'.logger();
    } finally {
      try {
        _width = null;
        _height = null;
        audioPreviewPlayer.stop();
        audioPreviewPlayer.dispose();
      } catch (e) {
        'Error dispose AudioPreviewPlayer : $e'.logger();
      }

      defaultPath = null;
      if (betterPlayerController != null) {
        betterPlayerController!.dispose();
        betterPlayerController = null;
      }
    }
  }

  bool _noRefresh = false;
  bool get noRefresh => _noRefresh;
  set noRefresh(bool state) {
    _noRefresh = state;
    notifyListeners();
  }

  void goToVideoEditor(BuildContext context, FeatureType type) async {
    noRefresh = true;
    final path = fileContent?[0];
    if (path != null) {
      isLoadVideo = true;
      betterPlayerController?.pause();
      final seconds = betterPlayerController?.value.duration ?? const Duration(seconds: 10);

      final newPath = await Navigator.push(
        context,
        MaterialPageRoute<String?>(
          builder: (BuildContext context) => VideoEditor(
            file: File(path),
            videoSeconds: seconds,
            type: type,
          ),
        ),
      );
      if (newPath != null) {
        final controller = VideoPlayerController.file(File(newPath));
        try {
          controller.initialize();
          fileContent?[0] = newPath;
          isLoadVideo = false;
          Future.delayed(const Duration(milliseconds: 500), () {
            initVideoPlayer(context);
            noRefresh = false;
          });
        } catch (e) {
          messageLimit = 'Error convert';
          showToast(const Duration(seconds: 3));
        }
      } else {
        isLoadVideo = false;
        // Future.delayed(const Duration(milliseconds: 500), (){
        //
        //   initVideoPlayer(context);
        //   noRefresh = false;
        // });
      }
    }
  }

  void applyFilters({GlobalKey? globalKey}) async {
    if (globalKey != null) {
      // edited file holder
      String? _file;

      try {
        // generated widget to image
        _file = await System().convertWidgetToImage(globalKey);

        _fileContent?[indexView] = _file;
      } catch (e) {
        e.toString().logger();
      }
    }

    isSheetOpen = false;
    persistentBottomSheetController?.close();
  }

  void closeFilters() {
    persistentBottomSheetController?.close();
    initialMatrixColor();
  }

  void addTextItem(BuildContext context) {
    if (System().extensionFiles(_fileContent?[indexView] ?? '') == '.$PNG' ||
        System().extensionFiles(_fileContent?[indexView] ?? '') == '.$JPG' ||
        System().extensionFiles(_fileContent?[indexView] ?? '') == '.$JPEG') {
      OverlayService().addOverlayElement(context, const CustomTextFieldForOverlay());
    } else {
      ShowBottomSheet().onShowColouredSheet(context, language.filterIsOnlySupportedForImage ?? '', color: kHyppeTextWarning, maxLines: 2);
    }
  }

  void applyTextItem(GlobalKey? globalKey) async {
    if (globalKey != null) {
      _addTextItemMode = false;
      // edited file holder
      String? _file;
      // check if filter changing or not
      _file = await System().convertWidgetToImage(globalKey);

      _fileContent?[indexView] = _file;
      clearAdditionalItem();
      notifyListeners();
    }
  }

  void openImageCropper(BuildContext context, int currIndex) async {
    try {
      final pathFile = fileContent?[currIndex];
      if (pathFile != null) {
        final newFile = await ImageCropper().cropImage(
          sourcePath: pathFile,
          compressFormat: ImageCompressFormat.jpg,
          compressQuality: 100,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            // CropAspectRatioPreset.ratio16x9
          ],
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: language.editImage,
              toolbarColor: kHyppePrimary,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: true,
              showCropGrid: true,
            ),
            IOSUiSettings(
              title: language.editImage,
            ),
            WebUiSettings(
              context: context,
              presentStyle: CropperPresentStyle.page,
              // boundary: const CroppieBoundary(
              //   width: 520,
              //   height: 520,
              // ),
              // viewPort:
              // const CroppieViewPort(width: 480, height: 480, type: 'circle'),
              enableExif: true,
              enableZoom: true,
              showZoomer: true,
            ),
          ],
        );
        if (newFile != null) {
          await File(pathFile).delete();
          setFileContent(newFile.path, currIndex);
        } else {
          throw 'file result is null';
        }
      } else {
        throw 'file is null';
      }
    } catch (e) {
      print('Error ImageCropper: $e');
      // ShowBottomSheet().onShowColouredSheet(context, e.toString(), color: kHyppeDanger, maxLines: 2);
    }
  }
}
