import 'dart:async';

import 'package:filedog/webView/webViewPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
//import 'package:lottie/lottie.dart';
import 'package:path/path.dart' as Path;
import 'package:image/image.dart' as Img;
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';

import 'defClassandGlobal.dart';
import 'generated/l10n.dart';

// 自定义Widget

Widget CupListTile({ required Widget title, Widget? subtitle, EdgeInsetsGeometry? padding, Widget? leading, Widget? trailing, required Function() onTap, }) {

  return InkWell(
    child: Container(
      padding: padding ?? EdgeInsets.fromLTRB( 16.0, 16.0, 24.0, 16.0),

      child: Row(
        children: [
          Container(
            child: ( leading ) ?? SizedBox(),
            padding: ( leading != null ) ? EdgeInsets.only( right: 0.0 ) : null,
          ),
          Expanded(
            child: Material(
              //type: MaterialType.button,
              color: Colors.transparent,
              textStyle: TextStyle( fontSize: 18.0, color: ( Get.isDarkMode ) ? Colors.grey.shade100 : Colors.black ),
              child: Container (
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only( left: 16.0 ),
                child: title,
              ),
            )
          ),
          Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only( left: 8.0 ),
            child: subtitle,
          ),
          trailing ?? Icon( Icons.chevron_right ),
        ]
      )
    ),
    onTap: onTap,
  );
}


Future<dynamic> GetXInputDialogWithRegExp({ required String title, String? defaultString, required List<TextInputFormatter> inputFormatters, String regExpString = '' } ) {

  final _textCtrl = TextEditingController();
  //final _textFocusNode = FocusNode();

  if ( defaultString != null )
    _textCtrl.value = TextEditingValue(
      text: defaultString,
      selection: TextSelection.fromPosition(
        TextPosition(
          affinity: TextAffinity.downstream,
          offset: defaultString.length,
        ),
      ),
    );

  return Get.defaultDialog(
    title: title,
    titleStyle: TextStyle( fontSize: 18.0, fontWeight: FontWeight.bold, ),
    titlePadding: EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 8.0),
    radius: 24.0,

    onWillPop: () async {
      //_textCtrl.dispose();
      debugPrint( 'onWillPop' );
      return true;
    },
    actions: [
      MyCustomButton(
        colorStyle: CustomButtonColorStyle.normal,
        label: Text( S.of(Get.context!).Cancel, style: TextStyle( fontSize: 18.0),),
        height: 48.0,
        width: 112.0,
        onPressed: () {
          //_textCtrl.dispose();
          Get.back( result: null);
        },
      ),

      VerticalDivider( width: 8.0, ),

      MyCustomButton(
        colorStyle: CustomButtonColorStyle.confirm,
        label: Text( S.of(Get.context!).Confirm, style: TextStyle( fontSize: 18.0),),
        height: 48.0,
        width: 112.0,
        onPressed:() {
          Get.back( result: _textCtrl.text );
          //_textCtrl.dispose();
        }
      ),
    ],

    content: Container(
      height: 120.0,
      width: ScreenSize(Get.context!).width - 16.0,
      child: Column(
        children: [
          Divider(),
          Padding(
            padding: EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 0.0),
            child: TextField(
              style: TextStyle( fontSize: 18.0 ),
              controller: _textCtrl,
              //focusNode: _textFocusNode,
              autofocus: true,
              inputFormatters: inputFormatters,
              decoration: InputDecoration(
                helperText: regExpString,
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                )
              ),
            ),
          ),
          Spacer(),
        ]
      ),
    ),
  );
}


// 圆形图标按钮，可以自定义背景色

Widget MyIconButton ( { double iconSize = 24.0,
  double backSize = 56.0,
  required Icon icon,
  Color backgroundColor = Colors.blue,
  Color iconColor = Colors.white,
  required Function onTap
} ) => Container(
    alignment: Alignment.center,
    height: backSize,
    width: backSize,
    decoration: new BoxDecoration(
      //背景
      color: backgroundColor,
      //设置四周圆角 角度
      borderRadius: BorderRadius.all(Radius.circular( backSize / 2.0 )),
      /*
      boxShadow: [
        BoxShadow(
          blurRadius: 2.0, //阴影范围
          spreadRadius: 1.0, //阴影浓度
          color: Colors.grey, //阴影颜色
          offset: Offset.fromDirection( 2.0 )
        )
      ]

      */
    ),
    child: IconButton(
      color: iconColor,
      iconSize: iconSize,
      icon: icon,
      onPressed: () => onTap(),
    )
);


