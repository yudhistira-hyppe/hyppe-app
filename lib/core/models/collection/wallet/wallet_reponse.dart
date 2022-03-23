import 'package:hyppe/core/models/collection/wallet/wallet_event.dart';

class WalletResponse {
  dynamic status;
  WalletEvent data;
  WalletResponse({required this.status, required this.data});

  factory WalletResponse.fromJson(dynamic json) {
    return WalletResponse(status: json['status'], data: WalletEvent.fromJson(json['data']));
  }
}