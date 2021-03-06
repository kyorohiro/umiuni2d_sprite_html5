part of umiuni2d_sprite_html5;

class Stage extends core.Stage {
  Context glContext;
  double get x => 0.0;
  double get y => 0.0;
  double get w => glContext.widht;
  double get h => glContext.height;

  double get paddingTop => 0.0;
  double get paddingBottom => 0.0;
  double get paddingRight => 0.0;
  double get paddingLeft => 0.0;

  double get deviceRadio => 1.0;
  int lastUpdateTime = 0;
  int tappedEventTime = 0;
  bool animeIsStart = false;
  int animeId = 0;
  int paintInterval;
  int tickInterval;
  GameWidget _context;
  GameWidget get context => _context;

  int countKickMv = 0;
  num prevTime = 0;

  core.StageBase stageBase;
  Stage(this._context, core.DisplayObject root,core.DisplayObject background, core.DisplayObject front,
      {double width: 400.0, double height: 300.0, String selectors: null, this.tickInterval: 15, this.paintInterval: 40}) {
    print("#TinyWebglStage");
    glContext = new Context(width: width, height: height, selectors: selectors);
    stageBase = new core.StageBase(this, root, background, front);
    this.startable = true;
    mouseTest();
    touchTtest();
    keyTest();
  }

  void updateSize(double w, double h) {
    glContext.widht = w;
    glContext.height = h;
    root.changeStageStatus(this, null);
  }

  int onshot = 0;
  int aac = 0;
  void markPaintshot() {
    if(animeIsStart == true) {
      return;
    }
    if(onshot<=0){
      onshot =1;
      start(oneshot: true);
    } else if(onshot<3) {
      onshot++;
    }
  }

  void init() {}

  void start({oneshot:false}) {
    if(animeIsStart == true) {
      return;
    }
    if (oneshot == false && animeIsStart == false) {
      animeIsStart = true;
    }
    if(_animeIsOn == false) {
      //print("A sanimeIsStart ok");
      _anime();
    }
  }

  bool _animeIsOn = false;
  core.Canvas c = null;
  Future _anime() async {
    _animeIsOn = true;
    try {
      double sum = 0.0;
      double sum_a = 0.0;
      int count = 0;

      int interval = tickInterval;
      int prevInterval = tickInterval;
      if (prevTime == null || prevTime == 0) {
        prevTime = new DateTime.now().millisecondsSinceEpoch;
      }
      do {
        //if(animeIsStart)
        {
          int t = tickInterval - (interval - prevInterval);
          if (t < 5) {
            t = 5;
          } else if (t > tickInterval) {
            t = tickInterval;
          }
          prevInterval = t;
          await new Future.delayed(new Duration(milliseconds: t));
          countKickMv = 0;
        }
        num currentTime = new DateTime.now().millisecondsSinceEpoch;
        lastUpdateTime = currentTime;

        interval = (currentTime - prevTime);
        kick((prevTime + interval).toInt());
        sum += interval;
        sum_a += interval;
        count++;
        prevTime = currentTime;
        //markPaintshot();
        if (animeIsStart == false || sum_a > paintInterval) {
          //new Future(() {
            if(c == null) {
              c = new Canvas(this.w, this.h, glContext);
            }
            c.clear();
            kickPaint(this, c);
            c.flush();
            //(c as TinyWebglCanvasTS).flushraw();
         // });
          sum_a = 0.0;
        }
        if (count > 60) {
          print("###fps  ${1000~/(sum~/count)} ${onshot} ${animeIsStart}");
          sum = 0.0;
          count = 0;
        }
        if(onshot >=0) {
          --onshot;
        }
      } while (animeIsStart ||onshot>=0);
    } catch (e) {} finally {
      _animeIsOn = false;
    }
  }

  void stop() {
    animeIsStart = false;
  }

