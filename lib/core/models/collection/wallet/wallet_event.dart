import 'package:hyppe/core/constants/enum.dart';

class WalletEvent {
  WalletEventEnum? event;
  Map<WalletResourceType?, dynamic> infos = {};

  WalletEvent(this.event, this.infos);

  WalletEvent.fromJson(Map<String, dynamic> json) {
    event = _serializeEvents(json['event']);
    if (json['infos'] != null) {
      json['infos'].forEach((v) {
        infos[_serializeType(v['resourceType'])] = v['value'];
      });
    }
  }

  static WalletEventEnum? _serializeEvents(events) {
    switch (events) {
      case 'ACQUIRING':
        return WalletEventEnum.acquiring;
      case 'MINI_DANA':
        return WalletEventEnum.miniDana;
      default:
        return null;
    }
  }

  static WalletResourceType? _serializeType(type) {
    switch (type) {
      case 'MASK_DANA_ID':
        return WalletResourceType.maskDanaId;
      case 'BALANCE':
        return WalletResourceType.balance;
      case 'USER_KYC':
        return WalletResourceType.userKYC;
      case 'TRANSACTION_URL':
        return WalletResourceType.transactionUrl;
      case 'TOPUP_URL':
        return WalletResourceType.topUpUrl;
      case 'OAUTH_URL':
        return WalletResourceType.oauthUrl;
      default:
        return null;
    }
  }
}
