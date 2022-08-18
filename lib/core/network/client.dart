import 'dart:async';
import 'dart:io';

import 'package:anpha_petrol_smartgas/core/code_definition.dart';
import 'package:anpha_petrol_smartgas/core/global_manager.dart';
import 'package:anpha_petrol_smartgas/core/helper.dart';
import 'package:anpha_petrol_smartgas/core/network/api.dart';
import 'package:anpha_petrol_smartgas/core/utils/toast_utils.dart';
import 'package:anpha_petrol_smartgas/models/o_response.dart';
import 'package:anpha_petrol_smartgas/repositories/r_user.dart';
import 'package:curl_logger_dio_interceptor/curl_logger_dio_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/*
For update FormData, we need to install http_parser package.
var _formData = FormData.fromMap({
  'name-(whatever backend want)': await MultipartFile.fromFile(file.path, contentType: MediaType.parse("image/png")),
});
Client.post(url, _formData);
*/

class Client {
  Client._privateConstructor();

  static final Client _instance = Client._privateConstructor();

  factory Client() => _instance;

  static Future<AppResponse> get(
    endpoint, {
    Map<String, String>? queries,
  }) async {
    String url = API.getApiUrl(endpoint);
    final _dio = DioHelper.getDio();
    bool metricCompleted = false;
    final HttpMetric metric =
        FirebasePerformance.instance.newHttpMetric(url, HttpMethod.Get);
    try {
      await metric.start();
      Response response = await _dio.get(_urlWithQuery(url, queries));

      metric
        ..requestPayloadSize = int.tryParse(
            _dio.options.headers[Headers.contentLengthHeader] ?? "0")
        ..responseContentType =
            response.headers.value(Headers.contentTypeHeader)
        ..responsePayloadSize = int.tryParse(
            response.headers.value(Headers.contentLengthHeader) ?? "0")
        ..httpResponseCode = response.statusCode;
      await metric.stop();
      metricCompleted = true;

      return _handleResponse(response);
    } on Exception catch (e) {
      if (!metricCompleted) await metric.stop();
      showLog(msg: e.toString(), skipLog: false, logLevel: Level.error);
      return _handleException(e);
    } catch (tt) {
      if (!metricCompleted) await metric.stop();
      return AppResponse(
        success: false,
        systemMessage: GlobalManager.strings.errorOccurred ?? "",
        data: null,
      );
    }
  }

  static Future<AppResponse> post(
    String endpoint, {
    dynamic body,
    Map<String, String>? queries,
  }) async {
    final _dio = DioHelper.getDio();
    bool metricCompleted = false;
    String url = API.getApiUrl(endpoint);
    final HttpMetric metric =
        FirebasePerformance.instance.newHttpMetric(url, HttpMethod.Post);

    try {
      await metric.start();
      Response response =
          await _dio.post(_urlWithQuery(url, queries), data: body);
      metric
        ..requestPayloadSize = int.tryParse(
            _dio.options.headers[Headers.contentLengthHeader] ?? "0")
        ..responseContentType =
            response.headers.value(Headers.contentTypeHeader)
        ..responsePayloadSize = int.tryParse(
            response.headers.value(Headers.contentLengthHeader) ?? "0")
        ..httpResponseCode = response.statusCode;
      await metric.stop();
      metricCompleted = true;

      return _handleResponse(response);
    } on Exception catch (e) {
      if (!metricCompleted) await metric.stop();
      return _handleException(e);
    } catch (_) {
      if (!metricCompleted) await metric.stop();
      return AppResponse(
        success: false,
        systemMessage: GlobalManager.strings.errorOccurred!,
        data: null,
      );
    }
  }

