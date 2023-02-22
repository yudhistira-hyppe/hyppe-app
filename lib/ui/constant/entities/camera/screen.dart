import 'package:hyppe/ui/constant/entities/camera/notifier.dart';
import 'package:hyppe/ui/constant/entities/camera/widgets/camera_view.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:hyppe/ui/constant/widget/custom_error_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class CameraPage extends StatefulWidget {
  final Function(CameraNotifier cameraNotifier) onCameraNotifierUpdate;
  final Function? onChangeAppLifecycleState;
  final List<Widget> additionalViews;
  final bool backCamera;

  const CameraPage({
    Key? key,
    required this.additionalViews,
    this.onChangeAppLifecycleState,
    required this.onCameraNotifierUpdate,
    this.backCamera = false,
  }) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver, AfterFirstLayoutMixin {
  late CameraNotifier notifier;

  @override
  void initState() {

    super.initState();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    notifier = Provider.of<CameraNotifier>(context, listen: false);
    notifier.initCamera(context, mounted, backCamera: widget.backCamera);
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
      notifier.onNewCameraSelected();
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
    return AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, animation) => SlideTransition(
              child: child,
              position: Tween<Offset>(begin: const Offset(0.0, 1.0), end: const Offset(0.0, 0.0)).animate(animation),
            ),
        child: notifier.item2
            ? Center(
                child: SizedBox(
                  height: 198,
                  child: CustomErrorWidget(
                    errorType: null,
                    function: () => context.read<CameraNotifier>().initCamera(context, mounted),
                  ),
                ),
              )
            // : notifier.item1 && !notifier.item3
            // ?
            : Stack(
                children: [
                  const CameraView(),
                  ...widget.additionalViews,
                ],
              )
        // : const Center(child: CustomLoading()),
        );
  }
}
