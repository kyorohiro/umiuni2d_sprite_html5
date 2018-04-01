part of umiuni2d_sprite_html5;

class TinyWebglProgram {
  int maxBuffer = 100;
  Program compile(RenderingContext GL, String vs, String fs) {
    // setup shader
    Shader vertexShader = loadShader(GL, RenderingContext.VERTEX_SHADER, vs);

    Shader fragmentShader = loadShader(GL, RenderingContext.FRAGMENT_SHADER, fs);

    Program shaderProgram = GL.createProgram();
    GL.attachShader(shaderProgram, fragmentShader);
    GL.attachShader(shaderProgram, vertexShader);
    GL.linkProgram(shaderProgram);
    //
    //     GL.useProgram(shaderProgram);
    return shaderProgram;
  }

  Shader loadShader(RenderingContext context, int type, var src) {
    Shader shader = context.createShader(type);
    context.shaderSource(shader, src);
    context.compileShader(shader);
    if (false == context.getShaderParameter(shader, RenderingContext.COMPILE_STATUS)) {
      String message = "Error compiling shader ${context.getShaderInfoLog(shader)}";
      context.deleteShader(shader);
      throw "${message}\n";
    }
    return shader;
  }

  Map<Float32List, Buffer> ca = {};
  List<Float32List> _cal = [];
  Buffer createArrayBuffer(RenderingContext context, Float32List data) {
    if(ca.containsKey(data)) {
      //
      _cal.remove(data);
      _cal.insert(0, data);

      //
      Buffer ret = ca[data];
      context.bindBuffer(RenderingContext.ARRAY_BUFFER, ret);
      context.bufferData(RenderingContext.ARRAY_BUFFER, data, RenderingContext.STATIC_DRAW);
      context.bindBuffer(RenderingContext.ARRAY_BUFFER, null);
      return ret;
    } else {
      //
      _cal.add(data);
      if(_cal.length > maxBuffer) {
        Float32List data = _cal.removeLast();
        Buffer buffer = ca[data];
        if(buffer != null) {
          context.deleteBuffer(buffer);
        }
      }

      //
      Buffer ret = context.createBuffer();
      context.bindBuffer(RenderingContext.ARRAY_BUFFER, ret);
      context.bufferData(
          RenderingContext.ARRAY_BUFFER, data, RenderingContext.STATIC_DRAW);
      context.bindBuffer(RenderingContext.ARRAY_BUFFER, null);
      ca[data] = ret;
      return ret;
    }
  }

  Map<Uint16List, Buffer> ce = {};
  List<Uint16List> _cel = [];
  Buffer createElementArrayBuffer(RenderingContext context, Uint16List data) {
    if(ce.containsKey(data)) {
      //
      _cel.remove(data);
      _cel.insert(0, data);

      //
      Buffer ret = ce[data];
      context.bindBuffer(RenderingContext.ELEMENT_ARRAY_BUFFER, ret);
      context.bufferData(RenderingContext.ELEMENT_ARRAY_BUFFER, data,
          RenderingContext.STATIC_DRAW);
      context.bindBuffer(RenderingContext.ELEMENT_ARRAY_BUFFER, null);
      return ret;
    } else {
      //
      _cel.add(data);
      if(_cel.length > maxBuffer) {
        Uint16List data = _cel.removeLast();
        Buffer buffer = ce[data];
        if(buffer != null) {
          context.deleteBuffer(buffer);
        }
      }

      //
      Buffer ret = context.createBuffer();
      context.bindBuffer(RenderingContext.ELEMENT_ARRAY_BUFFER, ret);
      context.bufferData(RenderingContext.ELEMENT_ARRAY_BUFFER, data,
          RenderingContext.STATIC_DRAW);
      context.bindBuffer(RenderingContext.ELEMENT_ARRAY_BUFFER, null);
      ce[data] = ret;
      return ret;
    }
  }

  void setUniformF(RenderingContext context, Program program, String name, double v) {
    var location = context.getUniformLocation(program, name);
    context.uniform1f(location, v);
  }

  void setUniformVec4(RenderingContext context, Program program, String name, List v) {
    var location = context.getUniformLocation(program, name);
    context.uniform4fv(location, new Float32List.fromList(v));
  }

  void setUniformMat4(RenderingContext context, Program program, String name, Matrix4 v) {
    var location = context.getUniformLocation(program, name);
    context.uniformMatrix4fv(location, false, new Float32List.fromList(v.storage));
  }
}


class TinyWebglLoader {
  static Future<ImageElement> loadImage(String path) async {
    Completer<ImageElement> c = new Completer();
    ImageElement elm = new ImageElement(src: path);
    elm.onLoad.listen((_) {
      c.complete(elm);
    });
    elm.onError.listen((_) {
      c.completeError("failed to load image ${path}");
    });
    return c.future;
  }

  static Future<String> loadString(String path) async {
    return await HttpRequest.getString(path);
  }
}

class Context {
  RenderingContext GL;
  CanvasElement _canvasElement;
  CanvasElement get canvasElement => _canvasElement;
  double widht;
  double height;
  String selectors;
  Context({double width: 600.0, double height: 400.0, this.selectors: null}) {
    this.widht = width;
    this.height = height;
    if (selectors == null) {
      print("AA");
      _canvasElement = new CanvasElement(width: widht.toInt(), height: height.toInt());
      _canvasElement.style.width = "${widht.toInt()}px";
      _canvasElement.style.height = "${height.toInt()}px";
      document.body.append(_canvasElement);
    } else {
      print("BB");

      _canvasElement = window.document.querySelector(selectors);
      if (width != null) {
        _canvasElement.width = _canvasElement.offsetWidth;
      } else {
        this.widht = _canvasElement.offsetWidth.toDouble();
      }
      if (height != null) {
        _canvasElement.height = height.toInt();
      } else {
        this.height = _canvasElement.offsetHeight.toDouble();
      }
    }

    GL = _canvasElement.getContext3d(stencil: true);
    print("CC ${GL}");
  }
}

