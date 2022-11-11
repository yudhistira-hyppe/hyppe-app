import 'dart:io';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:better_player/better_player.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:hyppe/core/arguments/update_contents_argument.dart';
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
import '../../../constant/overlay/bottom_sheet/bottom_sheet_content/musics/on_choose_music.dart';

class PreviewContentNotifier with ChangeNotifier {
  LocalizationModelV2 language = LocalizationModelV2();
  translate(LocalizationModelV2 translate) {
    language = translate;
    notifyListeners();
  }

  final dataMusics1 = [
    Music(musicTitle: 'audio1', artistName: 'artis audio1', duration: 20, url: 'https://file-examples.com/storage/feb1825f1e635ae95f6f16d/2017/11/file_example_MP3_700KB.mp3', urlThumbnail: 'https://m.media-amazon.com/images/I/51sBKjJOwOL._SY580_.jpg'),
    Music(musicTitle: 'audio2', artistName: 'artis audio2', duration: 20, url: 'https://file-examples.com/storage/feb1825f1e635ae95f6f16d/2017/11/file_example_MP3_700KB.mp3', urlThumbnail: 'https://m.media-amazon.com/images/I/51sBKjJOwOL._SY580_.jpg'),
    Music(musicTitle: 'audio3', artistName: 'artis audio3', duration: 20, url: 'https://file-examples.com/storage/feb1825f1e635ae95f6f16d/2017/11/file_example_MP3_700KB.mp3', urlThumbnail: 'https://m.media-amazon.com/images/I/51sBKjJOwOL._SY580_.jpg'),
    Music(musicTitle: 'audio4', artistName: 'artis audio4', duration: 20, url: 'https://file-examples.com/storage/feb1825f1e635ae95f6f16d/2017/11/file_example_MP3_700KB.mp3', urlThumbnail: 'https://m.media-amazon.com/images/I/51sBKjJOwOL._SY580_.jpg'),
    Music(musicTitle: 'audio5', artistName: 'artis audio5', duration: 20, url: 'https://filesamples.com/samples/audio/aac/sample4.aac', urlThumbnail: 'https://i.scdn.co/image/ab67616d0000b2735320a1b471ae75632ef787e5'),
    Music(musicTitle: 'audio6', artistName: 'artis audio6', duration: 20, url: 'https://filesamples.com/samples/audio/aac/sample4.aac', urlThumbnail: 'https://i.scdn.co/image/ab67616d0000b2735320a1b471ae75632ef787e5'),
    Music(musicTitle: 'audio7', artistName: 'artis audio7', duration: 20, url: 'https://filesamples.com/samples/audio/aac/sample4.aac', urlThumbnail: 'https://i.scdn.co/image/ab67616d0000b2735320a1b471ae75632ef787e5'),
    Music(musicTitle: 'audio8', artistName: 'artis audio8', duration: 20, url: 'https://filesamples.com/samples/audio/aac/sample4.aac', urlThumbnail: 'https://i.scdn.co/image/ab67616d0000b2735320a1b471ae75632ef787e5'),
    Music(musicTitle: 'audio9', artistName: 'artis audio9', duration: 20, url: 'https://filesamples.com/samples/audio/aac/sample1.aac', urlThumbnail: 'https://i.pinimg.com/originals/c9/f5/08/c9f5083d6cc3579a036646311f07280b.jpg'),
    Music(musicTitle: 'audio10', artistName: 'artis audio10', duration: 20, url: 'https://filesamples.com/samples/audio/aac/sample1.aac', urlThumbnail: 'https://i.pinimg.com/originals/c9/f5/08/c9f5083d6cc3579a036646311f07280b.jpg'),
    Music(musicTitle: 'audio11', artistName: 'artis audio11', duration: 20, url: 'https://filesamples.com/samples/audio/aac/sample1.aac', urlThumbnail: 'https://i.pinimg.com/originals/c9/f5/08/c9f5083d6cc3579a036646311f07280b.jpg'),
    Music(musicTitle: 'audio12', artistName: 'artis audio12', duration: 20, url: 'https://filesamples.com/samples/audio/aac/sample1.aac', urlThumbnail: 'https://i.pinimg.com/originals/c9/f5/08/c9f5083d6cc3579a036646311f07280b.jpg'),
  ];

