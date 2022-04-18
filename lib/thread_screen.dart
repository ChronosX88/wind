import 'package:enough_mail/mime_message.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wind/message_item_view.dart';
import 'package:wind/thread_list_view.dart';
import 'package:wind/thread_model.dart';

class ThreadScreenArguments {
  final ThreadItem item;

  ThreadScreenArguments(this.item);
}

class ThreadScreen extends StatefulWidget {
  ThreadScreen({Key? key, required this.threadNumber}) : super(key: key);

  late int threadNumber;

  @override
  State<StatefulWidget> createState() => ThreadScreenState(threadNumber);
}

class ThreadScreenState extends State<ThreadScreen> {
  ThreadScreenState(this.threadNumber);

  late ThreadModel model;
  late int threadNumber;

  @override
  Widget build(BuildContext context) {
    model = Provider.of<ThreadModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text("Тред #${this.threadNumber}"),
        actions: [
          TextButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Обновление треда...')),
                );
                model.update();
              },
              label: const Text("Обновить"),
              style: TextButton.styleFrom(
                  primary: Theme.of(context).colorScheme.onPrimary),
              icon: Icon(Icons.sync))
        ],
      ),
      body: Center(
          child: Container(
        width: 650,
        child: Consumer<ThreadModel>(
            builder: ((context, value, child) =>
                FutureBuilder<List<MessageItem>>(
                  future: _fetch(context),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<MessageItem> data = List.from(snapshot.data!);
                      data.insert(
                          1, MessageItem("reply", 0, "", "", "", "")); // reply
                      return _listView(data);
                    } else if (snapshot.hasError) {
                      return Text("${snapshot.error}");
                    }
                    return Center(child: CircularProgressIndicator());
                  },
                ))),
      )),
    );
  }

  Future<List<MessageItem>> _fetch(BuildContext context) async {
    List<MessageItem> posts = [];

    var threadPosts = await model.getThread(threadNumber);
    posts.addAll(threadPosts);
    var opPost = await model.getPost(threadNumber);
    posts.insert(0, opPost);

    return posts;
  }

  Widget _listView(List<MessageItem> data) {
    return ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          if (index == 1) {
            return SendMessageForm(opPost: data[0].originalMessage!);
          }
          return MessageItemView(
              item: data[index],
              isOpPost: index == 0,
              isLast: index == data.length - 1);
        });
  }
}

class SendMessageForm extends StatefulWidget {
  const SendMessageForm({Key? key, required this.opPost}) : super(key: key);

  final MimeMessage opPost;

  @override
  SendMessageFormState createState() {
    return SendMessageFormState(opPost);
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class SendMessageFormState extends State<SendMessageForm> {
  SendMessageFormState(this.opPost);

  final MimeMessage opPost;

  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Container(
        margin: EdgeInsets.only(left: 16, right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(children: [
                Consumer<ThreadModel>(
                    builder: ((context, value, child) => TextFormField(
                          controller: value.commentTextController,
                          minLines: 5,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Комментарий"),
                          // The validator receives the text that the user has entered.
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Пожалуйста, введите текст';
                            }
                            return null;
                          },
                        ))),
                Consumer<ThreadModel>(
                  builder: (((context, value, child) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                // Validate returns true if the form is valid, or false otherwise.
                                if (_formKey.currentState!.validate()) {
                                  Provider.of<ThreadModel>(context,
                                          listen: false)
                                      .postMessage(opPost,
                                          value.commentTextController.text)
                                      .then((responseCode) {
                                    if (responseCode == 240) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text('Пост отправлен!')),
                                      );
                                      Provider.of<ThreadModel>(context,
                                              listen: false)
                                          .update();
                                    }
                                  });
                                  value.commentTextController.text = "";
                                }
                              },
                              child: const Text('Отправить'),
                            )
                          ])))),
                )
              ]),
            )
          ],
        ),
      ),
    );
  }
}
