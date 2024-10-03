//   the first stage in making the grid displa thing in flutter is making somethinglike this
//
import 'package:flutter/material.dart';

class Grid_Display extends StatefulWidget {
  const Grid_Display({super.key});

  @override
  State<Grid_Display> createState() => _Grid_Display();
}

class _Grid_Display extends State<Grid_Display> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Container(
      child: GridView(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 10,
              childAspectRatio: 2,
              mainAxisSpacing: 2,
              crossAxisSpacing: 4)
              //  here are two section here the itemsBuilder and the itemscCount for the building of each of the items in the gird view and ther f
              //  for the specficification of the number of items 
              
              ),
    ));
  }
}
