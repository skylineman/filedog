
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/extensions.dart';
import 'package:hive/hive.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:path/path.dart' as Path;
import 'package:get/get.dart';

enum _SelectionType {
  none,
  word,
  // line,
}

class EditNotepadPage extends StatefulWidget {
  EditNotepadPage ({Key? key, required this.curNotepadFile }) : super(key: key);
  final File curNotepadFile;

  @override
  _EditNotepadPageState createState() => _EditNotepadPageState();

}

class _EditNotepadPageState extends State<EditNotepadPage> {

  late QuillController _quillController;
  Timer? _selectAllTimer;
  _SelectionType _selectionType = _SelectionType.none;

  late FocusNode _focusNode;
  bool isNewNotepad = false;
  var isEditable = false.obs;
  late Document _document;

  @override
  void initState() {
    super.initState();
    // Here we must load the document and pass it to Zefyr controller.
    //final document = _loadDocument();
    _focusNode = FocusNode();


    if ( widget.curNotepadFile.lengthSync() != 0 ) {
      isNewNotepad = true;
      //debugPrint( '!!!!!!!!!!!' + _document.toString());
      //var myJSON = json.decode( '{"insert":"hello"}' );
      _document = Document.fromJson( [
        {'insert': 'Hello\n'},
      ] );
    }
    else {
      var _documentContent = widget.curNotepadFile.readAsLinesSync();
      _document = Document.fromJson( _documentContent );
    }

    _quillController = QuillController.basic(); //( document: _document, selection: TextSelection.collapsed(offset: 0));
    _quillController.document = _document;

    //_clipboardController = ClipboardController;
  }

  @override
  void dispose() {
    //widget.curNotepadFile.writeAsStringSync(json.encode(_controller.document.toJson()));
    _quillController.dispose();
    _focusNode.dispose();
    _selectAllTimer?.cancel();
    super.dispose();
  }

  void _pop( var result ) {

    Get.back( result: result);
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final defaultStyle = DefaultTextStyle.of(context);
    final baseStyle = defaultStyle.style.copyWith(
      fontSize: 16.0,
      height: 1.3,
    );
    //final baseSpacing = VerticalSpacing(top: 6.0, bottom: 10);

    return PopScope(
      canPop: true,
      onPopInvoked: ( bool didPop ) => _pop( didPop ),
      child: Scaffold(
       backgroundColor: Color.fromRGBO(0xf3, 0xe8, 0xcb, 1.0), //#F3E8CB
        appBar: AppBar(
          title: Text( Path.basename( widget.curNotepadFile.path ) ),
          actions: [
            isNewNotepad
              ? IconButton(
                icon: Icon(Icons.save),
                onPressed: () {
                  var _deltaData = _quillController.document.toDelta().toJson();
                  widget.curNotepadFile.writeAsStringSync( json.encode( _deltaData ));
                  //debugPrint(_deltaData.toString());
                }
              )
              : Obx(() => IconButton( icon: ( isEditable.value )
                ? ImageIcon( AssetImage( 'images/icons/read_only.png'), size: 24.0,)
                : ImageIcon( AssetImage( 'images/icons/edit.png'), size: 24.0,) ,
                onPressed: () {
                  isEditable.value = !isEditable.value;
                }
              ))
          ],
        ),
        body: _buildWelcomeEditor( context ),

      )
    );

    // TODO: implement build
    throw
    UnimplementedError
    (
    );
  }

  bool _onTripleClickSelection() {
    final controller = _quillController;

    _selectAllTimer?.cancel();
    _selectAllTimer = null;

    // If you want to select all text after paragraph, uncomment this line
    // if (_selectionType == _SelectionType.line) {
    //   final selection = TextSelection(
    //     baseOffset: 0,
    //     extentOffset: controller.document.length,
    //   );

    //   controller.updateSelection(selection, ChangeSource.REMOTE);

    //   _selectionType = _SelectionType.none;

    //   return true;
    // }

    if (controller.selection.isCollapsed) {
      _selectionType = _SelectionType.none;
    }

    if (_selectionType == _SelectionType.none) {
      _selectionType = _SelectionType.word;
      _startTripleClickTimer();
      return false;
    }

    if (_selectionType == _SelectionType.word) {
      final child = controller.document.queryChild(
        controller.selection.baseOffset,
      );
      final offset = child.node?.documentOffset ?? 0;
      final length = child.node?.length ?? 0;

      final selection = TextSelection(
        baseOffset: offset,
        extentOffset: offset + length,
      );

      controller.updateSelection(selection, ChangeSource.remote );

      // _selectionType = _SelectionType.line;

      _selectionType = _SelectionType.none;

      _startTripleClickTimer();

      return true;
    }

    return false;
  }