  final dataMusics2 = [
    Music(musicTitle: 'audio5', artistName: 'artis audio5', duration: 20, url: 'https://filesamples.com/samples/audio/aac/sample4.aac', urlThumbnail: 'https://i.scdn.co/image/ab67616d0000b2735320a1b471ae75632ef787e5'),
    Music(musicTitle: 'audio6', artistName: 'artis audio6', duration: 20, url: 'https://filesamples.com/samples/audio/aac/sample4.aac', urlThumbnail: 'https://i.scdn.co/image/ab67616d0000b2735320a1b471ae75632ef787e5'),
    Music(musicTitle: 'audio7', artistName: 'artis audio7', duration: 20, url: 'https://filesamples.com/samples/audio/aac/sample4.aac', urlThumbnail: 'https://i.scdn.co/image/ab67616d0000b2735320a1b471ae75632ef787e5'),
    Music(musicTitle: 'audio8', artistName: 'artis audio8', duration: 20, url: 'https://filesamples.com/samples/audio/aac/sample4.aac', urlThumbnail: 'https://i.scdn.co/image/ab67616d0000b2735320a1b471ae75632ef787e5'),
    Music(musicTitle: 'audio9', artistName: 'artis audio9', duration: 20, url: 'https://filesamples.com/samples/audio/aac/sample1.aac', urlThumbnail: 'https://i.pinimg.com/originals/c9/f5/08/c9f5083d6cc3579a036646311f07280b.jpg'),
    Music(musicTitle: 'audio10', artistName: 'artis audio10', duration: 20, url: 'https://filesamples.com/samples/audio/aac/sample1.aac', urlThumbnail: 'https://i.pinimg.com/originals/c9/f5/08/c9f5083d6cc3579a036646311f07280b.jpg'),
    Music(musicTitle: 'audio11', artistName: 'artis audio11', duration: 20, url: 'https://filesamples.com/samples/audio/aac/sample1.aac', urlThumbnail: 'https://i.pinimg.com/originals/c9/f5/08/c9f5083d6cc3579a036646311f07280b.jpg'),
    Music(musicTitle: 'audio12', artistName: 'artis audio12', duration: 20, url: 'https://filesamples.com/samples/audio/aac/sample1.aac', urlThumbnail: 'https://i.pinimg.com/originals/c9/f5/08/c9f5083d6cc3579a036646311f07280b.jpg'),
    Music(musicTitle: 'audio1', artistName: 'artis audio1', duration: 20, url: 'https://file-examples.com/storage/feb1825f1e635ae95f6f16d/2017/11/file_example_MP3_700KB.mp3', urlThumbnail: 'https://m.media-amazon.com/images/I/51sBKjJOwOL._SY580_.jpg'),
    Music(musicTitle: 'audio2', artistName: 'artis audio2', duration: 20, url: 'https://file-examples.com/storage/feb1825f1e635ae95f6f16d/2017/11/file_example_MP3_700KB.mp3', urlThumbnail: 'https://m.media-amazon.com/images/I/51sBKjJOwOL._SY580_.jpg'),
    Music(musicTitle: 'audio3', artistName: 'artis audio3', duration: 20, url: 'https://file-examples.com/storage/feb1825f1e635ae95f6f16d/2017/11/file_example_MP3_700KB.mp3', urlThumbnail: 'https://m.media-amazon.com/images/I/51sBKjJOwOL._SY580_.jpg'),
    Music(musicTitle: 'audio4', artistName: 'artis audio4', duration: 20, url: 'https://file-examples.com/storage/feb1825f1e635ae95f6f16d/2017/11/file_example_MP3_700KB.mp3', urlThumbnail: 'https://m.media-amazon.com/images/I/51sBKjJOwOL._SY580_.jpg'),
  ];

  double? _aspectRatio;
  FeatureType? _featureType;
  List<String?>? _fileContent;
  List<Uint8List?>? _thumbNails;
  int _indexView = 0;
  int _pageMusic = 0;
  String? _url;
  Music? _currentMusic;
  Music? _selectedMusic;
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
  List<Music> _listMusics = [];
  List<Music> get listMusics => _listMusics;

  BetterPlayerController? _betterPlayerController;
  PersistentBottomSheetController? _persistentBottomSheetController;
  final TransformationController _transformationController = TransformationController();
  final audioPlayer = AudioPlayer();

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
  Music? get currentMusic => _currentMusic;
  Music? get selectedMusic => _selectedMusic;
  SourceFile? get sourceFile => _sourceFile;
  int get indexView => _indexView;
  int get pageMusic => _pageMusic;
  double? get aspectRation => _aspectRatio;
  FeatureType? get featureType => _featureType;
  List<String?>? get fileContent => _fileContent;
  List<double> filterMatrix(int index) => _filterMatrix[index];

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

