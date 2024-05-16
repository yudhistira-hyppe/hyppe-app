import 'package:flutter/material.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';

class RefreshLoadmore extends StatefulWidget {
  final Future<void> Function()? onRefresh;

  final Future<void> Function()? onLoadmore;

  final bool isLastPage;

  final Widget child;

  final Color? color;

  final Widget? noMoreWidget;

  final ScrollController? scrollController;

  const RefreshLoadmore({
    Key? key,
    required this.child,
    required this.isLastPage,
    this.onRefresh,
    this.color,
    this.onLoadmore,
    this.noMoreWidget,
    this.scrollController,
  }) : super(key: key);
  @override
  State<RefreshLoadmore> createState() => _RefreshLoadmoreState();
}

class _RefreshLoadmoreState extends State<RefreshLoadmore> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  ScrollController? _scrollController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController!.addListener(() async {
      if (_scrollController!.position.pixels >=
          _scrollController!.position.maxScrollExtent) {
        if (_isLoading) {
          return;
        }

        if (mounted) {
          setState(() {
            _isLoading = true;
          });
        }

        if (!widget.isLastPage && widget.onLoadmore != null) {
          await widget.onLoadmore!();
        }

        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    if (widget.scrollController == null) _scrollController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget mainWiget = ListView(
      // physics: const BouncingScrollPhysics(),÷
      controller: _scrollController,
      children: [
        widget.child,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: _isLoading
                  ? const LoadingWidget()
                  : widget.isLastPage
                      ? widget.noMoreWidget ??
                          Text(
                            'No more data',
                            style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context).disabledColor,
                            ),
                          )
                      : Container(),
            ),
          ],
        )
      ],
    );

    if (widget.onRefresh == null) {
      return Scrollbar(
        controller: _scrollController,
        child: mainWiget);
    }

    return RefreshIndicator(
      color: widget.color ?? Colors.blue,
      strokeWidth: 2.0,
      key: _refreshIndicatorKey,
      onRefresh: () async {
        if (_isLoading) return;
        await widget.onRefresh!();
      },
      child: mainWiget,
    );
  }
}


class LoadingWidget extends StatelessWidget {
  final bool fallingDot;
  final Color leftDotColor;
  final Color rightDotColor;
  const LoadingWidget({Key? key, this.fallingDot = false, this.leftDotColor = Colors.black12, this.rightDotColor = Colors.black54}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CustomLoading()
    );
  }
}