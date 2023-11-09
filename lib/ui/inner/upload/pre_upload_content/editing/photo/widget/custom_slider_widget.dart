import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';

class CustomSliderWidget extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final Function(double value) onChanged;

  const CustomSliderWidget({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Visibility(
                visible: min < 0,
                child: Expanded(
                  flex: min.abs().round(),
                  child: LinearProgressIndicator(
                    minHeight: 2,
                    value: 1 - value / min,
                    color: kHyppeDividerColor,
                    backgroundColor: kHyppeTextPrimary,
                  ),
                ),
              ),
              Expanded(
                flex: max.abs().round(),
                child: LinearProgressIndicator(
                  minHeight: 2,
                  value: value / max,
                  color: kHyppeTextPrimary,
                  backgroundColor: kHyppeDividerColor,
                ),
              ),
            ],
          ),
        ),
        Slider(
          value: value,
          activeColor: Colors.transparent,
          inactiveColor: Colors.transparent,
          thumbColor: kHyppeTextPrimary,
          min: min,
          max: max,
          divisions: (min.abs() + max.abs()).round(),
          label: value.round().toString(),
          onChanged: onChanged
        ),
      ],
    );
  }
}
