import 'package:flutter/material.dart';

final appLoader = OverlayEntry(
  builder: (_) => Container(
    color: Colors.white54,
    child: const Center(
      child: CircularProgressIndicator(),
    ),
  ),
);
