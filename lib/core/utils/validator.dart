bool validateEmail(String email) {
  String p =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

  RegExp regExp = new RegExp(p);

  return regExp.hasMatch(email) ? true : false;
}

bool checkStringNullOrEmpty(String? src) {
  return src == null || src.isEmpty;
}

bool checkListIsNullOrEmpty(List? lst) {
  return lst == null || lst.isEmpty;
}

bool checkMapIsNullOrEmpty(Map? map) {
  return map == null || map.isEmpty;
}

bool checkSetIstNullOrEmpty(Set? set) {
  return set == null || set.isEmpty;
}

int lastClickedTime = 0;
const int MIN_LAST_CLICK_TIME = 1500;

bool isJustClicked() {
  int elapseRealTime = DateTime.now().millisecondsSinceEpoch;
  if (elapseRealTime - lastClickedTime < MIN_LAST_CLICK_TIME) {
    return true;
  }
  lastClickedTime = elapseRealTime;
  return false;
}

String addPortalDomain(String domain, String keyReplace, String content) {
  var text = domain + keyReplace;
  return content.replaceAll(keyReplace, text);
}

String removeFigureTag(String? html) {
  if (checkStringNullOrEmpty(html)) return '';
  return html!.replaceAll('<figure>', '').replaceAll('</figure>', '');
}