// 横向 Image List 的图形进度指示器
Widget MyImageProcessIndicator(){

  return Container(

    child: GridView.count(crossAxisCount: 5),

  );
}

// 自定义button，圆角纯底色

Widget MyCustomButton ( { required void Function()? onPressed, void Function()? onLongPress, CustomButtonColorStyle colorStyle = CustomButtonColorStyle.normal,
  Widget? icon, required Widget label, required double height, required double width, bool isEnable = true } ){

  Color? _backColor = Colors.grey[200];
  Color _foreColor = Get.theme.primaryColor;

  switch ( colorStyle ) {
    case CustomButtonColorStyle.confirm:
      _backColor = Get.theme.primaryColor;     //Theme.of( mainAppKey.currentContext! ).primaryColor;
      _foreColor = Colors.white;
      break;
    case CustomButtonColorStyle.alert:
      _backColor = Colors.orange;
      _foreColor = Colors.white;
      break;
    case CustomButtonColorStyle.delete:
      _backColor = Colors.deepOrange;
      _foreColor = Colors.white;
      break;
    default:
      break;
  }

  return SizedBox( width: width, height: height, child: ElevatedButton(
    onPressed: ( isEnable ) ? onPressed : null,
    style: ButtonStyle(
      backgroundColor: ( isEnable ) ? MaterialStateProperty.all( _backColor ) : MaterialStateProperty.all( Colors.grey ),
      foregroundColor: MaterialStateProperty.all( _foreColor ),
      shape: MaterialStateProperty.all( RoundedRectangleBorder(
          borderRadius: BorderRadius.circular( height / 2.0 ))
      ),
      //side: MaterialStateProperty.all( BorderSide( color: _backColor, width: 0.1 )),
      //maximumSize: MaterialStatePropertyAll( Size( width, height )),
      //fixedSize: MaterialStatePropertyAll( Size( 280.0, height )),
      //minimumSize: MaterialStateProperty.all( Size( 96.0, 48.0 )),
      elevation: MaterialStateProperty.all( 0.0 ),
    ),

    child: Container(
      alignment: Alignment.center,
      child: ( icon != null ) ? Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          SizedBox( width: 8.0,),
          label,
        ],
      )
      : label,
    ),
  ));
}

Widget myStepIndicator({ required pageIndex, int itemCount = 0 }) {

  /// 普通的颜色
  final Color normalColor = Theme.of( mainAppKey.currentContext!).primaryColor;

  /// 选中的颜色
  final Color selectedColor = Colors.red;

  /// 点的大小
  final double size = 8.0;

  /// 点的间距
  final double spacing = 4.0;

  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List<Widget>.generate(itemCount, (int index) {
      bool isCurrentPageSelected = ( index == ( pageIndex.value != null ? pageIndex.value.round() % itemCount : 0));
      return Container(
        height: size,
        width: size + (2 * spacing),
        child: Center(
          child: Material(
            color: isCurrentPageSelected ? selectedColor : normalColor,
            type: MaterialType.circle,
            child: Container(
              width: size,
              height: size,
            ),
          ),
        ),
      );
    }),
  );
}

Widget MyOutlinedButton({
  void Function()? onPressed,
  Color textColor = Colors.blue,
  Color foregroundColor = Colors.blue,
  Color backgroundColor = Colors.white,
  bool isBorder = true,
  IconData? icon,
  required String title,
  String? subTitle,

  }) => OutlinedButton(

  onPressed: onPressed,
  style: ButtonStyle(
    textStyle: MaterialStateProperty.all( TextStyle( color: textColor )),
    foregroundColor: MaterialStateProperty.all( foregroundColor),
    backgroundColor: MaterialStateProperty.all( backgroundColor),
    side: ( isBorder ) ? MaterialStateProperty.all( BorderSide( color: foregroundColor ) )
                       : MaterialStateProperty.all( BorderSide( color: backgroundColor ) ),
    shape: MaterialStateProperty.all( RoundedRectangleBorder(
      borderRadius: BorderRadius.circular( 16.0 )
    ))
  ),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Icon( icon, size: 24.0 ),
      SizedBox( width: 16.0 ),
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,

        children: (subTitle != null ) ? [
          Text( title, style: TextStyle( fontSize: 16.0),),
          Text( subTitle ),
        ]
        : [
        Text( title, style: TextStyle( fontSize: 16.0),),
        ],
      )
    ],
  ),
);

