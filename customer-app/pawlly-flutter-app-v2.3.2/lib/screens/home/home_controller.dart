import 'package:get/get.dart';
import '../../utils/local_storage.dart';
import '../dashboard/dashboard_res_model.dart';
import 'package:pawlly/utils/library.dart';

class HomeScreenController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isRefresh = false.obs;
  TextEditingController searchCont = TextEditingController();
  Rx<Future<DashboardRes>> getDashboardDetailFuture = Future(() => DashboardRes(data: DashboardData(upcommingBooking: BookingDataModel(service: SystemService(), payment: PaymentDetails(), training: Training())))).obs;

  Rx<DashboardData> dashboardData = DashboardData(upcommingBooking: BookingDataModel(service: SystemService(), payment: PaymentDetails(), training: Training())).obs;

  // late PackageInfoData info;

  @override
  void onReady() {
    init();
    super.onReady();
  }

  void init() async {
    // info = await getPackageInfo();

    getDashboardDetail();
    // _checkAndShowDialog(getContext, getValueFromLocal(AutoUpdateConst.isAutoUpdateOn));
  }

  ///Get ChooseService List
  Future<void> getDashboardDetail({bool isFromSwipRefresh = false}) async {
    if (!isFromSwipRefresh) {
      isLoading(true);
    }
    getAppConfigurations(forceConfigSync: isFromSwipRefresh);
    await getDashboardDetailFuture(HomeServiceApis.getDashboard()).then((value) {
      handleDashboardRes(value);
      try {
        setValueToLocal(APICacheConst.DASHBOARD_RESPONSE, value.toJson());
      } catch (e) {
        log('store DASHBOARD_RESPONSE E: $e');
      }
    }).whenComplete(() => isLoading(false));
  }

  void handleDashboardRes(DashboardRes value) {
    dashboardData(value.data);
    isRefresh(true);
    isRefresh(false);
    serviceList(value.data.systemService);
    taxPercentage(value.data.taxPercentage);

    weightUnits(value.data.weightUnit);
    heightUnits(value.data.heightUnit);
    if (weightUnits.isEmpty) {
      weightUnits = [defaulWEIGHT.value].obs;
    } else {
      defaulWEIGHT(weightUnits.first);
    }
    if (heightUnits.isEmpty) {
      heightUnits = [defaulHEIGHT.value].obs;
    } else {
      defaulHEIGHT(heightUnits.first);
    }
  }

/*  Future<void> _checkAndShowDialog(BuildContext context, bool isAutoUpdateOn) async {

    if (!isAutoUpdateOn) {
      debugPrint('Update dialog suppressed by flag.');
      return;
    }

    final result = await PlayxVersionUpdate.checkVersion(
      options: PlayxUpdateOptions(
        localVersion: info.versionCode,
        minVersion: 'com.pawlly.customer',
        androidPackageName: 'com.pawlly.customer',
      ),

    );

    result.when(
      success: (info) {
        if (info.newVersion != null) {
          showConfirmDialogCustom(
            primaryColor: context.primaryColor,
            getContext,
            negativeText: locale.value.later,
            positiveText: locale.value.updateNow,
            dialogType: DialogType.UPDATE,
            title: locale.value.updateNow,
            subTitle: '${locale.value.updateTo} v${info.newVersion} ${locale.value.available}',
            onAccept: (_) {
              PlayxVersionUpdate.openStore(storeUrl: info.storeUrl);
            },
            onCancel:(_){ Get.back();},
          );
        }
      },
      error: (error) {
        debugPrint('Version check failed: ${error.message}');
      },
    );


    result.when(
      success: (isShown) {
        debugPrint(isShown.canUpdate
            ? 'Update prompt displayed'
            : 'No update needed or user chose later.');
      },
      error: (error) {
        debugPrint('Version check failed: ${error.message}');
      },
    );
  }*/
}
