const String rmsBaseUrl = String.fromEnvironment(
  'RMS_BASE_URL',
  defaultValue: 'https://rms.armtech.online',
);

class RmsApiPaths {
  static const loginPage = '/Account/Login';
  static const loginPost = '/Account/Login';
  static const logout = '/Account/Logout';

  static const getCurrentLoginInformations =
      '/api/services/app/Session/GetCurrentLoginInformations';
}