Widget ImageOfFileType ( String fileType ) {

  String assetName = 'unknown.png';
  switch ( fileType.toUpperCase() ) {
    case '.DOC':
    case '.DOCX':
      assetName = 'docx.png';
      break;
    case '.XLS':
    case '.XLSX':
      assetName = 'xlsx.png';
      break;
    case '.PDF':
      assetName = 'pdf.png';
      break;
    case '.TXT':
      assetName = 'txt.png';
      break;
    case '.PAD':
      assetName = 'notepad.png';
      break;
    case '.MP3':
      assetName = 'mp3.png';
      break;
    case '.M4A':
    case '.OGG':
    case '.AAC':
      assetName = 'music.png';
      break;
    default:
      break;
  }
  return Image.asset( 'images/' + assetName, height: 40.0,width: 40.0, );
}

// 根据当前时间显示指定时间

Widget myShowDateTime( DateTime _time, String locale ) {
  String _str;
  debugPrint( locale);

  if ( _time.year == DateTime.now().year ){
    if ( _time.day == DateTime.now().day )
      _str = DateFormat.Hm().format(_time);              //formatDate (_time, [HH, ':', nn]);
    else
      _str = DateFormat.MMMd( locale ).format(_time);

    return Text(_str);
  }

  else return Container(
      child: Column(
        children: [
          Text(DateFormat.Md( locale ).format(_time)),
          Text(DateFormat.y().format(_time)),
        ],
      )
  );
}

// 带有 Head Lable 和 自定义 Body 的圆角底部弹出式底部弹出式
Future<dynamic> CustomBottomSheet( BuildContext context, { required Widget headLable, required Widget body, double? height }) =>
  Get.bottomSheet(
    Material(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only( topLeft: Radius.circular( 32.0), topRight: Radius.circular( 32.0))
      ),
      child: Ink(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          borderRadius: BorderRadius.all( Radius.circular( 32.0 )),
        ),
        height: height,
        child: Container(
          padding: EdgeInsets.only( left: 16, top: 0, right: 16, bottom: 0),
          child: ListView(
            children: [
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
                child: headLable
              ),
              Divider(
                height: 16.0,
                thickness: 1.0,
              ),
              body,
            ],
          ),
        )
      ),
    )
  );

// 选项列表的弹出式

Future<dynamic> MyListBottomSheet( BuildContext context, String headLable, List itemList, int selectedIndex) =>
  Get.bottomSheet( Material(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only( topLeft: Radius.circular( 32.0), topRight: Radius.circular( 32.0))
    ),
    child: Ink(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: BorderRadius.all( Radius.circular( 32.0 )),
      ),
      height: ((itemList.length) +1) * 64.0,
      child: ListView.builder(
        padding: EdgeInsets.only( left: 16, top: 0, right: 16, bottom: 0),
        itemCount: itemList.length + 2,
        itemBuilder: (BuildContext context, int index) {
          switch ( index ) {
            case 0:
              return Container(
                alignment: Alignment.center,
                padding: EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
                child: Text( headLable, style: TextStyle(fontSize: 18),)
              );
              break;
            case 1:
              return Divider(
                height: 16.0,
                thickness: 1.0,
              );
              break;
            default:
              return InkWell(
                splashColor: Theme.of(context).primaryColorLight,
                borderRadius: BorderRadius.all(Radius.circular( 16.0 )),
                onTap: () => Navigator.of(context).pop(index - 2),
                child: Container(
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: (index == ( selectedIndex + 2)) ? Theme.of(context).primaryColorLight : null,
                    borderRadius: BorderRadius.all(Radius.circular( 16.0 )),
                  ),
                  child: Text('${itemList[index - 2]}',
                    style: TextStyle(
                      fontSize: 16, color: (index == ( selectedIndex + 2)) ? Colors.white : null,),
                  )
                ),
              );
              break;
          }
        },
        //separatorBuilder: (context, index) => Divider(),
      ),
    ),
  ));

// 定制的“移动到回收站”弹出BottomSheet

