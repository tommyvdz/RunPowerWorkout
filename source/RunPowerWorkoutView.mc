using Toybox.WatchUi;
using Toybox.Graphics as Gfx;
using Toybox.Time;
using Toybox.Attention;
using Toybox.UserProfile;

class RunPowerWorkoutView extends WatchUi.DataField {
  hidden var timer;
  hidden var lapTime;
  hidden var lapStopPauseTime;
  hidden var lapDelta;
  hidden var lapStartTime;
  hidden var lapStartDistance;
  hidden var lapPower;
  hidden var targetHigh;
  hidden var targetLow;
  hidden var nextTargetHigh;
  hidden var nextTargetLow;
  hidden var nextTargetType;
  hidden var nextTargetDuration;
  hidden var remainingTime;
  hidden var remainingDistance;
  hidden var stepType;
  hidden var currentPower;
  hidden var paused;
  hidden var cadence;
  hidden var alertDisplayed;
  hidden var alertTimer;
  hidden var alertCount;
  hidden var alertDelay;
  hidden var hr;
  hidden var usePercentage;
  hidden var useMetric;
  hidden var FTP;
  hidden var vibrate;
  hidden var showAlerts;
  hidden var switchCounter;
  hidden var switchMetric;
  hidden var hrZones;
  hidden var shouldDisplayAlert;
  hidden var font;

  hidden var DEBUG = false;

  function initialize() {
    if (DEBUG) {
      System.println(
          "Debug mode: setting default targets, and printing a lot.");
    }

    // read settings
    var percentagesetting = Utils.replaceNull(
        Application.getApp().getProperty("PERCENTAGE"), false);
    var ftpsetting =
        Utils.replaceNull(Application.getApp().getProperty("FTP"), 325);
    var vibratesetting =
        Utils.replaceNull(Application.getApp().getProperty("VIBRATE"), false);
    var showalertssetting =
        Utils.replaceNull(Application.getApp().getProperty("ALERT"), true);

    font = WatchUi.loadResource(Rez.Fonts.Pragati26);

    usePercentage = percentagesetting;
    FTP = ftpsetting;
    showAlerts = showalertssetting;
    vibrate = vibratesetting;

    useMetric = System.getDeviceSettings().paceUnits == System.UNIT_METRIC
                    ? true
                    : false;

    DataField.initialize();
    timer = 0;
    lapTime = 0;
    lapStartTime = 0;
    lapStartDistance = 0;
    targetHigh = 0;
    targetLow = 0;
    remainingTime = 0;
    remainingDistance = 0;
    stepType = 0;
    currentPower = 0;
    cadence = 0;
    hr = 0;
    paused = true;
    alertDisplayed = false;
    shouldDisplayAlert = true;
    alertTimer = 0;
    alertCount = 0;
    alertDelay = 10;
    switchCounter = 0;
    switchMetric = 0;
    hrZones = UserProfile.getHeartRateZones(UserProfile.HR_ZONE_SPORT_GENERIC);
  }

  function onTimerStart() {
    if (DEBUG) {
      System.println("Timer Start");
    }
    paused = false;
  }

  function onTimerStop() {
    if (DEBUG) {
      System.println("Timer Stop");
    }
    paused = true;
  }

  function onTimerResume() {
    if (DEBUG) {
      System.println("Timer Resume");
    }
    paused = false;
  }

  function onTimerPause() {
    if (DEBUG) {
      System.println("Timer Pause");
    }
    paused = true;
  }

  function onTimerLap() {
    if (DEBUG) {
      System.println("Timer Lap");
    }
  }

  function onWorkoutStepComplete() {
    lapStartTime = timer;
    lapTime = 0;
    lapStartDistance = Activity.getActivityInfo().elapsedDistance;
    lapPower = null;
    remainingTime = 0;
    alertCount = 0;
    alertDisplayed = false;
  }

  function onTimerReset() {
    if (DEBUG) {
      System.println("Timer Reset");
    }

    lapStartTime = timer;
    lapStartDistance = 0;
    lapTime = 0;
    lapPower = null;
    remainingTime = 0;
    alertCount = 0;
    alertDisplayed = false;
  }

