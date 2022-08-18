import 'package:anpha_petrol_smartgas/animations/slide_page_route.dart';
import 'package:anpha_petrol_smartgas/core/enum_definition.dart';
import 'package:anpha_petrol_smartgas/core/global_manager.dart';
import 'package:anpha_petrol_smartgas/core/helper.dart';
import 'package:anpha_petrol_smartgas/core/utils/image_cache_manager.dart';
import 'package:anpha_petrol_smartgas/core/utils/validator.dart';
import 'package:anpha_petrol_smartgas/models/m_device_history.dart';
import 'package:anpha_petrol_smartgas/models/o_response.dart';
import 'package:anpha_petrol_smartgas/pages/devices/device_reschedule_page.dart';
import 'package:anpha_petrol_smartgas/pages/order/order_editor_page.dart';
import 'package:anpha_petrol_smartgas/repositories/r_devices.dart';
import 'package:anpha_petrol_smartgas/repositories/r_user.dart';
import 'package:anpha_petrol_smartgas/widgets/custom_app_bar.dart';
import 'package:anpha_petrol_smartgas/widgets/custom_dialog/custom_alert_dialog.dart';
import 'package:anpha_petrol_smartgas/widgets/custom_text_field.dart';
import 'package:anpha_petrol_smartgas/widgets/qr_scanner_page.dart';
import 'package:anpha_petrol_smartgas/widgets/ui_button.dart';
import 'package:cupertino_stepper/cupertino_stepper.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_settings/open_settings.dart';

import '../../animations/fade_page_route.dart';
import '../../core/network/api.dart';
import '../../core/utils/toast_utils.dart';
import '../../widgets/camera_picker/camera_picker.dart';
import '../../widgets/camera_picker/image_gallery.dart';
import '../../widgets/custom_dialog/custom_loading_dialog.dart';
import '../../widgets/custom_dialog/custom_note_dialog.dart';
import '../delivery/shift_selection_page.dart';

class SetupPage extends StatefulWidget {
  final int scanType;
  final MDeviceHistory? task;

  const SetupPage({
    Key? key,
    this.task,
    required this.scanType,
  }) : super(key: key);

  @override
  _SetupPageState createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  final double _buttonHeight = 38;
  final double _textFieldHeight = 38;
  final double _radius = 8.0;
  final double _smallSpacing = GlobalManager.styles.smallSpacing;
  final double _mediumSpacing = GlobalManager.styles.mediumSpacing;
  final double _bigSpacing = GlobalManager.styles.bigSpacing;

  final TextEditingController _firstDeviceEditingController =
      TextEditingController();
  final TextEditingController _urlEditingController =
  TextEditingController();
  final TextEditingController _threshold1EditingController =
  TextEditingController();
  final TextEditingController _threshold2EditingController =
  TextEditingController();
  final TextEditingController _secondDeviceEditingController =
      TextEditingController();
  final TextEditingController _noteEditingController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  final FocusNode _firstDeviceFocusNode = FocusNode();
  final FocusNode _urlFocusNode = FocusNode();
  final FocusNode _threshold1FocusNode = FocusNode();
  final FocusNode _threshold2FocusNode = FocusNode();
  final FocusNode _secondDeviceFocusNode = FocusNode();
  final FocusNode _noteFocusNode = FocusNode();

  final _filterStatusKey = GlobalKey<DropdownSearchState<String>>();

  bool _isScanning = false;
  late MDeviceHistory _task;
  late int _taskType;
  final List<String> _selectedImages = [];
  final List<String> _selectedContractImages = [];
  static const String ADD_ITEM = "ADD_ITEM";
  int _secondDeviceStatus = -1, _firstDeviceStatus = -1;
  ValueNotifier<int>? _deliveryFailedNotifier;

  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _selectedImages.add(ADD_ITEM);
    _selectedContractImages.add(ADD_ITEM);
    if (widget.task == null) {
      _task = MDeviceHistory(id: 0);
    } else {
      _task = widget.task!;
    }
    _taskType = widget.scanType;

