//
// use http://sapphire-al2o3.github.io/font_tex/
//
part of umiuni2d_sprite_html5;

const int FLLENGTH = 6*50 * 2;
const int FORCE_FLUSH_LEBGTH = 6*40 * 2;
const int vertLen = 6;

class FL {
  Float32List value;
  int index = 0;
  int get length => index;
  FL(int length) {
    value = new Float32List(length);
  }
  void clear() {
    index = 0;
    for(int i=0;i<value.length;i++) {
      value[i] = 0.0;
    }
  }
  void addAll(List<double> vs) {
    for(double v in vs) {
      value[index++] = v;
    }
  }

  void add(double v) {
    value[index++] = v;
  }
}

class IL {
  Uint16List value;
  int index = 0;
  int get length => index;
  IL(int length) {
    value = new Uint16List(length);
  }

  void clear() {
    index = 0;
    for(int i=0;i<value.length;i++) {
      value[i] = 0;
    }
  }
  void addAll(List<int> vs) {
    for(int v in vs) {
      value[index++] = v;
    }
  }

  void add(int v) {
    value[index++] = v;
  }
}

class DrawingShell extends core.DrawingShell {

  DrawingShell(double contextWidht, double contextHeight, { bool useLengthHAtCCoordinates:false})
      :super(contextWidht, contextHeight, useLengthHAtCCoordinates:useLengthHAtCCoordinates) {

  }

  FL flVert = new FL(FLLENGTH * 6);
  IL flInde = new IL(FLLENGTH * 2);
  FL flTex = new FL(FLLENGTH  * 2);
  core.Image flImg = null;


  void clear() {
    flVert.clear();
    flInde.clear();
    flTex.clear();
    flImg = null;
  }

  int c =0;
  int n =0;
  void flush() {
    if (flVert.length != 0) {
      c++;
      n =this.flVert.length;
      if(c>200) {
        //print(">> ${n}");
        c=0;
      }
      {
        if(this.flImg == null) {
          (canvas as Canvas).drawVertexWithColorRaw(
              this.flVert.value,
              this.flVert.length,
              this.flInde.value);
        } else {
          ImageShader s = null;
          s = canvas.getImageShader(this.flImg);
          (canvas as Canvas).drawVertexWithImageRaw(
              this.flVert.value,
              this.flVert.length,
              this.flTex.value,
              this.flInde.value,
              s);
        }
      }
    }
    flVert.clear();
    flInde.clear();
    flTex.clear();
    flImg = null;
  }


  Matrix4 calcMat() {
    cacheMatrix.setIdentity();
    cacheMatrix.translate(-1.0, 1.0, 0.0);
    cacheMatrix.scale(2.0 / contextWidht, -2.0 / contextHeight, 1.0);
    //cacheMatrix =
    cacheMatrix.multiply(getMatrix());
    return cacheMatrix;
  }

  Matrix4 getMatrix() {
    return currentMatrix;
  }


  //
  //
  // template
  //
  //

  int _numOfCircleElm;
  int get numOfCircleElm => _numOfCircleElm;
  List<double> _circleCache = [];


  void set numOfCircleElm(v) {
    _numOfCircleElm = v;
    for (int i = 0; i < _numOfCircleElm+1; i++) {
      _circleCache.add(math.cos(2 * math.pi * (i / _numOfCircleElm)));
      _circleCache.add(math.sin(2 * math.pi * (i / _numOfCircleElm)));
    }
  }


  void drawOval(core.Rect rect, core.Paint paint, {List<Object> cache: null}) {
    if (flImg != null || flVert.length > 100) {
      flush();
    }
    if (paint.style == core.PaintStyle.fill) {
      drawFillOval(rect, paint);
    } else {
      drawStrokeOval(rect, paint);
    }
  }

