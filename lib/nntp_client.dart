import 'dart:async';
import 'dart:collection';
import 'package:enough_mail/mime_message.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:tuple/tuple.dart';

class NNTPClient {
  late WebSocketChannel _channel;
  final Queue<_NNTPCommand> commandQueue = new Queue();
  final List<String> tempBuffer = [];

  String? currentGroup;

  NNTPClient(String addr) {
    _channel = WebSocketChannel.connect(
      Uri.parse("ws://$addr"),
    );

    _channel.stream.listen((data) {
      if ((data as String).startsWith("201")) {
        // skip welcome message
        return;
      }
      var resp = data.toString();
      var respLines = resp.split("\r\n");
      if (respLines.last == "") respLines.removeLast(); // trailing empty line

      if ((respLines.length > 1 || tempBuffer.isNotEmpty) &&
          respLines.last.codeUnits.last != ".".codeUnits.first) {
        // if it's multiline response and it doesn't contain dot in the end
        // then looks like we need to wait for next message to concatenate with current msg
        tempBuffer.add(resp);
        return;
      }

      if (tempBuffer.isNotEmpty) {
        tempBuffer.add(resp);
        resp = tempBuffer.join();
        respLines = resp.split("\r\n");
        respLines.removeLast(); // trailing empty line
        tempBuffer.clear();
      }
      var command = commandQueue.removeFirst();
      var respCode = int.parse(respLines[0].split(" ")[0]);
      command.responseCompleter.complete(_CommandResponse(respCode, respLines));
    });
  }

  Future<_CommandResponse> _sendCommand(
      String command, List<String> args) async {
    var cmd = _NNTPCommand(_CommandRequest(command, args));
    commandQueue.add(cmd);
    if (args.length > 0) {
      _channel.sink.add("$command ${args.join(" ")}\r\n");
    } else {
      _channel.sink.add("$command\r\n");
    }

    var result = await cmd.response;
    return result;
  }

  Future<List<GroupInfo>> getNewsGroupList() async {
    List<GroupInfo> l = [];

    var groupMap = {};

    await _sendCommand("LIST", ["NEWSGROUPS"]).then((value) {
      value.lines.removeAt(0);
      value.lines.removeLast();
      value.lines.forEach((element) {
        var firstSpace = element.indexOf(" ");
        var name = element.substring(0, firstSpace);
        groupMap.addAll({
          name: {"desc": element.substring(firstSpace + 1)}
        });
      });
    });

    await _sendCommand("LIST", ["ACTIVE"]).then((value) {
      value.lines.removeAt(0);
      value.lines.removeLast();
      value.lines.forEach((element) {
        var splitted = element.split(" ");
        var name = splitted[0];
        var high = splitted[1];
        var low = splitted[2];
        groupMap[name]["high"] = high;
        groupMap[name]["low"] = low;
      });
    });

    groupMap.forEach((key, value) {
      l.add(GroupInfo(key, value["desc"], int.parse(value["low"]),
          int.parse(value["high"])));
    });

    return l;
  }

  Future<void> selectGroup(String name) async {
    await _sendCommand("GROUP", [name]).then((value) => {currentGroup = name});
  }

  Future<List<Tuple2<int, MimeMessage>>> getNewThreads(
      int perPage, int pageNum) async {
    if (currentGroup == null) throw new ArgumentError("current group is null");

    List<Tuple2<int, MimeMessage>> threads = [];

    var newThreadList = await _sendCommand(
        "NEWTHREADS", [perPage.toString(), pageNum.toString()]);

    newThreadList.lines.removeAt(0);
    newThreadList.lines.removeLast(); // remove dot

    await Future.forEach<String>(newThreadList.lines, (element) async {
      await _sendCommand("ARTICLE", [element]).then((response) {
        response.lines.removeAt(0);
        response.lines.removeLast();
        var rawMsg = response.lines.join("\r\n");
        threads
            .add(Tuple2(int.parse(element), MimeMessage.parseFromText(rawMsg)));
      });
    });

    return threads;
  }
}

class _NNTPCommand {
  late _CommandRequest request;
  late Future<_CommandResponse> response;
  late Completer<_CommandResponse> responseCompleter;

  _NNTPCommand(_CommandRequest request) {
    this.request = request;
    this.responseCompleter = Completer();
    this.response = responseCompleter.future;
  }
}

class _CommandRequest {
  final String command;
  final List<String> args;

  _CommandRequest(this.command, this.args);
}

class _CommandResponse {
  final int responseCode;
  final List<String> lines;

  _CommandResponse(this.responseCode, this.lines);
}

class GroupInfo {
  final String name;
  final String description;
  final int lowWater;
  final int highWater;

  GroupInfo(this.name, this.description, this.lowWater, this.highWater);
}
