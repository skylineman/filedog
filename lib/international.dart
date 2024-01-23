import 'dart:ui';
import 'package:get/get.dart';

class Messages extends Translations {

  @override
  // TODO: implement keys
  Map<String, Map<String, String>> get keys => {

    'zh_CN': {
      'Created': '已被创建',
      'hello': "你好, 世界",
      'NewFolder': '新文件夹',
    },
    'en_US': {
      'Created': 'Created',
      'hello': 'hello world',
      'NewFolder': 'New Folder',
    }
  };
}

class MessagesController extends GetxController {

  void changeLanguage(String languageCode, String  countryCode) {
    var locale = Locale(languageCode, countryCode);
    Get.updateLocale(locale);
  }
}