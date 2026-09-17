import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pawlly/utils/extention/string_extentsion.dart';
import '../../../utils/local_storage.dart';
import 'package:pawlly/utils/library.dart';

class EditUserProfileController extends GetxController {
  //Constructor region
  EditUserProfileController({this.isProfilePhoto = false});

  bool isProfilePhoto;

  //Constructor endregion
  RxBool isLoading = false.obs;
  Rx<File> imageFile = File("").obs;
  XFile? pickedFile;

  TextEditingController fNameCont = TextEditingController();
  TextEditingController lNameCont = TextEditingController();
  TextEditingController emailCont = TextEditingController();
  TextEditingController mobileCont = TextEditingController();
  TextEditingController addressCont = TextEditingController();

  FocusNode fNameFocus = FocusNode();
  FocusNode lNameFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode mobileFocus = FocusNode();
  FocusNode addressFocus = FocusNode();

  Rx<Country> selectedCountry = defaultCountry.obs;
  RxString selectedGenderOption = GenderTypeConst.MALE.obs;
  RxString countryCode = ''.obs;

  RxString groupValue = ''.obs;
  final ValueNotifier valueNotifier = ValueNotifier(true);
  final List<String> genderOptions = [
    GenderTypeConst.MALE,
    GenderTypeConst.FEMALE,
    GenderTypeConst.OTHER,
  ];
  @override
  void onInit() {
    init();
    super.onInit();
  }

  Future<void> init() async {
    isLoading(true);
    loginUserData.value.mobile = await getUserProfileDetail();
    fNameCont.text = loginUserData.value.firstName;
    lNameCont.text = loginUserData.value.lastName;
    try {
      mobileCont.text = loginUserData.value.mobile.extractPhoneCodeAndNumber.$2;
      selectedCountry(CountryParser.parsePhoneCode(loginUserData.value.mobile.extractPhoneCodeAndNumber.$1));
      countryCode("+${selectedCountry.value.phoneCode}");
    } catch (e) {
      selectedCountry(Country.from(json: defaultCountry.toJson()));
      mobileCont.text = loginUserData.value.mobile.trim();
      countryCode("+${selectedCountry.value.phoneCode}");
    }
    mobileCont.text = loginUserData.value.mobile.splitAfter(' ');
    emailCont.text = loginUserData.value.email;
    addressCont.text = loginUserData.value.address;
    isLoading(false);
  }

  Future<void> updateUserProfile() async {
    if (!isProfilePhoto) {
      hideKeyBoardWithoutContext();
    }
    isLoading(true);

    AuthServiceApis.updateProfile(
      firstName: isProfilePhoto ? loginUserData.value.firstName : fNameCont.text.trim(),
      lastName: lNameCont.text.trim(),
      mobile: '+${mobileCont.text.trim().formatPhoneNumber(selectedCountry.value.phoneCode)}',
      gender: selectedGenderOption.value,
      address: addressCont.text.trim(),
      imageFile: imageFile.value.path.isNotEmpty ? imageFile.value : null,
      onSuccess: (data) {
        isLoading(false);
        if (data != null) {
          if ((data as String).isJson()) {
            log("Response: ${jsonDecode(data)}");
            LoginResponse loginResponseModel = LoginResponse.fromJson(jsonDecode(data));
            loginUserData(UserData(
              id: loginUserData.value.id,
              firstName: loginResponseModel.userData.firstName,
              lastName: loginResponseModel.userData.lastName,
              userName: "${loginResponseModel.userData.firstName} ${loginResponseModel.userData.lastName}",
              mobile: loginResponseModel.userData.mobile,
              email: loginUserData.value.email,
              userRole: loginUserData.value.userRole,
              address: loginResponseModel.userData.address,
              apiToken: loginUserData.value.apiToken,
              profileImage: loginResponseModel.userData.profileImage,
              loginType: loginUserData.value.loginType,
            ));
            setValueToLocal(SharedPreferenceConst.USER_DATA, loginUserData.toJson());
            Get.back();
          }
        }
      },
    ).then((data) {
      toast(locale.value.profileUpdatedSuccessfully);
    }).catchError((e) {
      isLoading(false);
      toast(e.toString());
    });
  }

  void _getFromGallery() async {
    pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1800, maxHeight: 1800);
    if (pickedFile != null) {
      imageFile(File(pickedFile!.path));
      if (isProfilePhoto) {
        showConfirmDialogChoosePhoto();
      }
      // setState(() {});
    }
  }

  Future<void> _getFromCamera() async {
    pickedFile = await ImagePicker().pickImage(source: ImageSource.camera, maxWidth: 1800, maxHeight: 1800);
    if (pickedFile != null) {
      imageFile(File(pickedFile!.path));
      if (isProfilePhoto) {
        showConfirmDialogChoosePhoto();
      }
    }
  }

  void showBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      backgroundColor: context.cardColor,
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SettingItemWidget(
              title: locale.value.gallery,
              leading: const Icon(Icons.image, color: primaryColor),
              onTap: () async {
                _getFromGallery();
                finish(context);
              },
            ),
            SettingItemWidget(
              title: locale.value.camera,
              leading: const Icon(Icons.camera, color: primaryColor),
              onTap: () {
                _getFromCamera();
                finish(context);
              },
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
            ),
          ],
        ).paddingAll(16.0);
      },
    );
  }

  void showConfirmDialogChoosePhoto() {
    showConfirmDialogCustom(
      getContext,
      primaryColor: primaryColor,
      negativeText: locale.value.cancel,
      positiveText: locale.value.yes,
      onAccept: (_) {
        ifNotTester(() async {
          if (await isNetworkAvailable()) {
            updateUserProfile();
          } else {
            toast(locale.value.yourInternetIsNotWorking);
          }
        });
      },
      dialogType: DialogType.ACCEPT,
      customCenterWidget: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.file(
            imageFile.value,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              alignment: Alignment.center,
              width: 100,
              height: 100,
              decoration: boxDecorationDefault(shape: BoxShape.circle, color: primaryColor.withValues(alpha: 0.4)),
              child: Text(
                "${StrEtx(loginUserData.value.firstName).firstLetter.toUpperCase()}${StrEtx(loginUserData.value.lastName).firstLetter.toUpperCase()}",
                style: const TextStyle(fontSize: 100 * 0.3, color: Colors.white),
              ),
            ),
          ).cornerRadiusWithClipRRect(45),
        ],
      ).paddingSymmetric(vertical: 16),
      title: locale.value.wouldYouLikeToSetProfilePhotoAsEmployee,
    );
  }

  Future<void> changeCountry(BuildContext context) async {
    showCountryPicker(
      context: context,
      countryListTheme: CountryListThemeData(
        textStyle: secondaryTextStyle(color: textSecondaryColorGlobal),
        searchTextStyle: primaryTextStyle(),
        inputDecoration: InputDecoration(
          labelText: "search",
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: const Color(0xFF8C98A8).withValues(alpha: 0.2),
            ),
          ),
        ),
      ),

      showPhoneCode: true,
      // optional. Shows phone code before the country name.
      onSelect: (Country country) {
        selectedCountry(country);
      },
    );
  }

  Future<String> getUserProfileDetail() async {
    GetUserProfileResponse response = await AuthServiceApis.viewProfile(id: loginUserData.value.id);
    return response.data.mobile;
  }
}
