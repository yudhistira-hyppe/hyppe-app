import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/services/route_observer_service.dart';
import 'package:hyppe/ui/constant/entities/camera/notifier.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:hyppe/ui/inner/upload/make_content/content/upload_content.dart';
import 'package:hyppe/ui/inner/upload/make_content/content/upload_id_verification.dart';
import 'package:hyppe/ui/inner/upload/make_content/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class MakeContentScreen extends StatefulWidget {
  const MakeContentScreen({super.key});

  @override
  _MakeContentScreenState createState() => _MakeContentScreenState();
}

class _MakeContentScreenState extends State<MakeContentScreen> with AfterFirstLayoutMixin, RouteAware {
  @override
  void afterFirstLayout(BuildContext context) {
    context.read<MakeContentNotifier>().onInitialUploadContent();
  }

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    super.initState();
  }

  @override
  void dispose() {
    CustomRouteObserver.routeObserver.unsubscribe(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    CustomRouteObserver.routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
    super.didChangeDependencies();
  }

  @override
  void didPopNext() {
    final notifier = Provider.of<MakeContentNotifier>(context, listen: false);
    if (notifier.isVideo || notifier.featureType != FeatureType.pic) {
      notifier.resetVariable(dispose: false);
    }
    super.didPopNext();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Consumer<MakeContentNotifier>(
      builder: (_, notifier, __) => WillPopScope(
        onWillPop: () async {
          if (notifier.conditionalOnClose()) {
            // context.read<CameraNotifier>().showEffect(isClose: true);
            bool? _sheetResponse;
            if (notifier.isRecordingVideo) {
              _sheetResponse = await ShowBottomSheet().onShowColouredSheet(
                context,
                notifier.language.cancelRecording ?? 'Cancel Recording',
                color: kHyppeTextWarning,
              );
            }
            if (_sheetResponse == null || _sheetResponse) {
              notifier.resetVariable(dispose: true);
              Routing().moveBack();
              return true;
            }
            return false;
          } else {
            return false;
          }
        },
        child: Scaffold(
          body: notifier.featureType != null ? UploadContent(notifier: notifier, mounted: mounted) : UploadIDVerification(notifier: notifier, mounted: mounted),
        ),
      ),
    );
  }
}