  void _startTripleClickTimer() {
    _selectAllTimer = Timer(const Duration(milliseconds: 900), () {
      _selectionType = _SelectionType.none;
    });
  }

  Widget _buildWelcomeEditor(BuildContext context) {
    Widget quillEditor = QuillEditor.basic(
      scrollController: ScrollController(),
      focusNode: _focusNode,
      configurations: QuillEditorConfigurations(
        controller: _quillController,
        autoFocus: false,
        readOnly: false,
        placeholder: 'Add content',
        enableSelectionToolbar: true,
        expands: false,
        padding: EdgeInsets.zero,
        scrollable: true,
        onTapUp: (details, p1) {
          return _onTripleClickSelection();
        },
        embedBuilders: [
          //...FlutterQuillEmbeds.builders(),
          //TimeStampEmbedBuilderWidget()
        ],
        customStyles: DefaultStyles(
          color: Colors.black,
          h1: DefaultTextBlockStyle(
            const TextStyle(
              fontSize: 32,
              color: Colors.black,
              height: 1.15,
              fontWeight: FontWeight.w300,
            ),
            const VerticalSpacing(16, 0),
            const VerticalSpacing(0, 0),
            null
          ),
          h2: DefaultTextBlockStyle(
            const TextStyle(
              fontSize: 28,
              color: Colors.black,
              height: 1.15,
              fontWeight: FontWeight.w300,
            ),
            const VerticalSpacing(16, 0),
            const VerticalSpacing(0, 0),
            null
          ),
          h3: DefaultTextBlockStyle(
              const TextStyle(
                fontSize: 26,
                color: Colors.black,
                height: 1.15,
                fontWeight: FontWeight.w300,
              ),
              const VerticalSpacing(16, 0),
              const VerticalSpacing(0, 0),
              null
          ),
          h4: DefaultTextBlockStyle(
              const TextStyle(
                fontSize: 24,
                color: Colors.black,
                height: 1.15,
                fontWeight: FontWeight.w300,
              ),
              const VerticalSpacing(16, 0),
              const VerticalSpacing(0, 0),
              null
          ),
          h5: DefaultTextBlockStyle(
              const TextStyle(
                fontSize: 22,
                color: Colors.black,
                height: 1.15,
                fontWeight: FontWeight.w300,
              ),
              const VerticalSpacing(16, 0),
              const VerticalSpacing(0, 0),
              null
          ),
          h6: DefaultTextBlockStyle(
              const TextStyle(
                fontSize: 20,
                color: Colors.black,
                height: 1.15,
                fontWeight: FontWeight.w300,
              ),
              const VerticalSpacing(16, 0),
              const VerticalSpacing(0, 0),
              null
          ),
          paragraph: DefaultTextBlockStyle(
              const TextStyle(
                fontSize: 18,
                color: Colors.black,
                height: 1.15,
                fontWeight: FontWeight.w300,
              ),
              const VerticalSpacing(16, 0),
              const VerticalSpacing(0, 0),
              null
          ),
          sizeSmall: const TextStyle(fontSize: 16 ),
          sizeLarge: const TextStyle(fontSize: 24 ),
          sizeHuge: const TextStyle(fontSize: 32 ),
        ),
      ),
    );

    var toolbar = QuillToolbar.simple(
      configurations: QuillSimpleToolbarConfigurations(
        controller: _quillController,
        showDividers: false,
        showFontFamily: false,
        showFontSize: true,
        showBoldButton: true,
        showItalicButton: true,
        showUnderLineButton: true,
        showSmallButton: false,
        showStrikeThrough: false,
        showInlineCode: false,
        showColorButton: false,
        showBackgroundColorButton: false,
        showClearFormat: false,
        showAlignmentButtons: true,
        showLeftAlignment: false,
        showCenterAlignment: false,
        showRightAlignment: false,
        showJustifyAlignment: false,
        showHeaderStyle: false,
        showListNumbers: true,
        showListBullets: true,
        showListCheck: false,
        showCodeBlock: false,
        showQuote: false,
        showIndent: false,
        showLink: false,
        showUndo: false,
        showRedo: false,
        showDirection: false,
        showSubscript: false,
        showSuperscript: false,
        showSearchButton: false,

        //afterButtonPressed: _focusNode.requestFocus,
      )

      /*
      embedButtons: FlutterQuillEmbeds.buttons(
        // provide a callback to enable picking images from device.
        // if omit, "image" button only allows adding images from url.
        // same goes for videos.
        onImagePickCallback: _onImagePickCallback,
        onVideoPickCallback: _onVideoPickCallback,
        // uncomment to provide a custom "pick from" dialog.
        // mediaPickSettingSelector: _selectMediaPickSetting,
        // uncomment to provide a custom "pick from" dialog.
        // cameraPickSettingSelector: _selectCameraPickSetting,
      ),

       */

    );

    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            flex: 15,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: quillEditor,
            ),
          ),
          Container(child: toolbar)
        ],
      ),
    );
  }
  /// Loads the document to be edited in Zefyr.
  ///
  /*
  NotusDocument _loadDocument() {
    // For simplicity we hardcode a simple document with one line of text
    // saying "Zefyr Quick Start".
    // (Note that delta must always end with newline.)
    //final Delta delta = Delta()..insert("Zefyr Quick Start\n");

    Delta _deltaData = Delta.fromJson(json.decode(widget.curNotepadFile.readAsStringSync()));
    return NotusDocument.fromDelta(_deltaData);
  }

   */



}

