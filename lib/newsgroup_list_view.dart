import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wind/nntp_client.dart';
import 'package:wind/thread_list_model.dart';

class NewsgroupListView extends StatefulWidget {
  NewsgroupListView({Key? key, required this.client}) : super(key: key);

  final NNTPClient client;

  @override
  State<StatefulWidget> createState() => new NewsgroupListViewState(client);
}

class NewsgroupListViewState extends State<NewsgroupListView> {
  late NNTPClient client;
  int _selectedIndex = -1;

  NewsgroupListViewState(this.client);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<GroupInfo>>(
      future: _fetchList(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<GroupInfo> data = snapshot.data!;
          return _newsgroupListView(data);
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  Future<List<GroupInfo>> _fetchList() async {
    return await client.getNewsGroupList();
  }

  Widget _newsgroupListView(List<GroupInfo> data) {
    return ListView.builder(
        controller: ScrollController(),
        itemCount: data.length,
        itemBuilder: (context, index) {
          return ListTile(
              style: ListTileStyle.drawer,
              title: Text(data[index].name),
              subtitle: Text(data[index].description),
              selected: index == _selectedIndex,
              onTap: () {
                setState(() => _selectedIndex = index);
                var model = context.read<ThreadListModel>();
                model
                    .selectNewsgroup(data[index].name)
                    .whenComplete(() => null);
              });
        });
  }
}
