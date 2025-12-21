import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:zatch_app/model/CartApiResponse.dart';
import 'package:zatch_app/model/ExploreApiRes.dart';
import 'package:zatch_app/model/SaveBitResponse.dart';
import 'package:zatch_app/model/SaveProductResponse.dart';
import 'package:zatch_app/model/SearchHistoryResponse.dart';
import 'package:zatch_app/model/SearchResultUser.dart';
import 'package:zatch_app/model/TrendingBit.dart';
import 'package:zatch_app/model/UpdateCartApiResponse.dart';
import 'package:zatch_app/model/UpdateProfileResponse.dart';
import 'package:zatch_app/model/api_response.dart';
import 'package:zatch_app/model/bit_details.dart';
import 'package:zatch_app/model/follow_response.dart';
import 'package:zatch_app/model/golivenowresponsemodel.dart';
import 'package:zatch_app/model/golivesteponeresponse.dart';
import 'package:zatch_app/model/golivestepthreeresponse.dart';
import 'package:zatch_app/model/live_comment.dart';
import 'package:zatch_app/model/live_details_response.dart';
import 'package:zatch_app/model/live_session_res.dart';
import 'package:zatch_app/model/livesummarymodel.dart';
import 'package:zatch_app/model/product_response.dart';
import 'package:zatch_app/model/product_response_seller.dart';
import 'package:zatch_app/model/register_req.dart';
import 'package:zatch_app/model/register_response_model.dart';
import 'package:zatch_app/model/login_request.dart';
import 'package:zatch_app/model/login_response.dart';
import 'package:zatch_app/model/share_profile_response.dart';
import 'package:zatch_app/model/shareliveresponsemodel.dart';
import 'package:zatch_app/model/toggle_save_bit.dart';
import 'package:zatch_app/model/top_pick_res.dart' hide Product;
import 'package:zatch_app/model/user_profile_model.dart';
import 'package:zatch_app/model/user_profile_response.dart';
import 'package:zatch_app/model/verify_otp_request.dart';
import 'package:zatch_app/model/verify_otp_response.dart';
import 'package:zatch_app/model/otp_req.dart';
import 'package:zatch_app/model/otp_response_model.dart';
import 'package:zatch_app/model/categories_response.dart';
import 'package:zatch_app/utils/local_storage.dart';

