import 'dart:async';
import 'dart:collection';
import 'package:web_socket_channel/web_socket_channel.dart';

class NNTPClient {
  late WebSocketChannel _channel;
  final Queue<_NNTPCommand> commandQueue = new Queue();

  NNTPClient(String addr) {
    _channel = WebSocketChannel.connect(
      Uri.parse("ws://$addr"),
    );

    _channel.stream.listen((data) {
      if ((data as String).contains("201")) {
        // skip welcome message
        return;
      }
      var command = commandQueue.removeFirst();
      var resp = data.toString();
      var respLines = resp.split("\r\n");
      respLines.removeWhere((element) => element == "");
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
