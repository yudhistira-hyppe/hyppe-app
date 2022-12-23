import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/models/collection/notification_v2/notification.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/services/system.dart';

extension CustomDateTimeExtentision on DateTime {
  bool get isFirstMonth => month == DateTime.january;

  DateTime get firstDateOfLastMonth => subtract(
        Duration(
          days: DateUtils.getDaysInMonth(DateTime.now().isFirstMonth ? DateTime.now().year - 1 : DateTime.now().year,
                  DateTime.now().isFirstMonth ? DateTime.december : DateTime.now().month - 1) +
              DateTime.now().day -
              1,
        ),
      );

  DateTime daysAgo(int? days) => subtract(Duration(days: days ?? 7));
}

extension MarkAllNotificationAsRead on List<NotificationModel> {
  void markAllDataAsRead(Function(NotificationModel data) callback) {
    where((element0) => element0.isRead == false).toList().forEach((element2) async {
      element2.isRead = true;
      await callback(element2);
    });
  }

  List<NotificationModel> filterNotification(List<NotificationCategory> notificationCategory) {
    List<NotificationModel> _result = [];
    for (var element1 in this) {
      if (notificationCategory.contains(System().getNotificationCategory(element1.eventType ?? ''))) {
        _result.add(element1);
      }
    }
    return _result;
  }
}

extension CustomIterableExtension<T> on Iterable<T> {
  Iterable<T> whereNoDuplicates({
    dynamic Function(T item)? by,
    bool removeNulls = false,
  }) sync* {
    if (by != null) {
      Set<dynamic> ids = <dynamic>{};
      for (T item in this) {
        if (removeNulls && item == null) continue;
        dynamic id = by(item);
        if (!ids.contains(id)) yield item;
        ids.add(id);
      }
    } else {
      Set<T> items = {};
      for (T item in this) {
        if (removeNulls && item == null) continue;
        if (!items.contains(item)) yield item;
        items.add(item);
      }
    }
  }
}

extension CustomListExtension<T> on List<T> {
  /// Returns a new list, which is equal to the original one, but without
  /// duplicates. In other words, the new list has only distinct items.
  /// Optionally, you can provide an [id] function to compare the items.
  List<T> distinct({dynamic Function(T item)? by}) => by != null
      ? whereNoDuplicates(by: by).toList()
      : [
          ...{...this}
        ];

  /// Removes all duplicates from the list, leaving only the distinct items.
  /// Optionally, you can provide an [id] function to compare the items.
  ///
  /// If you pass [removeNulls] as true, it will also remove the nulls
  /// (it will check the item is null, before applying the [by] function).
  void removeDuplicates({
    dynamic Function(T item)? by,
    bool removeNulls = false,
  }) {
    if (by != null) {
      Set<dynamic> ids = <dynamic>{};
      removeWhere((item) {
        if (removeNulls && item == null) return true;
        dynamic id = by(item);
        return !ids.add(id);
      });
    } else {
      Set<T> items = {};
      removeWhere((item) {
        if (removeNulls && item == null) return true;
        return !items.add(item);
      });
    }
  }

  /// Find duplicates in the list, leaving only the distinct items.
  List<T> findDuplicates({
    dynamic Function(T item)? by,
    bool removeNulls = false,
  }) {
    if (by != null) {
      Set<dynamic> ids = <dynamic>{};
      return where((item) {
        if (removeNulls && item == null) return false;
        dynamic id = by(item);
        return ids.add(id);
      }).toList();
    } else {
      Set<T> items = {};
      return where((item) {
        if (removeNulls && item == null) return false;
        return !items.add(item);
      }).toList();
    }
  }

  /// First or null.
  T? firstOrNull() => isEmpty ? null : first;

  /// Moves the first occurrence of the [item] to the start of the list.
  void moveToTheFront(T item) {
    int pos = indexOf(item);
    if (pos != -1 && pos != 0) {
      removeAt(pos);
      insert(0, item);
    }
  }

  /// Moves the first occurrence of the [item] to the end of the list.
  void moveToTheEnd(T item) {
    int pos = indexOf(item);
    if (pos != -1 && pos != length - 1) {
      removeAt(pos);
      add(item);
    }
  }

  /// Removes all `null`s from the [List].
  void removeNulls() {
    removeWhere((element) => element == null);
  }

  /// Returns a new list where [newItems] are added or updated, by their [id]
  /// (and the [id] is a function of the item), like so:
  ///
  /// 1) Items with the same [id] will be replaced, in place.
  /// 2) Items with new [id]s will be added go to the end of the list.
  ///
  /// Note: If the original iterable contains more than one item with the
  /// same [id] as some item in [newItems], the first will be replaced, and
  /// the others will be left untouched. If [newItems] contains more than
  /// one item with the same [id], the last one will be used, and the
  /// previous discarded.
  ///
  List<T> updateById(
    Iterable<T> newItems,
    dynamic Function(T item) id,
  ) {
    List<T> newList = [];

    Map<dynamic, T> idsPerNewItem = <dynamic, T>{for (T item in newItems) id(item): item};

    // Replace those with the same id.
    for (T item in this) {
      var itemId = id(item);
      if (idsPerNewItem.containsKey(itemId)) {
        T newItem = idsPerNewItem[itemId] as T;
        newList.add(newItem);
        idsPerNewItem.remove(itemId);
      } else {
        newList.add(item);
      }
    }

    // Add the new ones at the end.
    newList.addAll(idsPerNewItem.values);
    return newList;
  }
}

extension StringExtension on String? {
  String get camelCase => this?.replaceAllMapped(RegExp(r'(?:^|_)([a-z])'), (match) => (match.group(1) ?? '').toUpperCase()) ?? '';

  String get capitalized => this?.replaceAllMapped(RegExp(r'(?:^|_)([a-z])'), (match) => (match.group(1) ?? '').toUpperCase()) ?? '';
}
