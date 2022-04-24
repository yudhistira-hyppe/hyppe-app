import 'package:flutter/material.dart';

class ProfileCompletionForm extends StatelessWidget {
  const ProfileCompletionForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Text("Please input the data correctly"),
        Text(
            "you will be returned to post setting page after this process is done"),
      ],
    );
  }
}
