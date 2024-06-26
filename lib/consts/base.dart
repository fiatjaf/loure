class Base {
  static const APP_NAME = "loure";
  static int VERSION_NUM = 1;
  static const String PRIVACY_LINK =
      "https://nostrmo.com/pages/PolicyAndTerms.html";
  static const double BASE_PADDING = 12;
  static const double BASE_PADDING_HALF = 6;
  static String INDEXS_CONTACTS = "https://nostrmo.com/indexs/contacts.json";
  static String INDEXS_TOPICS = "https://nostrmo.com/indexs/topics.json";
  static String WEB_TOOLS = "https://nostrmo.com/indexs/webtools.json";
  static String IMAGE_PROXY_SERVICE = "https://imagebridge.nostrmo.com/";
  static String IMAGE_PROXY_SERVICE_KEY = "please_do_not_abuse_thanks";
  static String userAgent() {
    return "$APP_NAME 0.1.0";
  }

  static double BASE_FONT_SIZE = 14;
  static double BASE_FONT_SIZE_PC = 14;
  static double TABBAR_HEIGHT = 46;
}
