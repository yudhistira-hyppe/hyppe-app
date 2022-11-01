import 'dart:io';
import 'dart:typed_data';
import 'package:better_player/better_player.dart';
import 'package:hyppe/core/arguments/update_contents_argument.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/file_extension.dart';
import 'package:hyppe/core/constants/filter_matrix.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/services/overlay_service/overlay_handler.dart';
import 'package:hyppe/core/services/overlay_service/overlay_service.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/entities/camera/notifier.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_coloured_sheet.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/custom_snackbar.dart';
import 'package:hyppe/ui/constant/widget/custom_text_field_for_overlay.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

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
  String? _url;
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

  BetterPlayerController? _betterPlayerController;
  PersistentBottomSheetController? _persistentBottomSheetController;
  final TransformationController _transformationController = TransformationController();

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
  SourceFile? get sourceFile => _sourceFile;
  int get indexView => _indexView;
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

  void setFilterMatrix(List<double> val) {
    _filterMatrix[indexView] = val;
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
    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.file,
      Platform.isIOS ? _url!.replaceAll(" ", "%20") : _url!,
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
        _betterPlayerController?.setOverriddenAspectRatio(_betterPlayerController!.videoPlayerController!.value.aspectRatio);
        notifyListeners();
      });

      _betterPlayerController?.addEventsListener(
            (_) {
          _totalDuration = _.parameters?['duration'];
          if(_totalDuration != null){
            if (_betterPlayerController?.isVideoInitialized() ?? false) if (_betterPlayerController!.videoPlayerController!.value.position >=
                _betterPlayerController!.videoPlayerController!.value.duration!) {
              _nextVideo = true;
            }
          }

        },
      );

      // notifier.setVideoPlayerController(_betterPlayerController);
    } catch (e) {
      print('Setup data source error: $e');
    }
    finally{
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
      if(ms != null){
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
    notifier.privacyTitle == '' ? notifier.privacyTitle = notifier.language.public! : notifier.privacyTitle = notifier.privacyTitle;
    notifier.locationName == '' ? notifier.locationName = notifier.language.addLocation! : notifier.locationName = notifier.locationName;

    // notifier.compressVideo();

    Routing().move(Routes.preUploadContent, argument: UpdateContentsArgument(onEdit: false)).whenComplete(() => isForcePaused = false);
  }

  Future makeThumbnail(BuildContext context, int index) async {
    if (System().lookupContentMimeType(fileContent![index]!)?.startsWith('image') ?? false) {
      showNext = true;
    } else {
      _thumbNails = [];
      for (int i = 0; i <= index; i++) {
        Uint8List? _thumbnail = await VideoThumbnail.thumbnailData(
          video: fileContent![index]!,
          imageFormat: ImageFormat.JPEG,
          maxWidth: 128, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
          quality: 25,
        );
        _thumbNails!.add(_thumbnail);
      }
      if (_thumbNails!.isNotEmpty) {
        showNext = true;
      } else {
        if (betterPlayerController != null) isForcePaused = true;
        ShowBottomSheet.onShowSomethingWhenWrong(context, onClose: () => onWillPop(context));
      }
    }
  }

  void toDiaryVideoPlayer(int index, SourceFile sourceFile) {
    _url = fileContent![index];
    _sourceFile = sourceFile;
  }

  void showFilters(BuildContext context, GlobalKey<ScaffoldState> scaffoldState, GlobalKey? globalKey) {
    if (System().extensionFiles(_fileContent![indexView]!) == '.$PNG' ||
        System().extensionFiles(_fileContent![indexView]!) == '.$JPG' ||
        System().extensionFiles(_fileContent![indexView]!) == '.$JPEG') {
      isSheetOpen = true;
      persistentBottomSheetController = ShowBottomSheet().onShowFilters(context, scaffoldState, fileContent![indexView]!, globalKey);

      // listen to Scaffold status
      persistentBottomSheetController?.closed.whenComplete(() => isSheetOpen = false);
    } else {
      ShowBottomSheet().onShowColouredSheet(context, language.filterIsOnlySupportedForImage!, color: kHyppeTextWarning, maxLines: 2);
    }
  }

  void applyFilters({GlobalKey? globalKey}) async {
    if (globalKey != null) {
      // edited file holder
      String? _file;

      try {
        // generated widget to image
        _file = await System().convertWidgetToImage(globalKey);

        _fileContent![indexView] = _file;
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
    if (System().extensionFiles(_fileContent![indexView]!) == '.$PNG' ||
        System().extensionFiles(_fileContent![indexView]!) == '.$JPG' ||
        System().extensionFiles(_fileContent![indexView]!) == '.$JPEG') {
      OverlayService().addOverlayElement(context, const CustomTextFieldForOverlay());
    } else {
      ShowBottomSheet().onShowColouredSheet(context, language.filterIsOnlySupportedForImage!, color: kHyppeTextWarning, maxLines: 2);
    }
  }

  void applyTextItem(GlobalKey? globalKey) async {
    if (globalKey != null) {
      _addTextItemMode = false;
      // edited file holder
      String? _file;
      // check if filter changing or not
      _file = await System().convertWidgetToImage(globalKey);

      _fileContent![indexView] = _file;
      clearAdditionalItem();
      notifyListeners();
    }
  }
}
