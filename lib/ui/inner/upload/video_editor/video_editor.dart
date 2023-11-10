import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/upload/video_editor/widget/export_result.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';
import 'package:video_editor/video_editor.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../../core/constants/asset_path.dart';
import '../../../../core/models/collection/localization_v2/localization_model.dart';
import '../../../constant/widget/custom_icon_widget.dart';
import 'export_service.dart';

class VideoEditor extends StatefulWidget {
  final File file;
  final Duration videoSeconds;
  const VideoEditor(
      {super.key, required this.file, required this.videoSeconds});

  @override
  State<VideoEditor> createState() => _VideoEditorState();
}

class _VideoEditorState extends State<VideoEditor> {
  final _exportingProgress = ValueNotifier<double>(0.0);
  final _isExporting = ValueNotifier<bool>(false);
  final double height = 60;

  late final VideoEditorController _controller = VideoEditorController.file(
      widget.file,
      minDuration: const Duration(seconds: 1),
      maxDuration: widget.videoSeconds,
      trimStyle: TrimSliderStyle(
          onTrimmedColor: Colors.white,
          onTrimmingColor: Colors.white,
          leftIcon: null,
          rightIcon: null));
  late Duration currentTime;
  late final LocalizationModelV2 language;
  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    _controller
        .initialize(aspectRatio: 9 / 16)
        .then((_) => setState(() {}))
        .catchError((error) {
      // handle minumum duration bigger than video duration error
      Navigator.pop(context);
    }, test: (e) => e is VideoMinDurationError).whenComplete(() {
      Future.delayed(const Duration(seconds: 1), () {
        _controller.video.play();
      });
    });
    _controller.video.addListener(() async {
      if (mounted) {
        currentTime = await _controller.video.position ?? const Duration();
        setState(() {});
      }
    });

