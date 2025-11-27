class SearchHistoryResponse {
  final bool success;
  final String message;
  final List<SearchQuery> searchHistory;

  SearchHistoryResponse({
    required this.success,
    required this.message,
    required this.searchHistory,
  });

  factory SearchHistoryResponse.fromJson(Map<String, dynamic> json) {
    return SearchHistoryResponse(
      success: json['success'],
      message: json['message'],
      searchHistory: (json['searchHistory'] as List)
          .map((e) => SearchQuery.fromJson(e))
          .toList(),
    );
  }
}

class SearchQuery {
  final String query;
  final String createdAt;
  final String id;

  SearchQuery({
    required this.query,
    required this.createdAt,
    required this.id,
  });

  factory SearchQuery.fromJson(Map<String, dynamic> json) {
    return SearchQuery(
      query: json['query'],
      createdAt: json['createdAt'],
      id: json['_id'],
    );
  }
}
