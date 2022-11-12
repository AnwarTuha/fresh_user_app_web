import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/html_type.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';
import 'package:universal_html/html.dart' as html;
import 'package:universal_ui/universal_ui.dart';
import 'package:url_launcher/url_launcher.dart';

class HtmlViewerScreen extends StatefulWidget {
  final HtmlType htmlType;
  HtmlViewerScreen({@required this.htmlType});

  @override
  State<HtmlViewerScreen> createState() => _HtmlViewerScreenState();
}

class _HtmlViewerScreenState extends State<HtmlViewerScreen> {
  String _data;
  String _viewID;

  @override
  void initState() {
    super.initState();

    _data = widget.htmlType == HtmlType.TERMS_AND_CONDITION ? Get.find<SplashController>().configModel.termsAndConditions
        : widget.htmlType == HtmlType.ABOUT_US ? Get.find<SplashController>().configModel.aboutUs
        : widget.htmlType == HtmlType.PRIVACY_POLICY ? Get.find<SplashController>().configModel.privacyPolicy : null;

    if(_data != null && _data.isNotEmpty) {
      _data = _data.replaceAll('href=', 'target="_blank" href=');
    }

    _viewID = widget.htmlType.toString();
    if(GetPlatform.isWeb) {
      try{
        ui.platformViewRegistry.registerViewFactory(_viewID, (int viewId) {
          html.IFrameElement _ife = html.IFrameElement();
          _ife.width = Dimensions.WEB_MAX_WIDTH.toString();
          _ife.height = MediaQuery.of(context).size.height.toString();
          _ife.srcdoc = _data;
          _ife.contentEditable = 'false';
          _ife.style.border = 'none';
          _ife.allowFullscreen = true;
          return _ife;
        });
      }catch(e) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: widget.htmlType == HtmlType.TERMS_AND_CONDITION ? 'terms_conditions'.tr
          : widget.htmlType == HtmlType.ABOUT_US ? 'about_us'.tr : widget.htmlType == HtmlType.PRIVACY_POLICY
          ? 'privacy_policy'.tr : 'no_data_found'.tr),
      body: Center(
        child: Container(
          width: Dimensions.WEB_MAX_WIDTH,
          height: MediaQuery.of(context).size.height,
          color: GetPlatform.isWeb ? Colors.white : Theme.of(context).cardColor,
          child: GetPlatform.isWeb ? Column(
            children: [
              Container(
                height: 50, alignment: Alignment.center,
                child: SelectableText(widget.htmlType == HtmlType.TERMS_AND_CONDITION ? 'terms_conditions'.tr
                    : widget.htmlType == HtmlType.ABOUT_US ? 'about_us'.tr : widget.htmlType == HtmlType.PRIVACY_POLICY
                    ? 'privacy_policy'.tr : 'no_data_found'.tr,
                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Colors.black),
                ),
              ),
              Expanded(child: IgnorePointer(child: HtmlElementView(viewType: _viewID, key: Key(widget.htmlType.toString())))),
            ],
          ) : SingleChildScrollView(
            padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
            physics: BouncingScrollPhysics(),
            child: HtmlWidget(
              _data ?? '',
              key: Key(widget.htmlType.toString()),
              onTapUrl: (String url) {
                return launch(url);
              },
            ),
          ),
        ),
      ),
    );
  }
}