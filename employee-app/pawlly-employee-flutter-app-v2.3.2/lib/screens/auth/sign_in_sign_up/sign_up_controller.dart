// ignore_for_file: depend_on_referenced_packages

import 'package:get/get.dart';
import 'package:pawlly_employee/utils/extention/string_extentsion.dart';

import '../../../../utils/library.dart';

class SignUpController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool agree = false.obs;
  RxBool isAcceptedTc = false.obs;
  TextEditingController emailCont = TextEditingController();
  TextEditingController fisrtNameCont = TextEditingController();
  TextEditingController lastNameCont = TextEditingController();
  TextEditingController mobileCont = TextEditingController();
  TextEditingController passwordCont = TextEditingController();
  TextEditingController userTypeCont = TextEditingController();

  FocusNode emailFocus = FocusNode();
  FocusNode firstNameFocus = FocusNode();
  FocusNode lastNameFocus = FocusNode();
  FocusNode mobileFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();
  FocusNode userTypeFocus = FocusNode();

  Rx<DemoLoginData> selectedUserTypeForLogin = DemoLoginData().obs;
  Rx<Country> selectedCountry = defaultCountry.obs;

  Future<void> saveForm() async {
    if (isAcceptedTc.value) {
      isLoading(true);
      hideKeyBoardWithoutContext();
      Map<String, dynamic> req = {
        "email": emailCont.text.trim(),
        "first_name": fisrtNameCont.text.trim(),
        "last_name": lastNameCont.text.trim(),
        "mobile": '+${mobileCont.text.trim().formatPhoneNumber(selectedCountry.value.phoneCode)}',
        "password": passwordCont.text.trim(),
        UserKeys.userType: selectedUserTypeForLogin.value.userType,
      };

      await AuthServiceApis.createUser(request: req).then((value) async {
        try {
          final SignInController sCont = Get.find();
          sCont.emailCont.text = emailCont.text.trim();
          sCont.passwordCont.text = passwordCont.text.trim();
        } catch (e) {
          log('E: $e');
          isLoading(false);
          toast(e.toString(), print: true);
        }
        Get.back();
        toast(value.message.toString(), print: true);
      }).catchError((e) {
        isLoading(false);
        toast(e.toString(), print: true);
      }).whenComplete(() => isLoading(false));
    } else {
      toast(locale.value.pleaseAcceptTermsAnd);
    }
  }
}
