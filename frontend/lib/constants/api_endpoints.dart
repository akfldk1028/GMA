class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'http://localhost:8080/api';

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String me = '/users/me';
}