  set listMusics(List<Music> values){
    _listMusics = values;
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

  void initListMusics(){
    switch(_pageMusic){
      case 0:{
        _currentMusic = null;
        _listMusics = dataMusics1;
        audioPlayer.stop();
        break;
      }
      case 1:{
        _currentMusic = null;
        _listMusics = dataMusics2;
        audioPlayer.stop();
        break;
      }
    }
  }

  void setFilterMatrix(List<double> val) {
    _filterMatrix[indexView] = val;
    notifyListeners();
  }

  Future<void> videoMerger(String urlAudio) async{
    try{
      if(urlAudio.isNotEmpty){
        _isLoadVideo = true;
        String outputPath = await System().getSystemPath(params: 'postVideo');
        outputPath = '${outputPath + materialAppKey.currentContext!.getNameByDate()}.mp4';

        String command = '-stream_loop -1 -i $urlAudio -i ${_fileContent?[_indexView]} -shortest -c copy $outputPath';
        await FFmpegKit.executeAsync(command, (session) async{
          final codeSession = await session.getReturnCode();
          if(ReturnCode.isSuccess(codeSession)){
            print('ReturnCode = Success');
            final path = _fileContent?[_indexView] ?? '';

            _fileContent?[_indexView] = outputPath;
            _url = fileContent?[_indexView];
            _sourceFile = SourceFile.local;
            // _betterPlayerController = null;
            if(path.isNotEmpty){
              await File(path).delete();
            }
            // _betterPlayerController?.seekTo(const Duration(seconds: 0));
          }else if(ReturnCode.isCancel(codeSession)){
            print('ReturnCode = Cancel');
            // Cancel
          }else{
            print('ReturnCode = Error');
            // Error
          }

        }, (log){
          print('FFmpegKit ${log.getMessage()}');
        },);
      }else{
        throw 'urlAudio is empty';
      }

    }catch(e){
      'videoMerger Error : $e'.logger();
    }finally{
      _isLoadVideo = false;
    }

  }

  void disposeMusic() async{
    await audioPlayer.stop();
    await audioPlayer.dispose();
  }

  void playMusic(Music music, int index) async{
    try{
      // final currentMusic = notifier.currentMusic;
      _listMusics[index].isLoad = true;
      notifyListeners();
      final url = music.url;
      if(url != null){
        if(_currentMusic != null){
          final currentIndex = _listMusics.indexOf(_currentMusic!);
          if(music.isPlay){
            await audioPlayer.stop();
            _listMusics[index].isPlay = false;
            currentMusic?.isPlay = false;
            notifyListeners();
          }else{
            await audioPlayer.stop();
            await audioPlayer.play(UrlSource(url));
            _listMusics[currentIndex].isPlay = false;
            _currentMusic = music;
            currentMusic?.isPlay = true;
            _listMusics[index].isPlay = true;
            notifyListeners();
          }
        }else{
          await audioPlayer.stop();
          await audioPlayer.play(UrlSource(url));
          _currentMusic = music;
          currentMusic?.isPlay = true;
          _listMusics[index].isPlay = true;
          notifyListeners();
        }
      }else{
        throw 'url music is null';
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

  void selectMusic(Music music, int index){

    if(_selectedMusic != null){
      if(_selectedMusic!.musicTitle == music.musicTitle){
        _selectedMusic = null;
        _listMusics[index].isSelected = false;
      }else{
        _listMusics[_listMusics.indexOf(_selectedMusic!)].isSelected = false;
        _selectedMusic = music;
        _listMusics[index].isSelected = true;
      }
    }else{
      _selectedMusic = music;
      _listMusics[index].isSelected = true;
    }
    notifyListeners();
  }

  // void _resetSelectMusic(){
  //   for(var music in _listMusics){
  //     if(sele)
  //   }
  // }

  void initialMatrixColor() {
    if (_fileContent != null) {
      _filterMatrix.clear();
      _fileContent?.forEach((_) {
        _filterMatrix.add(NORMAL);
      });
    }
  }

  void initVideoPlayer(BuildContext context) async {
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
