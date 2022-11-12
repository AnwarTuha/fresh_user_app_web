import 'dart:convert';

import 'package:sixam_mart/data/api/api_client.dart';
import 'package:sixam_mart/data/model/response/address_model.dart';
import 'package:sixam_mart/data/model/response/module_model.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashRepo {
  ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  SplashRepo({@required this.sharedPreferences, @required this.apiClient});

  Future<Response> getConfigData() async {
    return await apiClient.getData(AppConstants.CONFIG_URI);
  }

  Future<ModuleModel> initSharedData() async {
    if(!sharedPreferences.containsKey(AppConstants.THEME)) {
      sharedPreferences.setBool(AppConstants.THEME, false);
    }
    if(!sharedPreferences.containsKey(AppConstants.COUNTRY_CODE)) {
      sharedPreferences.setString(AppConstants.COUNTRY_CODE, AppConstants.languages[0].countryCode);
    }
    if(!sharedPreferences.containsKey(AppConstants.LANGUAGE_CODE)) {
      sharedPreferences.setString(AppConstants.LANGUAGE_CODE, AppConstants.languages[0].languageCode);
    }
    if(!sharedPreferences.containsKey(AppConstants.CART_LIST)) {
      sharedPreferences.setStringList(AppConstants.CART_LIST, []);
    }
    if(!sharedPreferences.containsKey(AppConstants.SEARCH_HISTORY)) {
      sharedPreferences.setStringList(AppConstants.SEARCH_HISTORY, []);
    }
    if(!sharedPreferences.containsKey(AppConstants.NOTIFICATION)) {
      sharedPreferences.setBool(AppConstants.NOTIFICATION, true);
    }
    if(!sharedPreferences.containsKey(AppConstants.INTRO)) {
      sharedPreferences.setBool(AppConstants.INTRO, true);
    }
    if(!sharedPreferences.containsKey(AppConstants.NOTIFICATION_COUNT)) {
      sharedPreferences.setInt(AppConstants.NOTIFICATION_COUNT, 0);
    }
    ModuleModel _module;
    if(sharedPreferences.containsKey(AppConstants.MODULE_ID)) {
      try {
        _module = ModuleModel.fromJson(jsonDecode(sharedPreferences.getString(AppConstants.MODULE_ID)));
      }catch(e) {}
    }
    return _module;
  }

  void disableIntro() {
    sharedPreferences.setBool(AppConstants.INTRO, false);
  }

  bool showIntro() {
    return sharedPreferences.getBool(AppConstants.INTRO);
  }

  Future<void> setStoreCategory(int storeCategoryID) async {
    AddressModel _addressModel;
    try {
      _addressModel = AddressModel.fromJson(jsonDecode(sharedPreferences.getString(AppConstants.USER_ADDRESS)));
    }catch(e) {}
    apiClient.updateHeader(
      sharedPreferences.getString(AppConstants.TOKEN), _addressModel == null ? null : _addressModel.zoneId.toString(),
      sharedPreferences.getString(AppConstants.LANGUAGE_CODE), storeCategoryID,
    );
  }

  Future<Response> getModules() async {
    return await apiClient.getData(AppConstants.MODULES_URI);
  }

  Future<void> setModule(ModuleModel module) async {
    AddressModel _addressModel;
    try {
      _addressModel = AddressModel.fromJson(jsonDecode(sharedPreferences.getString(AppConstants.USER_ADDRESS)));
    }catch(e) {}
    apiClient.updateHeader(
      sharedPreferences.getString(AppConstants.TOKEN), _addressModel == null ? null : _addressModel.zoneId.toString(),
      sharedPreferences.getString(AppConstants.LANGUAGE_CODE), module != null ? module.id : null,
    );
    // if(module == null && ResponsiveHelper.isDesktop(context)) {
    //   await sharedPreferences.remove(AppConstants.USER_ADDRESS);
    //   apiClient.updateHeader(
    //     sharedPreferences.getString(AppConstants.TOKEN), null,
    //     sharedPreferences.getString(AppConstants.LANGUAGE_CODE), null,
    //   );
    // }
    if(module != null) {
      await sharedPreferences.setString(AppConstants.MODULE_ID, jsonEncode(module.toJson()));
    }else {
      await sharedPreferences.remove(AppConstants.MODULE_ID);
    }
  }

  ModuleModel getModule() {
    ModuleModel _module;
    if(sharedPreferences.containsKey(AppConstants.MODULE_ID)) {
      try {
        _module = ModuleModel.fromJson(jsonDecode(sharedPreferences.getString(AppConstants.MODULE_ID)));
      }catch(e) {}
    }
    return _module;
  }

}
