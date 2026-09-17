import 'dart:developer' as dev;
import 'package:get/get.dart' as getx;
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../utils/library.dart';

Map<String, String> buildHeaderTokens({
  Map? extraKeys,
  String? endPoint,
  bool isAuthRequire = true,
}) {
  /// Initialize & Handle if key is not present
  if (extraKeys == null) {
    extraKeys = {};
    extraKeys.putIfAbsent('isStripePayment', () => false);
  }

  Map<String, String> header = {
    HttpHeaders.cacheControlHeader: 'no-cache',
    'Access-Control-Allow-Headers': '*',
    'Access-Control-Allow-Origin': '*',
    'global-localization': selectedLanguageCode.value,
  };

  if (endPoint == APIEndPoints.register) {
    header.putIfAbsent(HttpHeaders.acceptHeader, () => 'application/json');
  }

  header.putIfAbsent(HttpHeaders.contentTypeHeader, () => 'application/json; charset=utf-8');

  if (isLoggedIn.value && extraKeys['isStripePayment']) {
    header.putIfAbsent(HttpHeaders.acceptHeader, () => 'application/x-www-form-urlencoded');
    header[HttpHeaders.contentTypeHeader] = 'application/x-www-form-urlencoded';
    header.putIfAbsent(HttpHeaders.authorizationHeader, () => 'Bearer ${extraKeys!['stripeKeyPayment']}');
  } else if (isLoggedIn.value && isAuthRequire) {
    header.putIfAbsent(HttpHeaders.authorizationHeader, () => 'Bearer ${loginUserData.value.apiToken}');
  }

  // log(jsonEncode(header));
  return header;
}

Uri buildBaseUrl(String endPoint) {
  Uri url = Uri.parse(endPoint);

  if (!endPoint.startsWith('http')) url = Uri.parse('$BASE_URL$endPoint');

  // log('URL: ${url.toString()}');

  return url;
}

Future<http.Response> buildHttpResponse(
  String endPoint, {
  HttpMethodType method = HttpMethodType.GET,
  Map? request,
  Map? extraKeys,
  Map<String, String>? header,
  bool isAuthRequire = true,
}) async {
  var headers = header ?? buildHeaderTokens(extraKeys: extraKeys, endPoint: endPoint);
  Uri url = buildBaseUrl(endPoint);

  http.Response response;
  log('URL (${method.name}): $url');

  try {
    if (method == HttpMethodType.POST) {
      log('Request: ${jsonEncode(request)}');
      response = await http.post(url, body: jsonEncode(request), headers: headers);
    } else if (method == HttpMethodType.DELETE) {
      response = await http.delete(url, headers: headers);
    } else if (method == HttpMethodType.PUT) {
      response = await http.put(url, body: jsonEncode(request), headers: headers);
    } else {
      response = await http.get(url, headers: headers);
    }

    apiPrint(
      url: url.toString(),
      endPoint: endPoint,
      headers: jsonEncode(headers),
      hasRequest: method == HttpMethodType.POST || method == HttpMethodType.PUT,
      request: jsonEncode(request),
      statusCode: response.statusCode,
      responseBody: response.body.trim(),
      methodtype: method.name,
    );

    if (isLoggedIn.value && response.statusCode == 401 && !endPoint.startsWith('http')) {
      bool tokenRegenerated = await reGenerateToken();

      if (tokenRegenerated) {
        return await buildHttpResponse(
          endPoint,
          method: method,
          request: request,
          header: header,
        );
      } else {
        await handleFailRegenerateToken();
        throw errorSomethingWentWrong;
      }
    } else {
      return response;
    }
  } on Exception catch (e) {
    log(e);
    if (!await isNetworkAvailable()) {
      throw locale.value.yourInternetIsNotWorking;
    } else {
      throw errorSomethingWentWrong;
    }
  }
}

