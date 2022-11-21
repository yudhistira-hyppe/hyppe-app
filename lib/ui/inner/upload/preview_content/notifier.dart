import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:better_player/better_player.dart';
import 'package:dio/dio.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:hyppe/core/arguments/update_contents_argument.dart';
import 'package:hyppe/core/bloc/music/bloc.dart';
import 'package:hyppe/core/bloc/music/state.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/file_extension.dart';
import 'package:hyppe/core/constants/filter_matrix.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/services/overlay_service/overlay_handler.dart';
import 'package:hyppe/core/services/overlay_service/overlay_service.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/entities/camera/notifier.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_coloured_sheet.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/custom_text_field_for_overlay.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../../../app.dart';
import '../../../../core/models/collection/music/music.dart';
import '../../../../core/models/collection/music/music_type.dart';

class PreviewContentNotifier with ChangeNotifier {
  LocalizationModelV2 language = LocalizationModelV2();
  translate(LocalizationModelV2 translate) {
    language = translate;
    notifyListeners();
  }

  double? _aspectRatio;
  FeatureType? _featureType;
  List<String?>? _fileContent;
  List<Uint8List?>? _thumbNails;
  int _indexView = 0;
  int _pageMusic = 0;
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

  BetterPlayerController? _betterPlayerController;
  PersistentBottomSheetController? _persistentBottomSheetController;
  final TransformationController _transformationController = TransformationController();
  var audioPlayer = AudioPlayer();
  final searchController = TextEditingController();
  var scrollController = ScrollController();
  var scrollExpController = ScrollController();
  final focusNode = FocusNode();

  BetterPlayerController? get betterPlayerController => _betterPlayerController;
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

