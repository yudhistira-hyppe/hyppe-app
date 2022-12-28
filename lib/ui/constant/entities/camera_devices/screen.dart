import 'package:hyppe/ui/constant/entities/camera_devices/widgets/camera_view.dart';
import 'package:hyppe/ui/constant/entities/camera_devices/notifier.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:hyppe/ui/constant/widget/custom_error_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class CameraDevicesPage extends StatefulWidget {
  final Function(CameraDevicesNotifier cameraNotifier) onCameraNotifierUpdate;
  final Function? onChangeAppLifecycleState;
  final List<Widget> additionalViews;
  final bool backCamera;

  const CameraDevicesPage({
    Key? key,
    required this.additionalViews,
    this.onChangeAppLifecycleState,
    required this.onCameraNotifierUpdate,
    this.backCamera = false,
  }) : super(key: key);

  @override
  _CameraDevicesPageState createState() => _CameraDevicesPageState();
}

class _CameraDevicesPageState extends State<CameraDevicesPage> with WidgetsBindingObserver, AfterFirstLayoutMixin {
  late CameraDevicesNotifier notifier;

  @override
  void initState() {
    super.initState();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    notifier = Provider.of<CameraDevicesNotifier>(context, listen: false);
    notifier.initCamera(context, mounted, backCamera: widget.backCamera);
  }

  @override
  void dispose() {
    notifier.disposeCamera();
    widget.onCameraNotifierUpdate(CameraDevicesNotifier());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final notifier = Provider.of<CameraDevicesNotifier>(context, listen: false);
    if (notifier.cameraController == null || !notifier.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      if (widget.onChangeAppLifecycleState != null) widget.onChangeAppLifecycleState!();
      notifier.disposeCamera();
    } else if (state == AppLifecycleState.resumed) {
      notifier.onNewCameraSelected();
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void didChangeDependencies() {
    var cameraNotifier = Provider.of<CameraDevicesNotifier>(context);
    widget.onCameraNotifierUpdate(cameraNotifier);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.select((CameraDevicesNotifier value) => Tuple3(value.isInitialized, value.hasError, value.loadingForObject(CameraDevicesNotifier.loadingForSwitching)));
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
                  function: () => context.read<CameraDevicesNotifier>().initCamera(context, mounted),
                ),
              ),
            )
          : notifier.item1 && !notifier.item3
              ? Stack(
                  children: [
                    const CameraDevicesView(),
                    ...widget.additionalViews,
                  ],
                )
              : const Center(child: CustomLoading()),
    );
  }
}
