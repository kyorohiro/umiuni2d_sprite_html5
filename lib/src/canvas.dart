part of umiuni2d_sprite_html5;

class TinyWebglCanvas extends core.Canvas {

  RenderingContext GL;
  TinyWebglContext glContext;
  double get contextWidht => glContext.widht;
  double get contextHeight => glContext.height;
  Program programShapeImage;
  Program programShapeColor;
  //-2.0 / glContext.height
  int stencilV = 1;
  int maxVertexTextureImageUnits = 3;

  TinyWebglCanvas(double w, double h, TinyWebglContext c, {int numOfCircleElm:16}):super(w, h) {
    print("#TinyWebglCanvas ${c.GL}");
    GL = c.GL;
    glContext = c;
    init();
    clear();
  }

  @override
  void init() {
    print("#INIT");
    maxVertexTextureImageUnits = GL.getParameter(RenderingContext.MAX_VERTEX_TEXTURE_IMAGE_UNITS);
    print("#[A] MAX_VERTEX_TEXTURE_IMAGE_UNITS # ${GL.getParameter(RenderingContext.MAX_VERTEX_TEXTURE_IMAGE_UNITS)}");
    print("#[B] ALIASED_POINT_SIZE_RANGE       # ${GL.getParameter(RenderingContext.ALIASED_POINT_SIZE_RANGE)}");
    print("#[B] ALIASED_POINT_SIZE_RANGE       # ${GL.getParameter(RenderingContext.ALIASED_POINT_SIZE_RANGE)}");
    {
      //
      // Image
      //
      String vsImage = [
        "attribute vec3 vp;",
        "attribute vec4 color;",
        "attribute vec2 a_tex;",
        "varying vec2 v_tex;",
        "uniform mat4 u_mat;",
        "varying vec4 vColor;",
        "",
        "void main() {",
        "  gl_Position = u_mat*vec4(vp.x,vp.y,vp.z,1.0);",
        "  vColor = color;",
        "  v_tex = a_tex;",
        "  gl_PointSize = 1.0;//u_point_size;",
        "",
        "}"
      ].join("\n");
      String fsImage = [
         "precision mediump float;",
         "varying vec2 v_tex;",
         "varying vec4 vColor;",
         "uniform sampler2D u_image;",
         "void main() {",
         "  gl_FragColor = vColor * texture2D(u_image, v_tex);",
         "}"].join("\n");


      //
      // Color
      //
      String vsColor = [
        "attribute vec3 vp;",
        "attribute vec4 color;",
        "uniform mat4 u_mat;",
        "varying vec4 vColor;",
        "",
        "void main() {",
        "  gl_Position = u_mat*vec4(vp.x,vp.y,vp.z,1.0);",
        "    vColor = color;",
        "  gl_PointSize = 1.0;//u_point_size;",
        "",
        "}"
      ].join("\n");
      String fsColor = [
        "precision mediump float;",
        "varying vec2 v_tex;",
        "varying vec4 vColor;",
        "void main() {",
        "    gl_FragColor = vColor;",
        "}"].join("\n");
      programShapeImage = TinyWebglProgram.compile(GL, vsImage, fsImage);
      programShapeColor = TinyWebglProgram.compile(GL, vsColor, fsColor);
    }
    {

    }
  }

  @override
  void clear() {
    super.clear();
    stencilV = 1;
    double r = 0.0;
    double g = 0.0;
    double b = 0.0;
    double a = 1.0;
    // GL.enable(RenderingContext.DEPTH_TEST);
    GL.enable(RenderingContext.STENCIL_TEST);
    GL.depthFunc(RenderingContext.LEQUAL);
    GL.clearColor(r, g, b, a);
    GL.clearDepth(1.0);
    GL.clearStencil(0);
    GL.enable(RenderingContext.BLEND);
    GL.viewport(0, 0, glContext.widht.toInt(), glContext.height.toInt());

    //
    GL.blendEquation(RenderingContext.FUNC_ADD);
    GL.blendFuncSeparate(RenderingContext.SRC_ALPHA, RenderingContext.ONE_MINUS_SRC_ALPHA, RenderingContext.SRC_ALPHA, RenderingContext.ONE_MINUS_CONSTANT_ALPHA);

    GL.clear(RenderingContext.COLOR_BUFFER_BIT | RenderingContext.STENCIL_BUFFER_BIT | RenderingContext.DEPTH_BUFFER_BIT);
  }

