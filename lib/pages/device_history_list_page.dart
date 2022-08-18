import 'dart:async';

import 'package:anpha_petrol_smartgas/core/enum_definition.dart';
import 'package:anpha_petrol_smartgas/core/global_manager.dart';
import 'package:anpha_petrol_smartgas/core/utils/image_cache_manager.dart';
import 'package:anpha_petrol_smartgas/core/utils/validator.dart';
import 'package:anpha_petrol_smartgas/core/utils/widget_utils.dart';
import 'package:anpha_petrol_smartgas/models/m_device_history.dart';
import 'package:anpha_petrol_smartgas/models/o_device_histories_response.dart';
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
import '../../core/utils/date_time_utils.dart';
import '../../models/o_response.dart';
import '../../repositories/r_user.dart';
import '../../widgets/clone_libs/flutter_date_time_picker/flutter_datetime_picker.dart';
import '../../widgets/clone_libs/flutter_date_time_picker/src/datetime_picker_theme.dart';
import '../../widgets/clone_libs/flutter_date_time_picker/src/i18n_model.dart';
import '../../widgets/custom_dialog/custom_alert_dialog.dart';

class DeviceHistoryTDeviceHistoryListPagefulWidget {
  final int taskType;

  const DeviceHistoryListPage({Key? key, required this.taskType})
      : super(key: key);

  @override
  _DeviceHistoryListPageState createState() =>
      _DeviceHistoryListPageState();
}