  // Set your layout here. Anytime the size of obscurity of
  // the draw context is changed this will be called.
  function onLayout(dc) {
    View.setLayout(Rez.Layouts.MainLayout(dc));

    var currentPowerLabel = View.findDrawableById("currentPower");
    var currentPowerValue = View.findDrawableById("currentPowerv");
    var lapPowerValue = View.findDrawableById("lapPowerv");
    var lapPowerLabel = View.findDrawableById("lapPower");
    var powerHighValue = View.findDrawableById("powerHighv");
    var powerLowValue = View.findDrawableById("powerLowv");
    var remainingTimeLabel = View.findDrawableById("remainingTime");
    var remainingTimeValue = View.findDrawableById("remainingTimev");
    var hrLabel = View.findDrawableById("hr");
    var hrValue = View.findDrawableById("hrv");
    var paceLabel = View.findDrawableById("pace");
    var paceUnit = View.findDrawableById("paceunit");
    var paceValue = View.findDrawableById("pacev");
    var distanceLabel = View.findDrawableById("distance");
    var distanceUnit = View.findDrawableById("distanceunit");
    var distanceValue = View.findDrawableById("distancev");
    var elapsedTimeLabel = View.findDrawableById("elapsedTime");
    var cadenceLabel = View.findDrawableById("cadence");
    var currentPowerBG = View.findDrawableById("currentPowerBG");
    var hrBG = View.findDrawableById("hrBG");
    var lapPowerBG = View.findDrawableById("lapPowerBG");

    currentPowerValue.setText("0");
    lapPowerLabel.setText("Lap Pwr");
    lapPowerValue.setText("0");
    paceLabel.setText("Pace");
    paceValue.setText(format_duration(0));
    powerHighValue.setText("-");
    distanceLabel.setText("Distance");
    elapsedTimeLabel.setText("Distance");

    var distance = format_distance(0);
    distanceValue.setText(distance[0]);
    distanceUnit.setText(distance[1]);
    if (useMetric) {
      paceUnit.setText("min/km");
    } else {
      paceUnit.setText("min/mi");
    }
    powerLowValue.setText("-");
    hrLabel.setText("HR");
    remainingTimeLabel.setText("Rem. Time");
    elapsedTimeLabel.setText("El. Time");
    cadenceLabel.setText("Cadence");

    var width = dc.getWidth();
    var height = dc.getHeight();

    currentPowerBG.setAttributes(0, 0, width, ((height / 3) + (0.02 * height)));
    hrBG.setAttributes(
        0.7 * width, ((height / 2) + (0.06 * height)), width,
        ((height / 2) + (0.06 * height)) - ((height / 3) + (0.01 * height)));
    lapPowerBG.setAttributes(
        0, ((height / 2) + (0.06 * height)), width * 0.3,
        ((height / 2) + (0.06 * height)) - ((height / 3) + (0.01 * height)));

    return true;
  }

