import 'package:dio/dio.dart';
import 'package:quiz_battle/features/home/data/repositories/home_repository.dart';

final class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl(this._dio);

  // ignore: unused_field
  final Dio _dio;
}
