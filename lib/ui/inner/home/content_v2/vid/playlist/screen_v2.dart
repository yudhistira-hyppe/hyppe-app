import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';

class NewVideoDetailScreen extends StatefulWidget {
  const NewVideoDetailScreen({Key? key}) : super(key: key);

  @override
  State<NewVideoDetailScreen> createState() => _NewVideoDetailScreenState();
}

class _NewVideoDetailScreenState extends State<NewVideoDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(16))),
            child: Row(
              children: [
                GestureDetector(
                  onTap:(){},
                    child: const CustomIconWidget(iconData: '${AssetPath.vectorPath}back-arrow.svg'))
              ],
            ),
          )
        ],
      ),
    );
  }
}
