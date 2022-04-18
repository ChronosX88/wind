import 'package:enough_mail/enough_mail.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wind/thread_model.dart';

class MessageItemView extends StatelessWidget {
  const MessageItemView(
      {Key? key,
      required this.item,
      required this.isOpPost,
      required this.isLast})
      : super(key: key);

  final MessageItem item;
  final bool isOpPost;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: this.isOpPost
            ? EdgeInsets.only(bottom: 10, left: 10, right: 10, top: 16)
            : isLast
                ? EdgeInsets.only(left: 10, right: 10, bottom: 16)
                : EdgeInsets.only(left: 10, right: 10),
        child: Card(
            elevation: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                isOpPost
                    ? Container(
                        child: Text(
                          item.subject!,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 21),
                        ),
                        margin: EdgeInsets.only(top: 16, left: 16, right: 16),
                      )
                    : Container(),
                Container(
                  child: Row(
                    children: [
                      Text(
                        item.author,
                        style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Colors.blue,
                            fontSize: 15),
                      ),
                      SizedBox(width: 5),
                      Text(
                        item.date,
                        style: TextStyle(fontSize: 15),
                      ),
                      SizedBox(width: 5),
                      InkWell(
                        child: Text(
                          "#${item.number}",
                          style: TextStyle(fontSize: 15, color: Colors.grey),
                        ),
                        onTap: () {
                          var model =
                              Provider.of<ThreadModel>(context, listen: false);
                          model.commentTextController.text +=
                              ">>${item.number}\n";
                        },
                      )
                    ],
                  ),
                  margin: isOpPost
                      ? EdgeInsets.only(top: 5, bottom: 2, left: 16, right: 16)
                      : EdgeInsets.only(top: 16, left: 16),
                ),
                Container(
                  child:
                      SelectableText(item.body, style: TextStyle(fontSize: 17)),
                  margin: EdgeInsets.all(16),
                )
              ],
            )));
  }
}

class MessageItem {
  final String id;
  final int number;
  final String? subject;
  final String author;
  final String date;
  final String body;

  MimeMessage? originalMessage;

  MessageItem(
      this.id, this.number, this.subject, this.author, this.date, this.body);
}
