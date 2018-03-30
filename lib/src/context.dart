part of umiuni2d_sprite_html5;

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
