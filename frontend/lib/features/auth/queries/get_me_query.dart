import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../utils/dio_provider.dart';
import '../models/user_model.dart';

part 'get_me_query.g.dart';

@riverpod
Future<User> getMeQuery(GetMeQueryRef ref) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get('/users/me');
  return User.fromJson(response.data);
}