  set isLoadVideo(bool val){
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

  set isLoadingMusic(bool state){
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

  set pageMusic(int state){
    _pageMusic = state;
    _selectedMusic = null;
    _currentMusic = null;
    _selectedType = null;
    audioPlayer.stop();
    for(var music in _listMusics){
      if(music.isSelected){
        final index = _listMusics.indexOf(music);
        _listMusics[index].isSelected = false;
      }
    }
    for(var music in _listExpMusics){
      if(music.isSelected){
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

  void setFileContent(String path, int index){
    _fileContent?[index] = path;
    notifyListeners();
  }

  set listType(List<MusicGroupType> values){
    _listTypes = values;
    notifyListeners();
  }

  void setMusicGroupState(int index, bool state){
    _listTypes[index].isSeeAll = state;
    notifyListeners();
  }

  set listMusics(List<Music> values){
    _listMusics = values;
    _isNextMusic = (values.length%10 == 0);
    notifyListeners();
  }

  set isNextMusic(bool state){
    _isNextMusic = state;
    notifyListeners();
  }

  set listExpMusics(List<Music> values){
    _listExpMusics = values;
    _isNextExpMusic = (values.length%10 == 0);
    notifyListeners();
  }

  set seletedType(MusicType? type){
    _selectedType = type;
    notifyListeners();
  }

  set selectedMusicEnum(MusicEnum? val){
    _selectedMusicEnum = val;
    notifyListeners();
  }

  set listGenres(List<MusicType> types){
    _listGenres = types;
    notifyListeners();
  }

  set listThemes(List<MusicType> types){
    _listThemes = types;
    notifyListeners();
  }

  set listMoods(List<MusicType> types){
    _listMoods = types;
    notifyListeners();
  }

  set currentMusic(Music? music){
    _currentMusic = music;
    notifyListeners();
  }

  set selectedMusic(Music? music){
    _selectedMusic = music;
    notifyListeners();
  }

  set fixSelectedMusic(Music? music){
    _fixSelectedMusic = music;
    notifyListeners();
  }

  set isLoadNextMusic(bool state){
    _isLoadNextMusic = state;
    notifyListeners();
  }

  set isLoadNextExpMusic(bool state){
    _isLoadNextExpMusic = state;
    notifyListeners();
  }

  set defaultPath(String? val){
    _defaultPath = val;
  }

  bool isNoDataTypes(){
    var isNoData = false;
    var count = 0;
    if(_listThemes.isEmpty){
      count += 1;
    }

    if(_listMoods.isEmpty){
      count += 1;
    }

    if(_listGenres.isEmpty){
      count += 1;
    }
    if(count > 2){
      isNoData = true;
    }

    return isNoData;
  }

  void onScrollExpMusics(BuildContext context, )async{
    if(scrollExpController.offset >= scrollExpController.position.maxScrollExtent && !scrollExpController.position.outOfRange){
      if(!_isLoadNextExpMusic){

        print('Test onScrollExpMusics');
        if(_isNextExpMusic){
          try{
            _isLoadNextExpMusic = true;
            final int pageNumber = _listExpMusics.length~/10;
            List<Music> res = [];
            final myId = _selectedType?.id;
            if(myId != null){
              if(_selectedMusicEnum == MusicEnum.mood){
                res = await getMusics(context, keyword: searchController.text, idMood: myId, pageNumber: pageNumber);
              }else if(_selectedMusicEnum == MusicEnum.genre){
                res = await getMusics(context, keyword: searchController.text, idGenre: myId, pageNumber: pageNumber);
              }else{
                res = await getMusics(context, keyword: searchController.text, idTheme: myId, pageNumber: pageNumber);
              }
              _isNextExpMusic = res.isEmpty ? false : res.length%10 == 0;
              _listExpMusics.addAll(res);
            }
          }catch(e){
            'Error onScrollMusics : $e'.logger();
          }finally{
            _isLoadNextExpMusic = false;
            notifyListeners();
          }
        }
      }
    }
  }

  void onScrollMusics(BuildContext context) async{
    if(scrollController.offset >= scrollController.position.maxScrollExtent && !scrollController.position.outOfRange){
      if(!_isLoadNextMusic){
        if(_isNextMusic){
          try{
            _isLoadNextMusic = true;
            final int pageNumber = _listMusics.length~/10;
            final res = await getMusics(context, keyword: searchController.text, pageNumber: pageNumber);
            _isNextMusic = res.isEmpty ? false : res.length%10 == 0;
            _listMusics.addAll(res);
            notifyListeners();
          }catch(e){
            'Error onScrollMusics : $e'.logger();
          }finally{
            _isLoadNextMusic = false;
          }
        }
      }
    }
  }

  void onChangeSearchMusic(BuildContext context, String value) {
    if(value.length > 2){
      for(var music in _listMusics){
        if(music.isSelected){
          final index = _listMusics.indexOf(music);
          _listMusics[index].isSelected = false;
        }
      }
      _currentMusic = null;
      _selectedMusic = null;
      _selectedType = null;
      notifyListeners();
      Future.delayed(const Duration(milliseconds: 500), () async{
        final currentValue = searchController.text;
        if(currentValue == value){
          _isLoadingMusic = true;
          notifyListeners();
          try{
            listMusics = await getMusics(context, keyword: value);
            _listGenres = await getMusicCategories(context, MusicEnum.genre, keyword: value);
            _listThemes = await getMusicCategories(context, MusicEnum.theme, keyword: value);
            _listMoods = await getMusicCategories(context, MusicEnum.mood, keyword: value);
          }catch(e){
            'Error onChangeSearchMusic : $e'.logger();
          }finally{
            _isLoadingMusic = false;
            FocusScope.of(context).unfocus();
            notifyListeners();
          }
        }
      });
    }else{
      if(value.isEmpty){
        initListMusics(context);
        FocusScope.of(context).unfocus();
      }
    }
  }

  void forceResetPlayer(){
    print('forceResetPlayer');
    audioPlayer.stop();
    for(var data in _listMusics){
      if(data.isPlay){
        data.isPlay = false;
        break;
      }
    }
    for(var data in _listExpMusics){
      if(data.isPlay){
        data.isPlay = false;
        break;
      }
    }
  }

  Future initListMusics(BuildContext context) async{
    audioPlayer.onPlayerStateChanged.listen((event) {
      if(event == PlayerState.completed){
        try{
          if(_currentMusic != null){
            final index = _listMusics.indexOf(_currentMusic!);
            if(index != -1){
              _listMusics[index].isPlay = false;
            }else{
              final expIndex = _listExpMusics.indexOf(_currentMusic!);
              if(expIndex != -1){
                _listExpMusics[_indexView].isPlay = false;
              }else{
                forceResetPlayer();
              }
            }
          }else{
            forceResetPlayer();
          }
        }catch(e){
          forceResetPlayer();
          e.logger();
        }finally{
          notifyListeners();
        }

      }
    });
    _isLoadingMusic = true;
    try{
      _listTypes = [MusicGroupType(group: language.theme ?? 'Theme', isSeeAll: false), MusicGroupType(group: language.genre ?? 'Genre', isSeeAll: false), MusicGroupType(group: language.mood ?? 'Mood', isSeeAll: false)];
      listMusics = await getMusics(context);
      _listGenres = await getMusicCategories(context, MusicEnum.genre);
      _listThemes = await getMusicCategories(context, MusicEnum.theme);
      _listMoods = await getMusicCategories(context, MusicEnum.mood);
      notifyListeners();
    }catch(e){
      'Error initListMusics : $e'.logger();
    }finally{
      _isLoadingMusic = false;
    }
  }

  Future getMusicByType(BuildContext context, {String keyword = '', String idGenre = '', String idTheme = '', String idMood =''}) async{
    listExpMusics = await getMusics(context, keyword: keyword, idGenre: idGenre, idTheme: idTheme, idMood: idMood);
    notifyListeners();
  }

  Future<List<Music>> getMusics(BuildContext context, {String keyword = '', String idGenre = '', String idTheme = '', String idMood ='', int pageNumber = 0, int pageRow = 10}) async{
    List<Music>? res = [];
    _isLoadingMusic = true;
    try{
      final bloc = MusicDataBloc();
      await bloc.getMusics(context, keyword: keyword, idTheme: idTheme, idGenre: idGenre, idMood: idMood, pageNumber: pageNumber, pageRow: pageRow);
      final fetch = bloc.musicDataFetch;
      if(fetch.musicDataState == MusicState.getMusicsBlocSuccess){
        res = (fetch.data as List<dynamic>?)?.map((item) => Music.fromJson(item as Map<String, dynamic>)).toList();
        print('res length = ${res?.length}');
        return res ?? [];
      }else if(fetch.musicDataState == MusicState.getMusicBlocError){
        throw '${(fetch.data as DioError).message}';
      }
    }catch(e){
      print('Error getMusics : $e');
    }finally{

      _isLoadingMusic = false;
    }
    return [];
  }

  Future<List<MusicType>> getMusicCategories(BuildContext context, MusicEnum type, {String keyword = ''}) async{
    List<MusicType>? res = [];
    try{
      final bloc = MusicDataBloc();
      await bloc.getTypeMusic(context, type, keyword: keyword);
      final fetch = bloc.musicDataFetch;
      if(fetch.musicDataState == MusicState.getMusicsBlocSuccess){
        res = (fetch.data as List<dynamic>?)?.map((item) => MusicType.fromJson(item as Map<String, dynamic>)).toList();

      }else if(fetch.musicDataState == MusicState.getMusicBlocError){
        throw '${(fetch.data as DioError).message}';
      }
    }catch(e){
      print('Error getMusicCategories : $e');
    }
    return res ?? [];
  }

  void setFilterMatrix(List<double> val) {
    _filterMatrix[indexView] = val;
    notifyListeners();
  }

  Future<void> imageMerger(BuildContext context, String urlAudio, int duration) async{
    try{
      if(urlAudio.isNotEmpty){
        _isLoadVideo = true;
        notifyListeners();
        String tempVideoPath = await System().getSystemPath(params: 'tempVid');
        tempVideoPath = '${tempVideoPath + materialAppKey.currentContext!.getNameByDate()}.mp4';
        String outputPath = await System().getSystemPath(params: 'postPic');File image = File(_fileContent?[_indexView] ?? ''); // Or any other way to get a File instance.
        final decodedImage = await decodeImageFromList(image.readAsBytesSync());
        print('real image : ${decodedImage.height}:${decodedImage.width}');
        outputPath = '${outputPath + materialAppKey.currentContext!.getNameByDate()}.mp4';
        double heightImage = decodedImage.height.toDouble();
        double widthImage = decodedImage.width.toDouble();
        const maxScale = 1080;
        var multiValue = 1.0;
        if(heightImage > maxScale || widthImage > maxScale){

          if(heightImage > maxScale && widthImage > maxScale){
            if(heightImage > widthImage){
              multiValue = maxScale/heightImage;
            }else{
              multiValue = maxScale/widthImage;
            }
          }else if(heightImage > maxScale){
            multiValue = maxScale/heightImage;
          }else if(widthImage> maxScale){
            multiValue = maxScale/widthImage;
          }
        }
        String command = '-framerate 1 -i ${_fileContent?[_indexView]} -r 30 -pix_fmt yuv420p -vf scale=${decodedImage.width/multiValue}:${decodedImage.height/multiValue} -c:v mpeg4 $tempVideoPath';
        await FFmpegKit.executeAsync(command, (session) async{
          final codeSession = await session.getReturnCode();
          if(ReturnCode.isSuccess(codeSession)){
            print('ReturnCode = Success');
            command = '-stream_loop -1 -i $tempVideoPath -i $urlAudio -shortest -c:v mpeg4 $outputPath';
            await FFmpegKit.executeAsync(command, (session) async{
              final codeSession = await session.getReturnCode();
              if(ReturnCode.isSuccess(codeSession)){
                final path = _fileContent?[_indexView] ?? '';
                print('URL now : $path');
                print('URL default 2 : $_defaultPath');
                _fileContent?[_indexView] = outputPath;
                _url = fileContent?[_indexView];
                _isLoadVideo = false;
                _sourceFile = SourceFile.local;
                _betterPlayerController = null;
                _defaultPath = path;
                notifyListeners();
              }else if(ReturnCode.isCancel(codeSession)){
                print('ReturnCode = Cancel');
                _isLoadVideo = false;
                notifyListeners();
                throw 'Merge picture is canceled';
                // Cancel
              }else{
                print('ReturnCode = Error');
                _isLoadVideo = false;
                notifyListeners();
                throw 'Merge picture is error';
                // Error
              }

            }, (log){
              print('FFmpegKit Image ${log.getMessage()}');
            },);

          }else if(ReturnCode.isCancel(codeSession)){
            print('ReturnCode = Cancel');
            _isLoadVideo = false;
            notifyListeners();
            throw 'Merge picture is canceled';
            // Cancel
          }else{
            print('ReturnCode = Error');
            _isLoadVideo = false;
            notifyListeners();
            throw 'Merge picture is error';
            // Error
          }

        }, (log){
          print('FFmpegKit Image ${log.getMessage()}');
        },);
      }
    }catch(e){
      'imageMerger Error : $e'.logger();
      ShowBottomSheet().onShowColouredSheet(context, '$e', color: kHyppeDanger, maxLines: 2);
    }finally{
      _isLoadVideo = false;
      notifyListeners();

    }
  }

  Future<void> videoMerger(BuildContext context, String urlAudio) async{
    try{
      if(urlAudio.isNotEmpty){
        _isLoadVideo = true;
        notifyListeners();
        String outputPath = await System().getSystemPath(params: 'postVideo');
        outputPath = '${outputPath + materialAppKey.currentContext!.getNameByDate()}.mp4';

        String command = '-stream_loop -1 -i $urlAudio -i ${_fileContent?[_indexView]} -shortest -c copy $outputPath';
        await FFmpegKit.executeAsync(command, (session) async{
          final codeSession = await session.getReturnCode();
          if(ReturnCode.isSuccess(codeSession)){
            print('ReturnCode = Success');
            await restartVideoPlayer(outputPath, context);
          }else if(ReturnCode.isCancel(codeSession)){
            print('ReturnCode = Cancel');
            _isLoadVideo = false;
            notifyListeners();
            throw 'Merge video is canceled';
            // Cancel
          }else{
            print('ReturnCode = Error');
            _isLoadVideo = false;
            notifyListeners();
            throw 'Merge video is Error';
            // Error
          }

        }, (log){
          print('FFmpegKit ${log.getMessage()}');
        },);
      }else{
        throw 'UrlAudio is empty';
      }

    }catch(e){
      'videoMerger Error : $e'.logger();
      ShowBottomSheet().onShowColouredSheet(context, '$e', color: kHyppeDanger, maxLines: 2);
    }finally{
      _isLoadVideo = false;
      notifyListeners();
    }

  }

  Future restartVideoPlayer(String outputPath, BuildContext context) async {
    final path = _fileContent?[_indexView] ?? '';
    print('URL now : $path');
    print('URL default 2 : $_defaultPath');
    _fileContent?[_indexView] = outputPath;
    _url = fileContent?[_indexView];
    _sourceFile = SourceFile.local;
    _betterPlayerController = null;
    notifyListeners();
    initVideoPlayer(context);
    if(path.isNotEmpty){
      if(path != _defaultPath){
        await File(path).delete();
      }
    }
  }

  void setDefaultVideo(BuildContext context) async{
    try{
      _isLoadVideo = true;
      notifyListeners();
      if(_defaultPath != null){
        final _isImage = (_defaultPath ?? '').isImageFormat();
        if(_isImage){
          final path = _fileContent?[_indexView] ?? '';
          _fileContent?[_indexView] = _defaultPath;
          _betterPlayerController = null;
          notifyListeners();
          if(path.isNotEmpty){
            if(path != _defaultPath){
              await File(path).delete();
            }
          }
        }else{
          await restartVideoPlayer(_defaultPath!, context);
          _selectedMusic = null;
          _fixSelectedMusic = null;
          notifyListeners();
        }

      }else{
        throw 'defaultPath is null';
      }
    }catch(e){
      e.logger();
      ShowBottomSheet().onShowColouredSheet(context, '$e', color: kHyppeDanger, maxLines: 2);
    }finally{
      _isLoadVideo = false;
      notifyListeners();
    }
  }

  void disposeMusic() async{
    forceResetPlayer();
    await audioPlayer.dispose();
  }

  void playExpMusic(BuildContext context, Music music, int index) async{
    try{
      // final currentMusic = notifier.currentMusic;
      _listExpMusics[index].isLoad = true;

      notifyListeners();
      var url = music.apsaraMusicUrl?.playUrl ?? '';
      if(_currentMusic != null){

        final currentIndex = _listExpMusics.indexOf(_currentMusic!);
        if(music.isPlay){
          await audioPlayer.stop();
          _listExpMusics[index].isPlay = false;

          currentMusic?.isPlay = false;
          notifyListeners();
        }else{
          await audioPlayer.stop();
          if(url.isNotEmpty){
            await audioPlayer.play(UrlSource(url));
          }else{
            throw 'url music is null';
          }

          _currentMusic = music;
          currentMusic?.isPlay = true;

          _listExpMusics[currentIndex].isPlay = false;
          _listExpMusics[index].isPlay = true;

          notifyListeners();
        }
      }else{
        await audioPlayer.stop();
        if(url != null){
          await audioPlayer.play(UrlSource(url));
        }else{
          throw 'url music is null';
        }
        _currentMusic = music;
        currentMusic?.isPlay = true;
        _listExpMusics[index].isPlay = true;
        notifyListeners();
      }

    }catch(e){

      'Error Play Music : $e'.logger();

      _listExpMusics[index].isPlay = false;
      notifyListeners();
    }finally{
      _listExpMusics[index].isLoad = false;
      notifyListeners();
    }
  }

  void playMusic(BuildContext context, Music music, int index) async{
    try{
      // final currentMusic = notifier.currentMusic;
      _listMusics[index].isLoad = true;

      notifyListeners();
      var url = music.apsaraMusicUrl?.playUrl ?? '';
      if(_currentMusic != null){

        final currentIndex = _listMusics.indexOf(_currentMusic!);
        if(music.isPlay){
          await audioPlayer.stop();
          _listMusics[index].isPlay = false;

          currentMusic?.isPlay = false;
          notifyListeners();
        }else{
          await audioPlayer.stop();
          if(url != null){
            await audioPlayer.play(UrlSource(url));
          }else{
            throw 'url music is null';
          }

          _currentMusic = music;
          currentMusic?.isPlay = true;

          _listMusics[currentIndex].isPlay = false;
          _listMusics[index].isPlay = true;

          notifyListeners();
        }
      }else{
        await audioPlayer.stop();
        if(url != null){
          await audioPlayer.play(UrlSource(url));
        }else{
          throw 'url music is null';
        }
        _currentMusic = music;
        currentMusic?.isPlay = true;
        _listMusics[index].isPlay = true;
        notifyListeners();
      }

    }catch(e){

      'Error Play Music : $e'.logger();

      _listMusics[index].isPlay = false;
      notifyListeners();
    }finally{
      _listMusics[index].isLoad = false;
      notifyListeners();
    }

  }

  void selectExpMusic(Music music, int index){

    if(_selectedMusic != null){
      if(_selectedMusic!.id == music.id){
        _selectedMusic = null;
        notifyListeners();
        _listExpMusics[index].isSelected = false;

      }else{
        _listExpMusics[_listExpMusics.indexOf(_selectedMusic!)].isSelected = false;
        _listExpMusics[index].isSelected = true;
        _selectedMusic = music;
      }
    }else{
      _listExpMusics[index].isSelected = true;
      _selectedMusic = music;
    }
    notifyListeners();
  }

  void selectMusic(Music music, int index){

    if(_selectedMusic != null){
      if(_selectedMusic!.id == music.id){
        _selectedMusic = null;
        notifyListeners();
        _listMusics[index].isSelected = false;
      }else{
        _listMusics[_listMusics.indexOf(_selectedMusic!)].isSelected = false;
        _listMusics[index].isSelected = true;
        _selectedMusic = music;
      }
    }else{
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

  void initVideoPlayer(BuildContext context,{isSaveDefault = false}) async {
    BetterPlayerConfiguration betterPlayerConfiguration = const BetterPlayerConfiguration(
      autoPlay: false,
      fit: BoxFit.contain,
      showPlaceholderUntilPlay: true,
      controlsConfiguration: BetterPlayerControlsConfiguration(
        showControls: false,
        enableFullscreen: false,
        controlBarColor: Colors.black26,
      ),
    );
    print('_url : $_url');
    if(isSaveDefault){
      final _isImage = (_defaultPath ?? '').isImageFormat();
      if(!_isImage){
        _defaultPath = _url;
      }
    }
    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.file,
      _url != null
          ? Platform.isIOS
              ? _url!.replaceAll(" ", "%20")
              : _url!
          : '',
      bufferingConfiguration: const BetterPlayerBufferingConfiguration(
        minBufferMs: BetterPlayerBufferingConfiguration.defaultMinBufferMs,
        maxBufferMs: BetterPlayerBufferingConfiguration.defaultMaxBufferMs,
        bufferForPlaybackMs: BetterPlayerBufferingConfiguration.defaultBufferForPlaybackMs,
        bufferForPlaybackAfterRebufferMs: BetterPlayerBufferingConfiguration.defaultBufferForPlaybackAfterRebufferMs,
      ),
    );

    _betterPlayerController = BetterPlayerController(betterPlayerConfiguration);
    try {
      _isLoadVideo = true;
      await _betterPlayerController?.setupDataSource(dataSource).then((_) {
        _betterPlayerController?.play();
        _betterPlayerController?.setLooping(true);
        _betterPlayerController?.setOverriddenAspectRatio(_betterPlayerController?.videoPlayerController?.value.aspectRatio ?? 0.0);
        notifyListeners();
      });

      _betterPlayerController?.addEventsListener(
        (_) {
          _totalDuration = _.parameters?['duration'];

          if (_totalDuration != null) {
            if (_betterPlayerController?.isVideoInitialized() ?? false) if ((_betterPlayerController?.videoPlayerController?.value.position ?? Duration.zero) >=
                (_betterPlayerController?.videoPlayerController?.value.duration ?? Duration.zero)) {
              _nextVideo = true;
            }
          }
        },
      );

      // notifier.setVideoPlayerController(_betterPlayerController);

    }catch(e){
      "Error Init Video $e".logger();
    } finally {
      _isLoadVideo = false;
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

  void setVideoPlayerController(BetterPlayerController? val) => _betterPlayerController = val;

  void clearAdditionalItem() {
    _additionalItem.clear();
    _positions.clear();
  }

  Future<bool> onWillPop(BuildContext context) async {
    _addTextItemMode = false;
    _fixSelectedMusic = null;
    _selectedMusic = null;
    _currentMusic = null;
    _selectedType = null;
    _showNext = false;
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
    notifier.thumbNail = _thumbNails != null ? _thumbNails![0] : null;
    notifier.privacyTitle == '' ? notifier.privacyTitle = notifier.language.public ?? 'public' : notifier.privacyTitle = notifier.privacyTitle;
    notifier.locationName == '' ? notifier.locationName = notifier.language.addLocation ?? 'add location' : notifier.locationName = notifier.locationName;
    notifier.musicSelected = _fixSelectedMusic;
    // notifier.compressVideo();

    Routing().move(Routes.preUploadContent, argument: UpdateContentsArgument(onEdit: false)).whenComplete(() => isForcePaused = false);
  }

  Future makeThumbnail(BuildContext context, int index) async {
    if (System().lookupContentMimeType(fileContent?[index] ?? '')?.startsWith('image') ?? false) {
      showNext = true;
    } else {
      _thumbNails = [];
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
      if (_thumbNails?.isNotEmpty ?? false) {
        showNext = true;
      } else {
        if (betterPlayerController != null) isForcePaused = true;
        ShowBottomSheet.onShowSomethingWhenWrong(context, onClose: () => onWillPop(context));
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
}
