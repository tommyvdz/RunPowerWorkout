using Toybox.WatchUi;
using Toybox.Graphics as Gfx;
using Toybox.Time;

class RunPowerWorkoutAlertView extends WatchUi.DataFieldAlert {
  hidden var targetHigh;
  hidden var targetLow;
  hidden var currentPower;

  hidden var DEBUG = true;

  function initialize(high, low, current) {
    if (DEBUG) {
      System.println(
          "Debug mode: setting default targets for alert, and printing a lot.");
    }

    DataFieldAlert.initialize();
    targetHigh = high;
    targetLow = low;
    currentPower = current;
  }

  // Set your layout here. Anytime the size of obscurity of
  // the draw context is changed this will be called.
  function onLayout(dc) {
    View.setLayout(Rez.Layouts.AlertLayout(dc));

    var alertLabel = View.findDrawableById("alert");
    var alertValue = View.findDrawableById("alertv");
    var alertTargets = View.findDrawableById("alerttargets");

    alertLabel.setText("High");
    alertValue.setText("0");
    alertTargets.setText("0-1000");

    return true;
  }

  // Display the value you computed here. This will be called
  // once a second when the data field is visible.
  function onUpdate(dc) {
    // Set the background color
    View.findDrawableById("Background").setColor(Graphics.COLOR_BLACK);

    var alertLabel = View.findDrawableById("alert");
    var alertValue = View.findDrawableById("alertv");
    var alertTargets = View.findDrawableById("alerttargets");
    var ringColor = Graphics.COLOR_RED;

    if (currentPower < targetLow) {
      alertLabel.setText("Low power !");
      ringColor = Graphics.COLOR_BLUE;

    } else {
      alertLabel.setText("High power !");
    }

    alertLabel.setColor(ringColor);
    alertValue.setText("" + currentPower.toNumber());
    alertTargets.setText("TGT " + targetLow + "-" + targetHigh);

    //! Call parent's onUpdate(dc) to redraw the layout
    View.onUpdate(dc);

    var screenWidth = dc.getWidth();
    var screenHeight = dc.getHeight();
    var centerX = screenWidth / 2;
    var centerY = screenHeight / 2;
    dc.setColor(ringColor, Graphics.COLOR_TRANSPARENT);
    dc.setPenWidth(5);
    dc.drawCircle(centerX, centerY, centerX - 2);
  }
}
