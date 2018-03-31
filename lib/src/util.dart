part of umiuni2d_sprite_html5;

class TinyWebglProgram {
  static Program compile(RenderingContext GL, String vs, String fs) {
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

  static Shader loadShader(RenderingContext context, int type, var src) {
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

  static Map<Float32List, Buffer> ca = {};
  static Buffer createArrayBuffer(RenderingContext context, Float32List data) {
    if(ca.containsKey(data)) {
      Buffer ret = ca[data];
      context.bindBuffer(RenderingContext.ARRAY_BUFFER, ret);
      context.bufferData(
          RenderingContext.ARRAY_BUFFER, data, RenderingContext.STATIC_DRAW);
      context.bindBuffer(RenderingContext.ARRAY_BUFFER, null);
      return ret;
    } else {
      Buffer ret = context.createBuffer();
      context.bindBuffer(RenderingContext.ARRAY_BUFFER, ret);
      context.bufferData(
          RenderingContext.ARRAY_BUFFER, data, RenderingContext.STATIC_DRAW);
      context.bindBuffer(RenderingContext.ARRAY_BUFFER, null);
      ca[data] = ret;
      return ret;
    }
  }

  static Map<Uint16List, Buffer> ce = {};
  static Buffer createElementArrayBuffer(RenderingContext context, Uint16List data) {
    if(ce.containsKey(data)) {
      Buffer ret = ce[data];
      context.bindBuffer(RenderingContext.ELEMENT_ARRAY_BUFFER, ret);
      context.bufferData(RenderingContext.ELEMENT_ARRAY_BUFFER, data,
          RenderingContext.STATIC_DRAW);
      context.bindBuffer(RenderingContext.ELEMENT_ARRAY_BUFFER, null);
      return ret;
    } else {
      Buffer ret = context.createBuffer();
      context.bindBuffer(RenderingContext.ELEMENT_ARRAY_BUFFER, ret);
      context.bufferData(RenderingContext.ELEMENT_ARRAY_BUFFER, data,
          RenderingContext.STATIC_DRAW);
      context.bindBuffer(RenderingContext.ELEMENT_ARRAY_BUFFER, null);
      ce[data] = ret;
      return ret;
    }
  }

  static setUniformF(RenderingContext context, Program program, String name, double v) {
    var location = context.getUniformLocation(program, name);
    context.uniform1f(location, v);
  }

  static setUniformVec4(RenderingContext context, Program program, String name, List v) {
    var location = context.getUniformLocation(program, name);
    context.uniform4fv(location, new Float32List.fromList(v));
  }

  static setUniformMat4(RenderingContext context, Program program, String name, Matrix4 v) {
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
