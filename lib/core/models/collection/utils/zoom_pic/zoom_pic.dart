//==============================================================================================

import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/scroll/screen.dart';
import "package:vector_math/vector_math_64.dart" as vector;

class ZoomableImage extends StatelessWidget {
  final bool? closeOnZoomOut;
  final Offset? focalPoint;
  final double? initialScale;
  final bool? animateToInitScale;
  final Widget child;
  final VoidCallback? onScaleStart;
  final VoidCallback? onScaleStop;
  final bool enable;

  const ZoomableImage({
    super.key,
    required this.child,
    this.closeOnZoomOut = false,
    this.focalPoint,
    this.initialScale,
    this.animateToInitScale,
    this.onScaleStart,
    this.onScaleStop,
    this.enable = true,
  });

  // Widget loadImage() {}

  @override
  Widget build(BuildContext context) {
    return enable
        ? ZoomablePhotoViewer(
            // url: url!,
            closeOnZoomOut: closeOnZoomOut ?? false,
            focalPoint: focalPoint ?? Offset(0, 0),
            initialScale: initialScale ?? 0,
            animateToInitScale: animateToInitScale ?? false,
            onScaleStart: onScaleStart,
            onScaleStop: onScaleStop,
            child: child,
          )
        : Container(
            child: child,
          );
  }
}
//==============================================================================================

class ZoomablePhotoViewer extends StatefulWidget {
  const ZoomablePhotoViewer({
    Key? key,
    required this.child,
    this.closeOnZoomOut,
    this.focalPoint,
    this.initialScale,
    this.animateToInitScale,
    this.onScaleStart,
    this.onScaleStop,
  }) : super(key: key);

  final Widget child;

  final bool? closeOnZoomOut;
  final Offset? focalPoint;
  final double? initialScale;
  final bool? animateToInitScale;
  final VoidCallback? onScaleStart;
  final VoidCallback? onScaleStop;

  @override
  State<ZoomablePhotoViewer> createState() => _ZoomablePhotoViewerState();
}

class _ZoomablePhotoViewerState extends State<ZoomablePhotoViewer> with TickerProviderStateMixin {
  static const double _minScale = 0.99;
  static const double _maxScale = 4.0;
  AnimationController? _flingAnimationController;
  Animation<Offset>? _flingAnimation;
  AnimationController? _zoomAnimationController;
  Animation<double>? _zoomAnimation;
  Offset? _offset;
  double? _scale;
  Offset? _normalizedOffset;
  double? _previousScale;
  AllowMultipleHorizontalDragRecognizer? _allowMultipleHorizontalDragRecognizer;
  AllowMultipleVerticalDragRecognizer? _allowMultipleVerticalDragRecognizer;
  Offset? _tapDownGlobalPosition;
  String? _url;
  bool? _closeOnZoomOut;
  Offset? _focalPoint;
  bool? _animateToInitScale;
  double? _initialScale;

//===================================================

  Matrix4? _matrix = Matrix4.identity();
  Offset? _startFocalPoint;
  late Animation<Matrix4> _animationReset;
  late AnimationController _controllerReset;
  OverlayEntry? _overlayEntry;
  bool _isZooming = false;
  int _touchCount = 0;
  Matrix4 _transformMatrix = Matrix4.identity();

  final _transformWidget = GlobalKey<_TransformWidgetState>();

  double newPositionY = 0;
  double updatePositionY = 0;

  @override
  void initState() {
    super.initState();
    _closeOnZoomOut = widget.closeOnZoomOut ?? false;
    _offset = Offset.zero;
    _scale = 1.0;
    _previousScale = 0;
    _initialScale = widget.initialScale;
    _focalPoint = widget.focalPoint;
    _animateToInitScale = widget.animateToInitScale;
    if (_animateToInitScale!) {
      // WidgetsBinding.instance.addPostFrameCallback((_) => _zoom(_focalPoint!, _initialScale!, context));
    }
    _flingAnimationController = AnimationController(vsync: this)..addListener(_handleFlingAnimation);
    _zoomAnimationController = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);

