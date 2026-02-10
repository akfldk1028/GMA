import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../utils/dio_provider.dart';
import '../models/user_model.dart';

part 'login_mutation.g.dart';

@riverpod
class LoginMutation extends _$LoginMutation {
  @override
  FutureOr<LoginResponse?> build() => null;

  Future<LoginResponse> call({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      final response = await ref.read(dioProvider).post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      final result = LoginResponse.fromJson(response.data);

      // 토큰 저장
      const storage = FlutterSecureStorage();
      await storage.write(key: 'access_token', value: result.accessToken);
      await storage.write(key: 'refresh_token', value: result.refreshToken);

      state = AsyncData(result);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}
