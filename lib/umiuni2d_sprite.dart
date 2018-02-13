library umiuni2d_sprite_html5;


import 'dart:html' as html;
import 'dart:async';
import 'package:umiuni2d_sprite/umiuni2d_sprite.dart' as core;

import 'package:vector_math/vector_math_64.dart';
import 'dart:html';
import 'dart:web_gl';
import 'dart:typed_data';
import 'dart:convert' as conv;
//
part 'src/stage.dart';
part 'src/util.dart';
part 'src/loader.dart';
part 'src/image.dart';
part 'src/canvas.dart';
part 'src/context.dart';

part 'util/canvas_text.dart';

class GameWidget extends core.GameWidget {
  core.Stage _stage;
  core.Stage get stage => _stage;
  core.OnStart onStart = null;

  GameWidget({
    core.DisplayObject root:null,
    double width:400.0,
    double height:300.0,
    this.assetsRoot:"",
    thisselectors: null}) {
    if(root == null) {
      root = new core.GameRoot(width, height);
    }

    this._stage = createStage(root: root);
    (this._stage as TinyWebglStage).isTMode = true;
  }

  void start({core.OnStart onStart, bool useAnimationLoop:false}) {
    this.onStart = onStart;
    if(useAnimationLoop) {
      stage.start();
    }
    if(onStart != null) {
      onStart(this);
    }
  }

  void stop() {
    stage.stop();
  }

  void run() {

  }

  String assetsRoot = "";
  String get assetsPath => (assetsRoot.endsWith("/")?assetsRoot:"${assetsRoot}/");
  int width = 600;
  int height = 400;
  int paintInterval = 40;
  int tickInterval = 15;
  String selectors = null;
  double fontPower = 2.0;

  core.Stage createStage({core.DisplayObject root}) {
    if(root == null) {
      root = new core.DisplayObject();
    }
    return new TinyWebglStage(this, root, width:width.toDouble(), height:height.toDouble(), selectors:selectors, tickInterval:tickInterval, paintInterval:paintInterval);
  }

  Future<core.Image> loadImage(String path) async {
    ImageElement elm = await TinyWebglLoader.loadImage("${assetsPath}${path}");
    return new TinyWebglImage(elm);
  }

  Future<Uint8List> loadBytes(String path) async {
    Completer<Uint8List> c = new Completer();
    HttpRequest request = new HttpRequest();
    request.open("GET", "${assetsRoot}${path}");
    request.responseType = "arraybuffer";
    request.onLoad.listen((ProgressEvent e) async {
      ByteBuffer buffer = request.response;
      c.complete(buffer.asUint8List());
    });
    request.onError.listen((ProgressEvent e) {
      c.completeError(e);
    });
    request.send();
    return c.future;
  }

  Future<String> loadString(String path) async {
    Uint8List buffer = await loadBytes(path);
    return await conv.UTF8.decode(buffer, allowMalformed: true);
  }


  Future<String> getLocale() async {
    return window.navigator.language;
  }

  Future<double> getDisplayDensity() async {
    return window.devicePixelRatio;
  }
}