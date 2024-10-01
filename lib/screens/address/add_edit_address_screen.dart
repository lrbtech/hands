import 'package:flutter/cupertino.dart';
import 'package:hands_user_app/component/base_scaffold_widget.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/model/address_model.dart';

class AddEditAddressScreen extends StatefulWidget {
  const AddEditAddressScreen({this.address, super.key});

  final AddressModel? address;

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  init() {}

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: language.setAddress,
      child: Column(
        children: [],
      ),
    );
  }
}
