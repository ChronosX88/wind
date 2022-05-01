import 'package:enough_mail/enough_mail.dart';
import 'package:flutter/cupertino.dart';
import 'package:wind/message_item_view.dart';
import 'package:wind/nntp_client.dart';

class ThreadModel extends ChangeNotifier {
  NNTPClient? client;

  var commentTextController = TextEditingController(text: "");

  Future<MessageItem> getPost(int number) async {
    var msg = await client!.getPost(number);
    var mi = MessageItem(
        msg.getHeaderValue("Message-Id")!,
        number,
        msg.decodeSubject()!,
        msg.getHeaderValue("From")!,
        msg.getHeaderValue("Date")!,
        msg.decodeTextPlainPart()!);
    mi.originalMessage = msg;
    return mi;
  }

  Future<List<MessageItem>> getThread(int threadNumber) async {
    if (client!.currentGroup == "") return [];

    List<MessageItem> items = [];

    var thread = await client!.getThread(threadNumber);

    thread.forEach((pair) {
      var messageNum = pair.item1;
      var message = pair.item2;
      items.add(MessageItem(
          message.getHeaderValue("Message-Id")!,
          messageNum,
          null,
          message.getHeaderValue("From")!,
          message.getHeaderValue("Date")!,
          message.decodeTextPlainPart()!.trim()));
    });

    return items;
  }

  Future<int> postMessage(MimeMessage opPost, String text) async {
    var msg = MessageBuilder.buildSimpleTextMessage(
        MailAddress.empty(), [], text.trim(),
        subject: "Re: " + opPost.decodeSubject()!);
    msg.setHeader("From", "anonymous");
    msg.addHeader("In-Reply-To", opPost.getHeaderValue("Message-Id"));
    msg.addHeader("References", opPost.getHeaderValue("Message-Id"));
    msg.addHeader("Newsgroups", client!.currentGroup!);
    return await client!.postArticle(msg);
  }

  Future<int> createThread(String subject, String text) async {
    var msg = MessageBuilder.buildSimpleTextMessage(
        MailAddress.empty(), [], text.trim(),
        subject: subject);
    msg.setHeader("From", "anonymous");
    msg.addHeader("Newsgroups", client!.currentGroup!);
    return await client!.postArticle(msg);
  }

  void update() {
    notifyListeners();
  }
}