    if (_taskType == DeviceTaskType.fix || _taskType == DeviceTaskType.revoke) {
      _firstDeviceEditingController.text = _task.device_code ?? "";
      _secondDeviceEditingController.addListener(() {
        if (_secondDeviceStatus != -1) {
          setState(() {
            _secondDeviceStatus = -1;
          });
        }
      });

      _firstDeviceEditingController.addListener(() {
        if (_firstDeviceStatus != -1) {
          setState(() {
            _firstDeviceStatus = -1;
          });
        }
      });
    } else {
      _firstDeviceEditingController.addListener(() {
        if (_secondDeviceStatus != -1) {
          setState(() {
            _secondDeviceStatus = -1;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _renderFilterDropdown(GlobalKey key, String title, List<String> items,
      String? selectedItem, bool showSearchBox, ValueChanged onChanged) {
    return DropdownSearch<String>(
      key: key,
      popupTitle: Container(
        margin: const EdgeInsets.only(left: 10, right: 10, top: 12, bottom: 4),
        child: Text(
          title,
          style: TextStyle(
              color: GlobalManager.colors.gray808080,
              fontWeight: FontWeight.w500,
              fontSize: 12),
        ),
      ),
      itemAsString: (value) {
        return value?.split("|").last ?? "";
      },
      selectedItem: selectedItem,
      mode: Mode.DIALOG,
      showSearchBox: showSearchBox,
      items: items,
      dropdownSearchDecoration: InputDecoration(
        labelText: title,
      ),
      onChanged: onChanged,
      showClearButton: true,
      searchDelay: const Duration(milliseconds: 0),
      showSelectedItems: true,
    );
  }

  CupertinoStepper _buildStepper(StepperType type) {
    final canCancel = _currentStep > 0;
    final canContinue = _currentStep < 3;
    return CupertinoStepper(
      controlsBuilder: (BuildContext context, controls) {
        return Padding(
          padding: EdgeInsets.only(top: 0),
          child: Row(
            children: <Widget>[
              Expanded(child: Container()),
              // FlatButton(
              //   onPressed: controls.onStepContinue,
              //   child: Text('TIẾP TỤC',
              //       style: TextStyle(
              //           fontSize: 15,
              //           fontWeight: FontWeight.bold,
              //           color: GlobalManager.colors.majorColor())),
              // ),
            ],
          ),
        );
      },
      type: type,
      currentStep: _currentStep,
      onStepTapped: (step) => setState(() => _currentStep = step),
      onStepCancel: canCancel ? () => setState(() => --_currentStep) : null,
      onStepContinue: canContinue ? () => setState(() => ++_currentStep) : null,
      steps: [
        // for (var i = 0; i < 3; ++i)
        //   _buildStep(
        //     title: Text('Step ${i + 1}'),
        //     isActive: i == _currentStep,
        //     state: i == _currentStep
        //         ? StepState.editing
        //         : i < _currentStep ? StepState.complete : StepState.indexed,
        //   ),
        // _buildStep(
        //   title: Text('Error'),
        //   state: StepState.error,
        // ),
        // _buildStep(
        //   title: Text('Disabled'),
        //   state: StepState.disabled,
        // )
        _buildStep1(
            title: Text(
              "Bước 1",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            state: StepState.indexed),
        _buildStep2(
            title: Text(
              "Bước 2",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            state: StepState.indexed),
        _buildStep3(
            title: Text(
              "Bước 3",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            state: StepState.indexed),
        _buildStep4(
            title: Text(
              "Bước 4",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            state: StepState.indexed),
      ],
    );
  }

  Step _buildStep1({
    required Widget title,
    StepState state = StepState.indexed,
    bool isActive = false,
  }) {
    return Step(
      title: title,
      subtitle: Text(
        'Chọn khách hàng',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
      ),
      state: state,
      isActive: isActive,
      content: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: _renderFilterDropdown(
            _filterStatusKey,
            GlobalManager.strings.customer!,
            [
              "1|ID: 1 - Kichi Kichi",
              "2|ID: 2 - Kichi Kichi",
              "3|ID: 3 - Kichi Kichi",
              "4|ID: 4 - Kichi Kichi",
              "5|ID: 5 - Kichi Kichi",
              "6|ID: 6 - Kichi Kichi",
              "7|ID: 7 - Kichi Kichi",
              "8|ID: 8 - Kichi Kichi",
              "9|ID: 9 - Kichi Kichi",
              "10|ID: 10 - Kichi Kichi",
            ],
            null, // value.selectedOwner,
            true, (newValue) {
          // value.setFilterOwner(newValue);
        }),
      ),
    );
  }

  Step _buildStep2({
    required Widget title,
    StepState state = StepState.indexed,
    bool isActive = false,
  }) {
    return Step(
      title: title,
      subtitle: Text(
        'Kết nối Wifi',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
      ),
      state: state,
      isActive: isActive,
      content: Column(
        children: [
          SizedBox(height: 12,),
          Text("Kết nối với mạng Wifi của thiết bị Smart Gas"),
          SizedBox(height: 12,),
          Container(
            margin: EdgeInsets.only(left: 0, right: 0),
            child: UIButton(
              text: "Kết nối",
              color: GlobalManager.colors.majorColor(),
              textSize: 13,
              fontWeight: FontWeight.w400,
              enableShadow: false,
              onTap: () {
                OpenSettings.openWIFISetting();
              },
              height: _buttonHeight,
            ),
          )
        ],
      ),
    );
  }

  Step _buildStep3({
    required Widget title,
    StepState state = StepState.indexed,
    bool isActive = false,
  }) {
    return Step(
      title: title,
      subtitle: Text(
        'Thiết lập',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
      ),
      state: state,
      isActive: isActive,
      content: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            SizedBox(
              height: 2 * _smallSpacing,
            ),
            _renderCustomerInfo(),
            SizedBox(
              height: _bigSpacing,
            ),
            _renderScanDevice(),
            SizedBox(
              height: _mediumSpacing,
            ),
            _renderPictureNote(),
            SizedBox(
              height: _bigSpacing + 0,
            ),
          ],
        ),
      ),
    );
  }

  Step _buildStep4({
    required Widget title,
    StepState state = StepState.indexed,
    bool isActive = false,
  }) {
    return Step(
      title: title,
      subtitle: Text(
        'Hoàn tất',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
      ),
      state: state,
      isActive: isActive,
      content: Text("Đã hoàn tất lắp đặt"),
    );
  }

  _showDialogImages(List<String> images, int initPos) {
    List<String> showImages = [];
    showImages.addAll(images);
    if (images.isNotEmpty && images.last == ADD_ITEM) {
      showImages.removeLast();
    }
    pushPageWithRoute(
      context,
      FadePageRoute(
        page: ImageGalleryScreen(
          items: showImages,
          currentIndex: initPos,
        ),
      ),
    );
  }

  /// [START] CUSTOMER
  Widget _renderCustomerInfo() {
    if (!_task.hasAccount()) {
      return const SizedBox();
    }
    return Container(
      margin: EdgeInsets.symmetric(horizontal: _bigSpacing),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(_radius)),
        boxShadow: [GlobalManager.styles.customBoxShadowAll],
      ),
      padding: EdgeInsets.all(_mediumSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _task.account_name ?? '',
                textScaleFactor: 1.0,
                style: TextStyle(
                  color: GlobalManager.colors.blue4178D4,
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),
                maxLines: 2,
              ),
              Text(
                _task.account_phone ?? '-',
                textScaleFactor: 1.0,
                maxLines: 1,
                style: TextStyle(
                  color: GlobalManager.colors.grayAEAEB2,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 4.0,
          ),
          _taskType != DeviceTaskType.setup &&
                  (_task.device_code?.isNotEmpty ?? false)
              ? Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _task.device_code ?? '',
                      textScaleFactor: 1.0,
                      style: TextStyle(
                        color: GlobalManager.colors.blue4178D4,
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                    ),
                    Text(
                      DeviceStatusType.getText(_task.device_status ?? 0),
                      textScaleFactor: 1.0,
                      maxLines: 1,
                      style: TextStyle(
                        color:
                            DeviceStatusType.getColor(_task.device_status ?? 0),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                )
              : Container(),
          _taskType != DeviceTaskType.setup &&
                  (_task.device_code?.isNotEmpty ?? false)
              ? const SizedBox(
                  height: 4.0,
                )
              : Container(),
          Text(
            _task.account_address ?? '-',
            textScaleFactor: 1.0,
            style: TextStyle(
              color: GlobalManager.colors.grayAEAEB2,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(
            height: _smallSpacing,
          ),
          Text(
            DeviceTaskStatus.getText(_task.task, _task.status),
            textScaleFactor: 1.0,
            style: TextStyle(
              color: DeviceTaskStatus.getColor(_task.status,
                  RUser.currentUserInfo.id == (_task.staff_id ?? 0)),
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(
            height: _smallSpacing,
          ),
          if (_taskType != DeviceTaskType.revoke) ...[
            _renderQuickOrder(),
          ]
        ],
      ),
    );
  }

  String getMessageDone() {
    switch (_taskType) {
      case DeviceTaskType.setup:
        return GlobalManager.strings.deviceTaskSetupDone!;
      case DeviceTaskType.revoke:
        return GlobalManager.strings.deviceTaskRevokeDone!;
      case DeviceTaskType.check:
        return GlobalManager.strings.deviceTaskFixDone!;
    }
    return "";
  }

  Widget _renderQuickOrder() {
    return Container(
      decoration: BoxDecoration(
          color: GlobalManager.colors.majorColor().withOpacity(0.1),
          borderRadius: BorderRadius.all(Radius.circular(_radius)),
          border: Border.all(
            color: GlobalManager.colors.green56C38F,
            width: 1,
          )),
      margin: const EdgeInsets.only(top: 4),
      height: 30,
      child: TextButton(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.all(0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(_radius)),
          ),
        ),
        onPressed: () async {
          bool result = await _gotoPage(OrderEditorPage(
            task: _task,
          ));
          if (result) {}
        },
        child: Center(
          child: Text(
            GlobalManager.strings.quickOrder!,
            textScaleFactor: 1.0,
            style: TextStyle(
              color: GlobalManager.colors.majorColor(),
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  /// [END] CUSTOMER

  /// [START] DEVICE SCANNING
  Widget _renderRowTextField(
    String label,
    String hint,
    TextEditingController editingController,
    FocusNode focusNode,
    TextInputType inputType,
    TextInputAction inputAction, {
    Widget? rightIcon,
    bool required = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 13,
              color: GlobalManager.colors.blue4178D4,
              height: 1.3,
              fontWeight: FontWeight.w400,
            ),
            text: label + ' ',
            children: [
              TextSpan(
                text: required ? ' *' : '',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: GlobalManager.colors.redEC1E37,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: CustomTextField(
                textSize: 12,
                hintText: hint,
                textInputType: TextInputType.text,
                textInputAction: TextInputAction.done,
                textController: editingController,
                focusNode: focusNode,
                height: _textFieldHeight,
                horizontalPadding: 0,
                verticalPadding: 0,
                borderTextFormFieldColor:
                    GlobalManager.colors.grayE8E8E8.withOpacity(0.5),
                bgColor: Colors.white,
                radius: 8,
              ),
            ),
            SizedBox(
              width: _smallSpacing,
            ),
            rightIcon ?? const SizedBox(),
          ],
        ),
      ],
    );
  }

  void checkStatusDevice(bool isFirst) async {
    setState(() {
      if (isFirst) {
        _firstDeviceStatus = -1;
      } else {
        _secondDeviceStatus = -1;
      }
    });
    String deviceCode;
    if (isFirst) {
      deviceCode = _firstDeviceEditingController.text.trim();
    } else {
      deviceCode = _secondDeviceEditingController.text.trim();
    }
    if (deviceCode.isEmpty) {
      showCustomAlertDialog(
        context,
        title: GlobalManager.strings.error,
        content: GlobalManager.strings.validateDeviceCodeEmpty,
        firstButtonText: GlobalManager.strings.ok!,
        firstButtonFunction: () => pop(context),
      );
      return;
    }

    AppResponse result = await RDevices.updateDeviceStatus(
      oldDeviceCode: "",
      deviceCode: deviceCode,
      phoneNumber: _task.account_phone ?? "",
      type: DeviceTaskType.check,
    );

    if (result.success) {
      setState(() {
        if (isFirst) {
          _firstDeviceStatus = result.data["data"];
        } else {
          _secondDeviceStatus = result.data["data"];
        }
      });
    } else {
      showCustomAlertDialog(
        context,
        title: GlobalManager.strings.error,
        content: result.systemMessage,
        firstButtonText: GlobalManager.strings.ok!,
        firstButtonFunction: () => pop(context),
      );
    }
  }

  Widget _renderFirstScanningDevice() {
    Widget scanWidget = Row(
      children: [
        _taskType == DeviceTaskType.fix
            ? SizedBox(
                width: 50,
                child: TextButton(
                  onPressed: () {
                    checkStatusDevice(true);
                  },
                  child: ImageCacheManager.getImage(
                    url: GlobalManager.myIcons.svgCheckStatus,
                    fit: BoxFit.contain,
                  ),
                ),
              )
            : Container(),
        SizedBox(
          width: 40,
          child: TextButton(
            onPressed: () {
              _gotoScanningPage(_firstDeviceEditingController);
            },
            child: ImageCacheManager.getImage(
              url: GlobalManager.myIcons.svgCodeScan,
              fit: BoxFit.contain,
            ),
          ),
        )
      ],
    );
    String title = _taskType == DeviceTaskType.fix
        ? GlobalManager.strings.oldDeviceCode!
        : GlobalManager.strings.deviceCode!;
    return _renderRowTextField(
      title,
      GlobalManager.strings.inputOrScan!,
      _firstDeviceEditingController,
      _firstDeviceFocusNode,
      TextInputType.text,
      TextInputAction.next,
      rightIcon: scanWidget,
    );
  }

  Widget _renderSecondScanningDevice() {
    Widget scanWidget = Row(
      children: [
        _taskType == DeviceTaskType.fix
            ? SizedBox(
                width: 50,
                child: TextButton(
                  onPressed: () {
                    checkStatusDevice(false);
                  },
                  child: ImageCacheManager.getImage(
                    url: GlobalManager.myIcons.svgCheckStatus,
                    fit: BoxFit.contain,
                  ),
                ),
              )
            : Container(),
        SizedBox(
          width: 40,
          child: TextButton(
            onPressed: () {
              _gotoScanningPage(_secondDeviceEditingController);
            },
            child: ImageCacheManager.getImage(
              url: GlobalManager.myIcons.svgCodeScan,
              fit: BoxFit.contain,
            ),
          ),
        )
      ],
    );
    return _renderRowTextField(
      GlobalManager.strings.newDeviceCode!,
      GlobalManager.strings.inputOrScan!,
      _secondDeviceEditingController,
      _secondDeviceFocusNode,
      TextInputType.text,
      TextInputAction.next,
      rightIcon: scanWidget,
    );
  }

  Widget _renderUrlDevice() {
    String title = _taskType == DeviceTaskType.fix
        ? GlobalManager.strings.oldDeviceCode!
        : GlobalManager.strings.deviceCode!;
    return _renderRowTextField(
      "Đường dẫn Server",
      "",
      _urlEditingController,
      _urlFocusNode,
      TextInputType.text,
      TextInputAction.next,
      required: true
    );
  }

  Widget _renderThreshold1Device() {
    String title = _taskType == DeviceTaskType.fix
        ? GlobalManager.strings.oldDeviceCode!
        : GlobalManager.strings.deviceCode!;
    return _renderRowTextField(
        "Ngưỡng van 1",
        "",
        _threshold1EditingController,
        _threshold1FocusNode,
        TextInputType.text,
        TextInputAction.next,
        required: false
    );
  }

  Widget _renderThreshold2Device() {
    String title = _taskType == DeviceTaskType.fix
        ? GlobalManager.strings.oldDeviceCode!
        : GlobalManager.strings.deviceCode!;
    return _renderRowTextField(
        "Ngưỡng van 2",
        "",
        _threshold2EditingController,
        _threshold2FocusNode,
        TextInputType.text,
        TextInputAction.next,
        required: false
    );
  }

  void _gotoScanningPage(TextEditingController editingController) async {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    _isScanning = true;
    String? qrCode = await pushPageWithRoute<String>(
      context,
      SlidePageRoute(
        slideTo: 'left',
        page: Stack(
          alignment: Alignment.topCenter,
          children: [
            QrScannerPage(
              appBarTitle: GlobalManager.strings.scanQR!,
              enableDataStream: true,
              function: (data) {
                if (_isScanning) {
                  _isScanning = false;
                  pop(context, object: data);
                }
              },
            ),
            Material(
              type: MaterialType.transparency,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 100,
                  right: 15,
                  left: 15,
                ),
                child: Text(
                  GlobalManager.strings.scanQR!,
                  textScaleFactor: 1.0,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    if (qrCode?.isNotEmpty ?? false) {
      editingController.text = qrCode ?? "";
    }
  }

  String? _validateScanningFields() {
    String oldDeviceCode = _firstDeviceEditingController.text.trim();
    if (checkStringNullOrEmpty(oldDeviceCode)) {
      return GlobalManager.strings.validateDeviceCodeEmpty;
    }

    if (_taskType == DeviceTaskType.fix) {
      String note = _noteEditingController.text.trim();
      if (checkStringNullOrEmpty(note)) {
        return GlobalManager.strings.validateNoteEmpty;
      }
    }
    return null;
  }

  String _getTypeString(int type) {
    switch (type) {
      case DeviceTaskType.setup:
        return GlobalManager.strings.setup!;
      case DeviceTaskType.fix:
        return GlobalManager.strings.replace!;
      case DeviceTaskType.revoke:
        return GlobalManager.strings.revoke!;
    }
    return "";
  }

  void _performDone() async {
    if (isJustClicked()) return;
    String? validateScanningFieldError = _validateScanningFields();
    if (!checkStringNullOrEmpty(validateScanningFieldError)) {
      showCustomAlertDialog(
        context,
        title: GlobalManager.strings.error,
        content: validateScanningFieldError!,
        firstButtonText: GlobalManager.strings.ok!,
        firstButtonFunction: () => pop(context),
      );
      return;
    }
    if (_selectedImages.length == 1) {
      showCustomAlertDialog(
        context,
        title: GlobalManager.strings.error,
        content: GlobalManager.strings.imageEmpty,
        firstButtonText: GlobalManager.strings.ok!,
        firstButtonFunction: () => pop(context),
      );
      return;
    }

    if (_selectedContractImages.length == 1 &&
        _taskType == DeviceTaskType.setup) {
      showCustomAlertDialog(
        context,
        title: GlobalManager.strings.error,
        content: GlobalManager.strings.contractImageEmpty,
        firstButtonText: GlobalManager.strings.ok!,
        firstButtonFunction: () => pop(context),
      );
      return;
    }

    String oldDeviceCode = _firstDeviceEditingController.text.trim();
    String newDeviceCode = _secondDeviceEditingController.text.trim();

    bool isReplaceDevice = false;
    String note = _noteEditingController.text.trim();
    if (_taskType == DeviceTaskType.fix) {
      if (newDeviceCode.isNotEmpty) {
        isReplaceDevice = true;
      }
      if (checkStringNullOrEmpty(note)) {
        showCustomAlertDialog(
          context,
          title: GlobalManager.strings.error,
          content: GlobalManager.strings.validateOldDeviceCodeEmpty,
          firstButtonText: GlobalManager.strings.ok!,
          firstButtonFunction: () => pop(context),
        );
        return;
      }
    }

    List<String> inputImages = [..._selectedImages];
    inputImages.removeLast();

    List<String> inputContractImages = [..._selectedContractImages];
    inputContractImages.removeLast();

    AppResponse result = await RDevices.completeTask(
        task: _taskType,
        accountId: _task.account_id ?? 0,
        deviceId: _task.device_id ?? 0,
        deviceCode:
            _taskType == DeviceTaskType.fix ? newDeviceCode : oldDeviceCode,
        note: note,
        id: _task.id ?? 0,
        status: DeviceTaskStatus.success,
        images: inputImages.join(";"),
        isReplaceDevice: isReplaceDevice,
        contractImages: inputContractImages.join(";"));

    if (result.success) {
      String content = '';
      switch (_taskType) {
        case DeviceTaskType.setup:
          content = GlobalManager.strings.setupDeviceSuccessfully!
              .replaceAll('###', oldDeviceCode);
          break;
        case DeviceTaskType.fix:
          if (isReplaceDevice) {
            content = GlobalManager.strings.replaceDeviceSuccessfully!
                .replaceAll('###', oldDeviceCode);
            content = content.replaceAll('@@@', newDeviceCode);
          } else {
            content = GlobalManager.strings.fixDeviceSuccessfully!
                .replaceAll('###', oldDeviceCode);
          }
          break;
        case DeviceTaskType.revoke:
          content = GlobalManager.strings.revokeDeviceSuccessfully!
              .replaceAll('###', oldDeviceCode);
          break;
      }
      await showCustomAlertDialog(
        context,
        title: GlobalManager.strings.success,
        content: content,
        firstButtonText: GlobalManager.strings.ok,
        firstButtonFunction: () {
          pop(context);
        },
      );
      pop(context, object: true);
    } else {
      showCustomAlertDialog(
        context,
        title: GlobalManager.strings.error,
        content: result.systemMessage,
        firstButtonText: GlobalManager.strings.ok,
        firstButtonFunction: () => pop(context),
      );
    }
  }

  /// [END] DEVICE SCANNING

  PreferredSizeWidget? _renderAppBar(String title) {
    return CustomAppBar(
      title: title,
      enableLeadingIcon: true,
    );
  }

  Future<dynamic>? _gotoPage(Widget page) {
    return pushPage(
      context,
      page,
    );
  }

  Widget _renderScanDevice() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: _bigSpacing),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(_radius)),
        boxShadow: [GlobalManager.styles.customBoxShadowAll],
      ),
      padding: EdgeInsets.all(_mediumSpacing),
      child: Column(
        children: [
          _renderFirstScanningDevice(),
          SizedBox(
            height: 1 * _smallSpacing,
          ),
          _renderUrlDevice(),
          SizedBox(
            height: 1 * _smallSpacing,
          ),
          _renderThreshold1Device(),
          SizedBox(
            height: 1 * _smallSpacing,
          ),
          _renderThreshold2Device(),
          SizedBox(
            height: 2 * _smallSpacing,
          ),
        ],
      ),
    );
  }

  Widget _renderPictureNote() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: _bigSpacing),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(_radius)),
        boxShadow: [GlobalManager.styles.customBoxShadowAll],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 13,
                  color: GlobalManager.colors.blue4178D4,
                  height: 1.3,
                  fontWeight: FontWeight.w400,
                ),
                text: GlobalManager.strings.image,
                children: [
                  TextSpan(
                    text: ' *',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: GlobalManager.colors.redEC1E37,
                    ),
                  ),
                ],
              ),
            ),
            margin: EdgeInsets.only(left: _mediumSpacing, top: _mediumSpacing),
          ),
          const SizedBox(
            height: 8,
          ),
          Container(
            child: _renderImage(),
          ),
          if (_taskType == DeviceTaskType.setup) ...[
            Container(
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 13,
                    color: GlobalManager.colors.blue4178D4,
                    height: 1.3,
                    fontWeight: FontWeight.w400,
                  ),
                  text: GlobalManager.strings.contract,
                  children: [
                    TextSpan(
                      text: ' *',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: GlobalManager.colors.redEC1E37,
                      ),
                    ),
                  ],
                ),
              ),
              margin:
                  EdgeInsets.only(left: _mediumSpacing, top: _mediumSpacing),
            ),
            const SizedBox(
              height: 8,
            ),
            Container(
              child: _renderContractImage(),
            ),
          ],
          const SizedBox(
            height: 8,
          ),
          Container(
            margin: EdgeInsets.only(left: _mediumSpacing),
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 13,
                  color: GlobalManager.colors.blue4178D4,
                  height: 1.3,
                  fontWeight: FontWeight.w400,
                ),
                text: GlobalManager.strings.note,
                children: [
                  TextSpan(
                    text: _taskType == DeviceTaskType.fix ? ' *' : '',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: GlobalManager.colors.redEC1E37,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Container(
            margin:
                EdgeInsets.only(left: _mediumSpacing, right: _mediumSpacing),
            child: CustomTextField(
              textSize: 12,
              onTap: () async {
                await Future.delayed(const Duration(milliseconds: 200));
                SchedulerBinding.instance?.addPostFrameCallback((_) {
                  _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.fastOutSlowIn);
                });
              },
              hintText: GlobalManager.strings.enterNote!,
              textInputType: TextInputType.multiline,
              textInputAction: TextInputAction.done,
              textController: _noteEditingController,
              focusNode: _noteFocusNode,
              horizontalPadding: 0,
              verticalPadding: 0,
              borderTextFormFieldColor:
                  GlobalManager.colors.grayE8E8E8.withOpacity(0.6),
              bgColor: Colors.white,
              radius: 8,
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          Row(
            children: [
              Expanded(
                  flex: 2,
                  child: Container(
                    margin: EdgeInsets.only(left: _mediumSpacing, right: _mediumSpacing),
                    child: UIButton(
                      text: "Xác nhận",
                      color: GlobalManager.colors.majorColor(),
                      textSize: 13,
                      fontWeight: FontWeight.w400,
                      enableShadow: false,
                      onTap: () {
                        _performDone();
                      },
                      height: _buttonHeight,
                    ),
                  ))
            ],
          ),
          SizedBox(
            height: _mediumSpacing,
          ),
        ],
      ),
    );
  }

  Widget _renderImage() {
    return GridView.count(
      crossAxisCount: 3,
      padding: EdgeInsets.only(
        left: _mediumSpacing,
        right: _mediumSpacing,
        top: 4,
        bottom: 4,
      ),
      shrinkWrap: true,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      physics: const NeverScrollableScrollPhysics(),
      children: _selectedImages.map((item) {
        return TextButton(
          onPressed: () {
            if (item == ADD_ITEM) {
              captureImage(false);
            } else {
              _showDialogImages(_selectedImages, _selectedImages.indexOf(item));
            }
          },
          style: GlobalManager.styles.defaultTextButtonStyle,
          child: item == ADD_ITEM
              ? DottedBorder(
                  dashPattern: [10, 5],
                  color: GlobalManager.colors.grayAEAEB2,
                  strokeWidth: 1,
                  borderType: BorderType.Rect,
                  radius: Radius.circular(10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: GlobalManager.colors.grayE6E5EE.withOpacity(0.4),
                    ),
                    width: 200,
                    height: 200,
                    child: ImageCacheManager.getImage(
                      url: GlobalManager.myIcons.svgImage,
                      width: 50,
                      height: 50,
                      fit: BoxFit.scaleDown,
                    ),
                  ),
                )
              : Stack(
                  children: [
                    Container(
                      width: 200,
                      height: 200,
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(6)),
                        boxShadow: [GlobalManager.styles.customBoxShadowB],
                        border: Border.all(
                          color: GlobalManager.colors.majorColor(),
                          width: 1,
                        ),
                      ),
                      child: ImageCacheManager.getImage(
                          url: item, fit: BoxFit.fitWidth),
                    ),
                    Positioned(
                      right: 0,
                      child: IconButton(
                          onPressed: () {
                            setState(() {
                              _selectedImages.remove(item);
                            });
                          },
                          icon: const Icon(Icons.delete, color: Colors.white)),
                    ),
                  ],
                ),
        );
      }).toList(),
    );
  }

  Widget _renderContractImage() {
    return GridView.count(
      crossAxisCount: 3,
      padding: EdgeInsets.only(
        left: _mediumSpacing,
        right: _mediumSpacing,
        top: 4,
        bottom: 4,
      ),
      shrinkWrap: true,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      physics: const NeverScrollableScrollPhysics(),
      children: _selectedContractImages.map((item) {
        return TextButton(
          onPressed: () {
            if (item == ADD_ITEM) {
              captureImage(true);
            } else {
              _showDialogImages(_selectedContractImages,
                  _selectedContractImages.indexOf(item));
            }
          },
          style: GlobalManager.styles.defaultTextButtonStyle,
          child: item == ADD_ITEM
              ? DottedBorder(
                  dashPattern: [10, 5],
                  color: GlobalManager.colors.grayAEAEB2,
                  strokeWidth: 1,
                  borderType: BorderType.Rect,
                  radius: Radius.circular(10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: GlobalManager.colors.grayE6E5EE.withOpacity(0.4),
                    ),
                    width: 200,
                    height: 200,
                    child: ImageCacheManager.getImage(
                      url: GlobalManager.myIcons.svgImage,
                      width: 50,
                      height: 50,
                      fit: BoxFit.scaleDown,
                    ),
                  ),
                )
              : Stack(
                  children: [
                    Container(
                      width: 200,
                      height: 200,
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(6)),
                        boxShadow: [GlobalManager.styles.customBoxShadowB],
                        border: Border.all(
                          color: GlobalManager.colors.majorColor(),
                          width: 1,
                        ),
                      ),
                      child: ImageCacheManager.getImage(
                          url: item, fit: BoxFit.fitWidth),
                    ),
                    Positioned(
                      right: 0,
                      child: IconButton(
                          onPressed: () {
                            setState(() {
                              _selectedContractImages.remove(item);
                            });
                          },
                          icon: const Icon(Icons.delete, color: Colors.white)),
                    ),
                  ],
                ),
        );
      }).toList(),
    );
  }

  void captureImage(bool isContract) async {
    final CameraPicker selectedCameraFile = CameraPicker();
    await selectedCameraFile.showImagePicker(
        imageSource: ImageSource.camera, imageQuality: 50);

    if (selectedCameraFile.file == null) return;

    if (selectedCameraFile.file?.path.isNotEmpty ?? false) {
      String url = await RDevices.uploadImage(
          isContract ? UploadImageType.contract : UploadImageType.device,
          selectedCameraFile.file!.path);
      if (url.isNotEmpty) {
        setState(() {
          if (isContract) {
            _selectedContractImages.insert(
                0, url.startsWith("http") ? url : (API.domain + "/" + url));
            if (_selectedContractImages.length >= 7) {
              _selectedContractImages.removeLast();
            }
          } else {
            _selectedImages.insert(
                0, url.startsWith("http") ? url : (API.domain + "/" + url));
            if (_selectedImages.length >= 7) {
              _selectedImages.removeLast();
            }
          }
        });
      }
    }
  }

  void _cancelTask() async {
    if (isJustClicked()) return;
    _deliveryFailedNotifier ??= ValueNotifier<int>(0);
    Map<int, String> _deliveryFailedReasonMap = {
      DeviceTaskCancellationType.reSchedule:
          GlobalManager.strings.customerChangeTaskDeviceDate!,
      DeviceTaskCancellationType.unableContact:
          GlobalManager.strings.unableToContact!,
      DeviceTaskCancellationType.byCustomer:
          GlobalManager.strings.customerCancelTaskDevice!,
      DeviceTaskCancellationType.other:
          GlobalManager.strings.staffCancelTaskDevice!
    };
    List<int> _itemIndex = [
      DeviceTaskCancellationType.reSchedule,
      DeviceTaskCancellationType.unableContact,
      DeviceTaskCancellationType.byCustomer,
      DeviceTaskCancellationType.other,
    ];

    void __shipperCancelOrder(int cancellationType,
        {int? dateReschedule, String? note}) async {
      showCustomLoadingDialog(context);
      var _response = await RDevices.failTask(
          note: note,
          task: _taskType,
          deviceId: _task.device_id ?? 0,
          accountId: _task.account_id ?? 0,
          failedReason: cancellationType,
          rescheduledDate: dateReschedule ?? 0);
      // pop for loading
      pop(context);
      if (_response.success) {
        showToastDefault(
            msg: GlobalManager.strings.failTaskSuccess!
                .replaceAll('###', _getTypeString(_taskType)));
        pop(context, object: true);
      } else {
        String errMsg = _response.systemMessage;
        if (checkStringNullOrEmpty(errMsg)) {
          errMsg = GlobalManager.strings.errorOccurred!;
        }
        showCustomAlertDialog(
          context,
          title: GlobalManager.strings.error!,
          content: errMsg,
          firstButtonText: GlobalManager.strings.ok!,
          firstButtonFunction: () => pop(context),
        );
      }
    }

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: GlobalManager.colors.grayEFF2F7,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
            ),
          ),
          // height: GlobalManager.appRatio.deviceHeight! * 2/3,
          padding: EdgeInsets.symmetric(vertical: _bigSpacing),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ValueListenableBuilder<int>(
                valueListenable: _deliveryFailedNotifier!,
                builder: (_, value, __) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RadioGroup<int>.builder(
                        direction: Axis.vertical,
                        groupValue: value,
                        onChanged: (val) {
                          if (val == null) return;
                          _deliveryFailedNotifier!.value = val;
                        },
                        items: _itemIndex,
                        horizontalAlignment: MainAxisAlignment.start,
                        textStyle: TextStyle(
                          fontSize: 15,
                          color: GlobalManager.colors.gray44494D,
                          fontWeight: FontWeight.w400,
                        ),
                        spacebetween: 44,
                        activeColor: GlobalManager.colors.redF8576A,
                        backgroundColor: Colors.white,
                        borderRadius: _smallSpacing,
                        marginVertical: _smallSpacing / 2,
                        marginHorizontal: _bigSpacing,
                        enableShadow: true,
                        itemBuilder: (item) => RadioButtonBuilder(
                          _deliveryFailedReasonMap[item]!,
                          textPosition: RadioButtonTextPosition.right,
                        ),
                      ),
                    ],
                  );
                },
              ),
              SizedBox(
                height: _bigSpacing,
              ),
              UIButton(
                height: 38,
                width: GlobalManager.appRatio.deviceWidth! - 2 * _bigSpacing,
                text: GlobalManager.strings.confirmToCancelTask!,
                color: GlobalManager.colors.redF8576A,
                radius: 6.0,
                textColor: Colors.white,
                onTap: () async {
                  if (isJustClicked()) return;
                  if (_deliveryFailedNotifier!.value == 0) return;
                  if (_deliveryFailedNotifier!.value ==
                          DeviceTaskCancellationType.other ||
                      _deliveryFailedNotifier!.value ==
                          DeviceTaskCancellationType.byCustomer) {
                    await showCustomNoteDialog(
                      context,
                      title: GlobalManager.strings.orderCancellationReason!,
                      hint: "${GlobalManager.strings.reason!}...",
                      errorEmptyText:
                          GlobalManager.strings.orderCancellationReasonEmpty!,
                      submitFunction: (note) async {
                        // pop for note dialog
                        pop(context);
                        // pop for bottom sheet
                        pop(context);
                        __shipperCancelOrder(
                          _deliveryFailedNotifier!.value,
                          note: note,
                        );
                      },
                    );
                  } else if (_deliveryFailedNotifier!.value ==
                      DeviceTaskCancellationType.reSchedule) {
                    var _result = await _gotoPage(
                      DeviceReschedulePage(scanType: _taskType),
                    );
                    if (_result != null) {
                      // pop for bottom sheet
                      pop(context);
                      Map<String, dynamic> shiftSelectionMap =
                          Map<String, dynamic>.from(_result);
                      int? date = shiftSelectionMap[
                          ShiftSelectionPage.dateSelectionKey];
                      __shipperCancelOrder(
                        DeviceTaskCancellationType.reSchedule,
                        dateReschedule: date,
                      );
                    }
                  } else {
                    await showCustomAlertDialog(
                      context,
                      title: GlobalManager.strings.confirm!,
                      content: GlobalManager.strings.confirmToCancelTaskAsk!,
                      firstButtonText: GlobalManager.strings.yes!,
                      firstButtonFunction: () {
                        // pop for dialog
                        pop(context);
                        // pop for bottom sheet
                        pop(context);
                        __shipperCancelOrder(
                          _deliveryFailedNotifier!.value,
                        );
                      },
                      secondButtonText: GlobalManager.strings.discard!,
                      secondButtonFunction: () => pop(context),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String title = '';
    switch (_taskType) {
      case DeviceTaskType.fix:
        title = GlobalManager.strings.maintain!;
        break;
      case DeviceTaskType.setup:
        title = GlobalManager.strings.setup!;
        break;
      case DeviceTaskType.revoke:
        title = GlobalManager.strings.revoke!;
        break;
      default:
        break;
    }

    Widget _buildElement = Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: GlobalManager.colors.bgMajor,
      appBar: _renderAppBar(title),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: _buildStepper(StepperType.vertical),
      ),
    );

    return NotificationListener<OverscrollIndicatorNotification>(
      child: _buildElement,
      onNotification: (overScroll) {
        overScroll.disallowIndicator();
        return false;
      },
    );
  }
}