    //===============================
    _startFocalPoint = Offset.zero;
    _controllerReset = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _controllerReset
      ..addListener(() {
        _transformWidget.currentState?.setMatrix(_animationReset.value);
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) hide();
      });
  }

  @override
  void dispose() {
    // _flingAnimationController!.dispose();
    // _zoomAnimationController!.dispose();

    //===
    _controllerReset.dispose();
    super.dispose();
  }

  // The maximum offset value is 0,0. If the size of this renderer's box is w,h
  // then the minimum offset value is w - _scale * w, h - _scale * h.
  Offset _clampOffset(Offset offset) {
    final Size size = context.size!;
    final Offset minOffset = Offset(size.width, size.height) * (1.0 - _scale!);
    return Offset(offset.dx.clamp(minOffset.dx, 0.0), offset.dy.clamp(minOffset.dy, 0.0));
  }

  void _handleFlingAnimation() {
    _transformWidget.currentState?.setMatrix(
      Matrix4.identity()
        ..translate(_flingAnimation!.value)
        ..scale(_scale),
    );
    setState(() {
      _offset = _flingAnimation!.value;
    });
  }

  Widget _build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          const ModalBarrier(
            color: Colors.black12,
          ),
          _TransformWidget(
            key: _transformWidget,
            matrix: _transformMatrix,
            child: widget.child,
          )
        ],
      ),
    );
  }

  Future<void> show() async {
    print("==========is zoom $_isZooming");
    if (!_isZooming) {
      final overlayState = Overlay.of(context);
      _overlayEntry = OverlayEntry(builder: _build);
      overlayState.insert(_overlayEntry!);
    }
  }

  Future<void> hide() async {
    setState(() {
      _isZooming = false;
    });

    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _handleOnScaleStart(ScaleStartDetails details) {
    print("==========new posisi");
    setState(() {
      _previousScale = 1;
      _normalizedOffset = (details.focalPoint - _offset!) / _scale!;
      // The fling animation stops if an input gesture starts.
      _flingAnimationController!.stop();
    });

    //=======
    //Dont start the effect if the image havent reset complete.
    // if (_controllerReset.isAnimating) return;
    // if (_touchCount < 2) return;

    // call start callback before everything else
    // widget.onScaleStart?.call();
    _startFocalPoint = (details.focalPoint - _offset!) / _scale!;

    _matrix = Matrix4.identity();

    // create an matrix of where the image is on the screen for the overlay
    final renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    newPositionY = position.dy;

    print("==========new posisi ${position.dy}");

    _transformMatrix = Matrix4.translation(
      vector.Vector3(position.dx, position.dy, 0),
    );
  }

  Future _handleOnScaleUpdate(ScaleUpdateDetails details) async {
    final renderBox = context.findRenderObject() as RenderBox;
    var position = renderBox.localToGlobal(Offset.zero);
    updatePositionY = position.dy;

    // if (newPositionY != position.dy) {
    //   hide();
    //   return;
    // }

    print("==========new posisi new banget $position");
    // if (_scale! < 1.0 && _closeOnZoomOut!) {
    //   print("kakakakakaka");
    //   _zoom(Offset.zero, 1.0, context);
    //   Navigator.pop(context);

    //   return;
    // }
    setState(() {
      _scale = (_previousScale! * details.scale).clamp(_minScale, _maxScale);
      // Ensure that image location under the focal point stays in the same place despite scaling.
      // _offset = _clampOffset(details.focalPoint - _normalizedOffset! * _scale!);
    });
    print("========scale $_scale");
    print("========scale $_previousScale");
    if (_scale! > _previousScale!) {
      show();
      widget.onScaleStart?.call();
      setState(() {
        _isZooming = true;
      });
      // return;
    } else {
      return;
    }

    //================================================

    if (!_isZooming || _controllerReset.isAnimating) return;

    final translationDelta = details.focalPoint - _startFocalPoint!;

    final translate = Matrix4.translation(
      vector.Vector3(translationDelta.dx, translationDelta.dy, 0),
    );

    final focalPoint = renderBox.globalToLocal(
      details.focalPoint - translationDelta,
    );

    var scaleby = details.scale;
    // if (widget.minScale != null && scaleby < widget.minScale!) {
    //   scaleby = widget.minScale ?? 0;
    // }

    // if (widget.maxScale != null && scaleby > widget.maxScale!) {
    //   scaleby = widget.maxScale ?? 0;
    // }

    final dx = (1 - scaleby) * focalPoint.dx;
    final dy = (1 - scaleby) * focalPoint.dy;

    final scale = Matrix4(scaleby, 0, 0, 0, 0, scaleby, 0, 0, 0, 0, 1, 0, dx, dy, 0, 1);

    _matrix = translate * scale;

    if (_transformWidget.currentState != null) {
      _transformWidget.currentState!.setMatrix(_matrix);
    }
  }

  void _handleOnScaleEnd(ScaleEndDetails details) {
//     const double _kMinFlingVelocity = 2000.0;
//     final double magnitude = details.velocity.pixelsPerSecond.distance;

// //    print('magnitude: ' + magnitude.toString());
//     // if (magnitude < _kMinFlingVelocity) return;

//     final Offset direction = details.velocity.pixelsPerSecond / magnitude;
//     final double distance = (Offset.zero & context.size!).shortestSide;
//     setState(() {
//       _scale = _previousScale;
//     });
//     _flingAnimation = Tween<Offset>(begin: _offset, end: _clampOffset(_offset! + direction * distance)).animate(_flingAnimationController!);
//     _flingAnimationController!
//       ..value = 0.0
//       ..fling(velocity: magnitude / 2000.0);
    widget.onScaleStop?.call();

    if (!_isZooming || _controllerReset.isAnimating) return;
    _animationReset = Matrix4Tween(
      begin: _matrix,
      end: Matrix4.identity(),
    ).animate(
      CurvedAnimation(
        parent: _controllerReset,
        curve: Curves.fastOutSlowIn,
      ),
    );
    _controllerReset
      ..reset()
      ..forward();

    // call end callback function when scale ends
  }

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      gestures: {
        AllowMultipleScaleRecognizer: GestureRecognizerFactoryWithHandlers<AllowMultipleScaleRecognizer>(
          () => AllowMultipleScaleRecognizer(), //constructor
          (AllowMultipleScaleRecognizer instance) {
            //initializer
            instance.onStart = (details) => _handleOnScaleStart(details);
            instance.onEnd = (details) => _handleOnScaleEnd(details);
            instance.onUpdate = (details) => _handleOnScaleUpdate(details);
          },
        ),
        AllowMultipleHorizontalDragRecognizer: GestureRecognizerFactoryWithHandlers<AllowMultipleHorizontalDragRecognizer>(
          () => AllowMultipleHorizontalDragRecognizer(),
          (AllowMultipleHorizontalDragRecognizer instance) {
            _allowMultipleHorizontalDragRecognizer = instance;
            instance.onStart = (details) => this._handleHorizontalDragAcceptPolicy(instance);
            instance.onUpdate = (details) => this._handleHorizontalDragAcceptPolicy(instance);
          },
        ),
        AllowMultipleVerticalDragRecognizer: GestureRecognizerFactoryWithHandlers<AllowMultipleVerticalDragRecognizer>(
          () => AllowMultipleVerticalDragRecognizer(),
          (AllowMultipleVerticalDragRecognizer instance) {
            _allowMultipleVerticalDragRecognizer = instance;
            instance.onStart = (details) => this._handleVerticalDragAcceptPolicy(instance);
            instance.onUpdate = (details) => this._handleVerticalDragAcceptPolicy(instance);
          },
        ),
        // AllowMultipleDoubleTapRecognizer: GestureRecognizerFactoryWithHandlers<AllowMultipleDoubleTapRecognizer>(
        //   () => AllowMultipleDoubleTapRecognizer(),
        //   (AllowMultipleDoubleTapRecognizer instance) {
        //     instance.onDoubleTap = () => this._handleDoubleTap();
        //   },
        // ),
        // AllowMultipleTapRecognizer: GestureRecognizerFactoryWithHandlers<AllowMultipleTapRecognizer>(
        //   () => AllowMultipleTapRecognizer(),
        //   (AllowMultipleTapRecognizer instance) {
        //     instance.onTapDown = (details) => this._handleTapDown(details.globalPosition);
        //   },
        // ),
      },
      //Creates the nested container within the first.
      behavior: HitTestBehavior.opaque,
      child: Opacity(opacity: _isZooming ? 0 : 1, child: widget.child),
      // child: Transform(
      //   transform: Matrix4.identity()
      //     ..translate(_offset!.dx, _offset!.dy)
      //     ..scale(_scale),
      //   child: _buildTransitionToImage(),
      // ),
    );
  }

  void _handleHorizontalDragAcceptPolicy(AllowMultipleHorizontalDragRecognizer instance) {
    _scale != 1.0 ? instance.alwaysAccept = true : instance.alwaysAccept = false;
  }

  void _handleVerticalDragAcceptPolicy(AllowMultipleVerticalDragRecognizer instance) {
    _scale != 1.0 ? instance.alwaysAccept = true : instance.alwaysAccept = false;
  }
}

