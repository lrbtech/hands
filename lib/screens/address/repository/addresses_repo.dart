import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/model/address_model.dart';
import 'package:hands_user_app/network/network_utils.dart';
import 'package:hands_user_app/screens/blog/model/blog_response_model.dart';
import 'package:hands_user_app/utils/constant.dart';
import 'package:nb_utils/nb_utils.dart';

Future<List<AddressModel>> getAddressList(
    {int? page,
    required List<AddressModel> addressData,
    Function(bool)? lastPageCallback}) async {
  try {
    List<dynamic> res = await handleResponse(await buildHttpResponse(
        'user-address-book',
        method: HttpMethodType.GET));
    if (res.length > 0) {
      addressData = res.map((e) => AddressModel.fromJson(e)).toList();
    }

    appStore.setLoading(false);

    cachedAddressList = addressData;

    return addressData;
  } catch (e) {
    appStore.setLoading(false);
    throw e;
  }
}

Future<Map<String, dynamic>> saveAddress(Map request) async {
  return (await handleResponse(await buildHttpResponse('user-address-book',
      request: request, method: HttpMethodType.POST)));
}
