import 'package:mediconsult/core/constants/constants.dart';
import 'package:mediconsult/core/helpers/shared_pref_helper.dart';
import 'package:mediconsult/core/network/dio_factory.dart';

Future<void> saveUserToken(String token, {int? memberId}) async {
  await SharedPrefHelper.setSecuredString(SharedPrefKeys.userToken, token);
  if (memberId != null) {
    await SharedPrefHelper.setSecuredString(
      SharedPrefKeys.memberId,
      memberId.toString(),
    );
  }
  DioFactory.setTokenIntoHeaderAfterLogin(token);
}