    language = (Routing.navigatorKey.currentContext ?? context)
        .read<TranslateNotifierV2>()
        .translate;
  }

  @override
  void dispose() async {
    _exportingProgress.dispose();
    _isExporting.dispose();
    _controller.dispose();
    ExportService.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  void _showErrorSnackBar(String message) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 1),
        ),
      );

  void _exportVideo() async {
    _exportingProgress.value = 0;
    _isExporting.value = true;

    final config = VideoFFmpegVideoEditorConfig(
      _controller,
      // format: VideoExportFormat.gif,
      // commandBuilder: (config, videoPath, outputPath) {
      //   final List<String> filters = config.getExportFilters();
      //   filters.add('hflip'); // add horizontal flip

      //   return '-i $videoPath ${config.filtersCmd(filters)} -preset ultrafast $outputPath';
      // },
    );

    await ExportService.runFFmpegCommand(
      await config.getExecuteConfig(),
      onProgress: (stats) {
        _exportingProgress.value = config.getFFmpegProgress(stats.getTime());
      },
      onError: (e, s) => _showErrorSnackBar("Error on export video :("),
      onCompleted: (file) {
        print('Trimming Successful');
        _isExporting.value = false;
        if (!mounted) return;
        print('Trimming Successful');
        Navigator.pop(context, file.path);
        // showDialog(
        //   context: context,
        //   builder: (_) => VideoResultPopup(video: file),
        // );
      },
    );
  }

  void _exportCover() async {
    final config = CoverFFmpegVideoEditorConfig(_controller);
    final execute = await config.getExecuteConfig();
    if (execute == null) {
      _showErrorSnackBar("Error on cover exportation initialization.");
      return;
    }

    await ExportService.runFFmpegCommand(
      execute,
      onError: (e, s) => _showErrorSnackBar("Error on cover exportation :("),
      onCompleted: (cover) {
        if (!mounted) return;

        showDialog(
          context: context,
          builder: (_) => CoverResultPopup(cover: cover),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: const Color(0xff151617),
        body: _controller.initialized
            ? SafeArea(
                child: Stack(
                  children: [
                    Column(
                      children: [
                        _topNavBar(),
                        Expanded(
                          child: Column(
                            children: [
                              Expanded(
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CropGridViewer.preview(
                                        controller: _controller),
                                    AnimatedBuilder(
                                      animation: _controller.video,
                                      builder: (_, __) => AnimatedOpacity(
                                        opacity: _controller.isPlaying ? 0 : 1,
                                        duration: kThemeAnimationDuration,
                                        child: GestureDetector(
                                          onTap: _controller.video.play,
                                          child: Container(
                                            width: 40,
                                            height: 40,
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.play_arrow,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  tenPx,
                                  _controller.video.value.isPlaying
                                      ? IconButton(
                                          icon: CustomIconWidget(
                                            iconData: "${AssetPath.vectorPath}ic_pause.svg",
                                            defaultColor: false,
                                            color: context.getColorScheme().background,),
                                          splashRadius: 1,
                                          onPressed: () {
                                            _controller.video.pause();
                                          },
                                        )
                                      : IconButton(
                                          icon: CustomIconWidget(
                                            iconData: "${AssetPath.vectorPath}ic_play.svg",
                                            defaultColor: false,
                                            color: context.getColorScheme().background,),
                                          splashRadius: 1,
                                          onPressed: () {
                                            _controller.video.play();
                                          },
                                        ),
                                  Expanded(
                                      child: Container(
                                    alignment: Alignment.center,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        CustomTextWidget(
                                          textToDisplay: formatter(currentTime),
                                          textStyle: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12),
                                        ),
                                        CustomTextWidget(
                                          textToDisplay:
                                              ' / ${formatter(_controller.videoDuration)}',
                                          textStyle: const TextStyle(
                                              color: Color(0xffD9DDE3),
                                              fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  )),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: _trimSlider(),
                              ),
                              ValueListenableBuilder(
                                valueListenable: _isExporting,
                                builder: (_, bool export, Widget? child) =>
                                    AnimatedSize(
                                  duration: kThemeAnimationDuration,
                                  child: export ? child : null,
                                ),
                                child: AlertDialog(
                                  title: ValueListenableBuilder(
                                    valueListenable: _exportingProgress,
                                    builder: (_, double value, __) => Text(
                                      "Exporting video ${(value * 100).ceil()}%",
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    )
                  ],
                ),
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _topNavBar() {
    return SafeArea(
      child: SizedBox(
        height: height,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_ios),
              tooltip: 'Leave editor',
              color: Colors.white,
            ),
            ElevatedButton(
                onPressed: _exportVideo,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent),
                child: CustomTextWidget(
                  textToDisplay: language.save ?? 'Save',
                  textStyle: const TextStyle(color: Colors.white, fontSize: 14),
                ),),
          ],
        ),
      ),
    );
  }

  String formatter(Duration duration) => [
        duration.inMinutes.remainder(60).toString().padLeft(2, '0'),
        duration.inSeconds.remainder(60).toString().padLeft(2, '0')
      ].join(":");

  List<Widget> _trimSlider() {
    return [
      Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(vertical: height / 4),
        child: TrimSlider(
          controller: _controller,
          height: height,
          horizontalMargin: height / 4,
          // child: TrimTimeline(
          //   controller: _controller,
          //   padding: const EdgeInsets.only(top: 10),
          // ),
        ),
      ),
      twentyPx,
      Container(
        width: double.infinity,
        alignment: Alignment.center,
        child: CustomTextWidget(
          textToDisplay: language.tapOnTrackToTrim ?? '',
          textStyle: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
      eightPx,
    ];
  }

  Widget _coverSelection() {
    return SingleChildScrollView(
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(15),
          child: CoverSelection(
            controller: _controller,
            size: height + 10,
            quantity: 8,
            selectedCoverBuilder: (cover, size) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  cover,
                  Icon(
                    Icons.check_circle,
                    color: const CoverSelectionStyle().selectedBorderColor,
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
