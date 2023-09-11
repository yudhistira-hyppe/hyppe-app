import 'package:flutter/material.dart';
import 'package:hyppe/core/bloc/tutor/bloc.dart';
import 'package:hyppe/core/bloc/tutor/state.dart';

class TutorNotifier with ChangeNotifier {
  Future postTutor(BuildContext context, String key) async {
    final bannerNotifier = TutorBloc();
    await bannerNotifier.postTutorBloc(context, key: key);
    final bannerFatch = bannerNotifier.tutorFetch;

    if (bannerFatch.tutorState == TutorState.getPostSuccess) {
      notifyListeners();
    }
  }
}
