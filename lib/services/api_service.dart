import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:zatch/model/CartApiResponse.dart';
import 'package:zatch/model/ExploreApiRes.dart';
import 'package:zatch/model/LiveSessionResponse.dart';
import 'package:zatch/model/SaveBitResponse.dart';
import 'package:zatch/model/SaveProductResponse.dart';
import 'package:zatch/model/SearchHistoryResponse.dart';
import 'package:zatch/model/SearchResultUser.dart';
import 'package:zatch/model/TrendingBit.dart';
import 'package:zatch/model/UpdateCartApiResponse.dart';
import 'package:zatch/model/UpdateProfileResponse.dart';
import 'package:zatch/model/api_response.dart';
import 'package:zatch/model/bit_details.dart';
import 'package:zatch/model/coupon_model.dart';
import 'package:zatch/model/follow_response.dart';
import 'package:zatch/model/live_comment.dart';
import 'package:zatch/model/live_session_res.dart';
import 'package:zatch/model/notification_model.dart';
import 'package:zatch/model/order_model.dart';
import 'package:zatch/model/register_req.dart';
import 'package:zatch/model/register_response_model.dart';
import 'package:zatch/model/login_request.dart';
import 'package:zatch/model/login_response.dart';
import 'package:zatch/model/share_live_response.dart';
import 'package:zatch/model/share_product_response.dart';
import 'package:zatch/model/share_profile_response.dart';
import 'package:zatch/model/toggle_save_bit.dart';
import 'package:zatch/model/top_pick_res.dart';
import 'package:zatch/model/user_profile_response.dart';
import 'package:zatch/model/verify_otp_request.dart';
import 'package:zatch/model/verify_otp_response.dart';
import 'package:zatch/model/otp_req.dart';
import 'package:zatch/model/otp_response_model.dart';
import 'package:zatch/model/categories_response.dart';
import 'package:zatch/model/bargain_model.dart';
import 'package:zatch/utils/local_storage.dart';
import 'package:zatch/model/product_response.dart';