import '../model/bit_response.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();

  factory ApiService() => _instance;

  ApiService._internal() {
    // Add interceptor for 401
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (e, handler) async {
          if (e.response?.statusCode == 401) {
            // Unauthorized → force logout
            _token = null;
            _dio.options.headers.remove("Authorization");
            await LocalStorage.clearToken();

            // Navigate to login page if possible
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
      // connectTimeout: const Duration(seconds: 15),
      // receiveTimeout: const Duration(seconds: 40),
      // sendTimeout: const Duration(seconds: 15),
    ),
  );

  String? _token;

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// Initialize service: load token from storage if available
  Future<void> init() async {
    final token = await LocalStorage.getSavedToken();
    if (token != null && token.isNotEmpty) {
      setToken(token);
    }
  }

  /// Save token and attach to headers
  void setToken(String token) {
    if (token.isEmpty) return; // avoid overwriting with empty string
    _token = token;
    _dio.options.headers["Authorization"] = "Bearer $token";
    LocalStorage.saveToken(token); // persist for next launch
  }

  /// Common response decoder
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

  /// LOGOUT
  Future<void> logoutUser() async {
    try {
      await _dio.post("/user/logout");
    } catch (_) {
      // ignore logout errors
    }

    // Clear token and headers
    _token = null;
    _dio.options.headers.remove("Authorization");
    await LocalStorage.clearToken();

    // Navigate to login page safely
    if (navigatorKey.currentState != null) {
      Navigator.pushNamedAndRemoveUntil(
        navigatorKey.currentState!.context,
        '/login',
        (route) => false,
      );
    }
  }

  // Example GET method
  Future<dynamic> get(String path) async {
    try {
      final response = await _dio.get(path);
      return _decodeResponse(response.data);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // Example POST method
  Future<dynamic> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return _decodeResponse(response.data);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // Error handler
  String _handleError(DioException e) {
    if (e.response?.statusCode == 401) {
      // Unauthorized → force logout
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

  /// REGISTER
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

  /// LOGIN
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

  /// VERIFY OTP
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

  /// SEND OTP
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

      // Print the raw response data from API
      print("🔹 Raw API Response: ${response.data}");

      final data = _decodeResponse(response.data);

      // Print the decoded JSON (after your _decodeResponse helper)
      print("🔹 Decoded Data: $data");

      // Create model
      final userProfile = UserProfileResponse.fromJson(data);

      // Print the parsed object values
      print("✅ Parsed UserProfileResponse:");
      print("   Username: ${userProfile.user.username}");
      print("   Email: ${userProfile.user.email}");
      print("   Followers: ${userProfile.user.followerCount}");
      print("   Profile Pic: ${userProfile.user.profilePic.url}");

      return userProfile;
    } on DioException catch (e) {
      print("❌ DioException: ${e.response?.data}");
      throw Exception(_handleError(e));
    } catch (e, st) {
      print("❌ Unexpected Error: $e");
      print(st);
      rethrow;
    }
  }

  /// CATEGORIES
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
        print(
          "Error: Expected a Map for LiveSessionsResponse but got ${data.runtimeType}",
        );
        throw Exception("Invalid data format received for live sessions.");
      }
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    } catch (e) {
      print("Error fetching live sessions: $e");
      throw Exception("Failed to fetch live sessions: ${e.toString()}");
    }
  }

  Future<dynamic> joinLiveSession(String sessionId) async {
    final String joinEndpoint = "/live/session/$sessionId/join";
    try {
      debugPrint("🔹 Joining live session with ID: $sessionId");
      final response = await _dio.post(joinEndpoint);
      debugPrint("Successfully joined live session $sessionId");
      return _decodeResponse(response.data);
    } on DioException catch (e) {
      debugPrint("joinLiveSession DioException: ${e.response?.data}");
      throw Exception(_handleError(e));
    } catch (e) {
      debugPrint("Unexpected error joining live session: $e");
      throw Exception(
        "An unexpected error occurred while joining the session.",
      );
    }
  }

  /// TOGGLE FOLLOW
  Future<FollowResponse> toggleFollowUser(String targetUserId) async {
    try {
      debugPrint("🔹 Toggling follow for userId: $targetUserId");
      final response = await _dio.post("/user/$targetUserId/toggleFollow");

      final data = _decodeResponse(response.data);
      print("✅ [API_SERVICE] Decoded Data for toggleFollow: $data");
      return FollowResponse.fromJson(data);
    } on DioException catch (e) {
      debugPrint("toggleFollowUser DioException: ${e.response?.data}");
      debugPrint("toggleFollowUser Status code: ${e.response?.statusCode}");
      debugPrint("toggleFollowUser Error: ${e.message}");
      throw Exception(_handleError(e));
    }
  }

  /// PRODUCTS
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

  /// PRODUCTS
  Future<List<ProductItem>> getProductgolive() async {
    try {
      final response = await _dio.get("/product/products");

      final data =
          response.data is String
              ? _decodeResponse(response.data)
              : response.data;

      log("DECODED DATA: $data");

      final productResponse = ProductResponseSeller.fromJson(data);
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

  /// TERMS & CONDITIONS
  Future<String> getTermsAndConditions() async {
    try {
      final response = await _dio.get("/terms-and-conditions");
      return response.data.toString(); // HTML as string
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// PRIVACY POLICY
  Future<String> getPrivacyPolicy() async {
    try {
      final response = await _dio.get("/privacy-policy");
      return response.data.toString(); // HTML as string
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// Send OTP to email
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

  /// Verify OTP for email
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

  /// Send OTP to phone
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

  /// Verify OTP for phone
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

  /// Send OTPs for both email and phone
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

  /// Verify both OTPs
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
    String? name,
    String? gender,
    String? dob,
    String? email,
    String? phone,
    String? countryCode,
    String? otp,
    String? otpType, // "email", "phone", "both" or null
  }) async {
    try {
      final Map<String, dynamic> data = {};

      if (name != null && name.isNotEmpty) data['name'] = name;
      if (gender != null && gender.isNotEmpty) data['gender'] = gender;
      if (dob != null && dob.isNotEmpty) data['dob'] = dob;
      if (email != null && email.isNotEmpty) data['email'] = email;
      if (phone != null && phone.isNotEmpty) {
        data['phone'] = phone;
        if (countryCode != null && countryCode.isNotEmpty) {
          data['countryCode'] = countryCode;
        }
      }

      if ((email != null || phone != null) && otp != null && otpType != null) {
        data['otp'] = otp;
        data['otpType'] = otpType;
      }

      print("Update Profile Request Data: $data");

      final response = await _dio.put("/user/profile-update", data: data);

      print("Update Profile Response: ${response.data}");

      return UpdateProfileResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// SHARE PROFILE
  Future<ShareProfileResponse> shareUserProfile(String userId) async {
    try {
      final response = await _dio.get("/user/share-profile/$userId");
      final data = _decodeResponse(response.data);
      return ShareProfileResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// GET Single Product
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

  /// TOP PICKS
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
      final errorMessage =
          e.response?.data is Map && e.response?.data["message"] != null
              ? e.response?.data["message"]
              : e.message ?? "API Error";

      throw Exception(errorMessage);
    } catch (e) {
      throw Exception("Unexpected error: $e");
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
    } catch (e) {
      print("Error in getAllUsers: $e");
      throw Exception("Failed to fetch all users: ${e.toString()}");
    }
  }

  Future<List<TrendingBit>> fetchTrendingBits() async {
    try {
      // This endpoint returns both 'live' and 'bits' lists.
      final response = await _dio.get("/trending/trending");
      final Map<String, dynamic> data = response.data;
      final List<dynamic> liveJson = data['live'] as List<dynamic>? ?? [];
      final List<dynamic> bitsJson = data['bits'] as List<dynamic>? ?? [];
      final List<dynamic> combinedJson = [...liveJson, ...bitsJson];
      if (combinedJson.isNotEmpty) {
        return combinedJson
            .map((json) => TrendingBit.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        return [];
      }
    } on DioException catch (e) {
      debugPrint("DioException fetching trending bits: ${e.response?.data}");
      throw Exception("Failed to fetch trending bits due to a network error.");
    } catch (e) {
      debugPrint("Unexpected error fetching trending bits: $e");
      throw Exception("Failed to fetch trending bits: $e");
    }
  }

  /// Get the user's search history
  Future<SearchHistoryResponse> getUserSearchHistory() async {
    try {
      final response = await _dio.get("/user/search-history");
      final data = _decodeResponse(response.data);
      return SearchHistoryResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// Get popular/explore bits
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
    if (query.isEmpty) {
      return SearchResult(
        success: false,
        message: "Empty query",
        products: [],
        people: [],
        all: [],
      );
    }

    try {
      final response = await _dio.get(
        "/search/search",
        queryParameters: {"query": query},
      );
      final data = _decodeResponse(response.data);

      print("🔹 Search API Response: $data"); // debug log

      return SearchResult.fromJson(data);
    } on DioException catch (e) {
      final msg = _handleError(e);
      print("❌ Search API Error: $msg");
      throw Exception(msg);
    } catch (e) {
      print("❌ Search API Unexpected Error: $e");
      throw Exception("Unexpected error: $e");
    }
  }

  Future<UserProfileResponse> getUserProfileById(String userId) async {
    try {
      debugPrint("🔹 Fetching profile for userId: $userId");
      final response = await _dio.get("/user/profile/$userId");

      if (response.statusCode == 200 && response.data["success"] == true) {
        debugPrint("✅ Other user profile fetched");
        return UserProfileResponse.fromJson(response.data);
      } else {
        throw Exception(response.data["message"] ?? "Failed to fetch profile");
      }
    } on DioException catch (e) {
      debugPrint("❌ DioException (getUserProfileById): ${e.response?.data}");
      throw Exception(_handleError(e));
    }
  }

  /// CHANGE PASSWORD
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

      // Log response for debugging
      debugPrint("🔹 Change Password Response: ${response.data}");

      // Decode and normalize response
      dynamic decoded = response.data;
      if (decoded is String) {
        try {
          decoded = jsonDecode(decoded);
        } catch (_) {
          decoded = jsonDecode('{${decoded.trim()}}');
        }
      }

      if (decoded is Map<String, dynamic>) {
        return decoded;
      } else {
        return {
          'success': false,
          'message': 'Unexpected response format from server.',
        };
      }
    } on DioException catch (e) {
      debugPrint("❌ DioException (changePassword): ${e.response?.data}");
      return {
        'success': false,
        'message':
            e.response?.data is Map
                ? e.response?.data['message'] ?? 'Password change failed'
                : _handleError(e),
      };
    } catch (e) {
      debugPrint("❌ Unexpected error (changePassword): $e");
      return {'success': false, 'message': 'Unexpected error: $e'};
    }
  }

  Future<Map<String, dynamic>> registerSellerStep({
    required int step,
    Map<String, dynamic>? payload,
  }) async {
    try {
      final Map<String, dynamic> body = {"step": step};
      if (payload != null) {
        body.addAll(payload);
      }

      debugPrint("Seller Registration Step $step → $body");

      final response = await _dio.post("/user/seller/register", data: body);

      final data = _decodeResponse(response.data);
      debugPrint("Seller Registration Step $step Response: $data");

      return data is Map<String, dynamic> ? data : {"success": false};
    } on DioException catch (e) {
      debugPrint("Seller Registration Step $step Error: ${e.response?.data}");
      throw Exception(_handleError(e));
    }
  }

  Future<String> getSellerTermsAndConditions() async {
    try {
      final response = await _dio.get("/user/seller/terms-and-conditions");
      if (response.statusCode == 200) {
        return response.data.toString();
      } else {
        throw Exception("Failed to load terms and conditions");
      }
    } catch (e) {
      throw Exception("Error fetching terms: $e");
    }
  }

  Future<Map<String, dynamic>> submitProductStep(
    Map<String, dynamic> payload,
  ) async {
    try {
      debugPrint("🔹 Submitting Product Step ${payload['step']} -> $payload");

      const String productCreateUrl = "/product/create";

      final response = await _dio.post(productCreateUrl, data: payload);

      final data = _decodeResponse(response.data);
      debugPrint("✅ Product Step ${payload['step']} Response: $data");

      if (data is Map<String, dynamic> && data['success'] == true) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'API returned success=false');
      }
    } on DioException catch (e) {
      debugPrint(
        "❌ Product Step ${payload['step']} Error: ${e.response?.data}",
      );
      throw Exception(_handleError(e));
    }
  }

  Future<ToggleSaveResponse> toggleBitSavedStatus(String bitId) async {
    try {
      // The endpoint is `/bits/:bitId/save` as per your previous code
      final response = await _dio.post("/bits/$bitId/save");

      // Decode the response and create the model
      final data = _decodeResponse(response.data);

      // Check for success and return the parsed model
      if (data['success'] == true) {
        return ToggleSaveResponse.fromJson(data);
      } else {
        throw Exception(data['message'] ?? 'Failed to toggle save status');
      }
    } on DioException catch (e) {
      debugPrint("API Error toggling save status for bit $bitId: $e");
      throw Exception(_handleError(e));
    } catch (e) {
      debugPrint("Unexpected error toggling save status for bit $bitId: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> toggleLike(String bitId) async {
    try {
      final response = await _dio.post("/bits/$bitId/toggleLike");
      final data = _decodeResponse(response.data);
      if (data['success'] == true &&
          data.containsKey('likeCount') &&
          data.containsKey('message')) {
        final int likeCount = data['likeCount'] as int;
        final String message = data['message'] as String;
        final bool isLiked = message.toLowerCase().contains("liked");

        debugPrint(
          "Successfully toggled like for bit: $bitId. New count: $likeCount, isLiked: $isLiked",
        );
        return {'likeCount': likeCount, 'isLiked': isLiked};
      } else {
        // If the response format is unexpected, throw an error.
        throw Exception(
          data['message'] ??
              'Failed to toggle like status or invalid response format',
        );
      }
    } on DioException catch (e) {
      debugPrint("API Error toggling like for bit $bitId: ${e.response?.data}");
      throw Exception(_handleError(e));
    } catch (e) {
      debugPrint("Unexpected error toggling like for bit $bitId: $e");
      rethrow;
    }
  }

  Future<int> toggleLikeProduct(String productId) async {
    try {
      final response = await _dio.post("/product/$productId/like");
      final data = _decodeResponse(response.data);
      if (data['success'] == true && data.containsKey('likeCount')) {
        debugPrint(
          "Successfully toggled like for product: $productId. New count: ${data['likeCount']}",
        );
        return data['likeCount'] as int;
      } else {
        throw Exception(
          data['message'] ?? 'Failed to toggle product like status',
        );
      }
    } on DioException catch (e) {
      debugPrint(
        "API Error toggling like for product $productId: ${e.response?.data}",
      );
      throw Exception(_handleError(e));
    } catch (e) {
      debugPrint("Unexpected error toggling like for product $productId: $e");
      rethrow;
    }
  }

  Future<void> saveProduct(String productId) async {
    try {
      await _dio.post("/product/$productId/save");
      debugPrint("Successfully saved product: $productId");
    } on DioException catch (e) {
      debugPrint("API Error saving product $productId: $e");
      throw Exception(_handleError(e));
    } catch (e) {
      debugPrint("Unexpected error saving product $productId: $e");
      rethrow;
    }
  }

  Future<SaveProductResponse> toggleSaveProduct(String productId) async {
    try {
      final response = await _dio.post("/product/$productId/save");
      final data = _decodeResponse(response.data);
      return SaveProductResponse.fromJson(data);
    } on DioException catch (e) {
      debugPrint(
        "API Error toggling save for product $productId: ${e.response?.data}",
      );
      throw Exception(_handleError(e));
    } catch (e) {
      debugPrint("Unexpected error toggling save for product $productId: $e");
      rethrow;
    }
  }

  Future<SaveBitResponse> toggleSaveBit(String bitId) async {
    try {
      final response = await _dio.post("/bits/$bitId/save");
      final data = _decodeResponse(response.data);
      return SaveBitResponse.fromJson(data);
    } on DioException catch (e) {
      debugPrint("API Error toggling save for bit $bitId: ${e.response?.data}");
      throw Exception(_handleError(e));
    } catch (e) {
      debugPrint("Unexpected error toggling save for bit $bitId: $e");
      rethrow;
    }
  }

  Future<Comment> addCommentToBit(String bitId, String text) async {
    final String commentEndpoint = "/bits/$bitId/comments";

    try {
      final response = await _dio.post(commentEndpoint, data: {'text': text});

      final data = _decodeResponse(response.data);

      if (data is Map<String, dynamic> && data['success'] == true) {
        return Comment.fromJson(data['comment']);
      } else {
        throw Exception("Failed to parse comment response.");
      }
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    } catch (e) {
      debugPrint("Error posting comment: $e");
      throw Exception("Could not post comment. Please try again.");
    }
  }

  Future<Map<String, dynamic>> getLiveSessionDetails(String sessionId) async {
    final String detailsEndpoint = "/live/session/$sessionId/details";
    try {
      final response = await _dio.get(detailsEndpoint);
      final decodedData = _decodeResponse(response.data);

      if (decodedData is Map<String, dynamic> &&
          decodedData['success'] == true) {
        return decodedData;
      } else {
        throw Exception(
          decodedData['message'] ?? "Failed to get live session details.",
        );
      }
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    } catch (e) {
      throw Exception("Error fetching session details: $e");
    }
  }

  Future<List<LiveComment>> getLiveSessionComments(
    String sessionId, {
    int limit = 20,
    int offset = 0,
  }) async {
    final String commentsEndpoint =
        "/live/session/$sessionId/comments?limit=$limit&offset=$offset";
    try {
      final response = await _dio.get(commentsEndpoint);
      final data = _decodeResponse(response.data);
      if (data is Map<String, dynamic> && data['success'] == true) {
        final commentsList = data['comments'] as List<dynamic>? ?? [];
        return commentsList.map((c) => LiveComment.fromJson(c)).toList();
      } else {
        throw Exception("Failed to fetch live session comments.");
      }
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    } catch (e) {
      throw Exception("Error fetching comments: $e");
    }
  }

  Future<LiveComment> postLiveComment(String sessionId, String text) async {
    final String commentEndpoint = "/live/session/$sessionId/comment";

    try {
      final response = await _dio.post(commentEndpoint, data: {'text': text});

      final data = _decodeResponse(response.data);

      if (data is Map<String, dynamic> && data['success'] == true) {
        if (data['comment'] is Map<String, dynamic>) {
          return LiveComment.fromJson(data['comment']);
        } else {
          throw Exception("API response is missing the 'comment' object.");
        }
      } else {
        throw Exception(data['message'] ?? "Failed to post comment.");
      }
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    } catch (e) {
      throw Exception("Error posting comment: $e");
    }
  }

  Future<String> shareBit(String bitId) async {
    try {
      final response = await _dio.get("/bits/$bitId/share");
      final data = _decodeResponse(response.data);

      if (data['success'] == true && data['shareLink'] != null) {
        return data['shareLink'] as String;
      } else {
        return "https://zatch.live/bits/$bitId";
      }
    } catch (e) {
      print("Failed to fetch share link: $e");
      return "https://zatch.live/bits/$bitId";
    }
  }

  Future<CartModel?> getCart() async {
    try {
      final response = await _dio.get("/cart");
      final data = _decodeResponse(response.data);
      final cartResponse = CartApiResponse.fromJson(data);
      if (cartResponse.success) {
        return cartResponse.cart;
      } else {
        throw Exception(data['message'] ?? "Failed to fetch cart");
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        debugPrint("Cart is empty or not found.");
        return null; // Or return an empty CartModel object if you prefer
      }
      throw Exception(_handleError(e));
    } catch (e) {
      debugPrint("Unexpected error in getCart: $e");
      rethrow;
    }
  }

  Future<UpdatedCartModel?> updateCartItem({
    required String productId,
    required int quantity,
    String? color,
    String? size,
  }) async {
    try {
      final Map<String, dynamic> payload = {
        'productId': productId,
        'qty': quantity,
      };
      if (color != null) payload['color'] = color;
      if (size != null) payload['size'] = size;

      final response = await _dio.post("/cart/update", data: payload);
      final data = _decodeResponse(response.data);

      final updateResponse = UpdateCartApiResponse.fromJson(data);
      if (updateResponse.success) {
        return updateResponse.cart;
      } else {
        throw Exception(updateResponse.message);
      }
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    } catch (e) {
      debugPrint("Unexpected error in updateCartItem: $e");
      rethrow;
    }
  }

  //seller live dashboard data

  Future<LiveSummaryModel> getLiveSummary(String timeFilter) async {
    try {
      final response = await _dio.get(
        "/live/dashboard",
        queryParameters: {"timeFilter": timeFilter},
      );

      final data = _decodeResponse(response.data);

      final liveSummary = LiveSummaryModel.fromJson(data);

      return liveSummary;
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // go live first api
  Future<GoLiveStepOneResponse?> goLiveStepOne({
    required Map<String, dynamic> payload,
  }) async {
    try {
      final response = await _dio.post("/live/schedule", data: payload);

      final data = _decodeResponse(response.data);

      final apiResponse = GoLiveStepOneResponse.fromJson(data);

      if (apiResponse.success) {
        return apiResponse;
      } else {
        throw Exception(apiResponse.message);
      }
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    } catch (e) {
      debugPrint("Unexpected error in goLiveStepOne: $e");
      rethrow;
    }
  }

  //go live step 3
  Future<GoLiveSuccessResponseModel?> goLiveStepThree({
    required FormData payload,
  }) async {
    try {
      final response = await _dio.post(
        "/live/schedule",
        data: payload,
        options: Options(contentType: "multipart/form-data"),
      );

      log("API STEP 3 RAW RESPONSE: ${response.data}");

      return GoLiveSuccessResponseModel.fromJson(response.data);
    } catch (e) {
      log("Step 3 API Error: $e");
      return null;
    }
  }

  //go live step 2
  Future<GoLiveStepOneResponse?> goLiveStepTwo({
    required Map<String, dynamic> payload,
  }) async {
    try {
      final response = await _dio.post("/live/schedule", data: payload);

      final data = _decodeResponse(response.data);

      final apiResponse = GoLiveStepOneResponse.fromJson(data);

      if (apiResponse.success) {
        return apiResponse;
      } else {
        throw Exception(apiResponse.message);
      }
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    } catch (e) {
      debugPrint("Unexpected error in goLiveStepOne: $e");
      rethrow;
    }
  }

  Future<GoLiveNowResponseModel> goLiveNow({
    required Map<String, dynamic> payload,
  }) async {
    try {
      final response = await _dio.post("/live/token", data: payload);

      final data = _decodeResponse(response.data);

      final apiResponse = GoLiveNowResponseModel.fromJson(data);

      if (apiResponse.success) {
        return apiResponse;
      } else {
        throw Exception(apiResponse);
      }
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    } catch (e) {
      debugPrint("Unexpected error in goLiveStepOne: $e");
      rethrow;
    }
  }

  //share live api
  Future<ShareResponseModel> shareLiveApi(String sessionId) async {
    try {
      final response = await _dio.get("/live/session/$sessionId/share");

      final data = _decodeResponse(response.data);

      final shareliveSummary = ShareResponseModel.fromJson(data);

      return shareliveSummary;
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<LiveDetailsResponse> fetchLiveNowDetails(String sessionId) async {
    try {
      final response = await _dio.get("/live/session/$sessionId/details");

      final decodedData = _decodeResponse(response.data);

      return LiveDetailsResponse.fromJson(decodedData);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    } catch (e) {
      throw Exception("Unexpected error occurred");
    }
  }
}
