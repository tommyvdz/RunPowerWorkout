using Toybox.WatchUi;
using Toybox.Graphics as Gfx;
using Toybox.Time;

class RunPowerWorkoutAlertView extends WatchUi.DataFieldAlert {
  hidden var targetHigh;
  hidden var targetLow;
  hidden var currentPower;
  hidden var useCustomFonts;
  hidden var fonts;
  ( : roundzero) hidden var geometry = [ 218, 109, 21, 163 ];
  ( : roundone) hidden var geometry = [ 240, 120, 24, 180 ];
  ( : roundtwo) hidden var geometry = [ 260, 130, 26, 195 ];
  ( : roundthree) hidden var geometry = [ 280, 140, 28, 210 ];
  ( : roundfour) hidden var geometry = [ 390, 195, 39, 292 ];

  hidden var DEBUG = false;

  function initialize(high, low, current) {
    DataFieldAlert.initialize();
    targetHigh = high;
    targetLow = low;
    currentPower = current;
    useCustomFonts = Utils.replaceNull(Application.getApp().getProperty("USE_CUSTOM_FONTS"), true);
    set_fonts();
  }

  ( : highmem) function set_fonts() {
    if (useCustomFonts) {
      fonts = [
        WatchUi.loadResource(Rez.Fonts.C), WatchUi.loadResource(Rez.Fonts.F)
      ];
    } else {
      fonts = [ Graphics.FONT_MEDIUM, Graphics.FONT_NUMBER_THAI_HOT ];
    }
  }

  ( : medmem) function set_fonts() {
    if (useCustomFonts) {
      fonts = [
        WatchUi.loadResource(Rez.Fonts.C), WatchUi.loadResource(Rez.Fonts.F)
      ];
    } else {
      fonts = [ Graphics.FONT_MEDIUM, Graphics.FONT_NUMBER_THAI_HOT ];
    }
  }

  ( : lowmem) function set_fonts() {
    fonts = [ Graphics.FONT_MEDIUM, Graphics.FONT_NUMBER_THAI_HOT ];
  }

  function onLayout(dc) { return true; }

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
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    dc.drawText(geometry[1], geometry[1], fonts[1], currentPower.toNumber(),
                Graphics.TEXT_JUSTIFY_VCENTER | Graphics.TEXT_JUSTIFY_CENTER);
    dc.drawText(geometry[1], geometry[2], fonts[0], alertText,
                Graphics.TEXT_JUSTIFY_CENTER);
    dc.drawText(geometry[1], geometry[3], fonts[0], alertValue,
                Graphics.TEXT_JUSTIFY_CENTER);
    dc.setColor(ringColor, Graphics.COLOR_TRANSPARENT);
    dc.setPenWidth(5);
    dc.drawCircle(geometry[1], geometry[1], geometry[1] - 2);
  }
}