  // The given info object contains all the current workout information.
  // Calculate a value and save it locally in this method.
  // Note that compute() and onUpdate() are asynchronous, and there is no
  // guarantee that compute() will be called before onUpdate().
  function compute(info) {
    // See Activity.Info in the documentation for available information.
    var workout = Activity.getCurrentWorkoutStep();
    var nextWorkout = Activity.getNextWorkoutStep();
    var activityInfo = Activity.getActivityInfo();

    if (paused != true) {
      if (activityInfo != null) {
        timer = activityInfo.timerTime / 1000;
        lapTime = timer - lapStartTime;

        shouldDisplayAlert = (lapTime > 15);

        if (nextWorkout != null && DEBUG == false) {
          nextTargetHigh = nextWorkout.step.targetValueHigh - 1000;
          nextTargetLow = nextWorkout.step.targetValueLow - 1000;
          if (nextTargetHigh < 0) {
            nextTargetHigh = 0;
          }
          if (nextTargetLow < 0) {
            nextTargetLow = 0;
          }

          if (usePercentage && nextTargetHigh != null &&
              nextTargetHigh != null) {
            nextTargetHigh = ((nextTargetHigh / (FTP * 1.0)) * 100).toNumber();
            nextTargetHigh = ((nextTargetHigh / (FTP * 1.0)) * 100).toNumber();
          }

          if (nextWorkout.step.targetType != null &&
              nextWorkout.step.durationType == 5) {
            nextTargetType = 5;
          } else if (nextWorkout.step.targetType != null &&
                     nextWorkout.step.durationType == 1) {
            nextTargetType = 1;
            if (nextWorkout.step.durationValue != null) {
              nextTargetDuration = nextWorkout.step.durationValue;
            }
          } else {
            nextTargetType = 0;
            if (nextWorkout.step.durationValue != null) {
              nextTargetDuration = nextWorkout.step.durationValue;
            }
          }
        }

        if (workout != null && DEBUG == false) {
          targetHigh = workout.step.targetValueHigh - 1000;
          targetLow = workout.step.targetValueLow - 1000;
          if (targetHigh < 0) {
            targetHigh = 0;
          }
          if (targetLow < 0) {
            targetLow = 0;
          }

          if (targetLow == 0 and targetHigh == 0) {
            shouldDisplayAlert = false;
          }

          if (usePercentage && targetHigh != null && targetLow != null) {
            targetHigh = ((targetHigh / (FTP * 1.0)) * 100).toNumber();
            targetLow = ((targetLow / (FTP * 1.0)) * 100).toNumber();
          }

          if (workout.step.targetType != null &&
              workout.step.durationType == 5) {
            stepType = 5;
          } else if (workout.step.targetType != null &&
                     workout.step.durationType == 1) {
            stepType = 1;
            if (workout.step.durationValue != null && DEBUG == false &&
                remainingDistance >= 0) {
              remainingDistance = workout.step.durationValue -
                                  ((activityInfo.elapsedDistance).toNumber() -
                                   lapStartDistance);
              if (shouldDisplayAlert && remainingDistance < 40) {
                shouldDisplayAlert = false;
              }
            }
          } else {
            stepType = 0;
            if (workout.step.durationValue != null && DEBUG == false &&
                remainingTime >= 0) {
              remainingTime = (workout.step.durationValue - lapTime).toNumber();
              if (shouldDisplayAlert && remainingTime < 15) {
                shouldDisplayAlert = false;
              }
            }
          }
        }

        if (DEBUG) {
          targetHigh = 160;
          targetLow = 100;
          stepType = 1;
          if (remainingDistance == 0) {
            remainingDistance = 20000;
          }
          remainingDistance = remainingDistance - 1;
          if (usePercentage && targetHigh != null && targetLow != null) {
            targetHigh = ((targetHigh / (FTP * 1.0)) * 100).toNumber();
            targetLow = ((targetLow / (FTP * 1.0)) * 100).toNumber();
          }
        }

        switchCounter++;
        if (switchCounter > 2) {
          if (switchMetric == 0) {
            switchMetric = 1;
          } else {
            switchMetric = 0;
          }
          switchCounter = 0;
        }

        if (activityInfo has : currentCadence) {
          cadence = activityInfo.currentCadence;
        }
        if (activityInfo has : currentHeartRate) {
          hr = activityInfo.currentHeartRate;
        }

        if (activityInfo has : currentPower) {
          if (usePercentage && activityInfo.currentPower != null) {
            currentPower =
                ((activityInfo.currentPower / (FTP * 1.0)) * 100).toNumber();
          } else {
            currentPower = activityInfo.currentPower;
          }

          if (currentPower != null) {
            if (lapPower == null) {
              lapPower = currentPower;
            } else if (lapTime != 0) {
              lapPower = (((lapPower * (lapTime - 1)) + currentPower) /
                          (lapTime * 1.0));
            }
          } else {
            currentPower = 0;  // in order to prevent problems when using
                               // currentpower elsewhere
          }

          // Show an alert if above of below
          if (WatchUi.DataField has
              : showAlert && showAlerts && shouldDisplayAlert) {
            if ((currentPower != null && (targetLow != 0 && targetHigh != 0) &&
                 (currentPower < targetLow || currentPower > targetHigh))) {
              if (alertDisplayed == false) {
                if (alertCount < 3) {
                  if (Attention has : vibrate && vibrate) {
                    Attention.vibrate([new Attention.VibeProfile(50, 1000)]);
                  }

                  WatchUi.DataField.showAlert(new RunPowerWorkoutAlertView(
                      targetHigh, targetLow, currentPower, false));
                  alertDisplayed = true;
                  alertTimer = timer;
                  alertCount++;
                }
              } else {
                if ((timer - alertTimer) > alertDelay) {
                  alertDisplayed = false;
                }
              }
            } else {
              alertCount = 0;
            }
          }
        }
      }
    }

    return true;
  }