Future MoveToTrashBottomSheet( BuildContext context ) => Get.bottomSheet(
  Material(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only( topLeft: Radius.circular( 32.0), topRight: Radius.circular( 32.0))
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.fromLTRB( 16.0, 24.0, 16.0, 16.0),
          child: Text( S.of(context).MovingToTrash , style: TextStyle( fontSize: 16.0, fontWeight: FontWeight.bold ),),
        ),
        Divider(height: 16.0,),
        ListTile(
          leading: Icon(Icons.delete, color: Colors.red,),
          title: Text( S.of( context ).Movingto + ' ' + S.of( context ).Trash ),
          onTap: () => Get.back(result: true),
        ),
        SizedBox( height: 32.0,),
      ]
    ),
  ));

// 定制的“用户隐私协议”弹出BottomSheet

Future PrivacyPolicyBottomSheet( BuildContext context ) => showModalBottomSheet(
  context: context,
  enableDrag: false,
  isDismissible: false,
  isScrollControlled: false,
  useSafeArea: true,
  builder: (BuildContext context) {
    bool isPrivacyPolicyAgree = true;
    bool isUserAgreementAgree = true;

    return Material(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only( topLeft: Radius.circular( 32.0), topRight: Radius.circular( 32.0))
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.fromLTRB( 16.0, 24.0, 16.0, 16.0),
            child: RichText(
              text: TextSpan(
                style: TextStyle( fontSize: 16.0, color: Colors.black),
                children: [
                  TextSpan( text: UserAgreementContent[0], style: TextStyle( fontSize: 16.0, color: Colors.black), ),
                  TextSpan(
                    text: UserAgreementContent[1],
                    style: TextStyle( fontSize: 16.0, color: Colors.blue ),
                    recognizer: TapGestureRecognizer()..onTap = () {
                      Get.to( WebViewPage(url: policyUrl, title: '用户协议', type: WebViewPageType.File ) )?.then((value) => isUserAgreementAgree = true );
                    }
                  ),
                  TextSpan( text: UserAgreementContent[2] ),
                  TextSpan(
                    text: UserAgreementContent[3],
                    style: TextStyle( fontSize: 16.0, color: Colors.blue ),
                    recognizer: TapGestureRecognizer()..onTap = () {
                      Get.to( WebViewPage(url: privacyUrl, title: '隐私政策', type: WebViewPageType.File ) )?.then((value) => isPrivacyPolicyAgree = true );
                    }
                  ),

                  TextSpan( text: UserAgreementContent[4] ),
                  TextSpan( text: UserAgreementContent[5] ),
                  TextSpan( text: UserAgreementContent[6] ),
                ]
              )
            )
          ),
          //Divider(height: 16.0,),
          MyCustomButton(
            label: Text( S.of( context ).Agree ),
            height: 48.0,
            width: ScreenSize( context ).width - 64.0,
            colorStyle: CustomButtonColorStyle.confirm,
            onPressed: () => ( isUserAgreementAgree && isPrivacyPolicyAgree )
              ? Get.back( result: true )
              : EasyLoading.showInfo( '请阅读用户协议与隐私政策', duration: Duration( seconds: 3 ), dismissOnTap: true ),
          ),
          SizedBox( height: 16.0,),
          MyCustomButton(
            label: Text( S.of( context ).Refuse ),
            height: 48.0,
            width: ScreenSize( context ).width - 64.0,
            colorStyle: CustomButtonColorStyle.normal,
            onPressed: () => Get.back( result: false ),
          ),
          SizedBox( height: 16.0,),
        ]
      ),
    ) ;
  },
);



// 导入文件弹出的BottomSheet