  void drawFillOval(core.Rect rect, core.Paint paint) {
    if (flImg != null || flVert.length > 100) {
      flush();
    }
    double cx = rect.x + rect.w / 2.0;
    double cy = rect.y + rect.h / 2.0;
    double a = rect.w / 2;
    double b = rect.h / 2;

    Matrix4 m = calcMat();
    Vector3 s = new Vector3(0.0, 0.0, 0.0);
    double colorR = currentColor.rf * paint.color.r / 0xff;
    double colorG = currentColor.gf * paint.color.g / 0xff;
    double colorB = currentColor.bf * paint.color.b / 0xff;
    double colorA = currentColor.af * paint.color.a / 0xff;

    for (int i = 0; i < _numOfCircleElm; i++) {
      //
      if(flVert.length > FORCE_FLUSH_LEBGTH) {
        flush();
      }
      int bbb = flVert.length ~/ vertLen;
      //
      s.x = cx;
      s.y = cy;
      s = m * s;
      flVert.add(s.x);
      flVert.add(s.y);
      flVert.add(colorR);
      flVert.add(colorG);
      flVert.add(colorB);
      flVert.add(colorA);

      //
      //
      s.x = cx + _circleCache[i*2+0] * a;
      s.y = cy + _circleCache[i*2+1] * b;
      s = m * s;
      flVert.add(s.x);
      flVert.add(s.y);
      flVert.add(colorR);
      flVert.add(colorG);
      flVert.add(colorB);
      flVert.add(colorA);

      //
      //
      s.x = cx + _circleCache[i*2+2] * a;
      s.y = cy + _circleCache[i*2+3] * b;
      s = m * s;
      flVert.add(s.x);
      flVert.add(s.y);
      flVert.add(colorR);
      flVert.add(colorG);
      flVert.add(colorB);
      flVert.add(colorA);
      flInde.add(bbb + 0);flInde.add(bbb + 1);flInde.add(bbb + 2);
    }
  }

  void drawStrokeOval(core.Rect rect, core.Paint paint) {

    if (flImg != null || flVert.length > 100) {
      flush();
    }
    double cx = rect.x + rect.w / 2.0;
    double cy = rect.y + rect.h / 2.0;
    double a = (rect.w + paint.strokeWidth) / 2;
    double b = (rect.h + paint.strokeWidth) / 2;
    double c = (rect.w - paint.strokeWidth) / 2;
    double d = (rect.h - paint.strokeWidth) / 2;

    Matrix4 m = calcMat();
    Vector3 s1 = new Vector3(0.0, 0.0, 0.0);
    Vector3 s2 = new Vector3(0.0, 0.0, 0.0);
    Vector3 s3 = new Vector3(0.0, 0.0, 0.0);
    Vector3 s4 = new Vector3(0.0, 0.0, 0.0);
    double colorR = paint.color.r / 0xff;
    double colorG = paint.color.g / 0xff;
    double colorB = paint.color.b / 0xff;
    double colorA = paint.color.a / 0xff;

    for (int i = 0; i < numOfCircleElm; i++) {
      s1.x = cx + _circleCache[i*2+0] * c;
      s1.y = cy + _circleCache[i*2+1] * d;
      s1 = m * s1;

      s2.x = cx + _circleCache[i*2+0] * a;
      s2.y = cy + _circleCache[i*2+1] * b;
      s2 = m * s2;

      s3.x = cx + _circleCache[i*2+2] * a;
      s3.y = cy + _circleCache[i*2+3] * b;
      s3 = m * s3;

      s4.x = cx + _circleCache[i*2+2] * c;
      s4.y = cy + _circleCache[i*2+3] * d;
      s4 = m * s4;
      _innerDrawFillRect(s1, s2, s4, s3, colorR, colorG, colorB, colorA);
    }

  }

  void drawRect(core.Rect rect, core.Paint paint, {List<Object> cache: null}) {
    if (flImg != null || flVert.length > 100) {
      flush();
    }
    if (paint.style == core.PaintStyle.fill) {
      drawFillRect(rect, paint);
    } else {
      drawStrokeRect(rect, paint);
    }
  }

  void drawFillRect(core.Rect rect, core.Paint paint,{Matrix4 m:null}) {
    if (flImg != null || flVert.length > 100) {
      flush();
    }
    if(m == null) {
      m = calcMat();
    }
    double sx = rect.x;
    double sy = rect.y;
    double ex = rect.x + rect.w;
    double ey = rect.y + rect.h;
    ss1.setValues(sx, sy, 0.0); ss1 = m * ss1;
    ss2.setValues(sx, ey, 0.0); ss2 = m * ss2;
    ss3.setValues(ex, sy, 0.0); ss3 = m * ss3;
    ss4.setValues(ex, ey, 0.0); ss4 = m * ss4;

    double colorR = currentColor.rf * paint.color.r / 0xff;
    double colorG = currentColor.gf * paint.color.g / 0xff;
    double colorB = currentColor.bf * paint.color.b / 0xff;
    double colorA = currentColor.af * paint.color.a / 0xff;
    _innerDrawFillRect(ss1, ss2, ss3, ss4, colorR, colorG, colorB, colorA);
  }