  // Display the value you computed here. This will be called
  // once a second when the data field is visible.
  function onUpdate(dc) {
    // Set the background color
    View.findDrawableById("Background").setColor(getBackgroundColor());

    var currentPowerValue = View.findDrawableById("currentPowerv");
    var lapPowerValue = View.findDrawableById("lapPowerv");
    var lapPowerLabel = View.findDrawableById("lapPower");
    var powerHighValue = View.findDrawableById("powerHighv");
    var powerLowValue = View.findDrawableById("powerLowv");
    var remainingTimeValue = View.findDrawableById("remainingTimev");
    var cadenceValue = View.findDrawableById("cadencev");
    var cadenceLabel = View.findDrawableById("cadence");
    var hrValue = View.findDrawableById("hrv");
    var hrLabel = View.findDrawableById("hr");
    var paceValue = View.findDrawableById("pacev");
    var paceLabel = View.findDrawableById("pace");
    var distanceLabel = View.findDrawableById("distance");
    var distanceValue = View.findDrawableById("distancev");
    var distanceUnit = View.findDrawableById("distanceunit");
    var paceUnit = View.findDrawableById("paceunit");
    var elapsedTimeValue = View.findDrawableById("elapsedTimev");
    var elapsedTimeLabel = View.findDrawableById("elapsedTime");
    var remainingTimeLabel = View.findDrawableById("remainingTime");
    var currentPowerBG = View.findDrawableById("currentPowerBG");
    var hrBG = View.findDrawableById("hrBG");
    var lapPowerBG = View.findDrawableById("lapPowerBG");

    if (getBackgroundColor() == Graphics.COLOR_BLACK) {
      currentPowerValue.setColor(Graphics.COLOR_WHITE);
      lapPowerValue.setColor(Graphics.COLOR_WHITE);
      powerHighValue.setColor(Graphics.COLOR_WHITE);
      powerLowValue.setColor(Graphics.COLOR_WHITE);
      remainingTimeValue.setColor(Graphics.COLOR_WHITE);
      cadenceValue.setColor(Graphics.COLOR_WHITE);
      elapsedTimeValue.setColor(Graphics.COLOR_WHITE);
      paceValue.setColor(Graphics.COLOR_WHITE);
      distanceValue.setColor(Graphics.COLOR_WHITE);
      distanceUnit.setColor(Graphics.COLOR_WHITE);
      paceUnit.setColor(Graphics.COLOR_WHITE);
      hrValue.setColor(Graphics.COLOR_WHITE);
    } else {
      currentPowerValue.setColor(Graphics.COLOR_BLACK);
      lapPowerValue.setColor(Graphics.COLOR_BLACK);
      powerHighValue.setColor(Graphics.COLOR_BLACK);
      powerLowValue.setColor(Graphics.COLOR_BLACK);
      remainingTimeValue.setColor(Graphics.COLOR_BLACK);
      cadenceValue.setColor(Graphics.COLOR_BLACK);
      elapsedTimeValue.setColor(Graphics.COLOR_BLACK);
      paceValue.setColor(Graphics.COLOR_BLACK);
      distanceValue.setColor(Graphics.COLOR_BLACK);
      distanceUnit.setColor(Graphics.COLOR_BLACK);
      paceUnit.setColor(Graphics.COLOR_BLACK);
      hrValue.setColor(Graphics.COLOR_BLACK);
    }

    //! Draw the outline
    var width = dc.getWidth();
    var height = dc.getHeight();
    var x = width / 2;
    var y = height / 2;

    if (hr == null) {
      hrValue.setText("0");
      hrBG.setColor(Graphics.COLOR_TRANSPARENT);
    } else {
      hrLabel.setColor(Graphics.COLOR_WHITE);
      hrValue.setColor(Graphics.COLOR_WHITE);
      if (hr > hrZones[4]) {
        hrBG.setColor(Graphics.COLOR_RED);
      } else if (hr > hrZones[3]) {
        hrBG.setColor(Graphics.COLOR_ORANGE);
      } else if (hr > hrZones[2]) {
        hrBG.setColor(Graphics.COLOR_GREEN);
      } else if (hr > hrZones[1]) {
        hrBG.setColor(Graphics.COLOR_BLUE);
      } else {
        hrBG.setColor(Graphics.COLOR_LT_GRAY);
      }
      hrValue.setText("" + hr);
    }

    if (currentPower == null) {
      currentPowerValue.setText("0");
    } else {
      if (targetHigh != 0 && targetLow != 0) {
        currentPowerValue.setColor(Graphics.COLOR_WHITE);
        powerHighValue.setColor(Graphics.COLOR_WHITE);
        powerLowValue.setColor(Graphics.COLOR_WHITE);
        if (currentPower < targetLow) {
          currentPowerBG.setColor(Graphics.COLOR_BLUE);
        } else if (currentPower > targetHigh) {
          currentPowerBG.setColor(Graphics.COLOR_RED);
        } else {
          currentPowerBG.setColor(Graphics.COLOR_GREEN);
        }
      } else {
        currentPowerBG.setColor(Graphics.COLOR_TRANSPARENT);
      }
      currentPowerValue.setText("" + currentPower);
    }
    if (lapPower == null) {
      lapPowerValue.setText("0");
      lapPowerBG.setColor(Graphics.COLOR_TRANSPARENT);
    } else {
      if (targetHigh != 0 && targetLow != 0) {
        lapPowerValue.setColor(Graphics.COLOR_WHITE);
        lapPowerLabel.setColor(Graphics.COLOR_WHITE);
        if (lapPower.toNumber() < targetLow) {
          lapPowerBG.setColor(Graphics.COLOR_BLUE);
        } else if (lapPower.toNumber() > targetHigh) {
          lapPowerBG.setColor(Graphics.COLOR_RED);
        } else {
          lapPowerBG.setColor(Graphics.COLOR_GREEN);
        }
      }
      lapPowerValue.setText("" + lapPower.toNumber());
    }

    if ((remainingDistance == 0 || remainingDistance > 30) &&
        (remainingTime == 0 || remainingTime > 12)) {
      if (stepType == 5) {
        remainingTimeLabel.setText("Until");
        remainingTimeValue.setText("Lap Press");
      } else if (stepType == 1) {
        var distance = format_distance(remainingDistance);
        remainingTimeLabel.setText("Rem. Dist");
        remainingTimeValue.setText("" + distance[0] + "" + distance[1]);
      } else {
        remainingTimeLabel.setText("Rem. Time");
        remainingTimeValue.setText("" + format_duration(remainingTime));
      }
    } else {
      remainingTimeLabel.setText("Next step");
      if (switchMetric == 0) {
        remainingTimeValue.setText(nextTargetLow + "-" + nextTargetHigh);
      } else {
        if (nextTargetType == 5) {
          remainingTimeValue.setText("Lap Press");
        } else if (nextTargetType == 1) {
          var distance = format_distance(nextTargetDuration * 1.0);
          remainingTimeValue.setText(distance[0] + distance[1]);
        } else {
          remainingTimeValue.setText(
              format_duration(nextTargetDuration.toNumber()));
        }
      }
    }

    powerHighValue.setText("" + targetHigh);
    powerLowValue.setText("" + targetLow);

    elapsedTimeValue.setText("" + format_duration(timer));

    if (Activity.getActivityInfo().elapsedDistance != null) {
      var distance =
          format_distance(Activity.getActivityInfo().elapsedDistance);
      distanceValue.setText("" + distance[0]);
      distanceUnit.setText("" + distance[1]);
    }

    if (cadence == null) {
      cadenceValue.setText("0");
    } else {
      cadenceValue.setText("" + cadence);
    }

    if (Activity.getActivityInfo().currentSpeed == null) {
      paceValue.setText(convert_speed_pace(0));
    } else {
      paceValue.setText(
          convert_speed_pace(Activity.getActivityInfo().currentSpeed));
    }

    //! Call parent's onUpdate(dc) to redraw the layout
    View.onUpdate(dc);

    //! Draw separator lines
    if (getBackgroundColor() == Graphics.COLOR_BLACK) {
      dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    } else {
      dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
    }
    dc.setPenWidth(1);

    //! Horizontal seperators
    dc.drawLine(0, ((height / 3) + (0.02 * height)), width,
                ((height / 3) + (0.02 * height)));
    dc.drawLine(0, ((height / 2) + (0.06 * height)), width,
                ((height / 2) + (0.06 * height)));
    dc.drawLine(0, 0.77 * height, width, 0.77 * height);

    //! vertical seperators
    dc.drawLine(width * 0.3, ((height / 3) + (0.02 * height)), width * 0.3,
                ((height / 2) + (0.06 * height)));
    dc.drawLine(width * 0.7, ((height / 3) + (0.02 * height)), width * 0.7,
                ((height / 2) + (0.06 * height)));
    dc.drawLine(width * 0.3, ((height / 3) + (0.06 * height)), width * 0.3,
                0.77 * height);
    dc.drawLine(width * 0.7, ((height / 3) + (0.06 * height)), width * 0.7,
                0.77 * height);

    //! The following code to draw the gauge is copied and adapted from
    //! Ravenfeld - Speed Gauge
    //! https://github.com/ravenfeld/Connect-IQ-DataField-Speed

    var SIZE = 10;

    dc.setPenWidth(SIZE);
    dc.setAntiAlias(true);
    dc.setColor(Graphics.COLOR_DK_RED, getBackgroundColor());
    dc.drawArc(x, y, dc.getWidth() / 2 - 10 - SIZE / 2,
               Gfx.ARC_COUNTER_CLOCKWISE, 30, 60);

    dc.setColor(Graphics.COLOR_DK_BLUE, getBackgroundColor());
    dc.drawArc(x, y, dc.getWidth() / 2 - 10 - SIZE / 2,
               Gfx.ARC_COUNTER_CLOCKWISE, 120, 150);

    dc.setColor(Graphics.COLOR_DK_GREEN, getBackgroundColor());
    dc.drawArc(x, y, dc.getWidth() / 2 - 10 - SIZE / 2,
               Gfx.ARC_COUNTER_CLOCKWISE, 60, 120);

    if (getBackgroundColor() == Graphics.COLOR_BLACK) {
      dc.setColor(Graphics.COLOR_WHITE, getBackgroundColor());
    } else {
      dc.setColor(Graphics.COLOR_BLACK, getBackgroundColor());
    }

    var percent = 0.15;
    var power = 0.0;
    if (currentPower > 0 && targetHigh > 0 && targetLow > 0) {
      var range = targetHigh - targetLow;
      var lowerlimit = 0;

      if (targetLow - range < 0) {
        lowerlimit = 0;
      } else {
        lowerlimit = targetLow - range;
      }

      var upperlimit = targetHigh + range;
      power = currentPower - lowerlimit;
      if (power > 0.0 && (upperlimit - lowerlimit) > 0) {
        percent = power / (upperlimit - lowerlimit * 1.0);
      }
      if (percent < 0.15) {
        System.println("percent is smaller than 0.15");
        percent = 0.15;
      }
      if (percent > 0.85) {
        System.println("percent is lager than 0.85");
        percent = 0.85;
      }
    }

    var orientation = -Math.PI * percent - 3 * Math.PI / 2;
    var radius = dc.getWidth() / 2 - 6;
    var xy1 = pol2Cart(x, y, orientation, radius);
    var xy2 = pol2Cart(x, y, orientation - 5 * Math.PI / 180, radius);
    var xy3 =
        pol2Cart(x, y, orientation - 5 * Math.PI / 180, radius - SIZE - 8);
    var xy4 = pol2Cart(x, y, orientation, radius - SIZE - 8);
    dc.fillPolygon([ xy1, xy2, xy3, xy4 ]);
  }