  void touchTtest() {
    Map touchs = {};
    oStu(TouchEvent e) {
      e.preventDefault();
      tappedEventTime = lastUpdateTime;
      for (Touch t in e.changedTouches) {
        int x = t.page.x - glContext._canvasElement.offsetLeft;
        int y = t.page.y - glContext._canvasElement.offsetTop;
        if (touchs.containsKey(t.identifier)) {
          countKickMv++;
          //if(countKickMv < 3) {
//          print("MOVE ${touchs}");
          kickTouch(this, t.identifier + 1, core.StagePointerType.MOVE, x.toDouble(), y.toDouble());
          //}
        } else {
//          print("DOWN ${touchs}");
          touchs[t.identifier] = t;
          kickTouch(this, t.identifier + 1, core.StagePointerType.DOWN, x.toDouble(), y.toDouble());
        }
      }
    }
    oEnd(TouchEvent e) {
      e.preventDefault();
      tappedEventTime = lastUpdateTime;
      for (Touch t in e.changedTouches) {
        if (touchs.containsKey(t.identifier)) {
          int x = t.page.x - glContext._canvasElement.offsetLeft;
          int y = t.page.y - glContext._canvasElement.offsetTop;
          touchs.remove(t.identifier);
          kickTouch(this, t.identifier + 1, core.StagePointerType.UP, x.toDouble(), y.toDouble());
        }
      }
    }
    glContext._canvasElement.onTouchCancel.listen(oEnd);
    glContext._canvasElement.onTouchEnd.listen(oEnd);
    glContext._canvasElement.onTouchEnter.listen(oStu);
    glContext._canvasElement.onTouchLeave.listen(oStu);
    glContext._canvasElement.onTouchMove.listen(oStu);
    glContext._canvasElement.onTouchStart.listen(oStu);
  }

  void mouseTest() {
    bool isTap = false;
    glContext.canvasElement.onMouseDown.listen((MouseEvent e) {
      e.preventDefault();
      if (tappedEventTime + 500 < lastUpdateTime) {
        //print("down offset=${e.offsetX}:${e.offsetY}  client=${e.clientX}:${e.clientY} screen=${e.screenX}:${e.screenY}");
        //print("down");
        isTap = true;
        kickTouch(this, 0, core.StagePointerType.DOWN, e.offset.x.toDouble(), e.offset.y.toDouble());
      }
    });
    glContext.canvasElement.onMouseUp.listen((MouseEvent e) {
      e.preventDefault();
      if (tappedEventTime + 500 < lastUpdateTime) {
        //print("up offset=${e.offsetX}:${e.offsetY}  client=${e.clientX}:${e.clientY} screen=${e.screenX}:${e.screenY}");
        if (isTap == true) {
          kickTouch(this, 0, core.StagePointerType.UP, e.offset.x.toDouble(), e.offset.y.toDouble());
          isTap = false;
        }
      }
    });
    glContext.canvasElement.onMouseEnter.listen((MouseEvent e) {
      e.preventDefault();
      if (tappedEventTime + 500 < lastUpdateTime) {
        // print("enter offset=${e.offsetX}:${e.offsetY}  client=${e.clientX}:${e.clientY} screen=${e.screenX}:${e.screenY}");
        if (isTap == true) {
          //root.touch(this, 0, "pointercancel", e.offsetX.toDouble(), e.offsetY.toDouble());
        }
      }
    });
    glContext.canvasElement.onMouseLeave.listen((MouseEvent e) {
      e.preventDefault();
      if (tappedEventTime + 500 < lastUpdateTime) {
        //  print("leave offset=${e.offsetX}:${e.offsetY}  client=${e.clientX}:${e.clientY} screen=${e.screenX}:${e.screenY}");
        //print("move");
        if (isTap == true) {
          kickTouch(this, 0, core.StagePointerType.CANCEL, e.offset.x.toDouble(), e.offset.y.toDouble());
          isTap = false;
        }
      }
    });
    glContext.canvasElement.onMouseMove.listen((MouseEvent e) {
      e.preventDefault();
      if (tappedEventTime + 500 < lastUpdateTime) {
        //print("move offset=${e.offsetX}:${e.offsetY}  client=${e.clientX}:${e.clientY} screen=${e.screenX}:${e.screenY}");
        if (isTap == true) {
          kickTouch(this, 0, core.StagePointerType.MOVE, e.offset.x.toDouble(), e.offset.y.toDouble());
        } //else {
        //  kickTouch(this, 0, TinyStagePointerType.DOWN, e.offset.x.toDouble(), e.offset.y.toDouble());
        //  isTap == true;
        //}
      }
    });

    glContext.canvasElement.onMouseOut.listen((MouseEvent e) {
      e.preventDefault();
      if (tappedEventTime + 500 < lastUpdateTime) {
        // print("out offset=${e.offsetX}:${e.offsetY}  client=${e.clientX}:${e.clientY} screen=${e.screenX}:${e.screenY}");
        if (isTap == true) {
          kickTouch(this, 0, core.StagePointerType.CANCEL, e.offset.x.toDouble(), e.offset.y.toDouble());
          isTap = false;
        }
      }
    });

    glContext.canvasElement.onMouseOver.listen((MouseEvent e) {
      e.preventDefault();
      if (tappedEventTime + 500 < lastUpdateTime) {
        // print("over offset=${e.offsetX}:${e.offsetY}  client=${e.clientX}:${e.clientY} screen=${e.screenX}:${e.screenY}");
        if (isTap == true) {
          // root.touch(this, 0, event.type, e.offsetX.toDouble(), e.offsetY.toDouble());
        }
      }
    });
  }