  static Future<AppResponse> put(
    String endpoint, {
    dynamic body,
    Map<String, String>? queries,
  }) async {
    final _dio = DioHelper.getDio();
    String url = API.getApiUrl(endpoint);
    bool metricCompleted = false;
    final HttpMetric metric =
        FirebasePerformance.instance.newHttpMetric(url, HttpMethod.Put);
    try {
      await metric.start();
      Response response =
          await _dio.put(_urlWithQuery(url, queries), data: body);
      metric
        ..requestPayloadSize = int.tryParse(
            _dio.options.headers[Headers.contentLengthHeader] ?? "0")
        ..responseContentType =
            response.headers.value(Headers.contentTypeHeader)
        ..responsePayloadSize = int.tryParse(
            response.headers.value(Headers.contentLengthHeader) ?? "0")
        ..httpResponseCode = response.statusCode;
      await metric.stop();
      metricCompleted = true;
      return _handleResponse(response);
    } on Exception catch (e) {
      if (!metricCompleted) await metric.stop();
      printDefault('error is ${e.toString()}');
      return _handleException(e);
    } catch (_) {
      if (!metricCompleted) await metric.stop();
      return AppResponse(
        success: false,
        systemMessage: GlobalManager.strings.errorOccurred!,
        data: null,
      );
    }
  }

  static String _urlWithQuery(String url, Map<String, String>? queries) {
    String query = "";
    if (queries != null && queries.isNotEmpty) {
      queries.forEach((key, value) {
        if (value is List) {
          List<String> l = value as List<String>;
          query = query + "&" + key + "=" + l.join(',');
        } else {
          query = query + "&" + key + "=" + value;
        }
      });
    }

    if (query != "") {
      query = query.substring(1);
      url = url + '?' + query;
    }
    return url;
  }

  static _handleException(Exception exception) {
    if (exception is TimeoutException) {
      return AppResponse(
        success: false,
        systemMessage: GlobalManager.strings.errorNetworkUnstable!,
        data: null,
      );
    } else if (exception is SocketException) {
      if (exception.osError!.errorCode == 60) {
        return AppResponse(
          success: false,
          systemMessage: GlobalManager.strings.errorNetworkUnstable!,
          data: null,
        );
      }
      return AppResponse(
        success: false,
        systemMessage: GlobalManager.strings.errorNetworkUnstable!,
        data: null,
      );
    } else if (exception is DioError){
      var _dioError = exception;
      switch (_dioError.type) {
        case DioErrorType.cancel:
        case DioErrorType.connectTimeout:
        case DioErrorType.other:
        case DioErrorType.receiveTimeout:
        case DioErrorType.sendTimeout:
          return AppResponse(
            success: false,
            systemMessage: GlobalManager.strings.errorNetworkUnstable!,
          );

        case DioErrorType.response:
          printDefault('dio error is ${_dioError.response?.data}');
          Map<String, dynamic>? _bodyResponse = Map<String, dynamic>.from(_dioError.response?.data ?? {});
          String? errorCode = _bodyResponse['error_code'];
          switch (_dioError.response?.statusCode) {
            case 401:
              if (errorCode == AUTH_WRONG_USER_NAME_OR_PASSWORD) {
                return AppResponse(
                  systemCode: USER_LOGIN_FAILED,
                  success: false,
                  systemMessage: GlobalManager.strings.errorMessages![USER_LOGIN_FAILED]!,
                  data: null,
                );
              }
              return AppResponse(
                systemCode: UNAUTHORIZED,
                success: false,
                systemMessage: GlobalManager.strings.errorMessages![UNAUTHORIZED]!,
                data: null,
              );
            case 403:
            case 400:
            // return NotFoundException();
            case 404:
            // return UnexpectedException();
            case 408:
            // return SendTimeoutException();
            case 409:
            // return ConflictException();
            case 500:
            // return InternalSeverErrorException();
            case 502:
            // return BadGatewayException();
            case 503:
            // return ServiceUnavailableException();
            case 504:
            // return GatewayTimeoutException();
            default:
              String? errMsg = GlobalManager.strings.errorMessages![errorCode];
              return AppResponse(
                systemCode: errorCode ?? '',
                success: false,
                systemMessage: errMsg ?? GlobalManager.strings.errorOccurred!,
                data: null,
              );
          }
      }
    } else {
      return AppResponse(
        success: false,
        systemMessage: GlobalManager.strings.errorOccurred!,
        data: null,
      );
    }
  }

