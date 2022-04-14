import 'package:flutter/material.dart';
import 'package:wind/newsgroup_list_view.dart';
import 'package:wind/nntp_client.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wind',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: MyHomePage(title: 'Wind'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late NNTPClient nntpClient;

  @override
  void initState() {
    super.initState();

    nntpClient = NNTPClient("localhost:1120");
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        body: Center(
          child: Container(
            child: Row(
              children: [
                SizedBox(
                  width: 300,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          margin: EdgeInsets.all(16),
                          child: Text(
                            "Новостные группы",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          )),
                      Expanded(
                          child: Builder(
                              builder: (context) =>
                                  NewsgroupListView(nntpClient))),
                    ],
                  ),
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                    child: Center(
                  child: ThreadsListView(),
                ))
              ],
            ),
          ),
        ));
  }
}

class ThreadsListView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ThreadsListViewState();
}

class ThreadsListViewState extends State<ThreadsListView> {
  String currentGroup = "no group selected";

  @override
  Widget build(BuildContext context) {
    return Container(width: 640, child: Center(child: Text(currentGroup)));
  }
}

class ThreadListItemView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 5,
        child: InkWell(
          splashColor: Colors.indigo.withAlpha(30),
          onTap: () => {},
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                child: Text(
                  "A question for those who watched The Matrix in 1999.",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21),
                ),
                margin: EdgeInsets.only(top: 16, left: 16, right: 16),
              ),
              Container(
                child: Row(
                  children: [
                    Text(
                      "@sample_user",
                      style: TextStyle(
                          fontWeight: FontWeight.normal,
                          color: Colors.blue,
                          fontSize: 15),
                    ),
                    SizedBox(width: 5),
                    Text(
                      "14/04/22 Чтв 00:57:52",
                      style: TextStyle(fontSize: 15),
                    ),
                  ],
                ),
                margin: EdgeInsets.only(top: 5, bottom: 2, left: 16, right: 16),
              ),
              Container(
                child: Text(
                    "So I'm 16 years old, and I finally watched the first Matrix movie yesterday, and I found it amazing. Everything about it was wonderful. Anyway, I watched it with my mom and she was gushing over it again, telling me about how it blew her away when she watched it in the theaters when it came out.\nAnd that inspired me to ask this question. To any of you in this subreddit who watched the movie when it was released, do you have any fond memories or stories about your experience in the theater that you can tell me about?\nI'd really like to hear them. 👍",
                    style: TextStyle(fontSize: 17)),
                margin: EdgeInsets.all(16),
              )
            ],
          ),
        ));
  }
}
