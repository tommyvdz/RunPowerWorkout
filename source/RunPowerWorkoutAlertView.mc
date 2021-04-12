using Toybox.WatchUi;
using Toybox.Graphics as Gfx;
using Toybox.Time;

class RunPowerWorkoutAlertView extends WatchUi.DataFieldAlert {
  hidden var targetHigh;
  hidden var targetLow;
  hidden var currentPower;
  (:roundzero) hidden var geometry = [ 218, 109, 21, 163 ];
  (:roundone) hidden var geometry = [ 240, 120, 24, 180 ];
  (:roundtwo) hidden var geometry = [ 260, 130, 26, 195 ];
  (:roundthree) hidden var geometry = [ 280, 140, 28, 210 ];
  (:roundfour) hidden var geometry = [ 390, 195, 39, 292 ];
  (:highmem) hidden var fonts =
      [ WatchUi.loadResource(Rez.Fonts.C), WatchUi.loadResource(Rez.Fonts.F) ];
  (:medmem) hidden var fonts =
      [ WatchUi.loadResource(Rez.Fonts.C), WatchUi.loadResource(Rez.Fonts.F) ];
  (:lowmem) hidden var fonts =
      [ Graphics.FONT_MEDIUM, Graphics.FONT_NUMBER_THAI_HOT ];

  hidden var DEBUG = false;

  function initialize(high, low, current) {
    DataFieldAlert.initialize();
    targetHigh = high;
    targetLow = low;
    currentPower = current;
  }

  function onLayout(dc) {
    return true;
  }


  function onUpdate(dc) {

    View.onUpdate(dc);

    var ringColor = Graphics.COLOR_RED;
    var alertText = "High power";
    var alertValue = "TGT " + targetLow + "-" + targetHigh;

    if (currentPower < targetLow) {
      ringColor = Graphics.COLOR_BLUE;
      alertText = "Low power";
    }

    dc.setAntiAlias(true);
    dc.setColor(ringColor, Graphics.COLOR_TRANSPARENT);
    dc.setPenWidth(5);
    dc.drawCircle(geometry[1], geometry[1], geometry[1] - 2);
    dc.drawText(geometry[1], geometry[1], fonts[1], currentPower.toNumber(),
                Graphics.TEXT_JUSTIFY_VCENTER | Graphics.TEXT_JUSTIFY_CENTER);
    dc.drawText(geometry[1], geometry[2], fonts[0], alertText,
                Graphics.TEXT_JUSTIFY_CENTER);
    dc.drawText(geometry[1], geometry[3], fonts[0], alertValue,
                Graphics.TEXT_JUSTIFY_CENTER);
  }
}
