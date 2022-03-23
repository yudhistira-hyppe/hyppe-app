enum DeviceState {
  init, loading,
  activityAwakeSuccess, activityAwakeError,
  activitySleepSuccess, activitySleepError,
}

class DeviceFetch {
  final data;
  final DeviceState deviceState;
  DeviceFetch(this.deviceState, {this.data});
}
