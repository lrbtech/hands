import 'package:flutter/material.dart';
import 'package:hands_user_app/provider/locale/base_language.dart';

extension ContextExt on BuildContext {
  Languages get translate => Languages.of(this);
}
