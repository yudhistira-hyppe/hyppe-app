import 'package:image_picker/image_picker.dart';

class GeneralArgument {
  bool isTrue;
  String? id;
  int? index;
  int? session;
  String? title;
  String? body;

  GeneralArgument({this.isTrue = true, this.id, this.index, this.session, this.body, this.title});
}

class FileArgument {
  String date;
  XFile xfile;

  FileArgument({required this.date, required this.xfile});
}
