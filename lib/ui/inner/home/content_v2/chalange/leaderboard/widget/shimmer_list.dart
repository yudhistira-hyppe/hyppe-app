import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_shimmer.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';

class ShimmerListLeaderboard extends StatelessWidget {
  const ShimmerListLeaderboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_sharp,
            color: kHyppeTextLightPrimary,
            size: 16,
          ),
          onPressed: () {},
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              child: const CustomShimmer(width: 300, height: 100, radius: 8),
            ),
            ListView.builder(
                shrinkWrap: true,
                itemCount: 11,
                itemBuilder: (context, index) => Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                          child: Row(
                            children: [
                              const ClipOval(child: CustomShimmer(width: 24, height: 24, radius: 4)),
                              twelvePx,
                              const ClipOval(child: CustomShimmer(width: 43, height: 41, radius: 50)),
                              twelvePx,
                              Column(
                                children: const [
                                  CustomShimmer(width: 200, height: 11, radius: 50),
                                  sixPx,
                                  CustomShimmer(width: 200, height: 11, radius: 50),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    )),
          ],
        ),
      ),
    );
  }
}
