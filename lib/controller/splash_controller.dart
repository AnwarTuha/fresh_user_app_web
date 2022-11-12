import 'package:sixam_mart/controller/cart_controller.dart';
import 'package:sixam_mart/data/api/api_checker.dart';
import 'package:sixam_mart/data/api/api_client.dart';
import 'package:sixam_mart/data/model/response/config_model.dart';
import 'package:sixam_mart/data/model/response/module_model.dart';
import 'package:sixam_mart/data/repository/splash_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/view/base/confirmation_dialog.dart';
import 'package:sixam_mart/view/screens/home/home_screen.dart';

class SplashController extends GetxController implements GetxService {
  final SplashRepo splashRepo;
  SplashController({@required this.splashRepo});

  ConfigModel _configModel;
  bool _firstTimeConnectionCheck = true;
  bool _hasConnection = true;
  ModuleModel _module;
  List<ModuleModel> _moduleList;
  Map<String, dynamic> _data = Map();

  ConfigModel get configModel => _configModel;
  DateTime get currentTime => DateTime.now();
  bool get firstTimeConnectionCheck => _firstTimeConnectionCheck;
  bool get hasConnection => _hasConnection;
  ModuleModel get module => _module;
  List<ModuleModel> get moduleList => _moduleList;

  Future<bool> getConfigData() async {
    _hasConnection = true;
    Response response = await splashRepo.getConfigData();
    bool _isSuccess = false;
    if(response.statusCode == 200) {
      _data = response.body;
      _configModel = ConfigModel.fromJson(response.body);
      if(_configModel.module != null) {
        setModule(_configModel.module);
      }else if(GetPlatform.isWeb) {
        setModule(splashRepo.getModule());
      }
      _isSuccess = true;
    }else {
      ApiChecker.checkApi(response);
      if(response.statusText == ApiClient.noInternetMessage) {
        _hasConnection = false;
      }
      _isSuccess = false;
    }
    update();
    return _isSuccess;
  }

  Future<void> initSharedData() async {
    if(!GetPlatform.isWeb) {
      _module = null;
      splashRepo.initSharedData();
    }else {
      _module = await splashRepo.initSharedData();
    }
    await setModule(_module, notify: false);
  }

  bool showIntro() {
    return splashRepo.showIntro();
  }

  void disableIntro() {
    splashRepo.disableIntro();
  }

  void setFirstTimeConnectionCheck(bool isChecked) {
    _firstTimeConnectionCheck = isChecked;
  }

  Future<void> setModule(ModuleModel module, {bool notify = true}) async {
    _module = module;
    splashRepo.setModule(module);
    if(module != null) {
      _configModel.moduleConfig.module = Module.fromJson(_data['module_config'][module.moduleType]);
    }
    if(notify) {
      update();
    }
  }

  Module getModule(String moduleType) => Module.fromJson(_data['module_config'][moduleType]);

  Future<void> getModules() async {
    Response response = await splashRepo.getModules();
    if (response.statusCode == 200) {
      _moduleList = [];
      response.body.forEach((storeCategory) => _moduleList.add(ModuleModel.fromJson(storeCategory)));
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  void switchModule(int index, bool fromPhone) async {
    if(_module == null || _module.id != _moduleList[index].id) {
      bool _clearData = (Get.find<CartController>().cartList.length > 0
          && Get.find<CartController>().cartList[0].item.moduleId != _moduleList[index].id);
      bool _switch = _module != null && _module.id != _moduleList[index].id;
      if(_clearData || (_switch && !fromPhone)) {
        Get.dialog(ConfirmationDialog(
          icon: Images.warning, title: _clearData ? 'are_you_sure_to_reset'.tr : null,
          description: 'if_you_continue_without_another_store'.tr,
          onYesPressed: () async {
            Get.back();
            Get.find<CartController>().clearCartList();
            await Get.find<SplashController>().setModule(_moduleList[index]);
            HomeScreen.loadData(true);
          },
        ));
      }else {
        await Get.find<SplashController>().setModule(_moduleList[index]);
        HomeScreen.loadData(true);
      }
    }
  }

}
