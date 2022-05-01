import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wind/create_thread_screen.dart';
import 'package:wind/newsgroup_list_view.dart';
import 'package:wind/nntp_client.dart';
import 'package:wind/thread_list_view.dart';
import 'package:wind/thread_model.dart';
import 'package:wind/thread_screen.dart';

import 'thread_list_model.dart';

void main() {
  runApp(MultiProvider(providers: [
    Provider<NNTPClient>(create: ((context) => NNTPClient("localhost:1120"))),
    ChangeNotifierProxyProvider<NNTPClient, ThreadListModel>(
        create: (context) => ThreadListModel(),
        update: (context, client, model) {
          model!.client = client;
          return model;
        }),
    ChangeNotifierProxyProvider<NNTPClient, ThreadModel>(
        create: (context) => ThreadModel(),
        update: (context, client, model) {
          model!.client = client;
          return model;
        }),
  ], child: MyApp()));
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
      onGenerateRoute: (settings) {
        Widget? pageView;
        if (settings.name != null) {
          var uriData = Uri.parse(settings.name!);

          switch (uriData.path) {
            case '/thread':
              pageView = ThreadScreen(
                  threadNumber:
                      int.parse(uriData.queryParametersAll['num']!.first));
              break;
            case '/thread/create':
              pageView = CreateThreadScreen();
              break;
            default:
              pageView = MyHomePage(title: 'Wind');
              break;
          }
        }
        if (pageView != null) {
          return MaterialPageRoute(
              settings: settings, builder: (BuildContext context) => pageView!);
        }
      },
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
    return Consumer<ThreadListModel>(
      builder: (context, value, child) => Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
            actions: value.currentGroup != ""
                ? [
                    TextButton.icon(
                      onPressed: () =>
                          Navigator.pushNamed(context, "/thread/create"),
                      icon: Icon(Icons.add),
                      label: Text("Создать тред"),
                      style: TextButton.styleFrom(
                          primary: Theme.of(context).colorScheme.onPrimary),
                    ),
                    TextButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Обновление списка тредов...')),
                          );
                          Provider.of<ThreadListModel>(context, listen: false)
                              .update();
                        },
                        label: const Text("Обновить"),
                        style: TextButton.styleFrom(
                            primary: Theme.of(context).colorScheme.onPrimary),
                        icon: Icon(Icons.sync))
                  ]
                : [],
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
                                    NewsgroupListView(client: nntpClient))),
                      ],
                    ),
                  ),
                  const VerticalDivider(thickness: 1, width: 1),
                  Expanded(
                      child: Center(
                    child: Consumer<ThreadListModel>(
                        builder: ((context, value, child) => ThreadListView())),
                  ))
                ],
              ),
            ),
          )),
    );
  }
}