  function pol2Cart(center_x, center_y, radian, radius) {
    var x = center_x - radius * Math.sin(radian);
    var y = center_y - radius * Math.cos(radian);

    return [ Math.ceil(x), Math.ceil(y) ];
  }

  function format_duration(seconds) {
    var hh = seconds / 3600;
    var mm = seconds / 60 % 60;
    var ss = seconds % 60;

    if (hh != 0) {
      return Lang.format("$1$:$2$:$3$",
                         [ hh, mm.format("%02d"), ss.format("%02d") ]);
    } else {
      return Lang.format("$1$:$2$", [ mm, ss.format("%02d") ]);
    }
  }

  function convert_speed_pace(speed) {
    if (speed != null && speed > 0) {
      var factor = useMetric ? 1000.0 : 1609.0;
      var secondsPerUnit = factor / speed;
      secondsPerUnit = (secondsPerUnit + 0.5).toNumber();
      var minutes = (secondsPerUnit / 60);
      var seconds = (secondsPerUnit % 60);
      return Lang.format("$1$:$2$", [ minutes, seconds.format("%02u") ]);
    } else {
      return "0:00";
    }
  }

  function format_distance(distance) {
    var factor = 1000;
    var smallunitfactor = 1000;
    var unit = "km";
    var smallunit = "m";

    if (!useMetric) {
      factor = 1609;
      smallunitfactor = 1760;
      unit = "mi";
      smallunit = "yd";
    }

    if ((distance / factor) >= 1) {
      return [ ((distance * 1.0) / (factor * 1.0)).format("%.2f") + "", unit ];
    } else {
      return
          [ (distance / factor * smallunitfactor).toNumber() + "", smallunit ];
    }
  }
}
