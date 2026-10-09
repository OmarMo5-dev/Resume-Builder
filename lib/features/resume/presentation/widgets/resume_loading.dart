import 'package:flutter/material.dart';

class ResumeLoading extends StatelessWidget {
  const ResumeLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Row(
        spacing: 15,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [CircularProgressIndicator(), Text("Loading....")],
      ),
    );
  }
}
