// ignore_for_file: depend_on_referenced_packages

import 'package:get/get.dart';
import 'package:pawlly/utils/extention/string_extentsion.dart';
import 'package:pawlly/utils/library.dart';

class SignUpController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool agree = false.obs;
  RxBool isAcceptedTc = false.obs;
  TextEditingController emailCont = TextEditingController();
  TextEditingController fisrtNameCont = TextEditingController();
  TextEditingController lastNameCont = TextEditingController();
  TextEditingController passwordCont = TextEditingController();
  TextEditingController mobileCont = TextEditingController();

  FocusNode emailFocus = FocusNode();
  FocusNode fisrtNameFocus = FocusNode();
  FocusNode lastNameFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();
  FocusNode mobileFocus = FocusNode();

  RxString selectedGenderOption = GenderTypeConst.MALE.obs;
  Rx<Country> selectedCountry = defaultCountry.obs;

  RxString groupValue = ''.obs;
  final ValueNotifier valueNotifier = ValueNotifier(true);
  final List<String> genderOptions = [
    GenderTypeConst.MALE,
    GenderTypeConst.FEMALE,
    GenderTypeConst.OTHER,
  ];

  Future<void> saveForm() async {
    if (isAcceptedTc.value) {
      isLoading(true);
      hideKeyBoardWithoutContext();
      Map<String, dynamic> req = {
        "first_name": fisrtNameCont.text.trim(),
        "last_name": lastNameCont.text.trim(),
        "email": emailCont.text.trim(),
        "mobile": '+${mobileCont.text.trim().formatPhoneNumber(selectedCountry.value.phoneCode)}',
        "password": passwordCont.text.trim(),
        'gender' : selectedGenderOption.value,
        UserKeys.userType: LoginTypeConst.LOGIN_TYPE_USER,
      };

      await AuthServiceApis.createUser(request: req).then((value) async {
        toast(value.message.toString(), print: true);
        try {
          final SignInController sCont = Get.find();
          sCont.emailCont.text = emailCont.text.trim();
          sCont.passwordCont.text = passwordCont.text.trim();
          isLoading(true);
          sCont.saveForm().whenComplete(() => isLoading(false));
          Get.offAll(() => DashboardScreen(), binding: BindingsBuilder(() {
            Get.put(HomeScreenController());
          }));
        } catch (e) {
          isLoading(false);
          log('E: $e');
          toast(e.toString(), print: true);
        }
        // Get.offUntil(GetPageRoute(page: () => SignInScreen()), (route) => route.isFirst || route.settings.name == '/$OptionScreen');
      }).catchError((e) {
        isLoading(false);
        toast(e.toString(), print: true);
      }).whenComplete(() => isLoading(false));
    } else {
      toast(locale.value.pleaseAcceptTermsAnd);
    }
  }
}
