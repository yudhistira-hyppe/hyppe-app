import 'package:flutter/material.dart';

class testAnimation extends StatefulWidget {
  @override
  _testAnimationState createState() => _testAnimationState();
}

class _testAnimationState extends State<testAnimation> {
  List<AnimatedLike> animatedLikes = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Animation'),
      ),
      body: GestureDetector(
        onTap: () {
          _addLike();
        },
        child: Stack(
          children: [
            // Your main content goes here
            Align(
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: () {
                  print("haha");
                  _addLike();
                }, //doesnt work

                child: Container(
                  height: 30,
                  width: 30,
                  color: Colors.red,
                ),
              ),
            ),

            // Animated heart icons
            for (var animatedLike in animatedLikes)
              SafeArea(
                child: AnimatedPositioned(
                  duration: Duration(milliseconds: 1500),
                  curve: animatedLike.curve,
                  top: animatedLike.top,
                  left: animatedLike.left,
                  child: Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: 30,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _addLike() {
    setState(() {
      // Get the tap position
      final RenderBox box = context.findRenderObject() as RenderBox;
      final Offset tapPosition = box.globalToLocal(Offset.zero);

      // Generate a random curve for jigjag motion
      Curve curve = _generateRandomCurve();

      // Add animated like to the list
      animatedLikes.add(
        AnimatedLike(
          curve: curve,
          top: tapPosition.dy - 50, // Adjust the initial position as needed
          left: tapPosition.dx,
        ),
      );
    });
  }

  Curve _generateRandomCurve() {
    List<Curve> curves = [
      Curves.easeInOut,
      Curves.easeIn,
      Curves.easeOut,
      Curves.linear,
    ];

    return curves[DateTime.now().microsecondsSinceEpoch % curves.length];
  }
}

class AnimatedLike {
  final Curve curve;
  final double top;
  final double left;

  AnimatedLike({required this.curve, required this.top, required this.left});
}