abstract class ScaleDownHandler {
  void handleScaleDown();
}

//==============================================================================================

class AllowMultipleHorizontalDragRecognizer extends HorizontalDragGestureRecognizer {
  bool alwaysAccept = false;

  @override
  void rejectGesture(int pointer) {
    acceptGesture(pointer);
  }

  @override
  void resolve(GestureDisposition disposition) {
    if (alwaysAccept) {
      super.resolve(GestureDisposition.accepted);
    } else {
      super.resolve(GestureDisposition.rejected);
    }
  }
}

//==============================================================================================

class AllowMultipleVerticalDragRecognizer extends VerticalDragGestureRecognizer {
  bool alwaysAccept = false;

  @override
  void rejectGesture(int pointer) {
    acceptGesture(pointer);
  }

  @override
  void resolve(GestureDisposition disposition) {
    if (alwaysAccept) {
      super.resolve(GestureDisposition.accepted);
    } else {
      super.resolve(GestureDisposition.rejected);
    }
  }
}

//==============================================================================================

class _TransformWidget extends StatefulWidget {
  const _TransformWidget({
    Key? key,
    required this.child,
    required this.matrix,
  }) : super(key: key);

  final Widget child;
  final Matrix4 matrix;

  @override
  _TransformWidgetState createState() => _TransformWidgetState();
}

class _TransformWidgetState extends State<_TransformWidget> {
  Matrix4? _matrix = Matrix4.identity();

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: widget.matrix * _matrix,
      child: widget.child,
    );
  }

  void setMatrix(Matrix4? matrix) {
    setState(() {
      _matrix = matrix;
    });
  }
}
