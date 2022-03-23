import 'package:hyppe/core/bloc/bookmark/state.dart';
import 'package:hyppe/core/bloc/repos/repos.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/status_code.dart';
import 'package:hyppe/core/models/collection/bookmark/bookmark.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';

class BookmarkBloc {
  BookmarkFetch _bookmarkFetch = BookmarkFetch(BookmarkState.init);
  BookmarkFetch get bookmarkFetch => _bookmarkFetch;
  setBookmarkFetch(BookmarkFetch val) => _bookmarkFetch = val;

  Future addBookmarkBloc(BuildContext context, {required Bookmark data}) async {
    setBookmarkFetch(BookmarkFetch(BookmarkState.loading));
    await Repos().reposPost(
      context,
      (onResult) {
        if (onResult.statusCode != HTTP_OK) {
          setBookmarkFetch(BookmarkFetch(BookmarkState.addBookmarkBlocError));
        } else {
          setBookmarkFetch(BookmarkFetch(BookmarkState.addBookmarkBlocSuccess, data: onResult.data));
        }
      },
      (errorData) {
        ShowBottomSheet.onInternalServerError(context, tryAgainButton: () => Routing().moveBack());
        setBookmarkFetch(BookmarkFetch(BookmarkState.addBookmarkBlocError));
      },
      data: data.toJson(),
      host: UrlConstants.addBookmark,
      withAlertMessage: true,
      methodType: MethodType.post,
      withCheckConnection: false,
    );
  }

  Future getBookmarkBloc(BuildContext context, {required String playlistID, int? page}) async {
    setBookmarkFetch(BookmarkFetch(BookmarkState.loading));
    String pg = page != null ? "&pageNumber=$page" : "";
    await Repos().reposPost(
      context,
      (onResult) {
        if (onResult.statusCode != HTTP_OK) {
          setBookmarkFetch(BookmarkFetch(BookmarkState.getBookmarkBlocError));
        } else {
          final Bookmark _result = Bookmark.fromJson(onResult.data);
          setBookmarkFetch(BookmarkFetch(BookmarkState.getBookmarkBlocSuccess, data: _result));
        }
      },
      (errorData) {
        ShowBottomSheet.onInternalServerError(context, tryAgainButton: () => Routing().moveBack());
        setBookmarkFetch(BookmarkFetch(BookmarkState.getBookmarkBlocError));
      },
      host: UrlConstants.getBookmark + "?playlistID=$playlistID" + pg,
      withAlertMessage: false,
      methodType: MethodType.get,
      withCheckConnection: false,
    );
  }
}
