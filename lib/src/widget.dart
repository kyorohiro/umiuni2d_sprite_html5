part of umiuni2d_sprite_html5;

class GameWidget extends core.GameWidget {
  core.Stage _stage;
  core.Stage get stage => _stage;
  Map<String, Object> objects = {};

  core.OnLoop onLoop = null;
  GameWidget({
    core.DisplayObject root:null,
    core.DisplayObject background,
    core.DisplayObject front,
    double width:400.0,
    double height:300.0,
    this.assetsRoot:"",
    this.selectors: null}) {

    if(root == null) {
      root = new core.GameRoot(width, height);
    }
    this._stage = createStage(root: root, background: background, front: front);
  }

  Future<GameWidget> start({core.OnStart onStart, core.OnLoop onLoop, bool useAnimationLoop:false}) async {
    this.onLoop = onStart;
    this.onLoop = onLoop;
    if(useAnimationLoop) {
      stage.start();
    }
    if(onStart != null) {
      onStart(this);
    }
    return this;
  }

  Future<GameWidget> stop() async {
    stage.stop();
    return this;
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

  core.Stage createStage({core.DisplayObject root, core.DisplayObject background, core.DisplayObject front}) {
    if(root == null) {
      root = new core.DisplayObject();
    }
    return new Stage(this, root, background, front, width:width.toDouble(), height:height.toDouble(),
        selectors:selectors, tickInterval:tickInterval, paintInterval:paintInterval);
  }

  Future<core.Image> loadImage(String path) async {
    ImageElement elm = await TinyWebglLoader.loadImage("${assetsPath}${path}");
    return new Image(elm);
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

  Map<String, Object> cached = {};
  Future<Image> loadAndCacheImage(String path) async {
    cached[path] = await loadImage(path);
    return cached[path] as Image;
  }

  Image getCachedImage(String path) {
    if(cached.containsKey(path)) {
      return cached[path];
    } else {
      return null;
    }
  }
//  Future<core.ImageShader> createImageShader(core.Image image) async {
//    return null;
//  }
}

