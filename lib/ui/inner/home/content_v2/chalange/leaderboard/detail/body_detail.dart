import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/size_config.dart';

class BodyDetailWidget extends StatefulWidget {
  const BodyDetailWidget({super.key});

  @override
  State<BodyDetailWidget> createState() => _BodyDetailWidgetState();
}

class _BodyDetailWidgetState extends State<BodyDetailWidget> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Widget _tabSection(BuildContext context) {
    return PreferredSize(
      child: ListView(
        shrinkWrap: true,
        children: [
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(child: Text('Page 1')),
              Tab(child: Text('Page 2')),
            ],
          ),
          TabBarView(controller: _tabController, children: [
            Text("asd"),
            Text("asd"),
          ]),
        ],
      ),
      preferredSize: Size.fromHeight(40),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 16.0, right: 16),
      padding: const EdgeInsets.only(top: 8, left: 16.0, right: 16),
      color: Colors.white,
      child: Column(
        children: [
          Center(
            child: Container(
                width: SizeConfig.screenWidth,
                padding: const EdgeInsets.only(top: 24, bottom: 24),
                margin: const EdgeInsets.only(top: 16, left: 16.0, right: 16),
                decoration: const ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8))),
                ),
                child: const Center(
                  child: Text("Leaderboard",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      )),
                )),
          ),
          _tabSection(context),
        ],
      ),
    );
  }
}
