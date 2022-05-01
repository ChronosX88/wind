import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wind/thread_list_model.dart';
import 'package:wind/thread_model.dart';

class CreateThreadScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CreateThreadScreenState();
}

class _CreateThreadScreenState extends State<CreateThreadScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Создать новый тред")),
        body: Center(
            child: Container(
          width: 640,
          child: Consumer<ThreadModel>(
            builder: (context, value, child) => CreateThreadForm(model: value),
          ),
        )));
  }
}

class CreateThreadForm extends StatefulWidget {
  CreateThreadForm({Key? key, required this.model}) : super(key: key);

  ThreadModel model;

  @override
  CreateThreadFormState createState() {
    return CreateThreadFormState(model);
  }
}

// Define a corresponding State class.
// This class holds data related to the form.
class CreateThreadFormState extends State<CreateThreadForm> {
  CreateThreadFormState(this.model);

  ThreadModel model;
  final _formKey = GlobalKey<FormState>();

  String _subject = "";
  String _text = "";

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: TextFormField(
                onSaved: ((newValue) {
                  _subject = newValue!;
                }),
                decoration: InputDecoration(
                    border: OutlineInputBorder(), labelText: "Название поста"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите название';
                  }
                  return null;
                }),
          ),
          Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextFormField(
                onSaved: (newValue) {
                  _text = newValue!;
                },
                minLines: 5,
                keyboardType: TextInputType.multiline,
                maxLines: 35,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), labelText: "Текст поста"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите текст';
                  }
                  return null;
                },
              )),
          ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  model.createThread(_subject, _text).then((value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Тред создан!')),
                    );
                    Provider.of<ThreadListModel>(context, listen: false)
                        .update();
                    Navigator.pop(context);
                  }, onError: (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'При создании треда произошла ошибка: ${error.toString()}')),
                    );
                  });
                }
              },
              child: Text("Создать"))
        ],
      ),
    );
  }
}
