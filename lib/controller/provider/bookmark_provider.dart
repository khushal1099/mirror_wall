import 'package:flutter/cupertino.dart';

class BookMarkProvider extends ChangeNotifier {
  List<String> sitenamelist = [];
  List<String> siteurllist = [];
  bool isBookmark = false;

  void addBookmark(String name) {
    sitenamelist.add(name);
    isBookmark = !isBookmark;
    // siteurllist.add(url);
    notifyListeners();
  }
}
