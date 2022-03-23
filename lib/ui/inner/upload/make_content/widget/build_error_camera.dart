import 'package:hyppe/core/constants/size_config.dart';
import 'package:flutter/material.dart';

class BuildErrorCamera extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.no_photography,
            color: Colors.red,
            size: 30 * SizeConfig.scaleDiagonal,
          ),
          Text(
            "Something's gone wrong with the camera!!",
            style: TextStyle(
                color: Colors.red,
                fontSize: 14.0 * SizeConfig.scaleDiagonal,
                letterSpacing: -0.153,
                fontWeight: FontWeight.w700,
                height: 1.411764705882353,
                fontFamily: 'Roboto'),
          )
        ],
      ),
    );
  }
}
