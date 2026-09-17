import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pawlly/utils/library.dart';

class ProductReviewDialog extends StatefulWidget {
  final bool addReview;
  final RxList<XFile>? imageList;

  const ProductReviewDialog(this.addReview, {this.imageList, super.key});

  @override
  State<ProductReviewDialog> createState() => _ProductReviewDialogState();
}

class _ProductReviewDialogState extends State<ProductReviewDialog> {
  final OrderDetailController orderDetailController = Get.find();

  @override
  void initState() {
    super.initState();
    if (widget.imageList != null && widget.imageList!.isNotEmpty) {
      orderDetailController.mergePickedFiles(widget.imageList!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: Get.width,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: boxDecorationDefault(
                  color: primaryColor,
                  borderRadius: radiusOnly(topRight: 8, topLeft: 8),
                ),
                child: Row(
                  children: [
                    Text(locale.value.yourReview, style: boldTextStyle(color: Colors.white)).expand(),
                    IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white, size: 16),
                      onPressed: () => finish(context),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: boxDecorationDefault(color: context.cardColor),
                    child: Row(
                      children: [
                        Text(locale.value.yourReview, style: secondaryTextStyle()),
                        16.width,
                        Obx(
                          () => RatingBarWidget(
                            onRatingChanged: (rating) {
                              orderDetailController.selectedRating(rating);
                            },
                            activeColor: getRatingBarColor(orderDetailController.selectedRating.value),
                            inActiveColor: ratingBarColor,
                            rating: orderDetailController.selectedRating.value,
                            size: 18,
                          ).expand(),
                        ),
                      ],
                    ),
                  ),
                  16.height,
                  AppTextField(
                    controller: orderDetailController.reviewCont,
                    textFieldType: TextFieldType.OTHER,
                    minLines: 5,
                    maxLines: 10,
                    enableChatGPT: appConfigs.value.enableChatGpt,
                    promptFieldInputDecorationChatGPT: inputDecoration(
                      context,
                      hintText: locale.value.writeHere,
                      fillColor: context.scaffoldBackgroundColor,
                      filled: true,
                    ),
                    testWithoutKeyChatGPT: appConfigs.value.testWithoutKey,
                    loaderWidgetForChatGPT: const ChatGPTLoadingWidget(),
                    textCapitalization: TextCapitalization.sentences,
                    decoration: inputDecoration(
                      context,
                      labelText: "${locale.value.enterYourReview} ('${locale.value.optional}')",
                    ).copyWith(fillColor: context.cardColor, filled: true),
                  ),
                  Obx(() {
                    // Snapshot to prevent concurrent modification
                    final files = List<XFile>.from(orderDetailController.pickedFile);
                    return AnimatedWrap(
                      spacing: 10,
                      itemCount: files.length,
                      itemBuilder: (context, index) {
                        return Image.file(
                          File(files[index].path),
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ).cornerRadiusWithClipRRect(defaultRadius);
                      },
                    ).paddingTop(16).visible(files.isNotEmpty);
                  }),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: boxDecorationDefault(
                      border: Border.all(color: primaryColor),
                      color: context.cardColor,
                    ),
                    child: TextIcon(
                      text: locale.value.addPhoto,
                      textStyle: primaryTextStyle(),
                      prefix: const Icon(Icons.camera_alt_outlined, color: primaryColor, size: 16),
                      edgeInsets: EdgeInsets.zero,
                      onTap: () {
                        hideKeyboard(context);
                        orderDetailController.showBottomSheet(context);
                      },
                    ),
                  ).paddingTop(16),
                  32.height,
                  Row(
                    children: [
                      AppButton(
                        text: locale.value.cancel,
                        textColor: orderDetailController.isUpdate.value ? Colors.red : textPrimaryColorGlobal,
                        color: context.cardColor,
                        onTap: () => finish(context),
                      ).expand(),
                      16.width,
                      AppButton(
                        textColor: Colors.white,
                        text: locale.value.submit,
                        color: context.primaryColor,
                        onTap: () {
                          if (orderDetailController.selectedRating.value == 0) {
                            toast(locale.value.ratingIsRequired);
                          } else {
                            orderDetailController.submit(widget.addReview);
                          }
                        },
                      ).expand(),
                    ],
                  ),
                ],
              ).paddingAll(16),
            ],
          ),
        ),
        Obx(() => const LoaderWidget().visible(orderDetailController.isLoading.value).withSize(height: 80, width: 80)),
      ],
    );
  }
}
