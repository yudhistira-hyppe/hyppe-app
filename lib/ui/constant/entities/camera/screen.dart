import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/constant/entities/camera/notifier.dart';
import 'package:hyppe/ui/constant/entities/camera/widgets/camera_view.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:hyppe/ui/constant/widget/custom_error_widget.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class CameraPage extends StatefulWidget {
  final Function(CameraNotifier cameraNotifier) onCameraNotifierUpdate;
  final Function? onChangeAppLifecycleState;
  final Function()? onDoubleTap;
  final List<Widget> additionalViews;
  final bool backCamera;

  const CameraPage({
    Key? key,
    required this.additionalViews,
    this.onChangeAppLifecycleState,
    this.onDoubleTap,
    required this.onCameraNotifierUpdate,
    this.backCamera = false,
  }) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver, AfterFirstLayoutMixin {
  late CameraNotifier notifier;
  bool isloading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void afterFirstLayout(BuildContext context) async {
    isloading = true;
    notifier = Provider.of<CameraNotifier>(context, listen: false);
    await notifier.initCamera(context, mounted, backCamera: widget.backCamera).then((value){
      Future.delayed(const Duration(milliseconds: 100), (){
        setState(() {
          isloading = false;
        });
      });
    });
  }

  @override
  void dispose() {
    notifier.disposeCamera(context);
    widget.onCameraNotifierUpdate(CameraNotifier());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final notifier = Provider.of<CameraNotifier>(context, listen: false);
    if (notifier.cameraController == null || !notifier.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      if (widget.onChangeAppLifecycleState != null) widget.onChangeAppLifecycleState!();
      notifier.disposeCamera(context);
    } else if (state == AppLifecycleState.resumed) {
      notifier.onNewCameraSelected(Routing.navigatorKey.currentContext!);
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void didChangeDependencies() {
    var cameraNotifier = Provider.of<CameraNotifier>(context);
    widget.onCameraNotifierUpdate(cameraNotifier);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.select((CameraNotifier value) => Tuple3(value.isInitialized, value.hasError, value.loadingForObject(CameraNotifier.loadingForSwitching)));
    return isloading
        ? Container(
            color: Colors.black,
            height: SizeConfig.screenHeight,
            width: SizeConfig.screenWidth,
            child: const Center(
              child: CustomLoading(),
            ))
        : Stack(
      children: [
        GestureDetector(
            onDoubleTap: widget.onDoubleTap,
            child: const CameraView()),
        ...widget.additionalViews,
      ],
    );
  }
}
