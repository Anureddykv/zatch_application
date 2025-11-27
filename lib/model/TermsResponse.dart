class TermsResponse {
  final String title;
  final String content;

  TermsResponse({required this.title, required this.content});

  factory TermsResponse.fromJson(Map<String, dynamic> json) {
    return TermsResponse(
      title: json["title"] ?? "",
      content: json["content"] ?? "",
    );
  }
}
