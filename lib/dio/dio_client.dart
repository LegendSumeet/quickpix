import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:path_provider/path_provider.dart';

class DioClient {
  final Dio _dio;

  DioClient._internal(this._dio);

  static DioClient? _instance;

  factory DioClient() {
    if (_instance == null) {
      final Dio dio = Dio(BaseOptions(
        baseUrl: 'https://api.pexels.com/v1',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Accept': 'application/json',
          'Authorization':
              'dCGIHKnDNprQKo8yBtBQteuRC1k7VnXe8aXoC7hkQlAxryCGk5lu3e8z'
        },
      ));

      if (kDebugMode) {
        (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
            (client) {
          client.badCertificateCallback =
              (X509Certificate cert, String host, int port) => true;
        };
      }

      _instance = DioClient._internal(dio);
    }

    return _instance!;
  }

  Dio get client => _dio;

  static Interceptor _loggingInterceptor() {
    return PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      compact: false,
    );
  }

  /// Cache interceptor initialization should be handled in an async manner
  static Future<List<Interceptor>> _initializeInterceptors() async {
    var cacheDir = await getTemporaryDirectory();

    var cacheStore = HiveCacheStore(
      cacheDir.path,
      hiveBoxName: "quickpix_cache_box",
    );

    final cacheOptions = CacheOptions(
      keyBuilder: CacheOptions.defaultCacheKeyBuilder,
      priority: CachePriority.high,
      store: cacheStore,
      policy: CachePolicy.request,
      hitCacheOnErrorExcept: [401, 403],
      maxStale: const Duration(minutes: 60),
    );

    return [
      _loggingInterceptor(),
      DioCacheInterceptor(options: cacheOptions),
      _errorInterceptor(),
    ];
  }

  static Interceptor _errorInterceptor() {
    return InterceptorsWrapper(
      onError: (DioException e, ErrorInterceptorHandler handler) {
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
            print("Connection Timeout Error: ${e.message}");
            break;
          case DioExceptionType.receiveTimeout:
            print("Receive Timeout Error: ${e.message}");
            break;
          case DioExceptionType.badResponse:
            print(
                "Bad Response: ${e.response?.statusCode} ${e.response?.data}");
            break;
          default:
            print("Unhandled Error: ${e.message}");
        }
        handler.next(e);
      },
    );
  }

  Future<void> initialize() async {
    List<Interceptor> interceptors = await _initializeInterceptors();
    _dio.interceptors.addAll(interceptors);
  }

  Future<Response> get(String endpoint,
      {Map<String, dynamic>? queryParams}) async {
    try {
      return await _dio.get(endpoint, queryParameters: queryParams);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> post(String endpoint, {dynamic data}) async {
    try {
      return await _dio.post(endpoint, data: data);
    } catch (e) {
      rethrow;
    }
  }
}
