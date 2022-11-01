import 'package:flutter/cupertino.dart';

class HelpNotifier with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
}
