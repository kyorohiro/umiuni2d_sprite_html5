part of umiuni2d_sprite_html5;


class ImageShader extends core.ImageShader {

  Image baseImage;
  ImageShader(core.Image rawImage) {
    this.baseImage = rawImage;
  }

  void dispose() {
    _dispose();
  }

  int get w => baseImage.w;
  int get h => baseImage.h;

  Texture _tex = null;
  RenderingContext cacheGL = null;

  Texture getTex(RenderingContext GL) {
    if (cacheGL != null && cacheGL != GL)
    {
      dispose();
    }
    if (_tex == null)
    {
      cacheGL = GL;
      _tex = GL.createTexture();
      GL.bindTexture(RenderingContext.TEXTURE_2D, _tex);
      GL.texImage2D(RenderingContext.TEXTURE_2D, 0,
          RenderingContext.RGBA, RenderingContext.RGBA, RenderingContext.UNSIGNED_BYTE, baseImage.elm);
      GL.texParameteri(RenderingContext.TEXTURE_2D, RenderingContext.TEXTURE_WRAP_S, RenderingContext.CLAMP_TO_EDGE);
      GL.texParameteri(RenderingContext.TEXTURE_2D, RenderingContext.TEXTURE_WRAP_T, RenderingContext.CLAMP_TO_EDGE);
      GL.texParameteri(RenderingContext.TEXTURE_2D, RenderingContext.TEXTURE_MIN_FILTER, RenderingContext.NEAREST);
      GL.texParameteri(RenderingContext.TEXTURE_2D, RenderingContext.TEXTURE_MAG_FILTER, RenderingContext.NEAREST);
      GL.bindTexture(RenderingContext.TEXTURE_2D, null);
    }
    return _tex;
  }


  void _dispose() {
    try {
      if (_tex != null && cacheGL != null) {
        cacheGL.deleteTexture(_tex);
        _tex = null;
        cacheGL = null;
      }
    } catch (e) {
      print("##ERROR # ${e}");
    }
  }
}

class Image extends core.Image {
  int get w => elm.width;
  int get h => elm.height;
  html.ImageElement elm;//ImageElement elm;

  Image(this.elm) {
  }

  int get hashCode => this.elm.hashCode;

  @override
  void dispose() {
    elm = null;
  }
}

