import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/rms_api/rms_dio_provider.dart';
import '../data/data_sources/rms_auth_remote_data_source.dart';
import '../data/repositories/rms_auth_repository.dart';
import '../data/repositories/rms_auth_repository_impl.dart';

final rmsAuthRemoteDataSourceProvider = Provider<RmsAuthRemoteDataSource>((
  ref,
) {
  final dio = ref.watch(rmsDioProvider);
  return RmsAuthRemoteDataSource(dio: dio);
});

final rmsAuthRepositoryProvider = Provider<RmsAuthRepository>((ref) {
  final remote = ref.watch(rmsAuthRemoteDataSourceProvider);
  return RmsAuthRepositoryImpl(remoteDataSource: remote, ref: ref);
});