Future<bool?> ImportBottomSheet( StreamController _streamCtrlProcessImg, String headLabel, String importedLabel, int itemNumber, int totleNumber, bool isDeleteAvaliable  ) {

  var _processCounter = 0.obs;
  var isDeleteAsset = true.obs;
  int _importedItems = 0;

  // 从导入进度流中获取进度
  // 监听导入进度

  StreamSubscription _streamSub = _streamCtrlProcessImg.stream.listen(( event ) {
    _processCounter.value++;
    if ( event >= 0 )
      _importedItems = event;
  });

  return Get.bottomSheet( Material(
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only( topLeft: Radius.circular( 32.0), topRight: Radius.circular( 32.0))
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(24.0),
          child: Text( headLabel, style: TextStyle( fontSize: 18.0),),
        ),
        Divider(height: 1.0, thickness: 1.0),

        Obx(() => Container(
          //color: Colors.grey,
          height: 120.0,
          alignment: Alignment.center,
          child: ( _processCounter < totleNumber )
            ? CircularPercentIndicator(
                percent: _processCounter.toDouble() / totleNumber.toDouble(),
                radius: 48.0,
                lineWidth: 8.0,
                progressColor: Colors.blue,
                center: Text( _importedItems.toString() + '/' + itemNumber.toString(), style: TextStyle( fontSize: 20.0 ),),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text( itemNumber.toString(), style: TextStyle( fontSize: 40.0, fontWeight: FontWeight.bold, color: Theme.of( Get.context! ).primaryColorDark ),),
                  Text( importedLabel, style: TextStyle( fontSize: 16.0 ) ),
                ],
              ),
          )
        ),

        if ( isDeleteAvaliable )
          ListTile(
            leading: Icon( Icons.delete ),
            title: Text( S.of( Get.context! ).isDeleteSourceFile ),
            trailing: Obx(() => Switch(
              activeColor: Theme.of( Get.context! ).primaryColorDark,
              value: isDeleteAsset.value,
              onChanged: ( v ) {
                isDeleteAsset.value = v;
              },
            )),
          ),
        SizedBox( height: 16.0 ),
        Obx(() => MyCustomButton(
          colorStyle: CustomButtonColorStyle.confirm,
          onPressed: () {
            //if ( _streamSub.!)
            _streamSub.cancel();
            Get.back( result: isDeleteAsset.value );
          },
          label: Text( S.of( Get.context! ).Close, style: TextStyle(fontSize: 18.0),),
          height: 48.0,
          width: 200.0,
          isEnable: ( _processCounter.value >= totleNumber ),
        )),
        SizedBox( height: 16.0 )
      ]
    ),
  ),
    //backgroundColor: Colors.white,
    isDismissible: false,
    enableDrag: false,
  );
}


// 定制的TextFieldEdit

TextFormField CustomTextForm({
    TextEditingController? controller,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    Widget? prefixIcon,
    int? minLines,
    int? maxLines = 1,
    String? inputText,
    String? hintText,
    void Function(String)? onChanged,
  }

  ) => TextFormField(
    style: TextStyle( fontSize: 18.0 ),
    controller: controller,
    keyboardType: keyboardType,
    inputFormatters: inputFormatters,
    textAlignVertical: TextAlignVertical.center,
    maxLines: maxLines,
    minLines: minLines,
    decoration: InputDecoration(
    //helperText: regExpString,
      contentPadding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
      prefixIcon: prefixIcon,
      floatingLabelBehavior: FloatingLabelBehavior.never,

      hintText: hintText,
      suffixIcon: InkWell(
        child: Icon( Icons.close, color: Colors.black12, ),
        radius: 1.0,
        onTap: () => controller?.clear(),
      ),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.lightBlue),
        borderRadius: BorderRadius.all( Radius.circular( 16.0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.lightBlue),
        borderRadius: BorderRadius.all( Radius.circular( 16.0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blue),
        borderRadius: BorderRadius.all( Radius.circular( 16.0)),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent),
        borderRadius: BorderRadius.all( Radius.circular( 16.0)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent),
        borderRadius: BorderRadius.all( Radius.circular( 16.0)),
      ),
      disabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey ),
        borderRadius: BorderRadius.all( Radius.circular( 16.0)),
      ),
    ),
    validator: ( value ){
      if ( value!= null && value.isNotEmpty )
        return null;
      else
        return 'Field can not be empty!';
    },
    onSaved: ( value ){
      if ( value!= null && value.isNotEmpty )
        inputText = value;
    },
    onChanged: onChanged
  );


// 空文件夹
Widget MyEmptyFolder() => Container(
  alignment: Alignment.center,
  child:
  //Column(
  //  mainAxisAlignment: MainAxisAlignment.center,
  //  children: [
      Image.asset('images/empty-folder.png', width: 256.0, height: 256.0,),
      //Lottie.asset('images/lottie/empty-box.json'),
  //    SizedBox(height: 24.0),
  //    Text('There is nothing, Please import some files!', style: TextStyle(fontSize: 16.0)),
  //  ],
  //),
);

