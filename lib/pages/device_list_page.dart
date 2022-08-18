import 'dart:async';

import 'package:anpha_petrol_smartgas/core/enum_definition.dart';
import 'package:anpha_petrol_smartgas/core/global_manager.dart';
import 'package:anpha_petrol_smartgas/core/utils/image_cache_manager.dart';
import 'package:anpha_petrol_smartgas/core/utils/validator.dart';
import 'package:anpha_petrol_smartgas/core/utils/widget_utils.dart';
import 'package:anpha_petrol_smartgas/models/m_device_history.dart';
import 'package:anpha_petrol_smartgas/models/o_device_histories_response.dart';
import 'package:anpha_petrol_smartgas/pages/devices/device_history_list_page.dart';
import 'package:anpha_petrol_smartgas/pages/devices/device_task_item.dart';
import 'package:anpha_petrol_smartgas/pages/devices/setup_page.dart';
import 'package:anpha_petrol_smartgas/pages/devices/device_task_viewer_page.dart';
import 'package:anpha_petrol_smartgas/providers/p_task.dart';
import 'package:anpha_petrol_smartgas/repositories/r_devices.dart';
import 'package:anpha_petrol_smartgas/widgets/custom_app_bar.dart';
import 'package:anpha_petrol_smartgas/widgets/custom_text_field.dart';
import 'package:anpha_petrol_smartgas/widgets/loading_dot.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../core/helper.dart';
import '../../models/o_response.dart';
import '../../repositories/r_user.dart';
import '../../widgets/custom_dialog/custom_alert_dialog.dart';

class DeviceTaskListDeviceListPagefulWidget {
  final int taskType;

  const DeviceListPage({Key? key, required this.taskType})
      : super(key: key);

  @override
  _DeviceListPageState createState() => _DeviceListPageState();
}

