class OrderScreenResponse {
  final bool success;
  final String message;
  final OrderScreenSummary summary;
  final OrderScreenOrders orders;
  final OrderScreenPagination pagination;
  final OrderScreenFilters filters;

  OrderScreenResponse({
    required this.success,
    required this.message,
    required this.summary,
    required this.orders,
    required this.pagination,
    required this.filters,
  });

  factory OrderScreenResponse.fromJson(Map<String, dynamic> json) {
    return OrderScreenResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      summary: OrderScreenSummary.fromJson(json['performanceSummary'] ?? {}),
      orders: OrderScreenOrders.fromJson(json['orders'] ?? {}),
      pagination: OrderScreenPagination.fromJson(json['pagination'] ?? {}),
      filters: OrderScreenFilters.fromJson(json['filters'] ?? {}),
    );
  }
}

class OrderScreenSummary {
  final int views;
  final String viewsChange;
  final String revenue;
  final String revenueChange;
  final int pendingOrders;
  final String pendingChange;
  final int readyToShip;
  final int averageOrderValue;
  final int pendingRevenue;

  OrderScreenSummary({
    required this.views,
    required this.viewsChange,
    required this.revenue,
    required this.revenueChange,
    required this.pendingOrders,
    required this.pendingChange,
    required this.readyToShip,
    required this.averageOrderValue,
    required this.pendingRevenue,
  });

  factory OrderScreenSummary.fromJson(Map<String, dynamic> json) {
    return OrderScreenSummary(
      views: json['views'] ?? 0,
      viewsChange: json['viewsChange'] ?? '',
      revenue: json['revenue'] ?? '',
      revenueChange: json['revenueChange'] ?? '',
      pendingOrders: json['pending'] ?? 0,
      pendingChange: json['pendingChange'] ?? '',
      readyToShip: json['readyToShip'] ?? 0,
      averageOrderValue: json['avgOrderValue'] ?? 0,
      pendingRevenue: json['pendingRevenue'] ?? 0,
    );
  }
}

class OrderScreenOrders {
  final List<OrderScreenOrder> inProgress;
  final List<OrderScreenOrder> returns;
  final List<OrderScreenOrder> completed;

  OrderScreenOrders({
    required this.inProgress,
    required this.returns,
    required this.completed,
  });

  factory OrderScreenOrders.fromJson(Map<String, dynamic> json) {
    return OrderScreenOrders(
      inProgress:
          (json['inProgress'] as List? ?? [])
              .map((e) => OrderScreenOrder.fromJson(e))
              .toList(),
      returns:
          (json['return'] as List? ?? [])
              .map((e) => OrderScreenOrder.fromJson(e))
              .toList(),
      completed:
          (json['done'] as List? ?? [])
              .map((e) => OrderScreenOrder.fromJson(e))
              .toList(),
    );
  }
}

class OrderScreenOrder {
  final String id;
  final String orderId;
  final String status;
  final String statusLabel;
  final DateTime createdAt;
  final String orderType;
  final String deliveryType;
  final String location;
  final int totalCost;
  final int totalQuantity;
  final DateTime dueDate;
  final OrderScreenBuyer buyer;
  final List<OrderScreenProduct> products;
  final List<String> actions;

  OrderScreenOrder({
    required this.id,
    required this.orderId,
    required this.status,
    required this.statusLabel,
    required this.createdAt,
    required this.orderType,
    required this.deliveryType,
    required this.location,
    required this.totalCost,
    required this.totalQuantity,
    required this.dueDate,
    required this.buyer,
    required this.products,
    required this.actions,
  });

  factory OrderScreenOrder.fromJson(Map<String, dynamic> json) {
    return OrderScreenOrder(
      id: json['_id'] ?? '',
      orderId: json['orderId'] ?? '',
      status: json['status'] ?? '',
      statusLabel: json['statusLabel'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      orderType: json['orderType'] ?? '',
      deliveryType: json['deliveryType'] ?? '',
      location: json['location'] ?? '',
      totalCost: json['cost'] ?? 0,
      totalQuantity: json['qty'] ?? 0,
      dueDate: DateTime.parse(json['dueDate']),
      buyer: OrderScreenBuyer.fromJson(json['buyer'] ?? {}),
      products:
          (json['items'] as List? ?? [])
              .map((e) => OrderScreenProduct.fromJson(e))
              .toList(),
      actions: List<String>.from(json['actions'] ?? []),
    );
  }
}

class OrderScreenBuyer {
  final String name;
  final String phone;
  final String profileImage;

  OrderScreenBuyer({
    required this.name,
    required this.phone,
    required this.profileImage,
  });

  factory OrderScreenBuyer.fromJson(Map<String, dynamic> json) {
    return OrderScreenBuyer(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      profileImage: json['profilePic'] ?? '',
    );
  }
}

class OrderScreenProduct {
  final String productName;
  final String productImage;
  final int quantity;
  final int price;

  OrderScreenProduct({
    required this.productName,
    required this.productImage,
    required this.quantity,
    required this.price,
  });

  factory OrderScreenProduct.fromJson(Map<String, dynamic> json) {
    return OrderScreenProduct(
      productName: json['name'] ?? '',
      productImage: json['image'] ?? '',
      quantity: json['qty'] ?? 0,
      price: json['price'] ?? 0,
    );
  }
}

class OrderScreenPagination {
  final int currentPage;
  final int totalPages;
  final int totalOrders;
  final int limit;

  OrderScreenPagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalOrders,
    required this.limit,
  });

  factory OrderScreenPagination.fromJson(Map<String, dynamic> json) {
    return OrderScreenPagination(
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      totalOrders: json['totalOrders'] ?? 0,
      limit: json['limit'] ?? 0,
    );
  }
}

class OrderScreenFilters {
  final String timeFilter;
  final String status;
  final String search;

  OrderScreenFilters({
    required this.timeFilter,
    required this.status,
    required this.search,
  });

  factory OrderScreenFilters.fromJson(Map<String, dynamic> json) {
    return OrderScreenFilters(
      timeFilter: json['timeFilter'] ?? '',
      status: json['status'] ?? '',
      search: json['search'] ?? '',
    );
  }
}