  void flush() {
    super.flush();
  }

  Matrix4 baseMat = new Matrix4.identity();
  void clearClip() {
    flush();
    stencilV = 1;
    GL.clearStencil(0);
  }

  void clipRect(core.Rect rect, {Matrix4 m:null}) {
    flush();
    GL.colorMask(false, false, false, false);
    GL.depthMask(false);
    GL.stencilOp(RenderingContext.KEEP, RenderingContext.REPLACE, RenderingContext.REPLACE);
    GL.stencilFunc(RenderingContext.ALWAYS, stencilV, 0xff);

    //
    core.Paint p = new core.Paint();
    p.color = new core.Color.argb(0xff, 0x00, 0x00, 0xff);
    drawRect(rect, p);
//    drawFillRect(rect, m:m);
    flush();
    //
    // GL.disable(RenderingContext.STENCIL_TEST);
    //
    GL.colorMask(true, true, true, true);
    GL.depthMask(true);
    GL.stencilOp(RenderingContext.KEEP, RenderingContext.KEEP, RenderingContext.KEEP);
    // todo
    GL.stencilFunc(RenderingContext.LEQUAL, stencilV, 0xff);
    stencilV++;
  }

  void drawVertexWithImage(List<double> positions, List<double> cCoordinates, List<int> indices, core.Image img,
      {List<double> colors, bool hasZ:false}) {
    List<double> svertex = [];

    int positionSize = (hasZ?3:2);
    int length = positions.length ~/positionSize;
    List<double> texs = [];
    if(hasZ) {
      for(int i=0;i<length;i++) {
        svertex.add(positions[3 * i + 0]);
        svertex.add(positions[3 * i + 1]);
        svertex.add(positions[3 * i + 2]);

        svertex.add(colors[4 * i + 0]);
        svertex.add(colors[4 * i + 1]);
        svertex.add(colors[4 * i + 2]);
        svertex.add(colors[4 * i + 3]);
        //
        texs.add(cCoordinates[2*i+0]);
        texs.add(cCoordinates[2*i+1]);
      }
    } else {
      double dz = 0.001;
      for(int i=0;i<length;i++) {
        svertex.add(positions[2 * i + 0]);
        svertex.add(positions[2 * i + 1]);
        svertex.add(dz+=0.001);

        svertex.add(colors[4 * i + 0]);
        svertex.add(colors[4 * i + 1]);
        svertex.add(colors[4 * i + 2]);
        svertex.add(colors[4 * i + 3]);
        //
        texs.add(cCoordinates[2*i+0]);
        texs.add(cCoordinates[2*i+1]);
      }

    }

    {
      //
      //
      Program program = programShapeImage;
      GL.useProgram(null);
      GL.useProgram(program);
      int texLocation = 0;

      {
        // tex
        texLocation = GL.getAttribLocation(program, "a_tex");
        Buffer texBuffer = GL.createBuffer();
        GL.bindBuffer(RenderingContext.ARRAY_BUFFER, texBuffer);
        GL.bufferData(
            RenderingContext.ARRAY_BUFFER, new Float32List.fromList(texs),
            RenderingContext.STATIC_DRAW);
        GL.enableVertexAttribArray(texLocation);
        GL.vertexAttribPointer(
            texLocation, 2, RenderingContext.FLOAT, false, 0, 0);
      }

      {
        // tex
        Texture tex = (img as TinyWebglImage).getTex(GL);
        GL.bindTexture(RenderingContext.TEXTURE_2D, tex);

      }

      //
      // vertex
      Buffer rectBuffer = TinyWebglProgram.createArrayBuffer(GL, svertex);
      GL.bindBuffer(RenderingContext.ARRAY_BUFFER, rectBuffer);

      Buffer rectIndexBuffer = TinyWebglProgram.createElementArrayBuffer(GL, indices);
      GL.bindBuffer(RenderingContext.ELEMENT_ARRAY_BUFFER, rectIndexBuffer);

      //

      //
      // draw
      int locationAttributeUseTex;
      {
        TinyWebglProgram.setUniformMat4(GL, program, "u_mat", baseMat);
        int colorAttribLocation = GL.getAttribLocation(program, "color");
        int locationVertexPosition = GL.getAttribLocation(program, "vp");


        GL.vertexAttribPointer(locationVertexPosition, 3, RenderingContext.FLOAT, false, 4 * 7, 0);
        GL.vertexAttribPointer(colorAttribLocation, 4, RenderingContext.FLOAT, false, 4 * 7, 4 * 3);
        GL.enableVertexAttribArray(locationVertexPosition);
        GL.enableVertexAttribArray(colorAttribLocation);

        GL.drawElements(
            RenderingContext.TRIANGLES,
            //RenderingContext.LINE_STRIP,
            indices.length, //svertex.length ~/ 3,
            RenderingContext.UNSIGNED_SHORT,
            0);
      }
      if (texLocation != 0) {
        GL.disableVertexAttribArray(texLocation);
        GL.bindTexture(RenderingContext.TEXTURE_2D, null);
      }
      GL.useProgram(null);
    }
  }