  void drawStrokeRect(core.Rect rect, core.Paint paint) {
    if (flImg != null || flVert.length > 100) {
      flush();
    }
    Matrix4 m = calcMat();
    double sx = rect.x + paint.strokeWidth / 2;
    double sy = rect.y + paint.strokeWidth / 2;
    double ex = rect.x + rect.w - paint.strokeWidth / 2;
    double ey = rect.y + rect.h - paint.strokeWidth / 2;

    Vector3 ss1 = m * new Vector3(sx, sy, 0.0);
    Vector3 sz1 = m * new Vector3(sx - paint.strokeWidth, sy - paint.strokeWidth, 0.0);
    Vector3 ss2 = m * new Vector3(sx, ey, 0.0);
    Vector3 sz2 = m * new Vector3(sx - paint.strokeWidth, ey + paint.strokeWidth, 0.0);
    Vector3 ss3 = m * new Vector3(ex, sy, 0.0);
    Vector3 sz3 = m * new Vector3(ex + paint.strokeWidth, sy - paint.strokeWidth, 0.0);
    Vector3 ss4 = m * new Vector3(ex, ey, 0.0);
    Vector3 sz4 = m * new Vector3(ex + paint.strokeWidth, ey + paint.strokeWidth, 0.0);
    double colorR = currentColor.rf *paint.color.r / 0xff;
    double colorG = currentColor.gf *paint.color.g / 0xff;
    double colorB = currentColor.bf *paint.color.b / 0xff;
    double colorA = currentColor.af *paint.color.a / 0xff;
    _innerDrawFillRect(sz1, sz2, ss1, ss2, colorR, colorG, colorB, colorA);
    _innerDrawFillRect(sz2, sz4, ss2, ss4, colorR, colorG, colorB, colorA);
    _innerDrawFillRect(sz4, sz3, ss4, ss3, colorR, colorG, colorB, colorA);
    _innerDrawFillRect(sz3, sz1, ss3, ss1, colorR, colorG, colorB, colorA);
  }

  Matrix4 baseMat = new Matrix4.identity();

  void drawLine(core.Point p1, core.Point p2, core.Paint paint, {List<Object> cache: null}) {
    if (flImg != null || flVert.length > 100) {
      flush();
    }
    Matrix4 m = calcMat();
    double d = math.sqrt(math.pow(p1.x - p2.x, 2) + math.pow(p1.y - p2.y, 2));
    double dy = -1 * paint.strokeWidth * (p2.x - p1.x) / (d * 2);
    double dx = paint.strokeWidth * (p2.y - p1.y) / (d * 2);
    double sx = p1.x;
    double sy = p1.y;
    double ex = p2.x;
    double ey = p2.y;

    Vector3 v1 = new Vector3(sx - dx, sy - dy, 0.0);
    Vector3 v2 = new Vector3(sx + dx, sy + dy, 0.0);
    Vector3 v3 = new Vector3(ex + dx, ey + dy, 0.0);
    Vector3 v4 = new Vector3(ex - dx, ey - dy, 0.0);
    v1 = m * v1;
    v2 = m * v2;
    v3 = m * v3;
    v4 = m * v4;
    double colorR = currentColor.rf * paint.color.r / 0xff;
    double colorG = currentColor.gf * paint.color.g / 0xff;
    double colorB = currentColor.bf * paint.color.b / 0xff;
    double colorA = currentColor.af * paint.color.a / 0xff;
    _innerDrawFillRect(v1, v2, v3, v4, colorR, colorG, colorB, colorA);
  }


  void _innerDrawFillRect(
      Vector3 ss1, Vector3 ss2, Vector3 ss3, Vector3 ss4,
      double colorR, double colorG, double colorB, double colorA) {
    int b = flVert.length ~/ vertLen;

    flVert.add(ss1.x); flVert.add(ss1.y);    // 7
    flVert.add(colorR); flVert.add(colorG); flVert.add(colorB); flVert.add(colorA);
    flVert.add(ss2.x); flVert.add(ss2.y); // 1
    flVert.add(colorR); flVert.add(colorG); flVert.add(colorB); flVert.add(colorA);
    flVert.add(ss3.x); flVert.add(ss3.y); // 9
    flVert.add(colorR); flVert.add(colorG); flVert.add(colorB); flVert.add(colorA);
    flVert.add(ss4.x); flVert.add(ss4.y); //3
    flVert.add(colorR); flVert.add(colorG); flVert.add(colorB); flVert.add(colorA);

    flInde.add(b + 0); flInde.add(b + 1); flInde.add(b + 2); flInde.add(b + 1); flInde.add(b + 3); flInde.add(b + 2);
  }