  static AppResponse _handleResponse(Response response) {
    var body = response.data;
    var statusCode = response.statusCode;
    if (statusCode != 200) {
      // body == null || body.isEmpty
      AppResponse result = AppResponse();
      result.success = false;
      result.data = null;
      result.systemCode = "";
      result.systemMessage = GlobalManager.strings.errorOccurred!;
      return result;
    }

    var result = AppResponse();
    if (statusCode == 200) {
      try {
        result.success = true;
        result.data = body;
        // String code = body['code'];
        // if (code.compareTo("SUCCESS") == 0) {
        //   result.success = true;
        //   dynamic data = body['data'];
        //   result.data = data;
        // } else {
        //   result.success = false;
        //   result.data = null;
        //   result.systemCode = code;
        //   result.systemMessage =
        //       GlobalManager.strings.errorMessages![code] ?? GlobalManager.strings.errorOccurred;
        //
        //   switch (code) {
        //     case ACCESS_DENY:
        //     case MAINTENANCE:
        //     case FORCE_UPDATE:
        //       restartApp(code);
        //       break;
        //     default:
        //       break;
        //   }
        // }
      } catch (ex) {
        showLog(
          msg: '[CLIENT NETWORK] Client throw exception: $ex',
          skipLog: false,
        );
        result.success = false;
        result.data = null;
        result.systemCode = "";
        result.systemMessage = GlobalManager.strings.errorNetworkUnstable!;
      }
    } else if (statusCode == 401) {
      result.success = false;
      result.data = null;
      result.systemCode = UNAUTHORIZED;
      result.systemMessage = GlobalManager.strings.errorMessages![UNAUTHORIZED];
    } else if (statusCode == 403) {
      result.success = false;
      result.data = null;
      result.systemCode = UNAUTHORIZED;
      result.systemMessage = GlobalManager.strings.errorMessages![FORBIDDEN];
    } else {
      result.success = false;
      result.data = null;
      result.systemCode = "";
      result.systemMessage = GlobalManager.strings.errorOccurred!;
    }

    return result;
  }
}

class DioHelper {
  static Dio? _dio;

  static Dio getDio() {
    _dio ??= createDio();
    return _dio!;
  }

  static Dio createDio() {
    Dio dio;

    var options = BaseOptions(
      receiveDataWhenStatusError: true,
      connectTimeout: 30 * 1000, // 30s
      receiveTimeout: 30 * 1000, // 30s
    );

    dio = Dio(options)
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (
            RequestOptions options,
            RequestInterceptorHandler handler,
          ) {
            Map<String, String> _header = {
              "client-version": GlobalManager.clientVersion!.getClientVersion(),
              "language": GlobalManager.currentAppLanguage,
            };

            if (RUser.currentUserToken.token != null &&
                RUser.currentUserToken.token != "") {
              _header['Authorization'] =
                  // 'Bearer ${RUser.currentUserToken.token}';
                  '${RUser.currentUserToken.token}';
            }

            if (_header.isNotEmpty) {
              options.headers.addAll(_header);
            }

            showLog(msg: '${options.headers['Authorization']}', skipLog: true);
            showLog(msg: 'URL ${options.uri}', skipLog: true);
            handler.next(options);
          },
        onResponse: (response, handler) {
          showLog(msg: 'Response ==>  ${response.data}', skipLog: true);
          handler.next(response);
        },
        onError: (error, handler) {
          showLog(msg: 'Error $error', skipLog: true);
          handler.next(error);
        },
      ));

    // log curl
    if (!kReleaseMode) {
      dio.interceptors.add(CurlLoggerDioInterceptor(printOnSuccess: true));
    }

    return dio;
  }
}