import '../model/address_model.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();

  factory ApiService() => _instance;

  ApiService._internal() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (e, handler) async {
          if (e.response?.statusCode == 401) {
            _token = null;
            _dio.options.headers.remove("Authorization");
            await LocalStorage.clearToken();

            if (navigatorKey.currentState != null) {
              Navigator.pushNamedAndRemoveUntil(
                navigatorKey.currentState!.context,
                '/login',
                (route) => false,
              );
            }
          }
          handler.next(e);
        },
      ),
    );
  }

  static const String baseUrl = "https://zatch-e9ye.onrender.com/api/v1";
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      headers: {"Content-Type": "application/json"},
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 40),
      sendTimeout: const Duration(seconds: 15),
    ),
  );

  String? _token;

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  Future<void> init() async {
    final token = await LocalStorage.getSavedToken();
    if (token != null && token.isNotEmpty) {
      setToken(token);
    }
  }

  void setToken(String token) {
    if (token.isEmpty) return; 
    _token = token;
    _dio.options.headers["Authorization"] = "Bearer $token";
    LocalStorage.saveToken(token); 
  }

  dynamic _decodeResponse(dynamic data) {
    if (data is String) {
      try {
        return jsonDecode(data.substring(data.indexOf('{')));
      } catch (_) {
        return jsonDecode(data);
      }
    }
    return data;
  }

  Future<void> logoutUser() async {
    try {
      await _dio.post("/user/logout");
    } catch (_) {
    }

    _token = null;
    _dio.options.headers.remove("Authorization");
    await LocalStorage.clearToken();

    if (navigatorKey.currentState != null) {
      Navigator.pushNamedAndRemoveUntil(
        navigatorKey.currentState!.context,
        '/login',
        (route) => false,
      );
    }
  }

  Future<dynamic> get(String path) async {
    try {
      final response = await _dio.get(path);
      return _decodeResponse(response.data);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<dynamic> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return _decodeResponse(response.data);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  String _handleError(DioException e) {
    if (e.response?.statusCode == 401) {
      _token = null;
      _dio.options.headers.remove("Authorization");
      LocalStorage.clearToken();
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return "Connection timeout. Please try again.";
      case DioExceptionType.sendTimeout:
        return "Send timeout. Please try again.";
      case DioExceptionType.receiveTimeout:
        return "Receive timeout. Please try again.";

      case DioExceptionType.badResponse:
        return e.response?.data["message"] ?? "Server error occurred.";
      case DioExceptionType.cancel:
        return "Request cancelled.";
      case DioExceptionType.unknown:
      default:
        return "Connection error. Please check your internet.";
    }
  }

  Future<RegisterResponse> registerUser(RegisterRequest request) async {
    try {
      final response = await _dio.post(
        "/user/register",
        data: request.toJson(),
      );
      final data = _decodeResponse(response.data);
      final registerResponse = RegisterResponse.fromJson(data);
      setToken(registerResponse.token);
      return registerResponse;
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<LoginResponse> loginUser(LoginRequest request) async {
    try {
      final response = await _dio.post("/user/login", data: request.toJson());
      final data = _decodeResponse(response.data);
      final loginResponse = LoginResponse.fromJson(data);
      setToken(loginResponse.token);
      return loginResponse;
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<VerifyApiResponse> verifyOtp(VerifyOtpRequest request) async {
    try {
      final response = await _dio.post(
        "/twilio-sms/verify-otp",
        data: request.toJson(),
      );
      final data = _decodeResponse(response.data);
      return VerifyApiResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<ResponseApi> sendOtp(SendOtpRequest request) async {
    try {
      final response = await _dio.post(
        "/twilio-sms/send-otp",
        data: request.toJson(),
      );
      final data = _decodeResponse(response.data);
      return ResponseApi.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<UserProfileResponse> getUserProfile() async {
    try {
      final response = await _dio.get("/user/profile");
      final data = _decodeResponse(response.data);
      return UserProfileResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<List<Category>> getCategories() async {
    try {
      final response = await _dio.get("/category");
      final data = _decodeResponse(response.data);
      final categoriesResponse = CategoriesResponse.fromJson(data);
      return categoriesResponse.categories;
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<LiveSessionsResponse> getLiveSessions() async {
    const String liveSessionsEndpoint = "/live/sessions";
    try {
      final response = await _dio.get(liveSessionsEndpoint);
      final data = _decodeResponse(response.data);
      if (data is Map<String, dynamic>) {
        return LiveSessionsResponse.fromJson(data);
      } else {
        throw Exception("Invalid data format received for live sessions.");
      }
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<JoinLiveSessionResponse> joinLiveSession(String sessionId) async {
    final String joinEndpoint = "/live/session/$sessionId/join";
    try {
      final Response response = await _dio.get(joinEndpoint);
      final data = _decodeResponse(response.data);
      return JoinLiveSessionResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<FollowResponse> toggleFollowUser(String targetUserId) async {
    try {
      final response = await _dio.post("/user/$targetUserId/toggleFollow");
      final data = _decodeResponse(response.data);
      return FollowResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<List<Product>> getProducts() async {
    try {
      final response = await _dio.get("/product/products");
      final data = _decodeResponse(response.data);
      final productResponse = ProductResponse.fromJson(data);
      return productResponse.products;
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<BitDetails> fetchBitDetails(String bitId) async {
    final response = await _dio.get('/bits/$bitId');
    if (response.statusCode == 200 && response.data['success'] == true) {
      final bitResponse = BitDetailsResponse.fromJson(response.data);
      return bitResponse.bit;
    } else {
      throw Exception('Failed to load bit details');
    }
  }

  Future<String> getTermsAndConditions() async {
    try {
      final response = await _dio.get("/terms-and-conditions");
      return response.data.toString(); 
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<String> getPrivacyPolicy() async {
    try {
      final response = await _dio.get("/privacy-policy");
      return response.data.toString(); 
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<Map<String, dynamic>> sendEmailOtp(String email) async {
    try {
      final response = await _dio.post(
        "/brevo/send-email-otp",
        data: {"email": email},
      );
      return _decodeResponse(response.data);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<Map<String, dynamic>> verifyEmailOtp(String otp) async {
    try {
      final response = await _dio.post(
        "/brevo/verify-email-otp",
        data: {"otp": otp},
      );
      return _decodeResponse(response.data);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<Map<String, dynamic>> sendPhoneOtp(
    String countryCode,
    String phoneNumber,
  ) async {
    try {
      final response = await _dio.post(
        "/twilio-sms/send-otp",
        data: {"countryCode": countryCode, "phoneNumber": phoneNumber},
      );
      return _decodeResponse(response.data);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<Map<String, dynamic>> verifyPhoneOtp(
    String countryCode,
    String phoneNumber,
    String otp,
  ) async {
    try {
      final response = await _dio.post(
        "/twilio-sms/verify-otp",
        data: {
          "countryCode": countryCode,
          "phoneNumber": phoneNumber,
          "otp": otp,
        },
      );
      return _decodeResponse(response.data);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<Map<String, dynamic>> sendBothOtp(
    String email,
    String countryCode,
    String phoneNumber,
  ) async {
    try {
      final response = await _dio.post(
        "/otp/send-both",
        data: {
          "email": email,
          "countryCode": countryCode,
          "phoneNumber": phoneNumber,
        },
      );
      return _decodeResponse(response.data);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<Map<String, dynamic>> verifyBothOtp({
    required String email,
    required String emailOtp,
    required String countryCode,
    required String phoneNumber,
    required String phoneOtp,
  }) async {
    try {
      final response = await _dio.post(
        "/otp/verify-both",
        data: {
          "email": email,
          "emailOtp": emailOtp,
          "countryCode": countryCode,
          "phoneNumber": phoneNumber,
          "phoneOtp": phoneOtp,
        },
      );
      return _decodeResponse(response.data);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<UpdateProfileResponse> updateUserProfile({
    String? username,
    String? gender,
    String? dob,
    String? email,
    String? phone,
    String? countryCode,
    String? otp,
    String? otpType,
    dynamic profilePic, 
    bool? removeProfilePic, 
  }) async {
    try {
      final Map<String, dynamic> fields = {};

      if (username != null && username.isNotEmpty) fields['username'] = username;
      if (gender != null && gender.isNotEmpty) fields['gender'] = gender;
      if (dob != null && dob.isNotEmpty) fields['dob'] = dob;
      if (email != null && email.isNotEmpty) fields['email'] = email;
      if (phone != null && phone.isNotEmpty) {
        fields['phone'] = phone;
        if (countryCode != null && countryCode.isNotEmpty) {
          fields['countryCode'] = countryCode;
        }
      }

      if ((email != null || phone != null) && otp != null && otpType != null) {
        fields['otp'] = otp;
        fields['otpType'] = otpType;
      }

      // Updated Logic for profilePic removal per instruction:
      // If removeProfilePic is true, send it as true and OMIT profilePic.
      // Otherwise, send profilePic if provided.
      if (removeProfilePic == true) {
        fields['removeProfilePic'] = 'true'; 
      } else if (profilePic != null) {
        fields['profilePic'] = profilePic;
      }

      final formData = FormData.fromMap(fields);

      final response = await _dio.put(
        "/user/profile-update",
        data: formData,
        options: Options(contentType: "multipart/form-data"),
      );

      return UpdateProfileResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<ShareProfileResponse> shareUserProfile(String userId) async {
    try {
      final response = await _dio.post("/user/share-profile/$userId");
      final data = _decodeResponse(response.data);
      return ShareProfileResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<Product> getSingleProduct(String productId) async {
    try {
      final response = await _dio.get("/product/$productId");
      final data = _decodeResponse(response.data);
      if (data["success"] == true && data["product"] != null) {
        return Product.fromJson(data["product"]);
      } else {
        throw Exception(data["message"] ?? "Failed to fetch product");
      }
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<List<Product>> getTopPicks() async {
    try {
      final response = await _dio.get("/product/top-picks");
      final data = _decodeResponse(response.data);
      final topPickResponse = TopPicksResponse.fromJson(data);
      if (topPickResponse.success) {
        return topPickResponse.products;
      } else {
        throw Exception(topPickResponse.message);
      }
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<Product> getProductById(String productId) async {
    try {
      final response = await _dio.get("/product/$productId");
      if (response.statusCode == 200 && response.data["success"] == true) {
        return Product.fromJson(response.data["product"]);
      } else {
        throw Exception(response.data["message"] ?? "Failed to fetch product");
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data is Map && e.response?.data["message"] != null
              ? e.response?.data["message"]
              : e.message ?? "API Error";
      throw Exception(errorMessage);
    }
  }

  Future<int> likeProduct(String productId) async {
    try {
      final response = await _dio.post("/product/$productId/like");
      final data = response.data;
      if (data['success'] == true) {
        return data['likeCount'] ?? 0;
      } else {
        throw Exception(data['message'] ?? 'Failed to like product');
      }
    } catch (e) {
      throw Exception('Error liking product: $e');
    }
  }

  Future<ApiResponse> getAllUsers() async {
    try {
      final response = await _dio.get("/user/all-users");
      final data = _decodeResponse(response.data);
      return ApiResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<List<TrendingBit>> fetchTrendingBits() async {
    try {
      final response = await _dio.get("/trending/trending");
      final Map<String, dynamic> data = response.data;
      final List<dynamic> liveJson = data['live'] as List<dynamic>? ?? [];
      final List<dynamic> bitsJson = data['bits'] as List<dynamic>? ?? [];
      final List<dynamic> combinedJson = [...liveJson, ...bitsJson];
      return combinedJson.map((json) => TrendingBit.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception("Failed to fetch trending bits due to a network error.");
    }
  }

  Future<SearchHistoryResponse> getUserSearchHistory() async {
    try {
      final response = await _dio.get("/user/search-history");
      final dynamic data = _decodeResponse(response.data);
      if (data is List) {
        final List<Map<String, dynamic>> formattedList = data.map((item) {
              if (item is Map<String, dynamic>) return item;
              return {
                "query": item.toString(),
                "createdAt": DateTime.now().toIso8601String(),
                "_id": DateTime.now().millisecondsSinceEpoch.toString(),
              };
            }).toList();
        return SearchHistoryResponse.fromJson({
          "success": true,
          "message": "Fetched successfully",
          "searchHistory": formattedList,
        });
      }
      return SearchHistoryResponse.fromJson(data);
    } on DioException catch (e) {
      return SearchHistoryResponse(success: false, message: _handleError(e), searchHistory: []);
    }
  }

  Future<List<Bits>> getExploreBits() async {
    try {
      final response = await _dio.get("/bits/list");
      final data = _decodeResponse(response.data);
      final bitsResponse = ExploreApiResponse.fromJson(data);
      return bitsResponse.bits;
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<SearchResult> search(String query) async {
    if (query.isEmpty) return SearchResult(success: false, message: "Empty query", products: [], people: [], all: []);
    try {
      final response = await _dio.get("/search/search", queryParameters: {"query": query});
      final data = _decodeResponse(response.data);
      return SearchResult.fromJson(data);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<UserProfileResponse> getUserProfileById(String userId) async {
    try {
      final response = await _dio.get("/user/profile/$userId");
      if (response.statusCode == 200 && response.data["success"] == true) {
        return UserProfileResponse.fromJson(response.data);
      } else {
        throw Exception(response.data["message"] ?? "Failed to fetch profile");
      }
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<Map<String, dynamic>> changePassword({
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _dio.put(
        "/user/change-password",
        data: {'newPassword': newPassword, 'confirmPassword': confirmPassword},
        options: Options(headers: {'Authorization': 'Bearer $_token'}),
      );
      dynamic decoded = _decodeResponse(response.data);
      if (decoded is Map<String, dynamic>) return decoded;
      return {'success': false, 'message': 'Unexpected response format.'};
    } on DioException catch (e) {
      return {'success': false, 'message': e.response?.data is Map ? e.response?.data['message'] ?? 'Failed' : _handleError(e)};
    }
  }

  Future<Map<String, dynamic>> registerSellerStep({required int step, Map<String, dynamic>? payload}) async {
    try {
      final Map<String, dynamic> body = {"step": step};
      if (payload != null) body.addAll(payload);
      final response = await _dio.post("/user/seller/register", data: body);
      final data = _decodeResponse(response.data);
      return data is Map<String, dynamic> ? data : {"success": false};
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<String> getSellerTermsAndConditions() async {
    try {
      final response = await _dio.get("/user/seller/terms-and-conditions");
      return response.data.toString();
    } catch (e) {
      throw Exception("Error fetching terms: $e");
    }
  }

  Future<Map<String, dynamic>> submitProductStep(Map<String, dynamic> payload) async {
    try {
      final response = await _dio.post("/product/create", data: payload);
      final data = _decodeResponse(response.data);
      if (data is Map<String, dynamic> && data['success'] == true) return data;
      throw Exception(data['message'] ?? 'API error');
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<ToggleSaveResponse> toggleBitSavedStatus(String bitId) async {
    try {
      final response = await _dio.post("/bits/$bitId/save");
      final data = _decodeResponse(response.data);
      if (data['success'] == true) return ToggleSaveResponse.fromJson(data);
      throw Exception(data['message'] ?? 'Failed');
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<Map<String, dynamic>> toggleLike(String bitId) async {
    try {
      final response = await _dio.post("/bits/$bitId/toggleLike");
      final data = _decodeResponse(response.data);
      if (data['success'] == true) {
        final int likeCount = data['likeCount'] as int;
        final bool isLiked = (data['message'] as String).toLowerCase().contains("liked");
        return {'likeCount': likeCount, 'isLiked': isLiked};
      }
      throw Exception(data['message'] ?? 'Failed');
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<int> toggleLikeProduct(String productId) async {
    try {
      final response = await _dio.post("/product/$productId/like");
      final data = _decodeResponse(response.data);
      if (data['success'] == true) return data['likeCount'] as int;
      throw Exception(data['message'] ?? 'Failed');
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<void> saveProduct(String productId) async {
    try {
      await _dio.post("/product/$productId/save");
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<SaveProductResponse> toggleSaveProduct(String productId) async {
    try {
      final response = await _dio.post("/product/$productId/save");
      final data = _decodeResponse(response.data);
      return SaveProductResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<SaveBitResponse> toggleSaveBit(String bitId) async {
    try {
      final response = await _dio.post("/bits/$bitId/save");
      final data = _decodeResponse(response.data);
      return SaveBitResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<Comment> addCommentToBit(String bitId, String text) async {
    try {
      final response = await _dio.post("/bits/$bitId/comments", data: {'text': text});
      final data = _decodeResponse(response.data);
      if (data is Map<String, dynamic> && data['success'] == true) return Comment.fromJson(data['comment']);
      throw Exception("Failed to parse comment.");
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<Map<String, dynamic>> toggleLiveSessionLike(String sessionId) async {
    try {
      final response = await _dio.post("/live/session/$sessionId/like");
      final data = _decodeResponse(response.data);
      if (data is Map<String, dynamic> && data['success'] == true) {
        return {'likeCount': data['likeCount'] ?? 0, 'isLiked': data['hasLiked'] ?? false, 'triggerAnimation': data['triggerAnimation'] ?? false};
      }
      throw Exception(data['message'] ?? "Failed.");
    } on DioException catch (e) {
      if (e.response?.statusCode == 400 && e.response?.data['message'] == "Already liked") {
        return {'likeCount': e.response?.data['likeCount'] ?? 0, 'isLiked': true, 'triggerAnimation': false};
      }
      throw Exception(_handleError(e));
    }
  }

  Future<SessionDetails> getLiveSessionDetails(String sessionId) async {
    try {
      final Response response = await _dio.get("/live/session/$sessionId/details");
      final data = _decodeResponse(response.data);
      if (data is Map<String, dynamic> && data['success'] == true) return SessionDetails.fromJson(data['sessionDetails']);
      throw Exception(data['message'] ?? "Failed.");
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<LiveCommentResponse> getLiveSessionComments(String sessionId, {int limit = 20, int offset = 0}) async {
    try {
      final response = await _dio.get("/live/session/$sessionId/comments?limit=$limit&offset=$offset");
      final data = _decodeResponse(response.data);
      if (data is Map<String, dynamic> && data['success'] == true) return LiveCommentResponse.fromJson(data);
      throw Exception("Failed.");
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<LiveComment> postLiveComment(String sessionId, String text) async {
    try {
      final response = await _dio.post("/live/session/$sessionId/comment", data: {'text': text});
      final data = _decodeResponse(response.data);
      if (data is Map<String, dynamic> && data['success'] == true) {
        if (data['comment'] is Map<String, dynamic>) return LiveComment.fromJson(data['comment']);
        throw Exception("API response missing comment.");
      }
      throw Exception(data['message'] ?? "Failed.");
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<ShareProductResponse> shareBit(String bitId) async {
    try {
      final response = await _dio.post("/bits/$bitId/share");
      final data = _decodeResponse(response.data);
      return ShareProductResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<CartModel?> getCart() async {
    try {
      final response = await _dio.get("/cart");
      final data = _decodeResponse(response.data);
      final cartResponse = CartApiResponse.fromJson(data);
      return cartResponse.success ? cartResponse.cart : throw Exception(data['message'] ?? "Failed");
    } on DioException catch (e) {
      return e.response?.statusCode == 404 ? null : throw Exception(_handleError(e));
    }
  }

  Future<UpdatedCartModel?> updateCartItem({required String productId, required int quantity, String? color, String? size}) async {
    try {
      final payload = {'productId': productId, 'qty': quantity};
      if (color != null) payload['color'] = color;
      if (size != null) payload['size'] = size;
      final response = await _dio.post("/cart/update", data: payload);
      final data = _decodeResponse(response.data);
      final updateResponse = UpdateCartApiResponse.fromJson(data);
      return updateResponse.success ? updateResponse.cart : throw Exception(updateResponse.message);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<void> removeCartItem({required String productId}) async {
    try {
      final response = await _dio.post("/cart/remove", queryParameters: {"productId": productId});
      final data = _decodeResponse(response.data);
      if (data is Map<String, dynamic> && data['success'] == true) return;
      throw Exception(data['message'] ?? "Failed.");
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<Map<String, dynamic>> joinLiveSessionWithToken(String sessionId) async {
    try {
      final response = await _dio.post("/live/session/$sessionId/join");
      final data = _decodeResponse(response.data);
      return (data['success'] == true && data['session'] != null) ? data : throw Exception(data['message'] ?? "Failed.");
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<Map<String, dynamic>> getLiveSessionFullDetails(String sessionId) async {
    try {
      final response = await _dio.get("/live/session/$sessionId/details");
      final data = _decodeResponse(response.data);
      return (data['success'] == true && data['sessionDetails'] != null) ? data : throw Exception(data['message'] ?? "Failed.");
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }
  Future<ShareLiveResponse> shareLiveSession(String sessionId) async {
    try {
      final response = await _dio.get("/live/session/$sessionId/share");
      final data = _decodeResponse(response.data);
      return ShareLiveResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }
  Future<List<OrderModel>> getMyOrders({String? status}) async {
    try {
      final queryParams = status != null ? {'status': status} : <String, dynamic>{};
      final response = await _dio.get('/orders/my-orders', queryParameters: queryParams);
      if (response.statusCode == 200 && response.data['success'] == true) {
        return (response.data['orders'] as List).map((json) => OrderModel.fromJson(json)).toList();
      }
      throw Exception("Failed.");
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<Map<String, dynamic>> createDirectOrder({required String addressId, required String paymentMethod, required List<Map<String, dynamic>> items, String? buyerNote}) async {
    try {
      final body = {"addressId": addressId, "paymentMethod": paymentMethod, "items": items, "buyerNote": buyerNote};
      final response = await _dio.post("/orders/create-direct", data: body);
      final data = _decodeResponse(response.data);
      return data['success'] == true ? data : throw Exception(data['message'] ?? 'Failed');
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<Map<String, dynamic>> createOrder({required String addressId, required String paymentMethod, String? buyerNote, String? liveSessionId, String? bitId}) async {
    try {
      final body = {"addressId": addressId, "paymentMethod": paymentMethod, "buyerNote": buyerNote, if (liveSessionId != null) "liveSessionId": liveSessionId, if (bitId != null) "bitId": bitId};
      final response = await _dio.post("/orders/create", data: body);
      final data = _decodeResponse(response.data);
      return data['success'] == true ? data : throw Exception(data['message'] ?? 'Failed');
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<List<Address>> getAllAddresses() async {
    try {
      final response = await _dio.get("/address");
      final data = _decodeResponse(response.data);
      if (data is List) return data.map((json) => Address.fromJson(json)).toList();
      if (data is Map<String, dynamic> && data['addresses'] is List) return (data['addresses'] as List).map((json) => Address.fromJson(json)).toList();
      return [];
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<Address> saveAddress({String? addressId, required String label, required String type, required String line1, String? line2, required String city, required String state, required String pincode, required String phone, double? lat, double? lng}) async {
    try {
      final payload = {'label': label, 'type': type, 'line1': line1, 'city': city, 'state': state, 'pincode': pincode, 'phone': phone, if (line2 != null) 'line2': line2, if (lat != null) 'lat': lat, if (lng != null) 'lng': lng};
      final response = addressId != null ? await _dio.put("/address/$addressId", data: payload) : await _dio.post("/address/save", data: payload);
      final data = _decodeResponse(response.data);
      return (data['success'] == true && data['address'] != null) ? Address.fromJson(data['address']) : throw Exception(data['message'] ?? 'Failed');
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<Map<String, dynamic>> geocodeAddress(double lat, double lng) async {
    try {
      final response = await _dio.post("/address/geocode", data: {'lat': lat, 'lng': lng});
      final data = _decodeResponse(response.data);
      return (data['success'] == true && data['address'] != null) ? data['address'] : throw Exception(data['message'] ?? 'Failed');
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<bool> deleteAddress(String addressId) async {
    try {
      final response = await _dio.delete("/address/$addressId");
      final data = _decodeResponse(response.data);
      return data['success'] == true;
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<List<Coupon>> getCoupons() async {
    try {
      final response = await _dio.get("/coupons/list");
      final data = _decodeResponse(response.data);
      return (data['success'] == true && data['coupons'] is List) ? (data['coupons'] as List).map((e) => Coupon.fromJson(e)).toList() : [];
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<Map<String, dynamic>> applyCoupon({required String couponId, required String code, required double cartTotal, required List<String> productIds}) async {
    try {
      final response = await _dio.post("/coupons/apply/$couponId", data: {"code": code, "cartTotal": cartTotal, "productIds": productIds});
      final data = _decodeResponse(response.data);
      return data['success'] == true ? data : throw Exception(data['message'] ?? "Failed");
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<List<dynamic>> getPreferenceCategories() async {
    try {
      final response = await _dio.get("/preference/categories");
      final data = _decodeResponse(response.data);
      return (data['success'] == true && data['categories'] is List) ? data['categories'] : [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> getUserPreferences() async {
    try {
      final response = await _dio.get("/preference");
      final data = _decodeResponse(response.data);
      return (data['success'] == true && data['preferences'] != null) ? data['preferences'] : {};
    } on DioException catch (e) {
      return e.response?.statusCode == 404 ? {} : throw Exception(_handleError(e));
    }
  }

  Future<Map<String, dynamic>> saveUserPreferences(List<String> categories) async {
    try {
      final response = await _dio.post("/preference/save", data: {"categories": categories});
      final data = _decodeResponse(response.data);
      return data['success'] == true ? data : throw Exception(data['message'] ?? "Failed");
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<BargainDetailResponse> getBargainDetails(String bargainId) async {
    try {
      final response = await _dio.get("/bargains/$bargainId");
      return BargainDetailResponse.fromJson(_decodeResponse(response.data));
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<CreateBargainResponse> createBargain({required String productId, required double offeredPrice, String? color, String? size, int quantity = 1, String? buyerNote}) async {
    try {
      final payload = {"productId": productId, "offeredPrice": offeredPrice, "variant": {if (color != null) "color": color, if (size != null) "size": size}, "quantity": quantity, if (buyerNote != null) "buyerNote": buyerNote};
      final response = await _dio.post("/bargains/create", data: payload);
      return CreateBargainResponse.fromJson(_decodeResponse(response.data));
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) return CreateBargainResponse.fromJson(_decodeResponse(e.response?.data));
      throw Exception(_handleError(e));
    }
  }

  Future<BargainDetailResponse> sendBuyerCounter(String bargainId, {required double counterPrice, String? message}) async {
    try {
      final response = await _dio.post("/bargains/$bargainId/buyer-counter", data: {"counterPrice": counterPrice, "message": message});
      return BargainDetailResponse.fromJson(_decodeResponse(response.data));
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<bool> rejectCounter(String bargainId) async {
    try {
      final response = await _dio.post("/bargains/$bargainId/reject-counter");
      return _decodeResponse(response.data)['success'] == true;
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<bool> acceptCounter(String bargainId) async {
    try {
      final response = await _dio.post("/bargains/$bargainId/accept-counter");
      return _decodeResponse(response.data)['success'] == true;
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<BargainListResponse> getMyBargains() async {
    try {
      final response = await _dio.get("/bargains/buyer/my-bargains");
      return BargainListResponse.fromJson(_decodeResponse(response.data));
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<OrderModel> cancelOrder(String orderId, String reason) async {
    try {
      final response = await _dio.post("/orders/$orderId/cancel", data: {"reason": reason});
      final data = _decodeResponse(response.data);
      return (data['success'] == true && data['order'] != null) ? OrderModel.fromJson(data['order']) : throw Exception(data['message'] ?? 'Failed');
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<Map<String, String>> generateInvoice(String orderId) async {
    try {
      final response = await _dio.get("/orders/$orderId/generate-invoice");
      final dynamic raw = response.data;
      late final Map<String, dynamic> data;
      if (raw is String) data = jsonDecode(raw);
      else if (raw is Map<String, dynamic>) data = raw;
      else throw Exception('Invalid format');
      if (data['success'] == true && data['invoice'] is Map) {
        return (data['invoice'] as Map).map<String, String>((key, value) => MapEntry(key.toString(), value.toString()));
      }
      throw Exception(data['message'] ?? 'Failed');
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<NotificationResponse> getNotifications({int page = 1, int limit = 20}) async {
    try {
      final response = await _dio.get("/notifications", queryParameters: {"page": page, "limit": limit});
      return NotificationResponse.fromJson(_decodeResponse(response.data));
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<bool> markAllNotificationsAsRead() async {
    try {
      final response = await _dio.get("/notifications/read-all");
      return _decodeResponse(response.data)['success'] == true;
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<bool> deleteNotification(String notificationId) async {
    try {
      final response = await _dio.delete("/notifications/$notificationId");
      return _decodeResponse(response.data)['success'] == true;
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }
  Future<ShareProductResponse> shareProduct(String productId) async {
    try {
      final response = await _dio.post("/product/$productId/share");
      final data = _decodeResponse(response.data);
      return ShareProductResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }
}