  Vector3 ss1 = new Vector3(0.0, 0.0, 0.0);
  Vector3 ss2 = new Vector3(0.0, 0.0, 0.0);
  Vector3 ss3 = new Vector3(0.0, 0.0, 0.0);
  Vector3 ss4 = new Vector3(0.0, 0.0, 0.0);
  void drawImageRect(core.Image image, core.Rect src, core.Rect dst,
      {core.CanvasTransform transform: core.CanvasTransform.NONE, core.Paint paint:null,
        List<Object> cache: null}) {
    if (flImg != image || flVert.length > 100) {
      flush();
    }
    flImg = image;

    double xs = src.x / (!this.useLengthHAtCCoordinates?flImg.w:1.0);
    double ys = src.y / (!this.useLengthHAtCCoordinates?flImg.h:1.0);
    double xe = (src.x + src.w) / (!this.useLengthHAtCCoordinates?flImg.w:1.0);
    double ye = (src.y + src.h) / (!this.useLengthHAtCCoordinates?flImg.h:1.0);
    switch (transform) {
      case core.CanvasTransform.NONE:
        flTex.add(xs);flTex.add(ys);flTex.add(xs);flTex.add(ye);flTex.add(xe);flTex.add(ys);flTex.add(xe);flTex.add(ye);
        break;
      case core.CanvasTransform.ROT90:
        flTex.add(xs);flTex.add(ye);flTex.add(xe);flTex.add(ye);flTex.add(xs);flTex.add(ys);flTex.add(xe);flTex.add(ys);
        break;
      case core.CanvasTransform.ROT180:
        flTex.add(xe);flTex.add(ye);flTex.add(xe);flTex.add(ys);flTex.add(xs);flTex.add(ye);flTex.add(xs);flTex.add(ys);
        break;
      case core.CanvasTransform.ROT270:
        flTex.add(xe);flTex.add(ys);flTex.add(xs);flTex.add(ys);flTex.add(xe);flTex.add(ye);flTex.add(xs);flTex.add(ye);
        break;
      case core.CanvasTransform.MIRROR:
        flTex.add(xe);flTex.add(ys);flTex.add(xe);flTex.add(ye);flTex.add(xs);flTex.add(ys);flTex.add(xs);flTex.add(ye);
        break;
      case core.CanvasTransform.MIRROR_ROT90:
        flTex.add(xs);flTex.add(ys);flTex.add(xe);flTex.add(ys);flTex.add(xs);flTex.add(ye);flTex.add(xe);flTex.add(ye);
        break;
      case core.CanvasTransform.MIRROR_ROT180:
        flTex.add(xs);flTex.add(ye);flTex.add(xs);flTex.add(ys);flTex.add(xe);flTex.add(ye);flTex.add(xe);flTex.add(ys);
        break;
      case core.CanvasTransform.MIRROR_ROT270:
        flTex.add(xe);flTex.add(ye);flTex.add(xs);flTex.add(ye);flTex.add(xe);flTex.add(ys);flTex.add(xs);flTex.add(ys);
        break;
      default:
        flTex.add(xs);flTex.add(ys);flTex.add(xs);flTex.add(ye);flTex.add(xe);flTex.add(ys);flTex.add(xe);flTex.add(ye);
    }

    //
    //
    //
    Matrix4 m = calcMat();
    double sx = dst.x;
    double sy = dst.y;
    double ex = dst.x + dst.w;
    double ey = dst.y + dst.h;


    ss1.setValues(sx, sy, 0.0); ss1 = m * ss1;
    ss2.setValues(sx, ey, 0.0); ss2 = m * ss2;
    ss3.setValues(ex, sy, 0.0); ss3 = m * ss3;
    ss4.setValues(ex, ey, 0.0); ss4 = m * ss4;

    double s7x = ss1.x;
    double s7y = ss1.y;
    double s1x = ss2.x;
    double s1y = ss2.y;
    double s9x = ss3.x;
    double s9y = ss3.y;
    double s3x = ss4.x;
    double s3y = ss4.y;


    int b = flVert.length ~/ vertLen;

    double colorR = currentColor.rf;
    double colorG = currentColor.gf;
    double colorB = currentColor.bf;
    double colorA = currentColor.af;

    if(paint != null) {
      colorR *= paint.color.r / 0xff;
      colorG *= paint.color.g / 0xff;
      colorB *= paint.color.b / 0xff;
      colorA *= paint.color.a / 0xff;
    }

    // 7
    flVert.add(s7x);flVert.add(s7y);
    flVert.add(colorR);flVert.add(colorG);flVert.add(colorB);flVert.add(colorA);

    // 1
    flVert.add(s1x);flVert.add(s1y);
    flVert.add(colorR); flVert.add(colorG); flVert.add(colorB); flVert.add(colorA);

    // 9
    flVert.add(s9x);flVert.add(s9y);
    flVert.add(colorR); flVert.add(colorG); flVert.add(colorB); flVert.add(colorA); // color

    //3
    flVert.add(s3x);flVert.add(s3y);
    flVert.add(colorR); flVert.add(colorG); flVert.add(colorB); flVert.add(colorA);

    flInde.add(b + 0);flInde.add(b + 1);flInde.add(b + 2);flInde.add(b + 1);flInde.add(b + 3);flInde.add(b + 2);
  }

}


