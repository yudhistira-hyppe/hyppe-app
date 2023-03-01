// import 'package:flutter_aliplayer/flutter_aliplayer.dart';
// import 'package:flutter_aliplayer/flutter_aliplayer_factory.dart';
// import 'package:flutter/material.dart';

// enum ModeType { URL, STS, AUTH, MPS }

// class AliPlayer extends StatefulWidget {
//   const AliPlayer({Key? key}) : super(key: key);

//   @override
//   State<AliPlayer> createState() => _AliPlayerState();
// }

// class _AliPlayerState extends State<AliPlayer> {
//   FlutterAliplayer fAliplayer = FlutterAliPlayerFactory.createAliPlayer();

//   Map _dataSourceMap = {};
   

//   @override
//   Widget build(BuildContext context) {
//     var x = 0.0;
//     var y = 0.0;
//     Orientation orientation = MediaQuery.of(context).orientation;
//     var width = MediaQuery.of(context).size.width;

//     var height;
//     if (orientation == Orientation.portrait) {
//       height = width * 9.0 / 16.0;
//     } else {
//       height = MediaQuery.of(context).size.height;
//     }
//     AliPlayerView aliPlayerView = AliPlayerView(onCreated: onViewPlayerCreated, x: x, y: y, width: width, height: height);
//     return OrientationBuilder(
//       builder: (BuildContext context, Orientation orientation) {
//         return Scaffold(
//           body: Column(
//             children: [
//               Container(color: Colors.black, child: aliPlayerView, width: width, height: height),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
