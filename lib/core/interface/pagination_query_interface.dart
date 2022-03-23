import 'package:flutter/material.dart';

abstract class PaginationQueryInterface {
  bool loading = false;

  bool hasNext = true;

  int page = 0;

  int limit = 5;

  Future<List> loadNext(BuildContext context) async {
    throw UnimplementedError();
  }

  Future<List> reload(BuildContext context) async {
    throw UnimplementedError();
  }
}