class _DeviceHistory_DeviceHistoryListPageState<DeviceHistoryListPage>
    with AutomaticKeepAliveClientMixin<DeviceHistoryListPage> {
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
  final _filterCityKey = GlobalKey<DropdownSearchState<String>>();
  final _filterDistrictKey = GlobalKey<DropdownSearchState<String>>();
  final _filterWardKey = GlobalKey<DropdownSearchState<String>>();
  TaskFilter _filter = TaskFilter();
  Timer? _debounce;
  late ValueNotifier<List<DateTime>> _filterDateRangeNotifier;
  late ValueNotifier<int> _filterTabNotifier;
  final int _filterDayType = 1;
  final int _filterRangeDayType = 2;
  final int _filterMonthType = 3;
  DateTime? _filterFromDate;
  DateTime? _filterToDate;

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

    _filterFromDate = DateTime.now();
    _filterToDate = DateTime.now();

    _filterDateRangeNotifier = ValueNotifier([_now]);
    _filterTabNotifier = ValueNotifier(_filterDayType);

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _refreshController.requestRefresh();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _filterTabNotifier.dispose();
    _filterDateRangeNotifier.value.clear();
    _filterDateRangeNotifier.dispose();
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

    // List<DateTime> lstFilter = _filterDateRangeNotifier.value;
    // DateTime? from = lstFilter[0];
    // if (_filterTabNotifier.value == _filterMonthType) {
    //   _filterFromDate = DateTime(from.year, from.month, 1);
    //   _filterToDate = DateTime(from.year, from.month + 1, 1);
    //   _filterToDate = _filterToDate?.subtract(const Duration(days: 1));
    // }

    DeviceHistoriesResponse response = await RDevices.getHistoryTasks(
        widget.taskType,
        _currentPage,
        20,
        _filter.getFilterCity(),
        _filter.getFilterDistrict(),
        _filter.getFilterWard(),
        _searchKeywordController.text,
        "-1",
        _getBorderOfDate(true, _filterFromDate),
        _getBorderOfDate(false, _filterToDate));
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

        return Container(
          margin: EdgeInsets.only(
            left: 16,
            right: 16,
            top: (index == 0 ? 6 : 0),
            bottom: 24,
          ),
          child: DeviceTaskItem(
            task: item,
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
            margin: const EdgeInsets.only(left: 16, right: 16, top: 10),
            child: _renderTabBar(),
          ),
          Container(
            margin: const EdgeInsets.only(left: 16, right: 16, top: 6),
            child: _renderFilterTime(),
          ),
          Container(
            margin: const EdgeInsets.only(left: 16, right: 16, top: 6),
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
                        height: MediaQuery.of(context).size.height * 0.6,
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
    );
  }

  Widget _renderTabBar() {
    Widget __renderTab(String title, bool isSelected, int type) {
      Widget _content;
      if (isSelected) {
        _content = Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: GlobalManager.colors.majorColor(),
              width: 1,
            ),
            borderRadius: BorderRadius.all(Radius.circular(_radius)),
          ),
          padding: EdgeInsets.symmetric(
            vertical: 6,
            horizontal: _mediumSpacing,
          ),
          child: Text(
            title,
            textScaleFactor: 1.0,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: GlobalManager.colors.majorColor(),
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
        );
      } else {
        _content = Container(
          height: 32,
          child: Center(
            child: Text(
              title,
              textScaleFactor: 1.0,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: GlobalManager.colors.gray44494D,
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ),
        );
      }
      return InkWell(
        onTap: () {
          if (type == _filterTabNotifier.value) return;
          _filterTabNotifier.value = type;
          DateTime _now = DateTime.now();
          if (type == _filterRangeDayType) {
            _filterDateRangeNotifier.value = [_now, _now];
            _filterFromDate = _now;
            _filterToDate = _now;
          } else if (type == _filterMonthType) {
            _filterDateRangeNotifier.value = [DateTime.now()];
            _filterFromDate = DateTime(_now.year, _now.month, 1);
            _filterToDate = DateTime(_now.year, _now.month + 1, 1);
            _filterToDate = _filterToDate?.subtract(const Duration(days: 1));
          } else if (type == _filterDayType) {
            _filterDateRangeNotifier.value = [_now];
            _filterFromDate = _now;
            _filterToDate = _now;
          }
          _refreshController.requestRefresh();
        },
        child: _content,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: GlobalManager.colors.grayF1F2F2,
        borderRadius: BorderRadius.all(Radius.circular(_radius)),
        border: Border.all(color: GlobalManager.colors.grayCBD5E1, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
      child: ValueListenableBuilder<int>(
        valueListenable: _filterTabNotifier,
        builder: (_, type, __) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: __renderTab(
                  GlobalManager.strings.day!,
                  type == _filterDayType,
                  _filterDayType,
                ),
              ),
              SizedBox(
                width: _smallSpacing,
              ),
              Expanded(
                child: __renderTab(
                  GlobalManager.strings.month!,
                  type == _filterMonthType,
                  _filterMonthType,
                ),
              ),
              SizedBox(
                width: _smallSpacing,
              ),
              Expanded(
                child: __renderTab(
                  GlobalManager.strings.other!,
                  type == _filterRangeDayType,
                  _filterRangeDayType,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _renderFilterTime() {
    return ValueListenableBuilder<List<DateTime>>(
      valueListenable: _filterDateRangeNotifier,
      builder: (_, lstDateTime, __) {
        int type = _filterTabNotifier.value;
        DateTime _date = lstDateTime.first;
        String _formatDate;
        if (type == _filterDayType) {
          _formatDate =
              formatDateTime(_date, formatDisplay: formatDateTimeLongConst);
        } else if (type == _filterRangeDayType) {
          _formatDate = formatDateTime(_date, formatDisplay: formatDateConst);
          DateTime _last = lstDateTime.last;
          _formatDate =
              '$_formatDate - ${formatDateTime(_last, formatDisplay: formatDateConst)}';
        } else {
          _formatDate =
              formatDateTime(_date, formatDisplay: formatMonthOnlyConst);
        }
        return InkWell(
          onTap: () => _onFilterTimePressed(type),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: _mediumSpacing),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Align(
                    alignment: Alignment.center,
                    child: FaIcon(
                      FontAwesomeIcons.chevronLeft,
                      size: 12,
                      color: GlobalManager.colors.gray44494D,
                    ),
                  ),
                ),
                SizedBox(
                  width: _mediumSpacing,
                ),
                Text(
                  _formatDate,
                  textScaleFactor: 1.0,
                  style: TextStyle(
                    color: GlobalManager.colors.gray44494D,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(
                  width: _mediumSpacing,
                ),
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Align(
                    alignment: Alignment.center,
                    child: FaIcon(
                      FontAwesomeIcons.chevronRight,
                      size: 12,
                      color: GlobalManager.colors.gray44494D,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  DateTime? _getBorderOfDate(bool isStartDate, DateTime? dt) {
    if (dt == null) return null;
    if (isStartDate) {
      return DateTime(dt.year, dt.month, dt.day, 0, 0, 1);
    }
    return DateTime(dt.year, dt.month, dt.day, 23, 59, 59);
  }

  void _onFilterTimePressed(int type) async {
    DateTime _now = DateTime.now();
    const int numDaysBefore = 30;
    if (type == _filterDayType) {
      DateTime dt = _filterDateRangeNotifier.value[0];
      dynamic result = await showDatePicker(
        locale: Locale(GlobalManager.currentAppLanguage),
        context: context,
        initialDate: dt,
        firstDate: DateTime(2020, 1, 1),
        lastDate: _now,
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData(
              primarySwatch: MaterialColor(
                GlobalManager.colors.majorColor().value,
                rgbToMaterialColor(33, 57, 112),
              ),
              splashColor: GlobalManager.colors.majorColor(opacity: 0.1),
            ),
            child: child!,
          );
        },
      );
      if (result != null) {
        _filterDateRangeNotifier.value = [result];
        _filterFromDate = result;
        _filterToDate = result;
        _refreshController.requestRefresh();
      }
    } else if (type == _filterRangeDayType) {
      DateTime fromDate = _filterDateRangeNotifier.value[0];
      DateTime toDate = _filterDateRangeNotifier.value[1];
      DateTimeRange? result = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2020, 1, 1),
        lastDate: _now,
        initialDateRange: DateTimeRange(start: fromDate, end: toDate),
        locale: Locale(GlobalManager.currentAppLanguage),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData(
              primarySwatch: MaterialColor(
                GlobalManager.colors.majorColor().value,
                rgbToMaterialColor(33, 57, 112),
              ),
              splashColor: GlobalManager.colors.majorColor(opacity: 0.1),
            ),
            child: child!,
          );
        },
      );

      if (result != null) {
        _filterDateRangeNotifier.value = [result.start, result.end];
        _filterFromDate = result.start;
        _filterToDate = result.end;
        _refreshController.requestRefresh();
      }
    } else if (type == _filterMonthType) {
      // DateTime _now = DateTime.now();
      DatePicker.showDatePicker(
        context,
        title: GlobalManager.strings.selectMonth!,
        showTitleActions: true,
        showDaysColumns: false,
        limitChildren: true,
        minTime: DateTime(2022, 01, 01),
        maxTime: DateTime(2050, 12, 30),
        childCount: 12,
        onConfirm: (date) {
          _filterDateRangeNotifier.value = [date];
          DateTime _start = DateTime(date.year, date.month, 1);
          DateTime _end = DateTime(date.year, date.month + 1, 1);
          _filterFromDate = _start;
          _filterToDate = _end.subtract(
            const Duration(days: 1),
          );
          _refreshController.requestRefresh();
        },
        currentTime: _filterDateRangeNotifier.value[0],
        locale: GlobalManager.currentAppLanguage == 'en'
            ? LocaleType.en
            : LocaleType.vi,
        theme: DatePickerTheme(
            titleStyle: TextStyle(
              fontSize: 18.0,
              color: GlobalManager.colors.majorColor(),
              fontWeight: FontWeight.bold,
            ),
            cancelButtonDecoration: BoxDecoration(
              border: Border.all(color: GlobalManager.colors.majorColor()),
              borderRadius: BorderRadius.circular(8.0),
            ),
            cancelStyle: TextStyle(
              fontSize: 16.0,
              color: GlobalManager.colors.majorColor(),
              fontWeight: FontWeight.bold,
            ),
            doneButtonDecoration: BoxDecoration(
              color: GlobalManager.colors.majorColor(),
              borderRadius: BorderRadius.circular(8.0),
            )),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Widget _buildElement = Scaffold(
      backgroundColor: GlobalManager.colors.bgLightGray,
      appBar: _renderAppBar("Lịch sử lắp đặt / bảo trì"),
      body: _buildRefreshView(_renderPageBody(context)),
    );

    return NotificationListener<OverscrollIndicatorNotification>(
        child: _buildElement, //_buildRefreshView(, context),
        onNotification: (overScroll) {
          overScroll.disallowGlow();
          return false;
        });
  }

  String getTitle() {
    switch (widget.taskType) {
      case DeviceTaskType.setup:
        return GlobalManager.strings.deviceHistoryTaskSetupList!;
      case DeviceTaskType.revoke:
        return GlobalManager.strings.deviceHistoryTaskRevokeList!;
      case DeviceTaskType.fix:
        return GlobalManager.strings.deviceHistoryTaskFixList!;
      default:
        return "";
    }
  }

  @override
  bool get wantKeepAlive => true;
}
