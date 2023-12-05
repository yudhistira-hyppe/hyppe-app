import 'package:flutter/material.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/streamer/notifier.dart';
import 'package:provider/provider.dart';

class StreamerScreen extends StatefulWidget {
  const StreamerScreen({super.key});

  @override
  State<StreamerScreen> createState() => _StreamerScreenState();
}

class _StreamerScreenState extends State<StreamerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var streampro = Provider.of<Streamer>(context, listen: false);
      streampro.init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
