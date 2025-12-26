class ResponseApi {
  final bool success;
  final String message;
  final SendOtpResponse data;
  final int status;

  ResponseApi({
    required this.success,
    required this.message,
    required this.data,
    required this.status,
  });

  factory ResponseApi.fromJson(Map<String, dynamic> json) {
    return ResponseApi(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
      data: SendOtpResponse.fromJson(json["data"] ?? {}),
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

class SendOtpResponse {
  final String sid;
  final String serviceSid;
  final String accountSid;
  final String to;
  final String channel;
  final String status;
  final bool valid;
  final Lookup lookup;
  final List<SendCodeAttempt> sendCodeAttempts;
  final String? amount;
  final String? payee;
  final String dateCreated;
  final String dateUpdated;
  final String url;

  SendOtpResponse({
    required this.sid,
    required this.serviceSid,
    required this.accountSid,
    required this.to,
    required this.channel,
    required this.status,
    required this.valid,
    required this.lookup,
    required this.sendCodeAttempts,
    required this.dateCreated,
    required this.dateUpdated,
    required this.url,
    this.amount,
    this.payee,
  });

  factory SendOtpResponse.fromJson(Map<String, dynamic> json) {
    return SendOtpResponse(
      sid: json["sid"] ?? "",
      serviceSid: json["serviceSid"] ?? "",
      accountSid: json["accountSid"] ?? "",
      to: json["to"] ?? "",
      channel: json["channel"] ?? "",
      status: json["status"] ?? "",
      valid: json["valid"] ?? false,
      lookup: Lookup.fromJson(json["lookup"] ?? {}),
      sendCodeAttempts: (json["sendCodeAttempts"] as List<dynamic>? ?? [])
          .map((e) => SendCodeAttempt.fromJson(e as Map<String, dynamic>))
          .toList(),
      amount: json["amount"],
      payee: json["payee"],
      dateCreated: json["dateCreated"] ?? "",
      dateUpdated: json["dateUpdated"] ?? "",
      url: json["url"] ?? "",
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
      "lookup": lookup.toJson(),
      "sendCodeAttempts": sendCodeAttempts.map((e) => e.toJson()).toList(),
      "amount": amount,
      "payee": payee,
      "dateCreated": dateCreated,
      "dateUpdated": dateUpdated,
      "url": url,
    };
  }
}

class Lookup {
  final dynamic carrier;
  Lookup({this.carrier});

  factory Lookup.fromJson(Map<String, dynamic> json) {
    return Lookup(carrier: json["carrier"]);
  }

  Map<String, dynamic> toJson() => {"carrier": carrier};
}

class SendCodeAttempt {
  final String attemptSid;
  final String channel;
  final String time;

  SendCodeAttempt({
    required this.attemptSid,
    required this.channel,
    required this.time,
  });

  factory SendCodeAttempt.fromJson(Map<String, dynamic> json) {
    return SendCodeAttempt(
      attemptSid: json["attempt_sid"] ?? "",
      channel: json["channel"] ?? "",
      time: json["time"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "attempt_sid": attemptSid,
    "channel": channel,
    "time": time,
  };
}