Future<bool> reGenerateToken() async {
  bool result = false;
  Map<String, dynamic>? request;

  if (getBoolAsync(SharedPreferenceConst.IS_LOGGED_IN)) {
    if (loginUserData.value.loginType == LoginTypeConst.LOGIN_TYPE_OTP) {
      request = {
        UserKeys.username: loginUserData.value.userName,
        UserKeys.password: loginUserData.value.mobile,
        UserKeys.mobile: loginUserData.value.mobile,
        // UserKeys.userType: EmployeeKeyConst.LOGIN_TYPE_USER,
        UserKeys.loginType: LoginTypeConst.LOGIN_TYPE_OTP,
        UserKeys.firstName: loginUserData.value.firstName,
        UserKeys.lastName: loginUserData.value.lastName,
      };
    } else if (loginUserData.value.loginType == LoginTypeConst.LOGIN_TYPE_GOOGLE || loginUserData.value.loginType == LoginTypeConst.LOGIN_TYPE_APPLE) {
      request = {
        UserKeys.profileImage: loginUserData.value.profileImage,
        UserKeys.email: loginUserData.value.email,
        UserKeys.password: loginUserData.value.email,
        // UserKeys.userType: UserType.user.name,
        UserKeys.loginType: loginUserData.value.loginType,
        UserKeys.firstName: loginUserData.value.firstName,
        UserKeys.lastName: loginUserData.value.lastName,
        UserKeys.mobile: loginUserData.value.mobile,
      };
    }
  } else if (getStringAsync(SharedPreferenceConst.USER_EMAIL).isNotEmpty && getStringAsync(SharedPreferenceConst.USER_PASSWORD).isNotEmpty) {
    request = {
      UserKeys.email: getStringAsync(SharedPreferenceConst.USER_EMAIL),
      UserKeys.password: getStringAsync(SharedPreferenceConst.USER_PASSWORD),
      // UserKeys.userType: UserType.user.name,
    };
  } else {
    result = false;
  }
  if (request != null) {
    await AuthServiceApis.loginUser(request: request, isSocialLogin: getBoolAsync(SharedPreferenceConst.IS_LOGGED_IN)).then(
      (value) {
        result = true;
      },
    );
  } else {
    result = false;
  }

  return result;
}

Future<void> handleFailRegenerateToken() async {
  await GoogleSignInAuthService.deleteCurrentFirebaseUser();
  isLoggedIn.value = false;
  loginUserData(UserData());

  setValue(SharedPreferenceConst.IS_LOGGED_IN, false);
  setValue(SharedPreferenceConst.USER_DATA, loginUserData.value.toJson());
  setValue(SharedPreferenceConst.USER_EMAIL, '');
  setValue(SharedPreferenceConst.USER_PASSWORD, '');
  setValue(SharedPreferenceConst.API_TOKEN, '');
  setValue(APICacheConst.CACHED_DASHBOARD_DATA, '');

  Get.offAll(() => SignInScreen());
}

Future handleResponse(http.Response response, {HttpResponseType httpResponseType = HttpResponseType.JSON, bool? avoidTokenError}) async {
  if (!await isNetworkAvailable()) {
    throw errorInternetNotAvailable;
  }

  if (response.statusCode.isSuccessful()) {
    if (response.body.trim().isJson()) {
      Map body = jsonDecode(response.body.trim());

      if (body.containsKey('status')) {
        if (body['status']) {
          return body;
        } else {
          throw body['message'] ?? errorSomethingWentWrong;
        }
      } else {
        return body;
      }
    } else {
      throw errorSomethingWentWrong;
    }
  } else if (response.statusCode == 401) {
    await AuthServiceApis.clearData();
    getx.Get.offAll(() => SignInScreen());
    throw locale.value.tokenExpired;
  } else if (response.statusCode == 400) {
    throw locale.value.badRequest;
  } else if (response.statusCode == 403) {
    throw locale.value.forbidden;
  } else if (response.statusCode == 404) {
    throw locale.value.pageNotFound;
  } else if (response.statusCode == 429) {
    throw locale.value.tooManyRequests;
  } else if (response.statusCode == 500) {
    throw locale.value.internalServerError;
  } else if (response.statusCode == 502) {
    throw locale.value.badGateway;
  } else if (response.statusCode == 503) {
    throw locale.value.serviceUnavailable;
  } else if (response.statusCode == 504) {
    throw locale.value.gatewayTimeout;
  } else {
    Map body = jsonDecode(response.body.trim());

    if (body.containsKey('status') && body['status']) {
      return body;
    } else {
      throw body['message'] ?? errorSomethingWentWrong;
    }
  }
}

//region CommonFunctions
Future<Map<String, String>> getMultipartFields({required Map<String, dynamic> val}) async {
  Map<String, String> data = {};

  val.forEach((key, value) {
    data[key] = '$value';
  });

  return data;
}

