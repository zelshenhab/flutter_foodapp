import 'package:flutter/material.dart';

class AddressReadonlyTile extends StatelessWidget {
  final String address;
  const AddressReadonlyTile({super.key, required this.address});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.location_on, color: Colors.orange),
      title: Text(address),
    );
  }
}
