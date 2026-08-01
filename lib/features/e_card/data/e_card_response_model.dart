class ECardResponse {
  final bool success;
  final String timestamp;
  final String message;
  final ECardData? data;

  const ECardResponse({
    required this.success,
    required this.timestamp,
    required this.message,
    required this.data,
  });

  factory ECardResponse.fromJson(Map<String, dynamic> json) {
    final dataJson = json['data'];
    return ECardResponse(
      success: _asBool(json['success']),
      timestamp: _asString(json['timestamp']),
      message: _asString(json['message']),
      data: dataJson is Map<String, dynamic>
          ? ECardData.fromJson(dataJson)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'timestamp': timestamp,
    'message': message,
    'data': data?.toJson(),
  };
}

class ECardData {
  final int? memberId;
  final String memberCode;
  final String memberName;
  final String memberPhoto;
  final String mciCard;
  final String planTier;
  final String planColor;
  final String policyExpireDate;
  final String insuranceCompanyName;
  final String insuranceCompanyLogo;
  final String qrCodeValue;
  final String qrCodeImageUrl;
  final List<String> coverageNotes;

  const ECardData({
    required this.memberId,
    required this.memberCode,
    required this.memberName,
    required this.memberPhoto,
    required this.mciCard,
    required this.planTier,
    required this.planColor,
    required this.policyExpireDate,
    required this.insuranceCompanyName,
    required this.insuranceCompanyLogo,
    required this.qrCodeValue,
    required this.qrCodeImageUrl,
    required this.coverageNotes,
  });

  factory ECardData.fromJson(Map<String, dynamic> json) {
    return ECardData(
      memberId: _asInt(json['memberId']),
      memberCode: _asString(json['memberCode']),
      memberName: _asString(json['memberName']),
      memberPhoto: _asString(json['memberPhoto']),
      mciCard: _asString(json['mciCard']),
      planTier: _asString(json['planTier']),
      planColor: _asString(json['planColor']),
      policyExpireDate: _asString(json['policyExpireDate']),
      insuranceCompanyName: _asString(json['insuranceCompanyName']),
      insuranceCompanyLogo: _asString(json['insuranceCompanyLogo']),
      qrCodeValue: _asString(json['qrCodeValue']),
      qrCodeImageUrl: _asString(json['qrCodeImageUrl']),
      coverageNotes: _asStringList(json['coverageNotes']),
    );
  }

  String get displayMemberName => memberName.trim();

  List<String> get displayCoverageNotes => coverageNotes
      .map((note) => note.trim())
      .where((note) => note.isNotEmpty)
      .toList(growable: false);

  bool get hasMeaningfulData {
    return displayMemberName.isNotEmpty ||
        memberCode.trim().isNotEmpty ||
        mciCard.trim().isNotEmpty ||
        planTier.trim().isNotEmpty ||
        policyExpireDate.trim().isNotEmpty;
  }

  Map<String, dynamic> toJson() => {
    'memberId': memberId,
    'memberCode': memberCode,
    'memberName': memberName,
    'memberPhoto': memberPhoto,
    'mciCard': mciCard,
    'planTier': planTier,
    'planColor': planColor,
    'policyExpireDate': policyExpireDate,
    'insuranceCompanyName': insuranceCompanyName,
    'insuranceCompanyLogo': insuranceCompanyLogo,
    'qrCodeValue': qrCodeValue,
    'qrCodeImageUrl': qrCodeImageUrl,
    'coverageNotes': coverageNotes,
  };
}

bool _asBool(Object? value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) return value.toLowerCase().trim() == 'true';
  return false;
}

int? _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim());
  return null;
}

String _asString(Object? value) {
  if (value == null) return '';
  return value.toString();
}

List<String> _asStringList(Object? value) {
  if (value is List) {
    return value.map((item) => _asString(item)).toList(growable: false);
  }
  return const [];
}
