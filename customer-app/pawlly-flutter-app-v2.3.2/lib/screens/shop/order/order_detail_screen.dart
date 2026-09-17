import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/route_manager.dart';
import 'package:pawlly/utils/library.dart';

class OrderDetailScreen extends StatelessWidget {
  OrderDetailScreen({super.key});

  final OrderDetailController orderDetailController = Get.put(OrderDetailController());

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      actions: [
        Obx(() {
          return TextButton(
            onPressed: () async {
              await orderDetailController.getInvoice(orderDetailController.orderId.value);
            },
            child: Text(locale.value.dowanloadInvoice),
          ).paddingSymmetric(horizontal: 16).visible(orderDetailController.isShowInvoiceOption.value);
        }),
      ],
      appBarTitle: Obx(
        () => Text(
          '#${orderDetailController.orderCode.value}',
          style: primaryTextStyle(size: 16, decoration: TextDecoration.none),
        ),
      ),
      isLoading: orderDetailController.isLoading,
      body: Obx(
        () => SnapHelperWidget(
          future: orderDetailController.getOrderDetailFuture.value,
          loadingWidget: const LoaderWidget(),
          errorBuilder: (error) {
            return NoDataWidget(
              title: error,
              retryText: locale.value.reload,
              imageWidget: const ErrorStateWidget(),
              onRetry: () {
                orderDetailController.isLoading(true);

                orderDetailController.init();
              },
            );
          },
          onSuccess: (snap) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              orderDetailController.isShowInvoiceOption(
                snap.data.paymentStatus.toLowerCase().contains(PaymentStatus.PAID),
              );
              orderDetailController.orderId(snap.data.id);
            });

            if (snap.data.id.isNegative) {
              return NoDataWidget(
                title: locale.value.noDetailsFound,
                retryText: locale.value.reload,
                onRetry: () {
                  orderDetailController.isLoading(true);
                  orderDetailController.init();
                },
              );
            }

            return AnimatedScrollView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                OrderInformationComponent(orderData: snap.data),
                16.height,
                AboutProductComponent(
                  productData: snap.data.orderDetails.productDetails,
                  deliveryStatus: snap.data.deliveryStatus,
                ),
                16.height,
                OtherProductItemsComponent(
                  otherProductItemList: snap.data.orderDetails.otherOrderItems,
                ),
                16.height,
                OrderPaymentInfoComponent(orderData: snap.data),
                16.height,
                if (snap.data.orderDetails.otherOrderItems.isNotEmpty)
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('${locale.value.grandTotal}: ', style: primaryTextStyle(size: 14)),
                          PriceWidget(price: snap.data.orderDetails.grandTotal, size: 14),
                        ],
                      ),
                    ],
                  ),
                ShippingDetailComponent(shippingData: snap.data),
                16.height,
              ],
              onSwipeRefresh: () async {
                return orderDetailController.init();
              },
            );
          },
        ),
      ),
    );
  }
}
