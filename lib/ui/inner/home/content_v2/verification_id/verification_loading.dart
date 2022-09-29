import 'package:flutter/material.dart';

class VerificationIDLoading extends StatelessWidget {
  const VerificationIDLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