Future<MultipartRequest> getMultiPartRequest(String endPoint, {String? baseUrl}) async {
  String url = baseUrl ?? buildBaseUrl(endPoint).toString();
  // log(url);
  return MultipartRequest('POST', Uri.parse(url));
}

Future<void> sendMultiPartRequest(MultipartRequest multiPartRequest, {Function(dynamic)? onSuccess, Function(dynamic)? onError}) async {
  http.Response response = await http.Response.fromStream(await multiPartRequest.send());
  apiPrint(
      url: multiPartRequest.url.toString(), headers: jsonEncode(multiPartRequest.headers), request: jsonEncode(multiPartRequest.fields), hasRequest: true, statusCode: response.statusCode, responseBody: response.body.trim(), methodtype: "MultiPart");
  // log("Result: ${response.statusCode} - ${multiPartRequest.fields}");
  // log(response.body.trim());
  if (response.statusCode.isSuccessful()) {
    onSuccess?.call(response.body.trim());
  } else {
    onError?.call(errorSomethingWentWrong);
  }
}

Future<List<http.MultipartFile>> getMultipartImages({required List<PlatformFile> files, required String name}) async {
  List<http.MultipartFile> multiPartRequest = [];

  await Future.forEach<PlatformFile>(files, (element) async {
    int i = files.indexOf(element);

    multiPartRequest.add(await http.MultipartFile.fromPath('$name[${i.toString()}]', element.path.validate()));
  });

  return multiPartRequest;
}

Future<List<http.MultipartFile>> getMultipartImages2({required List<XFile> files, required String name}) async {
  List<http.MultipartFile> multiPartRequest = [];

  await Future.forEach<XFile>(files, (element) async {
    int i = files.indexOf(element);

    multiPartRequest.add(await http.MultipartFile.fromPath('$name[${i.toString()}]', element.path.validate()));
    log('MultipartFile: $name[${i.toString()}]');
  });

  return multiPartRequest;
}

String parseStripeError(String response) {
  try {
    var body = jsonDecode(response);
    return parseHtmlString(body['error']['message']);
  } on Exception catch (e) {
    log(e);
    throw errorSomethingWentWrong;
  }
}

void apiPrint({
  String url = "",
  String endPoint = "",
  String headers = "",
  String request = "",
  int statusCode = 0,
  String responseBody = "",
  String methodtype = "",
  bool hasRequest = false,
  bool fullLog = false,
}) {
  if (fullLog) {
    dev.log("┌───────────────────────────────────────────────────────────────────────────────────────────────────────");
    dev.log("\u001b[93m Url: \u001B[39m $url");
    dev.log("\u001b[93m endPoint: \u001B[39m \u001B[1m$endPoint\u001B[22m");
    dev.log("\u001b[93m header: \u001B[39m \u001b[96m$headers\u001B[39m");
    if (hasRequest) {
      dev.log('\u001b[93m Request: \u001B[39m \u001b[95m$request\u001B[39m');
    }
    dev.log(statusCode.isSuccessful() ? "\u001b[32m" : "\u001b[31m");
    dev.log('Response ($methodtype) $statusCode: ${formatJson(responseBody)}');
    dev.log("\u001B[0m");
    dev.log("└───────────────────────────────────────────────────────────────────────────────────────────────────────");
  } else {
    log("┌───────────────────────────────────────────────────────────────────────────────────────────────────────");
    log("\u001b[93m Url: \u001B[39m $url");
    log("\u001b[93m endPoint: \u001B[39m \u001B[1m$endPoint\u001B[22m");
    log("\u001b[93m header: \u001B[39m \u001b[96m$headers\u001B[39m");
    if (hasRequest) {
      log('\u001b[93m Request: \u001B[39m \u001b[95m$request\u001B[39m');
    }
    log(statusCode.isSuccessful() ? "\u001b[32m" : "\u001b[31m");
    log('Response ($methodtype) $statusCode: $responseBody');
    log("\u001B[0m");
    log("└───────────────────────────────────────────────────────────────────────────────────────────────────────");
  }
}

String formatJson(String jsonStr) {
  try {
    final dynamic parsedJson = jsonDecode(jsonStr);
    const formatter = JsonEncoder.withIndent('  ');
    return formatter.convert(parsedJson);
  } on Exception catch (e) {
    dev.log("\x1b[31m formatJson error ::-> ${e.toString()} \x1b[0m");
    return jsonStr;
  }
}
