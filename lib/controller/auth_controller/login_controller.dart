import 'package:zatch_app/model/login_request.dart';
import 'package:zatch_app/model/login_response.dart';
import 'package:zatch_app/model/register_response_model.dart';
import 'package:zatch_app/services/api_service.dart';

class LoginController {
  RegisterResponse? registrationResponse;
  final ApiService _apiService = ApiService();

  Future<LoginResponse> loginUser({
    required String phone,
    required String password,
    required String countryCode,
  }) async {
    final request = LoginRequest(phone: phone, password: password,countryCode: countryCode);
    return await _apiService.loginUser(request);
  }

  void setRegistrationResponse(RegisterResponse response) {
    registrationResponse = response;
  }

  String? getRegisteredPhone() {
    return registrationResponse?.user.phone;
  }
  String? getRegisteredCountryCode() {
    return registrationResponse?.user.countryCode;
  }
}
