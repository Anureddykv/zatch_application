class BargainSetting {
  final bool isEnabled;
  final double autoAccept;
  final double maxDiscount;

  BargainSetting({
    required this.isEnabled,
    required this.autoAccept,
    required this.maxDiscount,
  });

  BargainSetting copyWith({
    bool? isEnabled,
    double? autoAccept,
    double? maxDiscount,
  }) {
    return BargainSetting(
      isEnabled: isEnabled ?? this.isEnabled,
      autoAccept: autoAccept ?? this.autoAccept,
      maxDiscount: maxDiscount ?? this.maxDiscount,
    );
  }
}
