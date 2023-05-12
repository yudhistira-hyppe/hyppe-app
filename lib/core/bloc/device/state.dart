enum DeviceState {
  init,
  activityAwakeSuccess,
  loading,
  activityAwakeError,
  activitySleepSuccess,
  activitySleepError,
}

class DeviceFetch {
  final data;
  final DeviceState deviceState;
  final version;
  final versionIos;
  DeviceFetch(this.deviceState, {this.data, this.version, this.versionIos});
}
