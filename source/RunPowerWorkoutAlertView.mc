using Toybox.WatchUi;

class RunPowerWorkoutAlertView extends WatchUi.DataFieldAlert {
  hidden var targetHigh;
  hidden var targetLow;
  hidden var currentPower;
  hidden var useCustomFonts;
  hidden var fonts;
  hidden var ringColor;
  hidden var alertText;
  ( : roundzero) hidden var geometry = [ 218, 109, 21, 163 ];
  ( : roundone) hidden var geometry = [ 240, 120, 24, 180 ];
  ( : roundtwo) hidden var geometry = [ 260, 130, 26, 195 ];
  ( : roundthree) hidden var geometry = [ 280, 140, 28, 210 ];
  ( : roundfour) hidden var geometry = [ 390, 195, 39, 292 ];

  hidden var DEBUG = false;

  function initialize(high, low, current, parFonts) {
    DataFieldAlert.initialize();
    targetHigh = high;
    targetLow = low;
    currentPower = current;
    fonts = parFonts;
  }

  function onLayout(dc) { return true; }

  function onUpdate(dc) {
    View.onUpdate(dc);

    if (currentPower < targetLow) {
      ringColor = 0x00AAFF;
      alertText = WatchUi.loadResource(Rez.Strings.LOWPOWER);
    } else {
      ringColor = 0xFF0000;
      alertText = WatchUi.loadResource(Rez.Strings.HIGHPOWER);
    }

    dc.setAntiAlias(true);
    dc.setColor(0xFFFFFF, -1);
    dc.drawText(geometry[1], geometry[1], fonts[1], currentPower.toNumber(),
                4 | 1);
    dc.drawText(geometry[1], geometry[2], fonts[0], alertText, 1);
    dc.drawText(geometry[1], geometry[3], fonts[0],
                WatchUi.loadResource(Rez.Strings.TGT) + " " + targetLow + "-" +
                    targetHigh,
                1);
    dc.setColor(ringColor, -1);
    dc.setPenWidth(5);
    dc.drawCircle(geometry[1], geometry[1], geometry[1] - 2);
  }
}