/*
/// Builder for toolbar buttons handling toggleable style attributes.
///
/// See [myDefaultToggleStyleButtonBuilder] as a reference implementation.
typedef MyToggleStyleButtonBuilder = Widget Function(
    BuildContext context,
    //NotusAttribute attribute,
    IconData icon,
    bool isToggled,
    VoidCallback? onPressed,
    );

/// Toolbar button which allows to toggle a style attribute on or off.
class MyToggleStyleButton extends StatefulWidget {
  /// The style attribute controlled by this button.
  //final NotusAttribute attribute;

  /// The icon representing the style [attribute].
  final IconData icon;

  /// Controller attached to a Zefyr editor.
  //final ZefyrController controller;

  /// Builder function to customize visual representation of this button.
  //final ToggleStyleButtonBuilder childBuilder;

  const MyToggleStyleButton({
    Key? key,
    //required this.attribute,
    required this.icon,
    //required this.controller,
    //this.childBuilder = myDefaultToggleStyleButtonBuilder,
  }) : super(key: key);

  @override
  _MyToggleStyleButtonState createState() => _MyToggleStyleButtonState();
}

class _MyToggleStyleButtonState extends State<MyToggleStyleButton> {
  late bool _isToggled;

  //NotusStyle get _selectionStyle => widget.controller.getSelectionStyle();

  void _didChangeEditingValue() {
    //setState(() => _checkIsToggled());
    setState(() {
    //  _isToggled = widget.controller.getSelectionStyle().containsSame(widget.attribute);
    });
  }

  @override
  void initState() {
    super.initState();
    //_isToggled = _selectionStyle.containsSame(widget.attribute);
    //_checkIsToggled();
    //widget.controller.addListener(_didChangeEditingValue);
  }

  @override
  void didUpdateWidget(covariant MyToggleStyleButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    /*
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_didChangeEditingValue);
      widget.controller.addListener(_didChangeEditingValue);
      _isToggled = _selectionStyle.containsSame(widget.attribute);
      //_checkIsToggled();
    }

     */
  }

  @override
  void dispose() {
    //widget.controller.removeListener(_didChangeEditingValue);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If the cursor is currently inside a code block we disable all
    // toggle style buttons (except the code block button itself) since there
    // is no point in applying styles to a unformatted block of text.
    // TODO: Add code block checks to heading and embed buttons as well.
    /*
    final isInCodeBlock = _selectionStyle.containsSame(NotusAttribute.block.code);
    final isEnabled = !isInCodeBlock || widget.attribute == NotusAttribute.block.code;

     */
    //return widget.childBuilder(context, widget.attribute, widget.icon, _isToggled, isEnabled ? _toggleAttribute : null);
    return Container();
  }

  /*
  void _toggleAttribute() {
    if (_isToggled) {
      if (!widget.attribute.isUnset) {
        widget.controller.formatSelection(widget.attribute.unset);
      }
    } else {
      widget.controller.formatSelection(widget.attribute);
    }
  }

   */

  /*
  void _checkIsToggled() {
    if (widget.attribute.isUnset) {
      _isToggled = !_selectionStyle.contains(widget.attribute);
    } else {
      _isToggled = _selectionStyle.containsSame(widget.attribute);
    }
  }

   */
}
*/
