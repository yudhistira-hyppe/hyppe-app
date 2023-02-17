import 'package:flutter/material.dart';

abstract class QueryInterface {
  bool loading = false;

  Future reload(BuildContext context) async {
    throw UnimplementedError();
  }
}
