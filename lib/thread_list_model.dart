import 'package:flutter/cupertino.dart';
import 'package:wind/nntp_client.dart';
import 'package:wind/thread_list_view.dart';

class ThreadListModel extends ChangeNotifier {
  String currentGroup = "";
  NNTPClient? client;
  Map<String, Map<int, List<ThreadItem>>> threads = {};
  int _pageNum = -1;
  List<ThreadItem> _curItems = [];

  Future<void> selectNewsgroup(String name) async {
    if (currentGroup == name) return;

    currentGroup = name;
    await client!.selectGroup(name);
    threads.putIfAbsent(name, () => {});
    _curItems.clear();
    _pageNum = -1;

    notifyListeners();
  }

  Future<List<ThreadItem>> getNewThreads(bool clearCache) async {
    if (currentGroup == "") return [];

    _pageNum += 1;

    if (clearCache) {
      threads[currentGroup]?.clear();
    }

    if (threads[currentGroup]!.containsKey(_pageNum)) {
      _curItems.addAll(threads[currentGroup]![_pageNum]!);
    } else {
      var resp = await client!.getNewThreads(10, _pageNum);
      resp.forEach((pair) {
        var number = pair.item1;
        var msg = pair.item2;
        _curItems.add(ThreadItem(
            msg.getHeaderValue("Message-Id")!,
            number,
            msg.decodeSubject()!,
            msg.getHeaderValue("From")!,
            msg.getHeaderValue("Date")!,
            msg.decodeTextPlainPart()!));
      });

      if (resp.isEmpty) _pageNum -= 1;

      threads[currentGroup]![_pageNum] = List.from(_curItems);
    }

    return _curItems;
  }

  void update() {
    _curItems.clear();
    _pageNum = -1;
    threads[currentGroup]!.clear();
    notifyListeners();
  }
}
