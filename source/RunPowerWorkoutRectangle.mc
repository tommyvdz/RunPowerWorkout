using Toybox.WatchUi;
using Toybox.Application;
using Toybox.Graphics;

class Rectangle extends WatchUi.Drawable {
  hidden var mColor = Graphics.COLOR_TRANSPARENT;
  hidden var mX = 0;
  hidden var mY = 0;
  hidden var mWidth = 240;
  hidden var mHeight = 50;

  function initialize(params) {
    Drawable.initialize(params);
    mX = params.get( : x);
    mY = params.get( : y);
  }

  function setColor(color) { mColor = color; }

  function setAttributes(x, y, width, height) {
    mX = x;
    mY = y;
    mWidth = width;
    mHeight = height;
  }

  function draw(dc) {
    dc.setColor(mColor, Graphics.COLOR_TRANSPARENT);
    dc.fillRectangle(mX, mY, mWidth, mHeight);
    dc.clear();
  }
}