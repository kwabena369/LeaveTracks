import 'package:flutter/material.dart';
import 'package:leave_tracks/Service/http_helper.dart';

class InputTest extends StatefulWidget {
  const InputTest({Key? key}) : super(key: key);

  @override
  State<InputTest> createState() => _InputTestState();
}

class _InputTestState extends State<InputTest> {
  String inputValue = '';

  void handleChangeInput(String value) {
    setState(() {
      inputValue = value;
    });
  }

  // the instance of the httper helper

  Future<void> SendInformation() async {
    await HttpHelper().SendContent(inputValue);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("ghost"),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SingleInput(
                hintText: "Name",
                labelText: "E.g., Kofi",
                onChanged: handleChangeInput,
              ),
              const SizedBox(height: 20),
              Text(inputValue),
            ],
          ),
        ));
  }
}

class SingleInput extends StatelessWidget {
  final String hintText;
  final String labelText;
  final void Function(String) onChanged;

  const SingleInput({
    Key? key,
    required this.hintText,
    required this.labelText,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}
