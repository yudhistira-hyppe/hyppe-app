import 'package:hyppe/core/models/collection/id_proof/id_proof_data.dart';

class IdProof {
  int? statusCode;
  String? message;
  IdProofData? data;

  IdProof.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    message = json['message'];
    data = json['data'] != null ? IdProofData.fromJson(json['data']) : null;
  }
}