Future<bool> AuthFingerPrint( BuildContext context, String cancelButton ) => LocalAuthentication().authenticate(
  localizedReason: S.of(context).PleaseVerifyYourFingerprint,
  authMessages: <AuthMessages>[ AndroidAuthMessages(
      biometricHint: '',
      biometricNotRecognized: 'biometricNotRecognized',
      biometricRequiredTitle: 'biometricRequiredTitle',
      biometricSuccess: 'biometricSuccess',
      cancelButton: cancelButton,
      deviceCredentialsRequiredTitle: 'deviceCredentialsRequiredTitle',
      deviceCredentialsSetupDescription: 'deviceCredentialsSetupDescription',
      goToSettingsButton: 'goToSettingsButton',
      goToSettingsDescription: 'goToSettingsDescription',
      signInTitle: S.of(context).Filedog //'验证',
  )],
  options: AuthenticationOptions(
    biometricOnly: true,
  ),
);

// 定制的AppBar
// 定制的AppBar

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({Key? key, this.leading, this.title, this.actions, this.backgroundColor = Colors.white, this.foregroundColor = Colors.black87 }) : super(key: key);

  final Widget? leading;
  final Widget? title;
  final List<Widget>? actions;
  final Color foregroundColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      //color: backgroundColor,
      height: Size.infinite.height,
      decoration: BoxDecoration(
        color: backgroundColor
      ),
      foregroundDecoration: BoxDecoration(
        color: foregroundColor
      ),
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ( leading ) ?? SizedBox(),
          Expanded( child: (title) ?? SizedBox() ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: ( actions ) ?? [ SizedBox() ]
          )
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight( 56.0 );
}

// 选取音频资源，返回选中的资源

Future<List<AssetEntity>?> PickAudioAssets( BuildContext context ) {
  return AssetPicker.pickAssets(
    context,
    pickerConfig: AssetPickerConfig(
      maxAssets: MaxPickAssets,
      //selectedAssets: assetsPvFiles,
      requestType: RequestType.audio,
      gridCount: 3,
      pageSize: 24,
      specialPickerType: SpecialPickerType.noPreview,
    ),
  );
}

