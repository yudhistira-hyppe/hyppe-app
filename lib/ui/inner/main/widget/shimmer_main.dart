import 'package:hyppe/app.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/constant/widget/custom_shimmer.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:flutter/material.dart';

class ShimmerMain extends StatelessWidget {
  const ShimmerMain({super.key});

  @override
  Widget build(BuildContext context) {
    isFromSplash = false;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        CustomShimmer(width: 180, height: 20, radius: 8),
                        CustomShimmer(width: 30, height: 20, radius: 8),
                      ],
                    ),
                    twelvePx,
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        itemCount: 10,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return CustomShimmer(
                            width: 78,
                            height: 77,
                            radius: 20,
                            margin: EdgeInsets.only(right: 10),
                          );
                        },
                      ),
                    ),
                    twentyFourPx,
                    CustomShimmer(width: SizeConfig.screenWidth, height: 50, radius: 25),
                    twentyFourPx,
                    ListView.builder(
                      itemCount: 10,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return Container(
                          padding: EdgeInsets.all(16),
                          margin: EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Color(0xFFEAEAEA)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CustomShimmer(width: 50, height: 50, radius: 50),
                                  sixPx,
                                  Column(
                                    children: [
                                      CustomShimmer(width: 30, height: 10, radius: 8),
                                      sixPx,
                                      CustomShimmer(width: 30, height: 10, radius: 8),
                                    ],
                                  ),
                                ],
                              ),
                              twentyFourPx,
                              CustomShimmer(
                                width: SizeConfig.screenWidth,
                                height: 200,
                                radius: 25,
                              ),
                              twelvePx,
                              CustomShimmer(width: 90, height: 10, radius: 8),
                              sixPx,
                              CustomShimmer(width: SizeConfig.screenWidth, height: 10, radius: 8),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
