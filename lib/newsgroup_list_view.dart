import 'package:flutter/material.dart';
import 'package:wind/nntp_client.dart';

class NewsgroupListView extends StatelessWidget {
  final NNTPClient client;

  NewsgroupListView(this.client);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<GroupInfo>>(
      future: _fetchList(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<GroupInfo> data = snapshot.data!;
          return _newgroupListView(data);
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

  ListView _newgroupListView(List<GroupInfo> data) {
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        return ListTile(
            style: ListTileStyle.drawer,
            title: Text(data[index].name),
            subtitle: Text(data[index].description),
            onTap: () => {});
      },
    );
  }
}
