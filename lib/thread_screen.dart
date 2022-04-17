import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wind/message_item_view.dart';
import 'package:wind/nntp_client.dart';
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

  late NNTPClient client;
  late int threadNumber;

  @override
  Widget build(BuildContext context) {
    client = context.read<NNTPClient>();

    return Scaffold(
      appBar: AppBar(
        title: Text("Thread #${this.threadNumber}"),
      ),
      body: Center(
          child: Container(
        width: 640,
        child: FutureBuilder<List<MessageItem>>(
          future: _fetch(context),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<MessageItem> data = List.from(snapshot.data!);
              data.insert(1, MessageItem("reply", 0, "", "", "", "")); // reply
              return _listView(data);
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return Center(child: CircularProgressIndicator());
          },
        ),
      )),
    );
  }

  Future<List<MessageItem>> _fetch(BuildContext context) async {
    var model = context.read<ThreadModel>();
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
            return SendMessageForm();
          }
          return MessageItemView(item: data[index], isOpPost: index == 0);
        });
  }
}

class SendMessageForm extends StatefulWidget {
  const SendMessageForm({Key? key}) : super(key: key);

  @override
  SendMessageFormState createState() {
    return SendMessageFormState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class SendMessageFormState extends State<SendMessageForm> {
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
                            border: OutlineInputBorder(), labelText: "Comment"),
                        // The validator receives the text that the user has entered.
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                      ))),
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // Validate returns true if the form is valid, or false otherwise.
                            if (_formKey.currentState!.validate()) {
                              // If the form is valid, display a snackbar. In the real world,
                              // you'd often call a server or save the information in a database.
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Processing Data')),
                              );
                            }
                          },
                          child: const Text('Send'),
                        )
                      ]))
            ]),
          )
        ],
      ),
    );
  }
}
