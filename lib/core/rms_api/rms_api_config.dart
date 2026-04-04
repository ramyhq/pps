const String rmsBaseUrl = String.fromEnvironment(
  'RMS_BASE_URL',
  defaultValue: 'https://rms.armtech.online',
);

const String rmsProxyOrigin = String.fromEnvironment(
  'RMS_PROXY_ORIGIN',
  defaultValue: 'https://package-pricing-system-pps.web.app',
);

const String _rmsProxyKeyHardcoded = '';

const String _rmsProxyKeyFromEnv = String.fromEnvironment(
  'RMS_PROXY_KEY',
  defaultValue: '',
);

const String rmsProxyKey = _rmsProxyKeyFromEnv != ''
    ? _rmsProxyKeyFromEnv
    : _rmsProxyKeyHardcoded;

class RmsApiPaths {
  static const loginPage = '/Account/Login';
  static const loginPost = '/Account/Login';
  static const logout = '/Account/Logout';

  static const getCurrentLoginInformations =
      '/api/services/app/Session/GetCurrentLoginInformations';

  static const proxyLogin = '/rms/login';
  static const proxy = '/rms/proxy';
}
