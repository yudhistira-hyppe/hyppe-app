import 'package:flutter/material.dart';

class CustomTabPageSelector extends StatelessWidget {
  final TabController? controller;
  final double indicatorSize;
  final double indicatorDivider;
  final Color activeColor;
  final Color backgroundColor;

  const CustomTabPageSelector({
    Key? key,
    required this.controller,
    required this.activeColor,
    required this.backgroundColor,
    this.indicatorSize = 8.0,
    this.indicatorDivider = 2.0,
  }) : super(key: key);

  double _indexChangeProgress(TabController controller) {
    final double controllerValue = controller.animation?.value ?? 0.0;
    final double previousIndex = controller.previousIndex.toDouble();
    final double currentIndex = controller.index.toDouble();
    if (!controller.indexIsChanging) return (currentIndex - controllerValue).abs().clamp(0.0, 1.0);
    return (controllerValue - currentIndex).abs() / (currentIndex - previousIndex).abs();
  }

  Widget _buildTabIndicator(int tabIndex, TabController tabController, ColorTween selectedColorTween, ColorTween previousColorTween) {
    Color background;
    if (tabController.indexIsChanging) {
      final double t = 1.0 - _indexChangeProgress(tabController);
      if (tabController.index == tabIndex) {
        background = selectedColorTween.lerp(t) ?? Colors.white;
      } else if (tabController.previousIndex == tabIndex) {
        background = previousColorTween.lerp(t) ?? Colors.white;
      } else {
        background = selectedColorTween.begin ?? Colors.white;
      }
    } else {
      final double offset = tabController.offset;
      if (tabController.index == tabIndex) {
        background = selectedColorTween.lerp(1.0 - offset.abs()) ?? Colors.white;
      } else if (tabController.index == tabIndex - 1 && offset > 0.0) {
        background = selectedColorTween.lerp(offset) ?? Colors.white;
      } else if (tabController.index == tabIndex + 1 && offset < 0.0) {
        background = selectedColorTween.lerp(-offset) ?? Colors.white;
      } else {
        background = selectedColorTween.begin ?? Colors.white;
      }
    }
    return Container(
      margin: EdgeInsets.symmetric(horizontal: indicatorDivider),
      height: indicatorSize,
      width: indicatorSize,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TabController tabController = (controller ?? DefaultTabController.of(context));
    final Animation<double> animation = CurvedAnimation(
      parent: tabController.animation!,
      curve: Curves.fastOutSlowIn,
    );

    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          AnimatedBuilder(
            animation: animation,
            builder: (BuildContext context, Widget? child) {
              return Semantics(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List<Widget>.generate(
                    tabController.length,
                    (int tabIndex) {
                      final ColorTween selectedColorTween = ColorTween(begin: backgroundColor, end: activeColor);
                      final ColorTween previousColorTween = ColorTween(begin: activeColor, end: backgroundColor);
                      return _buildTabIndicator(tabIndex, tabController, selectedColorTween, previousColorTween);
                    },
                  ).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
