class CouponDashboardResponse {
  final bool success;
  final CouponPerformanceSummary couponPerformanceSummary;
  final CouponOverviewSummary couponOverviewSummary;
  final CouponLists couponLists;

  CouponDashboardResponse({
    required this.success,
    required this.couponPerformanceSummary,
    required this.couponOverviewSummary,
    required this.couponLists,
  });

  factory CouponDashboardResponse.fromJson(Map<String, dynamic> json) {
    return CouponDashboardResponse(
      success: json['success'] ?? false,
      couponPerformanceSummary: CouponPerformanceSummary.fromJson(
        json['performanceSummary'] ?? {},
      ),
      couponOverviewSummary: CouponOverviewSummary.fromJson(
        json['overview'] ?? {},
      ),
      couponLists: CouponLists.fromJson(json['coupons'] ?? {}),
    );
  }
}

class CouponPerformanceSummary {
  final String period;
  final int orders;
  final String ordersChange;
  final int gmv;
  final String gmvChange;
  final int views;
  final String viewsChange;

  CouponPerformanceSummary({
    required this.period,
    required this.orders,
    required this.ordersChange,
    required this.gmv,
    required this.gmvChange,
    required this.views,
    required this.viewsChange,
  });

  factory CouponPerformanceSummary.fromJson(Map<String, dynamic> json) {
    return CouponPerformanceSummary(
      period: json['period'] ?? '',
      orders: json['orders'] ?? 0,
      ordersChange: json['ordersChange'] ?? '0%',
      gmv: json['gmv'] ?? 0,
      gmvChange: json['gmvChange'] ?? '0%',
      views: json['views'] ?? 0,
      viewsChange: json['viewsChange'] ?? '0%',
    );
  }
}

class CouponOverviewSummary {
  final int totalCoupons;
  final int activeCoupons;
  final int inactiveCoupons;
  final int expiredCoupons;

  CouponOverviewSummary({
    required this.totalCoupons,
    required this.activeCoupons,
    required this.inactiveCoupons,
    required this.expiredCoupons,
  });

  factory CouponOverviewSummary.fromJson(Map<String, dynamic> json) {
    return CouponOverviewSummary(
      totalCoupons: json['totalCoupons'] ?? 0,
      activeCoupons: json['activeCoupons'] ?? 0,
      inactiveCoupons: json['inactiveCoupons'] ?? 0,
      expiredCoupons: json['expiredCoupons'] ?? 0,
    );
  }
}

class CouponLists {
  final List<CouponItem> allCoupons;
  final List<CouponItem> activeCoupons;
  final List<CouponItem> inactiveCoupons;
  final CouponCountSummary couponCountSummary;

  CouponLists({
    required this.allCoupons,
    required this.activeCoupons,
    required this.inactiveCoupons,
    required this.couponCountSummary,
  });

  factory CouponLists.fromJson(Map<String, dynamic> json) {
    return CouponLists(
      allCoupons:
          (json['all'] as List? ?? [])
              .map((e) => CouponItem.fromJson(e))
              .toList(),
      activeCoupons:
          (json['active'] as List? ?? [])
              .map((e) => CouponItem.fromJson(e))
              .toList(),
      inactiveCoupons:
          (json['inactive'] as List? ?? [])
              .map((e) => CouponItem.fromJson(e))
              .toList(),
      couponCountSummary: CouponCountSummary.fromJson(json['counts'] ?? {}),
    );
  }
}

class CouponCountSummary {
  final int total;
  final int active;
  final int inactive;

  CouponCountSummary({
    required this.total,
    required this.active,
    required this.inactive,
  });

  factory CouponCountSummary.fromJson(Map<String, dynamic> json) {
    return CouponCountSummary(
      total: json['all'] ?? 0,
      active: json['active'] ?? 0,
      inactive: json['inactive'] ?? 0,
    );
  }
}

class CouponItem {
  CouponItem();

  factory CouponItem.fromJson(Map<String, dynamic> json) {
    return CouponItem();
  }
}
