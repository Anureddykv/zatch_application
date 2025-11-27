import 'package:zatch_app/model/verify_otp_response.dart';

class VerifyApiResponse {
  final bool success;
  final String message;
  final VerifyOtpResponse data;
  final int status;

  VerifyApiResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.status,
  });

  factory VerifyApiResponse.fromJson(Map<String, dynamic> json) {
    return VerifyApiResponse(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
      data: VerifyOtpResponse.fromJson(json["data"] ?? {}),
      status: json["status"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "success": success,
      "message": message,
      "data": data.toJson(),
      "status": status,
    };
  }
}

class VerifyOtpResponse {
  final String? sid;
  final String? serviceSid;
  final String? accountSid;
  final String? to;
  final String? channel;
  final String? status;
  final bool? valid;
  final String? amount;
  final String? payee;
  final DateTime? dateCreated;
  final DateTime? dateUpdated;

  VerifyOtpResponse({
    this.sid,
    this.serviceSid,
    this.accountSid,
    this.to,
    this.channel,
    this.status,
    this.valid,
    this.amount,
    this.payee,
    this.dateCreated,
    this.dateUpdated,
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponse(
      sid: json['sid'] as String?,
      serviceSid: json['serviceSid'] as String?,
      accountSid: json['accountSid'] as String?,
      to: json['to'] as String?,
      channel: json['channel'] as String?,
      status: json['status'] as String?,
      valid: json['valid'] as bool?,
      amount: json['amount'] as String?,
      payee: json['payee'] as String?,
      dateCreated: json['dateCreated'] != null
          ? DateTime.tryParse(json['dateCreated'])
          : null,
      dateUpdated: json['dateUpdated'] != null
          ? DateTime.tryParse(json['dateUpdated'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "sid": sid,
      "serviceSid": serviceSid,
      "accountSid": accountSid,
      "to": to,
      "channel": channel,
      "status": status,
      "valid": valid,
      "amount": amount,
      "payee": payee,
      "dateCreated": dateCreated?.toIso8601String(),
      "dateUpdated": dateUpdated?.toIso8601String(),
    };
  }
}

