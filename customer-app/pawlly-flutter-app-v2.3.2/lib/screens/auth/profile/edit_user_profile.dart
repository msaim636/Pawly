import 'package:get/get.dart';
import 'package:pawlly/utils/library.dart';

class EditUserProfileScreen extends StatefulWidget {
  const EditUserProfileScreen({super.key});

  @override
  State<EditUserProfileScreen> createState() => _EditUserProfileScreenState();
}

class _EditUserProfileScreenState extends State<EditUserProfileScreen> {
  final EditUserProfileController editUserProfileController = Get.put(EditUserProfileController());

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String buildMobileNumber() {
    if (editUserProfileController.mobileCont.text.isEmpty) {
      return '';
    } else {
      return '${editUserProfileController.selectedCountry.value.phoneCode}-${editUserProfileController.mobileCont.text.trim()}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AppScaffold(
        appBartitleText: locale.value.editProfile,
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    16.height,
                    Obx(() => ProfilePicWidget(
                          heroTag: editUserProfileController.imageFile.value.path.isNotEmpty
                              ? editUserProfileController.imageFile.value.path
                              : loginUserData.value.profileImage.isNotEmpty
                                  ? loginUserData.value.profileImage
                                  : loginUserData.value.profileImage,
                          profileImage: editUserProfileController.imageFile.value.path.isNotEmpty
                              ? editUserProfileController.imageFile.value.path
                              : loginUserData.value.profileImage.isNotEmpty
                                  ? loginUserData.value.profileImage
                                  : loginUserData.value.profileImage,
                          firstName: loginUserData.value.firstName,
                          lastName: loginUserData.value.lastName,
                          userName: loginUserData.value.userName,
                          showBgCurves: false,
                          showOnlyPhoto: true,
                          onCameraTap: () {
                            editUserProfileController.showBottomSheet(context);
                          },
                          onPicTap: () {
                            editUserProfileController.showBottomSheet(context);
                          },
                        )),
                    32.height,
                    AppTextField(
                      title: locale.value.firstName,
                      textStyle: primaryTextStyle(size: 12),
                      controller: editUserProfileController.fNameCont,
                      focus: editUserProfileController.fNameFocus,
                      nextFocus: editUserProfileController.lNameFocus,
                      textFieldType: TextFieldType.NAME,
                      decoration: inputDecoration(
                        context,
                        hintText: "${locale.value.eG}  ${locale.value.merry}",
                        fillColor: context.cardColor,
                        filled: true,
                      ),
                      suffix: Assets.profileIconsIcUserOutlined.iconImage(fit: BoxFit.contain).paddingAll(14),
                    ).paddingSymmetric(horizontal: 16),
                    16.height,
                    AppTextField(
                      title: locale.value.lastName,
                      textStyle: primaryTextStyle(size: 12),
                      controller: editUserProfileController.lNameCont,
                      focus: editUserProfileController.lNameFocus,
                      nextFocus: editUserProfileController.emailFocus,
                      textFieldType: TextFieldType.NAME,
                      decoration: inputDecoration(
                        context,
                        hintText: "${locale.value.eG}  ${locale.value.doe}",
                        fillColor: context.cardColor,
                        filled: true,
                      ),
                      suffix: Assets.profileIconsIcUserOutlined.iconImage(fit: BoxFit.contain).paddingAll(14),
                    ).paddingSymmetric(horizontal: 16),
                    16.height,
                    AppTextField(
                      title: locale.value.email,
                      textStyle: primaryTextStyle(size: 12),
                      controller: editUserProfileController.emailCont,
                      focus: editUserProfileController.emailFocus,
                      nextFocus: editUserProfileController.mobileFocus,
                      textFieldType: TextFieldType.EMAIL,
                      readOnly: true,
                      enabled: false,
                      decoration: inputDecoration(
                        context,
                        hintText: "${locale.value.eG} merry_456@gmail.com",
                        fillColor: context.cardColor,
                        filled: true,
                      ),
                      suffix: Assets.iconsIcMail.iconImage(fit: BoxFit.contain).paddingAll(14),
                    ).paddingSymmetric(horizontal: 16),
                    16.height,
                    Text(locale.value.contactNumber, style: primaryTextStyle()).paddingSymmetric(horizontal: 16),
                    4.height,
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Country code ...
                        Container(
                          height: 48.0,
                          decoration: BoxDecoration(
                            color: context.cardColor,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Center(
                            child: ValueListenableBuilder(
                              valueListenable: editUserProfileController.valueNotifier,
                              builder: (context, value, child) => Row(
                                children: [
                                  Obx(() {
                                    return Text(
                                      "+${editUserProfileController.selectedCountry.value.phoneCode}",
                                      style: primaryTextStyle(size: 12),
                                    );
                                  }),
                                  Icon(
                                    Icons.arrow_drop_down,
                                    color: textSecondaryColorGlobal,
                                  )
                                ],
                              ).paddingOnly(left: 8),
                            ),
                          ),
                        ).onTap(() => editUserProfileController.changeCountry(context)),
                        10.width,
                        // Mobile number text field...
                        AppTextField(
                          textFieldType: isAndroid ? TextFieldType.PHONE : TextFieldType.NAME,
                          controller: editUserProfileController.mobileCont,
                          focus: editUserProfileController.mobileFocus,
                          nextFocus: editUserProfileController.addressFocus,
                          errorThisFieldRequired: locale.value.thisFieldIsRequired,
                          isValidationRequired: false,
                          maxLength: 15,
                          suffix: Assets.iconsIcCall.iconImage(fit: BoxFit.contain).paddingAll(14),
                          decoration: inputDecoration(
                            context,
                            hintText: "${locale.value.eG}  1-2188219848",
                            fillColor: context.cardColor,
                            filled: true,
                          ),
                        ).expand(),
                      ],
                    ).paddingSymmetric(horizontal: 16),
                    16.height,
                    Text(locale.value.gender, style: primaryTextStyle()).paddingSymmetric(horizontal: 16),
                    8.height,
                    Obx(() {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: editUserProfileController.genderOptions.map((gender) {
                          final isSelected = gender == editUserProfileController.selectedGenderOption.value;

                          return GestureDetector(
                            onTap: () {
                              editUserProfileController.selectedGenderOption(gender);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? primaryColor : context.cardColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? primaryColor : Colors.grey.shade500,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                textAlign: TextAlign.center,
                                gender.capitalizeFirstLetter(),
                                style: secondaryTextStyle(color: isSelected ? Colors.white : null),
                              ),
                            ).paddingOnly(left: gender == GenderTypeConst.MALE ? 0 : 8),
                          ).expand();
                        }).toList(),
                      ).paddingSymmetric(horizontal: 16);
                    }),
                    16.height,
                    AppTextField(
                      isValidationRequired: false,
                      title: locale.value.address,
                      textStyle: primaryTextStyle(size: 12),
                      textFieldType: TextFieldType.MULTILINE,
                      controller: editUserProfileController.addressCont,
                      focus: editUserProfileController.addressFocus,
                      errorThisFieldRequired: locale.value.thisFieldIsRequired,
                      decoration: inputDecoration(
                        context,
                        hintText: "${locale.value.eG} 123, ${locale.value.mainStreet}",
                        fillColor: context.cardColor,
                        filled: true,
                      ),
                    ).paddingSymmetric(horizontal: 16),
                    32.height,
                    AppButton(
                      width: Get.width,
                      text: locale.value.update,
                      textStyle: appButtonTextStyleWhite,
                      onTap: () async {
                        ifNotTester(() async {
                          if (await isNetworkAvailable()) {
                            editUserProfileController.updateUserProfile();
                          } else {
                            toast(locale.value.yourInternetIsNotWorking);
                          }
                        });
                      },
                    ).paddingSymmetric(horizontal: 16),
                    24.height,
                  ],
                ),
              ),
            ),
            Obx(() => const LoaderWidget().visible(editUserProfileController.isLoading.value)),
          ],
        ),
      ),
    );
  }
}