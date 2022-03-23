import 'package:flutter/material.dart';
// import 'package:google_maps_webservice/places.dart';
// import 'package:provider/provider.dart';
// import 'package:hyppe/core/constants/size_config.dart';
// import 'package:hyppe/ui/inner/upload/pre_upload_content/notifier.dart';

class BuildSuggestedLocation extends StatelessWidget {
  // final List<PlacesSearchResult>? data;
  // BuildSuggestedLocation({required this.data});

  @override
  Widget build(BuildContext context) {
    // final notifier = Provider.of<PreUploadContentNotifier>(context);
    // return ListView.builder(
    //   physics: BouncingScrollPhysics(),
    //   scrollDirection: Axis.horizontal,
    //   itemCount: data!.length,
    //   itemBuilder: (context, index) {
    //     return UnconstrainedBox(
    //       child: GestureDetector(
    //         onTap: () => notifier.handleTapOnLocation(data![index].name),
    //         child: Container(
    //           alignment: Alignment.center,
    //           height: 30 * SizeConfig.scaleDiagonal,
    //           margin: const EdgeInsets.symmetric(horizontal: 5),
    //           padding: const EdgeInsets.symmetric(horizontal: 10),
    //           decoration: BoxDecoration(color: const Color(0xff383B3E), borderRadius: BorderRadius.circular(14)),
    //           child: Text(
    //             data![index].name,
    //             maxLines: 1,
    //             style: TextStyle(
    //               color: const Color(0xff949596),
    //               fontFamily: "Roboto",
    //               fontWeight: FontWeight.w400,
    //               fontSize: 12 * SizeConfig.scaleDiagonal,
    //             ),
    //           ),
    //         ),
    //       ),
    //     );
    //   },
    // );
    return const Text('');
  }
}
