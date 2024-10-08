//  the single Savething
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Singlesavedroute extends StatelessWidget {
//  the information need
  final String id;
  final String previewFile;
  final String userProfile;
  final String userName;
  final String nameTrip;

  const Singlesavedroute(
      {super.key,
      required this.id,
      required this.previewFile,
      required this.userProfile,
      required this.userName, required this.nameTrip});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(9),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18), shape: BoxShape.rectangle),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //  the first is the image
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: const Image(
                  image: AssetImage('assets/Fun/Cat.png'),
                  fit: BoxFit.cover,
                ),
              ),
              //   some space for the  title of the location
              const SizedBox(
                height: 12,
              ),
              //  the name
              Center(
                
                child: Container(
                  color: Colors.black.withOpacity(0.4),
                  child:  Text(nameTrip,style: const TextStyle(color: Colors.white),),
                ),
              )
  //  the Profile information 
, 
SizedBox(height: 12,)
,
 Row(
    children: [
 
 ClipRRect(
   borderRadius: BorderRadius.circular(50),
   child: Image(image: AssetImage(userProfile),width: 200,height: 200,),
 
 )
 ,
//  the name of the person   
  Text(userName,style:  const TextStyle(
fontWeight: FontWeight.bold,
fontSize: 20
 ),)

  
 
    ],
 )
 

   
            ],
          ),
        ),
      ),
    );
  }
}
