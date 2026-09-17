import 'package:get/get.dart';

import '../../../../utils/library.dart';

class HomeController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isReviewLoading = false.obs;
  Rx<Future<DashboardRes>> getDashboardDetailFuture = Future(() => DashboardRes(data: DashboardData(petstoreDetail: PetStoreDetail()))).obs;
  Rx<DashboardData> dashboardData = DashboardData(petstoreDetail: PetStoreDetail()).obs;
  late PackageInfoData info;

  @override
  void onReady() {
    init();
    super.onReady();
  }

  void init() async {
    info = await getPackageInfo();
    try {
      final dashboardResFromLocal = getValueFromLocal(APICacheConst.DASHBOARD_RESPONSE);
      getAppConfigurations();
      if (dashboardResFromLocal != null) {
        handleDashboardRes(DashboardRes.fromJson(dashboardResFromLocal));
      }
    } catch (e) {
      log('handleDashboardRes from cache E: $e');
    }
    getDashboardDetail();
    // _checkAndShowDialog(getContext, getValueFromLocal(AutoUpdateConst.isAutoUpdateOn));

  }

  ///Get ChooseService List
  Future<void> getDashboardDetail({bool isFromSwipeRefresh = false}) async {
    if (!isFromSwipeRefresh) {
      isLoading(true);
      isReviewLoading(true);
    }
    getAppConfigurations(forceConfigSync: isFromSwipeRefresh);
    await getDashboardDetailFuture(HomeServiceApi.getDashboard()).then((value) {
      handleDashboardRes(value);
      try {
        setValueToLocal(APICacheConst.DASHBOARD_RESPONSE, value.toJson());
      } catch (e) {
        log('store DASHBOARD_RESPONSE E: $e');
      }
    }).whenComplete(() {
      isLoading(false);
      isReviewLoading(false);
    });
  }

  void handleDashboardRes(DashboardRes value) {
    dashboardData(value.data);
  }

  /*Future<void> _checkAndShowDialog(BuildContext context, bool isAutoUpdateOn) async {

    if (!isAutoUpdateOn) {
      debugPrint('Update dialog suppressed by flag.');
      return;
    }

    final result = await PlayxVersionUpdate.showUpdateDialog(
      context: context,
      options: PlayxUpdateOptions(

        androidPackageName: 'com.pawlly.employee',
        iosBundleId: 'com.Innoquad Technologies LLP.id6458044939',
        minVersion: info.versionCode,
      ),

      uiOptions: PlayxUpdateUIOptions(
        displayType: PlayxUpdateDisplayType.dialog,
        title: (info) => '${locale.value.updateTo} v${info.newVersion} ${locale.value.available}',
        titleTextStyle: primaryTextStyle(),
        description: (info) =>
        locale.value.aVertionUpdateIsAvailable,
        descriptionTextStyle: secondaryTextStyle(),
        updateButtonText: locale.value.updateNow,
        dismissButtonText: locale.value.later,
        showReleaseNotes: true,
        releaseNotesTitleTextStyle: primaryTextStyle(),
        releaseNotesTextStyle: secondaryTextStyle(),
      ),
    );

    result.when(
      success: (isShown) {
        debugPrint(isShown
            ? 'Update prompt displayed'
            : 'No update needed or user chose later.');
      },
      error: (error) {
        debugPrint('Version check failed: ${error.message}');
      },
    );
  }*/
}