  void keyTest() {
//    glContext.canvasElement
    document.onKeyUp.listen((KeyboardEvent e) {
      List<core.KeyEventButton> btns = this.getKeyEventButtonList(""+e.key);
      print("[u] ${e.ctrlKey} ${e.metaKey} ${e.altKey} ${e.shiftKey} ${e.key} ${e.code} ${e.location} ${btns.length}");

      for(core.KeyEventButton btn in btns) {
        btn.registerUp = true;
        btn.isTouch = false;
      }
    });
//    glContext.canvasElement
    document.onKeyDown.listen((KeyboardEvent e) {
      List<core.KeyEventButton> btns = this.getKeyEventButtonList(""+e.key);
      print("[d] ${e.ctrlKey} ${e.metaKey} ${e.altKey} ${e.shiftKey} ${e.key} ${e.code} ${e.location} ${btns.length}");

      for(core.KeyEventButton btn in btns) {
        btn.registerDown = true;
        btn.isTouch = true;
      }
    });
  }

  //
  //
  //
  //
  @override
  core.DisplayObject get root => stageBase.root;

  @override
  core.DisplayObject get background => stageBase.background;

  @override
  core.DisplayObject get front => stageBase.front;

  @override
  void set root(core.DisplayObject v) {
    stageBase.root = v;
  }

  void set background(core.DisplayObject v) {
    stageBase.background = v;
  }

  void set front(core.DisplayObject v) {
    stageBase.front = v;
  }

  @override
  void kick(int timeStamp) {
    if(this._context.onLoop != null) {
      this._context.onLoop(this._context);
    }
    stageBase.kick(timeStamp);
  }

  @override
  void kickPaint(core.Stage stage, core.Canvas canvas) {
    stageBase.kickPaint(stage, canvas);
  }

  @override
  void kickTouch(core.Stage stage, int id, core.StagePointerType type, double x, double y) {
    stageBase.kickTouch(stage, id, type, x, y);
  }

  @override
  List<Matrix4> get mats => stageBase.mats;

  @override
  pushMulMatrix(Matrix4 mat) {
    return stageBase.pushMulMatrix(mat);
  }

  @override
  popMatrix() {
    return stageBase.popMatrix();
  }

  Matrix4 getMatrix() {
    return stageBase.getMatrix();
  }

  @override
  Vector3 getCurrentPositionOnDisplayObject(double globalX, double globalY) {
    return stageBase.getCurrentPositionOnDisplayObject(globalX, globalY);
  }

  core.KeyEventButton createKeyEventButton(String key) {
    return stageBase.createKeyEventButton(key);
  }

  List<core.KeyEventButton> getKeyEventButtonList(String key) {
    return stageBase.getKeyEventButtonList(key);
  }
}
