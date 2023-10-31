import 'package:better_player/better_player.dart';
import 'package:better_player_example/constants.dart';
import 'package:flutter/material.dart';

class OverriddenAspectRatioPage extends StatefulWidget {
  @override
  _OverriddenAspectRatioPageState createState() => _OverriddenAspectRatioPageState();
}

class _OverriddenAspectRatioPageState extends State<OverriddenAspectRatioPage> {
  late BetterPlayerController _betterPlayerController;

  @override
  void initState() {
    BetterPlayerConfiguration betterPlayerConfiguration = BetterPlayerConfiguration(
      fit: BoxFit.fill,
    );
    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      'https://sandbox.hyppe.id/stream/4b96fd90-63b1-4483-adf1-d733599be297.m3u8',
      headers: {
        'post-id': 'd8734135-3567-4fc7-a153-5d197c092b53',
        'x-auth-user': 'ellen@getnada.com',
        'x-auth-token':
            'Bearer eyJhbGciOiJIUzM4NCJ9.eyJkZXZpY2VJZCI6ImN0Nl9qWHNUUUlxR0NDTDBldGpUdmk6QVBBOTFiRUJyc0NCS3Zldm8xbjBFZFBJS3l0UG1CLWhYWUIwUnJqRWtvQVFoYVdpSHN1Q25sbm14RFdNZUg2VGxPdGpWOE5ZazUyVEY5X09Mc3V6WVZoenFycEhBM2FEU0NJQWUwOUl5UHJQUUpnOUJNc0stNEdQV2pSc2l4VHFKRVFzQ3UxUjFnWEsiLCJlbWFpbCI6ImVsbGVuQGdldG5hZGEuY29tIiwiaWF0IjoxNjQxNDU5NTY2LCJleHAiOjE2NDE1MjQzNjZ9.6fd7RwJapuQhOrfDAyRkZ8woaMvUZhd1mE3yS6jpq1RUAFjP2f7pciBnJI4y5GMo',
      },
    );
    _betterPlayerController = BetterPlayerController(betterPlayerConfiguration);
    _betterPlayerController.setupDataSource(dataSource).whenComplete(() {
      _betterPlayerController.setOverriddenAspectRatio(9 / 16);
      setState(() {});
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Overridden aspect ratio"),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Player with different rotation and fit.",
              style: TextStyle(fontSize: 16),
            ),
          ),
          if (_betterPlayerController.isVideoInitialized() ?? false)
            BetterPlayer(
              controller: _betterPlayerController,
            ),
          // AspectRatio(
          //   aspectRatio: 1.0,
          //   child: BetterPlayer(controller: _betterPlayerController),
          // ),
        ],
      ),
    );
  }
}
