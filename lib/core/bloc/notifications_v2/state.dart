enum NotificationState {
  init,
  loading,
  getUsersNotificationBlocSuccess,
  getUsersNotificationBlocError,
}

class NotificationFetch {
  final data;
  final NotificationState notificationState;
  NotificationFetch(this.notificationState, {this.data});
}
