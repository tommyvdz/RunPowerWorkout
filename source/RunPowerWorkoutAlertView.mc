using Toybox.WatchUi;

class RunPowerWorkoutAlertView extends WatchUi.DataFieldAlert {
  hidden var targetHigh;
  hidden var targetLow;
  hidden var currentPower;
  hidden var fonts;

  (:roundzero) hidden var geometry = [ 218, 109, 21, 163 ];
  (:roundone) hidden var geometry = [ 240, 120, 24, 180 ];
  (:roundtwo) hidden var geometry = [ 260, 130, 26, 195 ];
  (:roundthree) hidden var geometry = [ 280, 140, 28, 210 ];
  (:roundfour) hidden var geometry = [ 390, 195, 39, 292 ];
  (:roundfive) hidden var geometry = [ 360, 180, 36, 266 ];
  (:roundsix) hidden var geometry = [ 416, 208, 41, 308 ];
  (:roundseven) hidden var geometry = [ 208, 104, 20, 153 ];
  
  function initialize(high, low, current, parFonts) {
    DataFieldAlert.initialize();
    targetHigh = high;
    targetLow = low;
    currentPower = current.toNumber();
    fonts = parFonts;
  }

  function onLayout(dc) { return true; }

  function onUpdate(dc) {
    View.onUpdate(dc);

    if(dc has :setAntiAlias){
      dc.setAntiAlias(true);
    }
    dc.setColor(0xFFFFFF, -1);
    dc.drawText(geometry[1], geometry[1], fonts[1], currentPower,
                4 | 1);
    dc.drawText(geometry[1], geometry[2], fonts[0], currentPower < targetLow ? "LOW POWER" : "HIGH POWER", 1);
    dc.drawText(geometry[1], geometry[3], fonts[0],
                "TGT" + " " + targetLow + "-" +
                    targetHigh,
                1);
    dc.setColor(currentPower < targetLow ? 0x00AAFF : 0xFF0000, -1);
    dc.setPenWidth(5);
    dc.drawCircle(geometry[1], geometry[1], geometry[1] - 2);
  }
}