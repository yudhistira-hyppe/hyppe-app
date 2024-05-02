
import 'package:flutter/material.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';

class ExternalLinkNotifier with ChangeNotifier {
  LocalizationModelV2 language = LocalizationModelV2();
  translate(LocalizationModelV2 translate) {
    language = translate;
    notifyListeners();
  }
  TextEditingController _linkController = TextEditingController();
  final FocusNode linkFocus = FocusNode();
  final FocusNode titleFocus = FocusNode();
  TextEditingController _titleController = TextEditingController();

  TextEditingController get linkController => _linkController;
  TextEditingController get titleController => _titleController;

  set linkController(TextEditingController val) {
    _linkController = val;
    notifyListeners();
  }

  set titleController(TextEditingController val) {
    _titleController = val;
    notifyListeners();
  }

  bool? _selectedPermission;
  bool isEdited = false;
  void setIsEdited(bool val) {
    isEdited = val;
    notifyListeners();
  }

  bool get selectedPermission => _selectedPermission??false;
  void setselectedPermission(bool? val) {
    _selectedPermission = val;
    notifyListeners();
  }

  bool urlValid = false;
  void urlValidator(bool val) {
    urlValid = val;
    notifyListeners();
  }

  void onWillPop(BuildContext context) {
    _linkController.clear();
    _titleController.clear();
    urlValid = false;
    _selectedPermission = false;
    isEdited = false;
    notifyListeners();
    Navigator.pop(context);
  }
}