class _DeviceTaskLis_DeviceListPageState<DeviceListPage>
    with AutomaticKeepAliveClientMixin<DeviceListPage> {
  final double _smallSpacing = GlobalManager.styles.smallSpacing;
  final double _mediumSpacing = GlobalManager.styles.mediumSpacing;
  final double _radius = 8.0;

  List<MDeviceHistory> _deviceTaskList = [];
  final int _startPage = 1;
  int _currentPage = 1;
  bool _shouldLoadMore = false;
  bool _isLoading = false;
  bool _fetched = false;
  int _totalItems = 0;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final TextEditingController _searchKeywordController =
      TextEditingController();
  final FocusNode _searchKeywordFocusNode = FocusNode();
  final _filterOwnerKey = GlobalKey<DropdownSearchState<String>>();
  final _filterStatusKey = GlobalKey<DropdownSearchState<String>>();
  final _filterTypeKey = GlobalKey<DropdownSearchState<String>>();
  final _filterCityKey = GlobalKey<DropdownSearchState<String>>();
  final _filterDistrictKey = GlobalKey<DropdownSearchState<String>>();
  final _filterWardKey = GlobalKey<DropdownSearchState<String>>();
  TaskFilter _filter = TaskFilter();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    DateTime _now = DateTime.now();
    PTask taskProvider = Provider.of<PTask>(context, listen: false);
    _searchKeywordController.addListener(() {
      _onSearchChanged(_searchKeywordController.text);
    });

    taskProvider.clearFilter();
    taskProvider.loadCountryData();

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _refreshController.requestRefresh();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _deviceTaskList.clear();
      _refreshController.requestRefresh();
    });
  }

  void searchTask() async {
    if (!mounted) return;

    DeviceHistoriesResponse response = await RDevices.getTasks(
        widget.taskType,
        _currentPage,
        20,
        _filter.getFilterCity(),
        _filter.getFilterDistrict(),
        _filter.getFilterWard(),
        _searchKeywordController.text,
        "0,1",
        _filter.getFilterOwner(),
        _filter.getFilterStatus(),
        _filter.getFilterType(),
        null,
        null);
    List<MDeviceHistory> deviceTask = response.histories ?? [];
    _totalItems = response.total ?? 0;
    _fetched = true;
    _refreshController.refreshCompleted();
    if (mounted) {
      if (!checkListIsNullOrEmpty(deviceTask)) {
        setState(() {
          _shouldLoadMore = true;
          if (_currentPage > _startPage) {
            _deviceTaskList.addAll(deviceTask);
          } else {
            _deviceTaskList = deviceTask;
          }
          _currentPage += 1;
        });
      } else {
        setState(() {
          if (_currentPage == _startPage) {
            _deviceTaskList.clear();
          }
          _shouldLoadMore = false;
        });
      }
    }
  }

  Future<dynamic>? _gotoPage(Widget page) {
    return pushPage(
      context,
      page,
    );
  }

  Widget _renderSmartRefresher(Widget child) {
    Widget smartRefresher = SmartRefresher(
      controller: _refreshController,
      enablePullUp: false,
      child: child,
      physics: const BouncingScrollPhysics(),
      footer: const ClassicFooter(
        loadStyle: LoadStyle.ShowWhenLoading,
        completeDuration: const Duration(milliseconds: 500),
      ),
      onRefresh: () async {
        _currentPage = _startPage;
        searchTask();
      },
      onLoading: () async {
        await Future.delayed(const Duration(milliseconds: 200));
      },
    );

    return Scrollbar(
      child: smartRefresher,
    );
  }

  Widget _renderPageBody(BuildContext context) {
    var listViewBuilder = ListView.builder(
      scrollDirection: Axis.vertical,
      itemCount: _deviceTaskList.length,
      itemBuilder: (BuildContext ctx, int index) {
        if (index == _deviceTaskList.length - 1) {
          loadMore();
        }
        if (index >= _deviceTaskList.length) return Container();
        MDeviceHistory item = _deviceTaskList[index];

        bool showAction = true;
        if (_deviceTaskList.length > 0) {
          MDeviceHistory device = _deviceTaskList[0];
          bool isMe = RUser.currentUserInfo.id == (device.staff_id ?? 0);
          if (isMe && (device.status ?? 0) == DeviceTaskStatus.processing) {
            showAction = false;
          }
        }
        return Container(
          margin: EdgeInsets.only(
            left: 16,
            right: 16,
            top: (index == 0 ? 6 : 0),
            bottom: 24,
          ),
          child: DeviceTaskItem(
            task: item,
            showAction: showAction,
            onPressed: () {
              bool isMe = RUser.currentUserInfo.id == (item.staff_id ?? 0);
              if (isMe && (item.status ?? 0) == DeviceTaskStatus.processing) {
                _goToScanningPage(item);
              } else {
                _gotoPage(
                    DeviceTaskViewerPage(task: item, scanType: item.task ?? 0));
              }
            },
            onPressedQuickAction: () async {
              int currentStatus = item.status ?? 0;
              String title = "";
              String content = "";
              if (currentStatus == DeviceTaskStatus.pending) {
                title = GlobalManager.strings.receiveTask! +
                    " " +
                    DeviceTaskType.getText(item.task ?? 0);
                content = GlobalManager.strings.confirmReceiveTask!
                    .replaceAll("@@@", DeviceTaskType.getText(item.task ?? 0));
              } else if (currentStatus == DeviceTaskStatus.processing) {
                title = GlobalManager.strings.cancel! +
                    " " +
                    DeviceTaskType.getText(item.task ?? 0);
                content = GlobalManager.strings.confirmCancelTask!
                    .replaceAll("@@@", DeviceTaskType.getText(item.task ?? 0));
              }
              dynamic result = await showCustomAlertDialog(
                context,
                title: title,
                iconUrl: GlobalManager.myIcons.svgInfo,
                content: content,
                firstButtonText: GlobalManager.strings.yes!.toUpperCase(),
                firstButtonFunction: () async {
                  pop(context);
                  int currentStatus = item.status ?? 0;
                  if (currentStatus == DeviceTaskStatus.pending) {
                    AppResponse response = await RDevices.receiveTask(
                        task: item.task ?? 0,
                        accountId: item.account_id ?? 0,
                        deviceId: item.device_id ?? 0);
                    if (response.success) {
                      item.status = DeviceTaskStatus.processing;
                      item.staff_id = RUser.currentUserInfo.id;
                      setState(() {
                        _refreshController.requestRefresh();
                        _goToScanningPage(item);
                      });
                    } else {
                      await showCustomAlertDialog(
                        context,
                        title: GlobalManager.strings.error,
                        iconUrl: GlobalManager.myIcons.svgError,
                        content: response.systemMessage,
                        firstButtonText:
                            GlobalManager.strings.yes!.toUpperCase(),
                        firstButtonFunction: () {
                          pop(context);
                        },
                      );
                      _refreshController.requestRefresh();
                    }
                  } else if (currentStatus == DeviceTaskStatus.processing) {
                    AppResponse response = await RDevices.cancelTask(
                        task: item.task ?? 0,
                        accountId: item.account_id ?? 0,
                        deviceId: item.device_id ?? 0);
                    if (response.success) {
                      item.status = DeviceTaskStatus.pending;
                      item.staff_id = null;
                      setState(() {});
                    } else {
                      showCustomAlertDialog(
                        context,
                        title: GlobalManager.strings.error,
                        iconUrl: GlobalManager.myIcons.svgError,
                        content: response.systemMessage,
                        firstButtonText:
                            GlobalManager.strings.yes!.toUpperCase(),
                        firstButtonFunction: () {
                          pop(context);
                          _refreshController.requestRefresh();
                        },
                      );
                    }
                  }
                },
                secondButtonText: GlobalManager.strings.no!.toUpperCase(),
                secondButtonFunction: () => pop(context),
              );
            },
          ),
        );
      },
    );

    return Container(
      decoration: BoxDecoration(color: GlobalManager.colors.bgGrayFDFDFD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(left: 16, right: 16, top: 16),
            child: _renderFilterBar(context),
          ),
          const SizedBox(height: 10),
          Expanded(
              child: (_isLoading
                  ? const LoadingIndicator()
                  : _renderSmartRefresher(
                      checkListIsNullOrEmpty(_deviceTaskList)
                          ? (_fetched
                              ? WidgetUtils.renderEmptyData()
                              : Container())
                          : listViewBuilder)))
        ],
      ),
    );
  }

  void _goToScanningPage(MDeviceHistory item) async {
    bool result = await _gotoPage(
        DeviceTaskScanningPage(task: item, scanType: item.task ?? 0));
    if (result) {
      _refreshController.requestRefresh();
    }
  }

  void loadMore() async {
    if (_shouldLoadMore) {
      WidgetsBinding.instance?.addPostFrameCallback((_) => searchTask());
    }
  }

  Widget _buildRefreshView(Widget child) {
    return RefreshConfiguration(
      child: child,
      headerBuilder: () => MaterialClassicHeader(
        backgroundColor: GlobalManager.colors.majorColor(),
      ),
      footerBuilder: null,
      shouldFooterFollowWhenNotFull: (state) {
        return false;
      },
      hideFooterWhenNotFull: true,
    );
  }

  Widget _renderFilterBar(BuildContext context) {
    PTask provider = Provider.of<PTask>(context, listen: false);
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: CustomTextField(
            textSize: 12,
            hintText: GlobalManager.strings.lookupSearchGuide!,
            textInputType: TextInputType.text,
            textInputAction: TextInputAction.done,
            textController: _searchKeywordController,
            focusNode: _searchKeywordFocusNode,
            height: 40,
            horizontalPadding: 0,
            verticalPadding: 0,
            borderTextFormFieldColor: Colors.transparent,
            bgColor: GlobalManager.colors.grayE8E8E8.withOpacity(0.5),
            suffixIcon: _searchKeywordController.text.isNotEmpty
                ? IconButton(
                    padding: const EdgeInsets.only(right: 10),
                    iconSize: 16,
                    onPressed: _searchKeywordController.clear,
                    icon: const Icon(Icons.clear, color: Colors.black),
                  )
                : null,
            suffixIconConstraints: const BoxConstraints(
              maxWidth: 30,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
        ),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: () {
            provider.prepareData();
            showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (BuildContext context) {
                return Consumer<PTask>(
                  builder: (context, value, child) {
                    return Container(
                        height: MediaQuery.of(context).size.height * (widget.taskType == DeviceTaskType.setup ? 0.5 : 0.75),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(18),
                            topRight: Radius.circular(18),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Center(
                              child: Container(
                                margin:
                                    const EdgeInsets.only(top: 12, bottom: 12),
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                    color: GlobalManager.colors.grayE5E5E5,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(3))),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(
                                        left: 16,
                                        right: 16,
                                        top: 12,
                                        bottom: 0),
                                    child: _renderFilterDropdown(
                                        _filterCityKey,
                                        GlobalManager
                                            .strings.lookupAddressCity!,
                                        value.localCities,
                                        value.selectedCity,
                                        true, (newValue) {
                                      value.setFilterCity(newValue);
                                      _filterDistrictKey.currentState?.clear();
                                      _filterWardKey.currentState?.clear();
                                    }),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 0, horizontal: 16),
                                    child: _renderFilterDropdown(
                                        _filterDistrictKey,
                                        GlobalManager
                                            .strings.lookupAddressDistrict!,
                                        value.localDistricts,
                                        value.selectedDistrict,
                                        true, (newValue) {
                                      value.setFilterDistrict(newValue);
                                      _filterWardKey.currentState?.clear();
                                    }),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 0, horizontal: 16),
                                    child: _renderFilterDropdown(
                                        _filterWardKey,
                                        GlobalManager
                                            .strings.lookupAddressWard!,
                                        value.localWards,
                                        value.selectedWard,
                                        true, (newValue) {
                                      value.setFilterWard(newValue);
                                    }),
                                  ),
                                  if (widget.taskType == DeviceTaskType.fix ||
                                      widget.taskType ==
                                          DeviceTaskType.revoke) ...[
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 0, horizontal: 16),
                                      child: _renderFilterDropdown(
                                          _filterOwnerKey,
                                          GlobalManager.strings.customer!,
                                          [
                                            "2|${GlobalManager.strings.deviceOwnerFilterBusy}",
                                            "1|${GlobalManager.strings.deviceOwnerFilterAvailable}",
                                          ],
                                          value.selectedOwner,
                                          false, (newValue) {
                                        value.setFilterOwner(newValue);
                                      }),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 0, horizontal: 16),
                                      child: _renderFilterDropdown(
                                          _filterStatusKey,
                                          GlobalManager.strings.device!,
                                          [
                                            "${DeviceStatusType.needToFix}|Fix",
                                            "${DeviceStatusType.emptyEnergy}|Empty Energy",
                                          ],
                                          value.selectedStatus,
                                          false, (newValue) {
                                        value.setFilterStatus(newValue);
                                      }),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 0, horizontal: 16),
                                      child: _renderFilterDropdown(
                                          _filterTypeKey,
                                          '${GlobalManager.strings.maintain}/${GlobalManager.strings.revoke}',
                                          [
                                            "${DeviceTaskType.fix}|${GlobalManager.strings.maintain}",
                                            "${DeviceTaskType.revoke}|${GlobalManager.strings.revoke}",
                                          ],
                                          value.selectedType,
                                          false, (newValue) {
                                        value.setFilterType(newValue);
                                      }),
                                    )
                                  ],
                                ],
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 16),
                              decoration: const BoxDecoration(),
                              child: TextButton(
                                onPressed: () {
                                  _filter = value.saveFilter();
                                  _deviceTaskList.clear();
                                  _refreshController.requestRefresh();
                                  Navigator.pop(context);
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor:
                                      GlobalManager.colors.majorColor(),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: Text(
                                  GlobalManager.strings.confirm!,
                                  textScaleFactor: 1.0,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ));
                  },
                );
              },
            );
          },
          child: _renderFilterButton(),
        )
      ],
    );
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
      mode: Mode.BOTTOM_SHEET,
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

  Widget _renderFilterButton() {
    return Consumer<PTask>(builder: (context, value, child) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
            color: GlobalManager.colors.grayE8E8E8.withOpacity(0.5),
            borderRadius: const BorderRadius.all(Radius.circular(8))),
        child: Stack(
          alignment: Alignment.center,
          children: [
            ImageCacheManager.getImage(
              url: GlobalManager.myIcons.svgFilter,
              width: 16,
              height: 16,
              fit: BoxFit.contain,
            ),
            value.countFilter() == 0
                ? Container()
                : Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.all(Radius.circular(8))),
                      child: Center(
                        child: Text(
                          value.countFilter().toString(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                              fontSize: 10),
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      );
    });
  }

  PreferredSizeWidget? _renderAppBar(String title) {
    return CustomAppBar(
      title: title,
      enableLeadingIcon: true,
      actions: [
        SizedBox(
          width: 50,
          child: TextButton(
            onPressed: () {
              _gotoPage(DeviceHistoryTaskListPage(taskType: widget.taskType));
            },
            style: GlobalManager.styles.defaultTextButtonStyle,
            child: ImageCacheManager.getImage(
              url: GlobalManager.myIcons.svgIconHistory,
              width: 24,
              height: 24,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Widget _buildElement = Scaffold(
      backgroundColor: GlobalManager.colors.bgLightGray,
      appBar: _renderAppBar("Danh sách thiết bị"),
      body: _buildRefreshView(_renderPageBody(context)),
      bottomNavigationBar: _renderBottomButton(),
    );

    return NotificationListener<OverscrollIndicatorNotification>(
        child: _buildElement, //_buildRefreshView(, context),
        onNotification: (overScroll) {
          overScroll.disallowGlow();
          return false;
        });
  }

  Widget _renderBottomButton() {
    if (_deviceTaskList.isEmpty) return const SizedBox();
    MDeviceHistory device = _deviceTaskList[0];
    bool isMe = RUser.currentUserInfo.id == (device.staff_id ?? 0);
    if (isMe && (device.status ?? 0) == DeviceTaskStatus.processing) {
    } else {
      return const SizedBox();
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [GlobalManager.styles.customBoxShadowAll],
      ),
      child: TextButton(
        onPressed: () {
          _goToScanningPage(device);
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(_radius)),
          ),
          primary: GlobalManager.colors.majorColor(opacity: 0.1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ImageCacheManager.getImage(
              url: GlobalManager.myIcons.svgSetup2,
              width: 40,
              height: 40,
            ),
            const SizedBox(
              width: 12,
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${device.account_name} - ${device.account_phone}',
                    textScaleFactor: 1.0,
                    style: TextStyle(
                      color: GlobalManager.colors.blue4178D4,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(
                    height: _smallSpacing / 2,
                  ),
                  Text(
                    device.account_address ?? "",
                    textScaleFactor: 1.0,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: GlobalManager.colors.grayAEAEB2,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(
                    height: _smallSpacing / 2,
                  ),
                  Text(
                    getBottomTitle(device.task ?? 0),
                    textScaleFactor: 1.0,
                    style: TextStyle(
                      color: GlobalManager.colors.purpleC490E4,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(
                    height: _smallSpacing,
                  ),
                ],
              ),
            ),
            FaIcon(
              FontAwesomeIcons.chevronRight,
              size: 18,
              color: GlobalManager.colors.grayAEAEB2,
            ),
          ],
        ),
      ),
    );
  }

  String getBottomTitle(int taskType) {
    switch (taskType) {
      case DeviceTaskType.setup:
        return GlobalManager.strings.deviceTaskSetupProcessing!;
      case DeviceTaskType.revoke:
        return GlobalManager.strings.deviceTaskRevokeProcessing!;
      case DeviceTaskType.fix:
        return GlobalManager.strings.deviceTaskFixProcessing!;
      default:
        return "";
    }
  }

  String getTitle() {
    switch (widget.taskType) {
      case DeviceTaskType.setup:
        return GlobalManager.strings.deviceTaskSetupList!;
      case DeviceTaskType.revoke:
        return GlobalManager.strings.maintainOrRevoke!;
      case DeviceTaskType.fix:
        return GlobalManager.strings.maintainOrRevoke!;
      default:
        return "";
    }
  }

  @override
  bool get wantKeepAlive => true;
}
