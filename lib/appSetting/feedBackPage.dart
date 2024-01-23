import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../defClassandGlobal.dart';
import '../generated/l10n.dart';
import '../customWidgets.dart';

class FeedBackPage extends StatefulWidget {

  FeedBackPage({Key? key }) : super(key: key);

  @override
  _FeedBackPageState createState() => _FeedBackPageState();

}

class _FeedBackPageState extends State<FeedBackPage> {

  final _key = GlobalKey<FormState>();
  TextEditingController _emailCtrl = TextEditingController();
  TextEditingController _subjectCtrl = TextEditingController();
  TextEditingController _contentCtrl = TextEditingController();
  //FirebaseFirestore dbFirebase = FirebaseFirestore.instance;

  @override
  Widget build( BuildContext context ){
    return Scaffold(
      appBar: AppBar(
        title: Text( S.of( context ).Feedback ),
      ),
      body: Container(
        alignment: Alignment.topCenter,
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _key,
          child: ListView(
            children: [

              // Email
              Container(
                padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                child: Text('Email'),
              ),
              CustomTextForm(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icon( Icons.email ),
              ),

              // Subject
              SizedBox( height: 16.0,),
              Container(
                padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                child: Text('Subject'),
              ),
              CustomTextForm(
                controller: _subjectCtrl,
                keyboardType: TextInputType.text,
                prefixIcon: Icon( Icons.subject ),
              ),

              // Content
              SizedBox( height: 16.0,),
              Container(
                padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                child: Text('Content'),
              ),
              CustomTextForm(
                controller: _contentCtrl,
                keyboardType: TextInputType.multiline,
                prefixIcon: Icon( Icons.text_snippet ),
                minLines: 10,
                maxLines: 20,
              ),
              SizedBox( height: 16.0,),
              MyCustomButton(
                colorStyle: CustomButtonColorStyle.confirm,
                height: 48.0,
                width: ScreenSize(context).width -32.0,
                label: Text('Submit'),
                onPressed: (){
                  if ( _key.currentState!.validate() ) {
                    //feedBackToFirebase().then((value) => null);
                  }
                }
              ),
            ],
          ),
        ),
      ),
    );
  }

  /*
  Future feedBackToFirebase() {
    return dbFirebase.collection('Feedback').add({
      "email": _emailCtrl.text,
      "subject": _subjectCtrl.text,
      "content": _contentCtrl.text,
    }).then((value) {
      EasyLoading.showSuccess('Sent Complete', duration: Duration( seconds: 3 ));
      Get.back();
    }).onError((error, stackTrace) {
      EasyLoading.showInfo( error.toString(), duration: Duration( seconds: 3 ) );
    });
  }

   */
}

