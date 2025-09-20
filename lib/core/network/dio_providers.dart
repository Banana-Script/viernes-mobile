import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dio_client.dart';

// Provider for authenticated Dio client
final authenticatedDioProvider = Provider<Dio>((ref) {
  return DioClient.instance.dio;
});

// Provider for public Dio client (unauthenticated requests)
final publicDioProvider = Provider<Dio>((ref) {
  return DioClient.publicClient;
});