  void drawVertexWithColor(List<double> positions, List<double> colors, List<int> indices,{bool hasZ:false}) {
    List<double> svertex = [];
    int positionSize = (hasZ?3:2);
    int length = positions.length ~/positionSize;
    if(hasZ) {
      for(int i=0;i<length;i++) {
        svertex.add(positions[3 * i + 0]);
        svertex.add(positions[3 * i + 1]);
        svertex.add(positions[3 * i + 2]);

        svertex.add(colors[4 * i + 0]);
        svertex.add(colors[4 * i + 1]);
        svertex.add(colors[4 * i + 2]);
        svertex.add(colors[4 * i + 3]);
      }
    } else {
      double dz = 0.001;
      for(int i=0;i<length;i++) {
        svertex.add(positions[2 * i + 0]);
        svertex.add(positions[2 * i + 1]);
        svertex.add(dz+=0.001);

        svertex.add(colors[4 * i + 0]);
        svertex.add(colors[4 * i + 1]);
        svertex.add(colors[4 * i + 2]);
        svertex.add(colors[4 * i + 3]);
      }
    }

    {
      Program program = programShapeColor;

      GL.useProgram(null);
      GL.useProgram(program);
      int texLocation = 0;


      //
      // vertex
      //
      Buffer rectBuffer = TinyWebglProgram.createArrayBuffer(GL, svertex);
      GL.bindBuffer(RenderingContext.ARRAY_BUFFER, rectBuffer);

      Buffer rectIndexBuffer = TinyWebglProgram.createElementArrayBuffer(GL, indices);
      GL.bindBuffer(RenderingContext.ELEMENT_ARRAY_BUFFER, rectIndexBuffer);

      //
      // draw
      //
      {
        TinyWebglProgram.setUniformMat4(GL, program, "u_mat", baseMat);
        int colorAttribLocation = GL.getAttribLocation(program, "color");
        int locationVertexPosition = GL.getAttribLocation(program, "vp");

        GL.vertexAttribPointer(locationVertexPosition, 3, RenderingContext.FLOAT, false, 4 * 7, 0);
        GL.vertexAttribPointer(colorAttribLocation, 4, RenderingContext.FLOAT, false, 4 * 7, 4 * 3);
        GL.enableVertexAttribArray(locationVertexPosition);
        GL.enableVertexAttribArray(colorAttribLocation);

        GL.drawElements(
            RenderingContext.TRIANGLES,
            indices.length,
            RenderingContext.UNSIGNED_SHORT,
            0);
      }
      if (texLocation != 0) {
        GL.disableVertexAttribArray(texLocation);
        GL.bindTexture(RenderingContext.TEXTURE_2D, null);
      }
      GL.useProgram(null);

    }
  }
}

