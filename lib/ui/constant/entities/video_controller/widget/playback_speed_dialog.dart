// import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
// import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
// import 'package:flutter/material.dart';
//
// class PlaybackSpeedDialog extends StatelessWidget {
//   const PlaybackSpeedDialog({
//     Key? key,
//     required List<double> speeds,
//     required double selected,
//   })   : _speeds = speeds,
//         _selected = selected,
//         super(key: key);
//
//   final List<double> _speeds;
//   final double _selected;
//
//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       shrinkWrap: true,
//       physics: const ScrollPhysics(),
//       itemBuilder: (context, index) {
//         final _speed = _speeds[index];
//         return ListTile(
//           dense: true,
//           title: Row(
//             children: [
//               if (_speed == _selected)
//                 Icon(Icons.check, size: 20.0, color: Theme.of(context).colorScheme.primaryVariant)
//               else
//                 twentyPx,
//               sixteenPx,
//               CustomTextWidget(textToDisplay: _speed.toString(), textStyle: Theme.of(context).textTheme.caption),
//             ],
//           ),
//           selected: _speed == _selected,
//           onTap: () => Navigator.of(context).pop(_speed),
//         );
//       },
//       itemCount: _speeds.length,
//     );
//   }
// }
