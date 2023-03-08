class GlobalSettings {
  ///软硬解开关
  static bool mEnableHardwareDecoder = true;

  ///播放器日志开关
  static bool mEnableAliPlayerLog = true;

  ///播放器日志级别
  // static int mLogLevel = FlutterAvpdef.AF_LOG_LEVEL_INFO;

  ///是否是精准seek
  static bool mEnableAccurateSeek = false;

  ///播放器名称
  static String mPlayerName = "";
}

///播放源相关
class DataSourceRelated {
  static const String defaultRegion = "ap-southeast-5";
  static const String defaultVideo = "6b357371ef3c45f4a06e2536fd534380";

  static const String defaultUrl = "https://alivc-demo-vod.aliyuncs.com/6b357371ef3c45f4a06e2536fd534380/53733986bce75cfc367d7554a47638c0-fd.mp4";

  static const String typeKey = "type";
  static const String regionKey = "region";
  static const String urlKey = "https://alivc-demo-vod.aliyuncs.com/6b357371ef3c45f4a06e2536fd534380/53733986bce75cfc367d7554a47638c0-fd.mp4";
  static const String vidKey = "5e79b300b28271edbf8f442380ea0102";
  static const String indexKey = "index";
  static const String accessKeyId = "LTAI5tP2FZeBukPgRq3McSpM";
  static const String accessKeySecret = "Q5hRgEciIYI2g265zbWsh2kc7meBjI";
  static const String securityToken = "securityToken";
  static const String previewTime = "previewTime";
  static const String playAuth = "playAuth";
  static const String playDomain = "playDomain";
  static const String authInfoKey = "authInfo";
  static const String hlsUriTokenKey = "hlsUriToken";
  static const String downloadSavePath = "savePath";
  static const String definitionList = "definitionList";
}
