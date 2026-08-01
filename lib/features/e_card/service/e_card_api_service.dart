import 'package:dio/dio.dart';
import 'package:mediconsult/core/network/api_constants.dart';
import 'package:mediconsult/features/e_card/data/e_card_response_model.dart';
import 'package:retrofit/retrofit.dart';

part 'e_card_api_service.g.dart';

@RestApi(baseUrl: ApiConstants.baseUrl)
abstract class ECardApiService {
  factory ECardApiService(Dio dio, {String baseUrl}) = _ECardApiService;

  @GET('{lang}/Ecard/Get')
  Future<ECardResponse> getECard(@Path('lang') String lang);
}
