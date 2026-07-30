import 'package:mediconsult/core/constants/api_result.dart';
import 'package:mediconsult/core/error/app_error_handler.dart';
import 'package:mediconsult/features/family_members/data/family_response_model.dart';
import 'package:mediconsult/features/family_members/service/family_member_api_service.dart';
import 'package:mediconsult/core/cache/family_cache_service.dart';
import 'package:dio/dio.dart';
import 'package:mediconsult/core/error/error_mapper.dart';

class FamilyMemberRepository {
  final FamilyMemberApiService _familyMemberApiService;

  FamilyMemberRepository(this._familyMemberApiService);

  Future<ApiResult<FamilyResponse>> getFamilyMembers(String lang, {bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cachedData = await FamilyCacheService.getCachedFamilyData(lang);
      if (cachedData != null) {
        return ApiResult.success(cachedData);
      }
    }

    try {
      final response = await _familyMemberApiService.getFamilyMembers(lang);

      if (response.success == true) {
        await FamilyCacheService.cacheFamilyData(response, lang);
        return ApiResult.success(response);
      } else {
        return ApiResult.failure(response.message);
      }
    } on DioException catch (e) {
      // Convert DioException to AppFailure
      final failure = mapDioException(e);
      final errorMessage = AppErrorHandler.messageFromFailure(failure);
      return ApiResult.failure(errorMessage);
    } catch (error) {
      // Handle other errors (parsing errors, etc.)
      final errorMessage = AppErrorHandler.getUserFriendlyMessage(error.toString());
      return ApiResult.failure(errorMessage);
    }
  }
}
