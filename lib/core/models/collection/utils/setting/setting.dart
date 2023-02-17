class SettingModel {
  bool? settingMP;

  SettingModel({
    this.settingMP,
  });
  static SettingModel fromJson(json) => SettingModel(
        settingMP: json['settingMP'],
      );
}
