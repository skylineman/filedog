
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:path/path.dart' as Path;
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import 'package:webview_flutter/webview_flutter.dart';

import '../hiveDataTable/defImageInfomationClass.dart';
import '../foldersAndFiles.dart';

//import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class MyDocumentsViewPage extends StatefulWidget {
  MyDocumentsViewPage({Key? key, required this.documentFilePath, required this.fileInfo }) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String documentFilePath;
  final ImageFileInfo fileInfo;

  @override
  _MyDocumentsViewPageState createState() => _MyDocumentsViewPageState();
}

class _MyDocumentsViewPageState extends State<MyDocumentsViewPage> {

  final Completer<PDFViewController> _pdfController = Completer<PDFViewController>();
  static const int _initialPage = 0;
  int _actualPageNumber = _initialPage, _allPagesCount = 0;
  late bool isReady;
  //late InAppWebViewController _controller;
  late WebViewController _controller;
  late Future<Uint8List> fileData;

  @override
  void initState() {
    //if ( Path.extension( widget.documentFilePath ) != '.pad' )
    fileData = ReadCyptoFile( File( widget.documentFilePath ));
    //else
    //  fileData = File( widget.documentFilePath ).readAsString();

    _controller = WebViewController.fromPlatformCreationParams( PlatformWebViewControllerCreationParams() );

    super.initState();
    //if ( Platform.isAndroid ) WebView.platform = AndroidWebView();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text( widget.fileInfo.realBaseName ),
        /*
        actions: [
          IconButton(
            icon: Icon( Icons.more_vert ),
            onPressed: (){
              OpenFile.open( widget.documentFilePath );
            },
          ),
        ],
        */
      ),

      body: FutureBuilder(
        future: fileData,
        builder: ( context, AsyncSnapshot<Uint8List> snapshot){
          if ( snapshot.connectionState == ConnectionState.done && snapshot.data != null )
            return documentViewBody( snapshot.data! );
          else
            return Center(
              child: CircularProgressIndicator(
                //radius: 32.0,
                //percent: 0.0,
                //animation: true,
              )
            );
        },
      ),

    );

    throw UnimplementedError();
  }

  Widget documentViewBody( Uint8List _fileData ) {

    if ( Path.extension( widget.fileInfo.realBaseName ) == '.pdf' )
      return PDFView(
        //filePath: widget.documentFilePath,
        pdfData: _fileData,
        enableSwipe: true,
        swipeHorizontal: true,
        autoSpacing: false,
        pageFling: false,
        onRender: ( _pages ) {
          setState(() {
            _actualPageNumber = _pages!;
            isReady = true;
          });
        },
        onError: (error) {
          print(error.toString());
        },
        onPageError: (page, error) {
          print('$page: ${error.toString()}');
        },
        onViewCreated: (PDFViewController pdfViewController) {
          _pdfController.complete(pdfViewController);
        },
      );

    if ( Path.extension( widget.fileInfo.realBaseName ) == '.docx' ) {
      _setWebViewController(_fileData, 'html-js/docxtest.html');

      return WebViewWidget(
        controller: _controller,
        /*
        initialUrl: 'file:///android_asset/flutter_assets/html-js/docxtest.html',
        javascriptMode: JavascriptMode.unrestricted,
        initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
        onWebViewCreated: ( _ctrl ) {
          _controller = _ctrl;
          EasyLoading.show(status: 'loading...');
        },
        onPageFinished: ( s ){
          _controller.runJavascript( 'fromFlutter($_fileData)');
          EasyLoading.dismiss();
        },
        
         */
      );
    }

    if ( Path.extension( widget.fileInfo.realBaseName ) == '.xlsx' ) {
      _setWebViewController(_fileData, 'html-js/exceltest.html');

      return WebViewWidget(
        controller: _controller,
        /*
        initialUrl: "file:///android_asset/flutter_assets/html-js/exceltest.html",
        javascriptMode: JavascriptMode.unrestricted,
        initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
        onWebViewCreated: ( _ctrl ) {
          _controller = _ctrl;
        },
        onPageFinished: ( s ){
          _controller.runJavascript( 'fromFlutter($_fileData)');
        },
        
         */
      );
    }
    return Container();
  }

  void _setWebViewController( Uint8List _fileData, String loadAsset ) {

    _controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            _controller.runJavaScript( 'fromFlutter($_fileData)');
            //debugPrint('Page finished loading: $_fileData');
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''Page resource error: code: ${error.errorCode}
                description: ${error.description}
                errorType: ${error.errorType}
                isForMainFrame: ${error.isForMainFrame}
            ''');
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              debugPrint('blocking navigation to ${request.url}');
              return NavigationDecision.prevent;
            }
            debugPrint('allowing navigation to ${request.url}');
            return NavigationDecision.navigate;
          },
          onUrlChange: (UrlChange change) {
            debugPrint('url change to ${change.url}');
          },
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        },
      )
      ..loadFlutterAsset( loadAsset ); //'html-js/docxtest.html');

  }

}