/*
const Duration _kExpand = Duration(milliseconds: 200);

/// A single-line [ListTile] with a trailing button that expands or collapses
/// the tile to reveal or hide the [children].
///
/// This widget is typically used with [ListView] to create an
/// "expand / collapse" list entry. When used with scrolling widgets like
/// [ListView], a unique [PageStorageKey] must be specified to enable the
/// [HJExpansionTile] to save and restore its expanded state when it is scrolled
/// in and out of view.
///
/// See also:
///
///  * [ListTile], useful for creating expansion tile [children] when the
///    expansion tile represents a sublist.
///  * The "Expand/collapse" section of
///    <https://material.io/guidelines/components/lists-controls.html>.

// 分割线显示时机
enum DividerDisplayTime {
  always, //总是显示
  opened, //展开时显示
  closed, //关闭时显示
  never //不显示
}

class HJExpansionTile extends StatefulWidget {
  /// Creates a single-line [ListTile] with a trailing button that expands or collapses
  /// the tile to reveal or hide the [children]. The [initiallyExpanded] property must
  /// be non-null.
  const HJExpansionTile({
    Key? key,
    this.leading,
    required this.title,
    this.backgroundColor,
    this.dividerColor,
    this.iconColor,
    this.dividerDisplayTime,
    this.onExpansionChanged,
    this.children = const <Widget>[],
    this.trailing,
    this.initiallyExpanded = false,
  })  : assert(initiallyExpanded != null),
        super(key: key);

  /// A widget to display before the title.
  ///
  /// Typically a [CircleAvatar] widget.
  final Widget? leading;

  /// The primary content of the list item.
  ///
  /// Typically a [Text] widget.
  final Widget title;

  /// Called when the tile expands or collapses.
  ///
  /// When the tile starts expanding, this function is called with the value
  /// true. When the tile starts collapsing, this function is called with
  /// the value false.
  final ValueChanged<bool>? onExpansionChanged;

  /// The widgets that are displayed when the tile expands.
  ///
  /// Typically [ListTile] widgets.
  final List<Widget> children;

  /// The color to display behind the sublist when expanded.
  final Color? backgroundColor;

  /// A widget to display instead of a rotating arrow icon.
  final Widget? trailing;

  /// Specifies if the list tile is initially expanded (true) or collapsed (false, the default).
  final bool initiallyExpanded;

  final Color? dividerColor;

  final DividerDisplayTime? dividerDisplayTime;

  final Color? iconColor;

  @override
  _HJExpansionTileState createState() => _HJExpansionTileState();
}

class _HJExpansionTileState extends State<HJExpansionTile> with SingleTickerProviderStateMixin {
  static final Animatable<double> _easeOutTween = CurveTween(curve: Curves.easeOut);
  static final Animatable<double> _easeInTween = CurveTween(curve: Curves.easeIn);
  static final Animatable<double> _halfTween = Tween<double>(begin: 0.0, end: 0.5);
  //static final Animatable<double> _halfTween = Tween<double>(begin: 0.0, end: 0.5);

  final ColorTween _borderColorTween = ColorTween();
  final ColorTween _headerColorTween = ColorTween();
  final ColorTween _iconColorTween = ColorTween();
  final ColorTween _backgroundColorTween = ColorTween();

  late AnimationController _controller;
  late Animation<double> _iconTurns;
  late Animation<double> _heightFactor;
  late Animation<Color?> _borderColor;
  late Animation<Color?> _headerColor;
  late Animation<Color?> _iconColor;
  late Animation<Color?> _backgroundColor;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: _kExpand, vsync: this);
    _heightFactor = _controller.drive(_easeInTween);
    _iconTurns = _controller.drive(_halfTween.chain(_easeInTween));
    _borderColor = _controller.drive( (_borderColorTween.chain(_easeInTween)) );
    _headerColor = _controller.drive(_headerColorTween.chain(_easeInTween));
    _iconColor = _controller.drive(_iconColorTween.chain(_easeInTween));
    _backgroundColor = _controller.drive(_backgroundColorTween.chain(_easeOutTween));

    _isExpanded = PageStorage.of(context).readState(context) ?? widget.initiallyExpanded;
    if (_isExpanded) _controller.value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse().then<void>((void value) {
          if (!mounted) return;
          setState(() {
            // Rebuild without widget.children.
          });
        });
      }
      PageStorage.of(context).writeState(context, _isExpanded);
    });
    if (widget.onExpansionChanged != null)
      widget.onExpansionChanged!(_isExpanded);
  }

  Widget _buildChildren(BuildContext context, Widget? child) {
    final Color borderSideColor = _borderColor.value ?? Colors.transparent;

    return Container(
      decoration: BoxDecoration(
        color: _backgroundColor.value ?? Colors.transparent,
        border: Border(
          bottom: BorderSide(color: borderSideColor),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTileTheme.merge(
            iconColor: _iconColor.value,
            textColor: _headerColor.value,
            child: ListTile(
              onTap: _handleTap,
              leading: widget.leading,
              title: widget.title,
              trailing: widget.trailing ??
                RotationTransition(
                  turns: _iconTurns,
                  child: const Icon(Icons.expand_more),
                ),
            ),
          ),
          ClipRect(
            child: Align(
              heightFactor: _heightFactor.value,
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void didChangeDependencies() {

    setupDidvierColorTween();

    setupIconColorTween();

    setupBackgroundColor();

    super.didChangeDependencies();
  }

  void setupDidvierColorTween() {
    final ThemeData theme = Theme.of(context);

    Color beginColor = this.widget.dividerColor ?? theme.dividerColor;
    Color endColor = beginColor;

    switch (widget.dividerDisplayTime) {
      case DividerDisplayTime.always:
        break;
      case DividerDisplayTime.opened:
        endColor = Colors.transparent;
        break;
      case DividerDisplayTime.closed:
        beginColor = Colors.transparent;
        break;
      case DividerDisplayTime.never:
        beginColor = Colors.transparent;
        endColor = Colors.transparent;
        break;
      default:
    }
    _borderColorTween
      ..begin = beginColor
      ..end = endColor;
  }

  void setupIconColorTween(){
    final ThemeData theme = Theme.of(context);

    Color beginColor = this.widget.iconColor ?? theme.unselectedWidgetColor;
    Color endColor = beginColor;

    _iconColorTween
      ..begin = beginColor
      ..end = endColor;
  }

  void setupBackgroundColor(){
    _backgroundColorTween
      ..begin = widget.backgroundColor
      ..end = widget.backgroundColor;
  }
  @override
  Widget build(BuildContext context) {
    final bool closed = !_isExpanded && _controller.isDismissed;
    return AnimatedBuilder(
      animation: _controller.view,
      builder: _buildChildren,
      child: closed ? null : Column(children: widget.children),
    );
  }
}


 */
