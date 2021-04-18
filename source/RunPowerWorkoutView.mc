using Toybox.WatchUi;
using Toybox.Time;
using Toybox.Attention;
using Toybox.UserProfile;

class RunPowerWorkoutView extends WatchUi.DataField {
  hidden var timer;
  hidden var stepTime;
  hidden var stepStartTime;
  hidden var stepStartDistance;
  hidden var stepPower;
  hidden var lapTime;
  hidden var lapStartTime;
  hidden var targetHigh;
  hidden var targetLow;
  hidden var nextTargetHigh;
  hidden var nextTargetLow;
  hidden var nextTargetType;
  hidden var nextTargetDuration;
  hidden var remainingTime;
  hidden var remainingDistance;
  hidden var remainingDistanceSpeed;
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
  hidden var powerAverage;
  hidden var currentPowerAverage;
  hidden var showColors;
  hidden var stepSpeed;
  hidden var fonts;
  hidden var fontOffset = 0;
  hidden var useCustomFonts;
  hidden var showSmallDecimals;
  hidden var pwrZones;
  hidden var pwrZonesLabels;
  hidden var pwrZonesColors;
  hidden var currentPwrZone;

  // [ Width, Center, 1st horizontal line, 2nd horizontal line
  // 3rd Horizontal line, 1st vertical, Second vertical, Radius,
  // Top Arc, Bottom Arc, Offset Target Y, Background rect height, Offset Target
  // X, Center mid field ]

  (
      : roundzero) hidden var geometry =
      [ 218, 109, 77, 122, 167, 70, 161, 103, 114, 85, 27, 45, 30, 116 ];
  (
      : roundone) hidden var geometry =
      [ 240, 120, 85, 135, 185, 77, 177, 105, 114, 96, 32, 50, 40, 127 ];
  (
      : roundtwo) hidden var geometry =
      [ 260, 130, 91, 146, 201, 83, 192, 115, 124, 106, 37, 55, 45, 138 ];
  (
      : roundthree) hidden var geometry =
      [ 280, 140, 98, 157, 216, 90, 207, 125, 134, 116, 42, 59, 50, 149 ];
  (
      : roundfour) hidden var geometry =
      [ 390, 195, 140, 220, 300, 125, 289, 180, 189, 171, 42, 80, 45, 207 ];

  hidden var showExtra = false;

  hidden var DEBUG = false;

  function initialize() {
    // read settings
    usePercentage = Utils.replaceNull(
        Application.getApp().getProperty("PERCENTAGE"), false);
    FTP = Utils.replaceNull(Application.getApp().getProperty("FTP"), 330);
    showAlerts =
        Utils.replaceNull(Application.getApp().getProperty("ALERT"), true);
    vibrate =
        Utils.replaceNull(Application.getApp().getProperty("VIBRATE"), true);
    powerAverage =
        Utils.replaceNull(Application.getApp().getProperty("POWER_AVERAGE"), 3);
    showColors =
        Utils.replaceNull(Application.getApp().getProperty("SHOW_COLORS"), 1);
    showColors =
        Utils.replaceNull(Application.getApp().getProperty("SHOW_COLORS"), 1);
    var zones = Utils.replaceNull(Application.getApp().getProperty("ZONES"), 4);

    useMetric = System.getDeviceSettings().paceUnits == System.UNIT_METRIC
                    ? true
                    : false;
    useCustomFonts = Utils.replaceNull(
        Application.getApp().getProperty("USE_CUSTOM_FONTS"), true);
    showSmallDecimals = Utils.replaceNull(
        Application.getApp().getProperty("SHOW_SMALL_DECIMALS"), true);

    set_fonts();

    DataField.initialize();
    timer = 0;
    stepTime = 0;
    lapTime = 0;
    lapStartTime = 0;
    stepStartTime = 0;
    stepSpeed = null;
    stepStartDistance = 0;
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
    currentPowerAverage = new[powerAverage];
    remainingDistanceSpeed = -1;
    currentPwrZone = 1;

    if (zones == 2) {
      pwrZones = WatchUi.loadResource(Rez.JsonData.P2);
      pwrZonesLabels = WatchUi.loadResource(Rez.JsonData.Z2);
      pwrZonesColors = WatchUi.loadResource(Rez.JsonData.C2);
    } else if (zones == 3) {
      pwrZones = WatchUi.loadResource(Rez.JsonData.P3);
      pwrZonesLabels = WatchUi.loadResource(Rez.JsonData.Z3);
      pwrZonesColors = WatchUi.loadResource(Rez.JsonData.C3);
    } else if (zones == 4) {
      pwrZones = WatchUi.loadResource(Rez.JsonData.P4);
      pwrZonesLabels = WatchUi.loadResource(Rez.JsonData.Z4);
      pwrZonesColors = WatchUi.loadResource(Rez.JsonData.C4);
    } else if (zones == 5) {
      pwrZones = WatchUi.loadResource(Rez.JsonData.P5);
      pwrZonesLabels = WatchUi.loadResource(Rez.JsonData.Z5);
      pwrZonesColors = WatchUi.loadResource(Rez.JsonData.C5);
    } else {
      pwrZones = WatchUi.loadResource(Rez.JsonData.P1);
      pwrZonesLabels = WatchUi.loadResource(Rez.JsonData.Z1);
      pwrZonesColors = WatchUi.loadResource(Rez.JsonData.C1);
    }
  }

  function onTimerStart() { paused = false; }

  function onTimerStop() { paused = true; }

  function onTimerResume() { paused = false; }

  function onTimerPause() { paused = true; }

  function onTimerLap() {
    lapTime = 0;
    lapStartTime = timer;
  }

  function onWorkoutStepComplete() {
    stepStartTime = timer;
    stepTime = 0;
    stepSpeed = null;
    stepStartDistance = Activity.getActivityInfo().elapsedDistance;
    stepPower = null;
    remainingTime = 0;
    alertCount = 0;
    alertDisplayed = false;
    remainingDistanceSpeed = -1;
  }

  function onTimerReset() {
    stepStartTime = timer;
    stepStartDistance = 0;
    stepTime = 0;
    lapTime = 0;
    lapStartTime = timer;
    stepPower = null;
    stepSpeed = null;
    remainingTime = 0;
    alertCount = 0;
    alertDisplayed = false;
    remainingDistanceSpeed = -1;
  }

  ( : highmem) function set_fonts() {
    if (useCustomFonts) {
      fontOffset = -4;
      showExtra = true;
      fonts = [
        WatchUi.loadResource(Rez.Fonts.A), WatchUi.loadResource(Rez.Fonts.B),
        WatchUi.loadResource(Rez.Fonts.C), WatchUi.loadResource(Rez.Fonts.D),
        WatchUi.loadResource(Rez.Fonts.E), WatchUi.loadResource(Rez.Fonts.F)
      ];
    } else {
      fonts = [ 0, 1, 2, 3, 6, 8 ];
    }
  }

  ( : medmem) function set_fonts() { fonts = [ 0, 1, 2, 3, 6, 8 ]; }

  ( : lowmem) function set_fonts() { fonts = [ 0, 1, 2, 3, 6, 8 ]; }

  // Set your layout here. Anytime the size of obscurity of
  // the draw context is changed this will be called.
  function onLayout(dc) { return true; }

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
        stepTime = timer - stepStartTime;
        lapTime = timer - lapStartTime;

        shouldDisplayAlert = (stepTime > 15);

        if (nextWorkout != null) {
          nextTargetHigh = nextWorkout.step.targetValueHigh - 1000;
          nextTargetLow = nextWorkout.step.targetValueLow - 1000;
          if (nextTargetHigh < 0) {
            nextTargetHigh = 0;
          }
          if (nextTargetLow < 0) {
            nextTargetLow = 0;
          }

          if (usePercentage && nextTargetHigh != null &&
              nextTargetLow != null) {
            nextTargetHigh = ((nextTargetHigh / (FTP * 1.0)) * 100).toNumber();
            nextTargetLow = ((nextTargetLow / (FTP * 1.0)) * 100).toNumber();
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
        } else {
          nextTargetHigh = 0;
          nextTargetLow = 0;
          nextTargetType = 5;
          nextTargetDuration = 0;
        }

        if (workout != null) {
          targetHigh = workout.step.targetValueHigh - 1000;
          targetLow = workout.step.targetValueLow - 1000;
          if (targetHigh < 0) {
            targetHigh = 0;
          }
          if (targetLow < 0) {
            targetLow = 0;
          }

          if (targetLow == 0 && targetHigh == 0) {
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
                                   stepStartDistance);
              if (shouldDisplayAlert &&
                  remainingDistance < remainingDistanceSpeed) {
                shouldDisplayAlert = false;
              }
            }
          } else {
            stepType = 0;
            if (workout.step.durationValue != null && DEBUG == false &&
                remainingTime >= 0) {
              remainingTime =
                  (workout.step.durationValue - stepTime).toNumber();
              if (shouldDisplayAlert && remainingTime < 20) {
                shouldDisplayAlert = false;
              }
            }
          }
        } else {
          stepType = 99;
          shouldDisplayAlert = false;
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
        if (switchCounter > 1) {
          if (switchMetric == 0) {
            switchMetric = 1;
          } else if (switchMetric == 1) {
            switchMetric = 2;
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

          if (stepType == 99) {
            var i = 1;
            var condition = true;
            while (currentPower != 0 && i < pwrZones.size() && condition) {
              if (usePercentage) {
                condition = currentPower >= pwrZones[i];
              } else {
                condition =
                    currentPower >=
                    (((pwrZones[i] * 1.0 * FTP) / 100) + 0.5).toNumber();
              }
              currentPwrZone = i;
              i++;
            }
            if (usePercentage) {
              targetHigh = pwrZones[currentPwrZone - 1].toNumber() + "%-" +
                           pwrZones[currentPwrZone].toNumber() + "%";
            } else {
              targetHigh =
                  (((pwrZones[currentPwrZone - 1] * 1.0 * FTP) / 100) + 0.5)
                      .toNumber() +
                  "-" +
                  (((pwrZones[currentPwrZone] * 1.0 * FTP) / 100) + 0.5)
                      .toNumber();
            }
            targetLow = "Zone " + pwrZonesLabels[currentPwrZone];
          }

          if (currentPower != null) {
            for (var i = powerAverage - 1; i > 0; --i) {
              currentPowerAverage[i] = currentPowerAverage[i - 1];
            }

            currentPowerAverage[0] = currentPower;

            if (stepPower == null) {
              stepPower = currentPower;
            } else if (stepTime != 0) {
              stepPower = (((stepPower * (stepTime - 1)) + currentPower) /
                           (stepTime * 1.0));
            }

            if (Activity.getActivityInfo().currentSpeed != null) {
              if (stepSpeed == null) {
                stepSpeed = Activity.getActivityInfo().currentSpeed;
              } else if (stepTime > 5) {
                stepSpeed = (((stepSpeed * (stepTime - 1)) +
                              Activity.getActivityInfo().currentSpeed) /
                             (stepTime * 1.0));
              }
            }

            if (stepType == 1 && remainingDistance < 100 &&
                remainingDistanceSpeed == -1 && stepSpeed != null &&
                stepSpeed != 0) {
              remainingDistanceSpeed = (15 * stepSpeed).toNumber();
            }

            var tempAverage = 0;
            var entries = powerAverage;

            for (var i = 0; i < powerAverage; ++i) {
              if (currentPowerAverage[i] != null) {
                tempAverage += currentPowerAverage[i];
              } else {
                entries -= 1;
              }
            }

            currentPower =
                ((tempAverage * 1.0 / entries * 1.0) + 0.5).toNumber();

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
                      targetHigh, targetLow, currentPower));
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
    dc.setAntiAlias(true);

    var singleField =
        dc.getWidth() == geometry[0] && dc.getHeight() == geometry[0];

    if (getBackgroundColor() == 0x000000) {
      dc.setColor(0xFFFFFF, -1);
    } else {
      dc.setColor(0x000000, -1);
    }

    if (currentPower != null) {
      if (stepType == 99) {
        if (showColors == 1) {
          dc.setColor(pwrZonesColors[currentPwrZone], -1);
          dc.fillRectangle(0, 0, singleField ? geometry[0] : dc.getWidth(),
                           singleField ? geometry[2] : dc.getHeight());
          dc.setColor(0xFFFFFF, -1);
        } else if (showColors == 2) {
          dc.setColor(pwrZonesColors[currentPwrZone], -1);
        }
      } else if (targetHigh != 0 && targetLow != 0) {
        if (showColors == 1) {
          if (currentPower < targetLow) {
            dc.setColor(0x0000FF, -1);
          } else if (currentPower > targetHigh) {
            dc.setColor(0xAA0000, -1);
          } else {
            dc.setColor(0x00AA00, -1);
          }
          dc.fillRectangle(0, 0, singleField ? geometry[0] : dc.getWidth(),
                           singleField ? geometry[2] : dc.getHeight());
          dc.setColor(0xFFFFFF, -1);
        } else if (showColors == 2) {
          if (currentPower < targetLow) {
            dc.setColor(0x0000FF, -1);
          } else if (currentPower > targetHigh) {
            dc.setColor(0xAA0000, -1);
          } else {
            dc.setColor(0x00AA00, -1);
          }
        }
      }
    }

    if (singleField) {
      dc.drawText(stepType == 99 ? 25 : geometry[12],
                  geometry[2] - geometry[10], fonts[2], targetLow, 2);
      dc.drawText(
          stepType == 99 ? geometry[0] - 25 : geometry[0] - geometry[12],
          geometry[2] - geometry[10], fonts[2], targetHigh, 0);
      dc.drawText(geometry[1] + 2,
                  stepType == 99 ? 0 + (fontOffset * 4) : 0 + 15 + fontOffset,
                  fonts[4], currentPower == null ? 0 : currentPower, 1);
    } else {
      var ratio = ((dc.getHeight() / (geometry[0] * 1.0)) * 10).toNumber() + 1;

      var labely = (dc.getHeight() / 40) + (fontOffset);
      var y = (dc.getHeight() / 2) + (dc.getHeight() / 15) - (fontOffset);
      var x = dc.getWidth() / 2;
      var align = 1;

      if (DataField.getObscurityFlags() & OBSCURE_TOP) {
        labely = dc.getHeight() - 10 - (dc.getHeight() / 4) + (fontOffset);
        y = (dc.getHeight() / 2) - dc.getHeight() / 12 + fontOffset;
      }

      if (DataField.getObscurityFlags() == 1 ||
          DataField.getObscurityFlags() == 3 ||
          DataField.getObscurityFlags() == 9) {
        x = dc.getWidth() - 5;
        align = 0;
      } else if (DataField.getObscurityFlags() == 4 ||
                 DataField.getObscurityFlags() == 6 ||
                 DataField.getObscurityFlags() == 12) {
        x = 5;
        align = 2;
      }

      if (DataField.getObscurityFlags() == 3 ||
          DataField.getObscurityFlags() == 6 ||
          DataField.getObscurityFlags() == 9 ||
          DataField.getObscurityFlags() == 12) {
          ratio -= 1;
                    dc.drawText(x, labely, fonts[ratio - 4 > 0 ? ratio - 4 : 0],
                  targetLow, align);
                                      dc.drawText(x, labely + 15, fonts[ratio - 4 > 0 ? ratio - 4 : 0],
                  targetHigh, align);
      } else {
            dc.drawText(x, labely, fonts[ratio - 3 > 0 ? ratio - 3 : 0],
                  targetLow + " - " + targetHigh, align);

      }
      dc.drawText(x, y, fonts[ratio < 7 ? ratio : 6],
                  currentPower == null ? 0 : currentPower, 4 | align);
      // smaller datafield

    }

    if (stepType == 99) {
      targetHigh = 0;
      targetLow = 0;
    }

    if (singleField) {
      if (getBackgroundColor() == 0x000000) {
        dc.setColor(0xFFFFFF, -1);
      } else {
        dc.setColor(0x000000, -1);
      }

      if (hr != null) {
        if (showColors == 1) {
          if (hr > hrZones[4]) {
            dc.setColor(0xFF0000, -1);
          } else if (hr > hrZones[3]) {
            dc.setColor(0xFF5500, -1);
          } else if (hr > hrZones[2]) {
            dc.setColor(0x00AA00, -1);
          } else if (hr > hrZones[1]) {
            dc.setColor(0x0000FF, -1);
          } else {
            dc.setColor(0x555555, -1);
          }
          dc.fillRectangle(geometry[6], geometry[3], geometry[5], geometry[11]);
          dc.setColor(0xFFFFFF, -1);
        } else if (showColors == 2) {
          if (hr > hrZones[4]) {
            dc.setColor(0xFF0000, -1);
          } else if (hr > hrZones[3]) {
            dc.setColor(0xFF5500, -1);
          } else if (hr > hrZones[2]) {
            dc.setColor(0x00AA00, -1);
          } else if (hr > hrZones[1]) {
            dc.setColor(0x0000FF, -1);
          } else {
            dc.setColor(0x555555, -1);
          }
        }
      }
      dc.drawText(geometry[6] + 3, geometry[3] + fontOffset, fonts[0], "HR", 2);
      dc.drawText(geometry[6] + 3, geometry[3] + (fontOffset * 5) + 15,
                  fonts[3], hr == null ? 0 : hr, 2);

      if (getBackgroundColor() == 0x000000) {
        dc.setColor(0xFFFFFF, -1);
      } else {
        dc.setColor(0x000000, -1);
      }

      if (stepPower != null) {
        if (stepType != 99 && targetHigh != 0 && targetLow != 0) {
          if (showColors == 1) {
            if (stepPower.toNumber() < targetLow) {
              dc.setColor(0x0000FF, -1);
            } else if (stepPower.toNumber() > targetHigh) {
              dc.setColor(0xAA0000, -1);
            } else {
              dc.setColor(0x00AA00, -1);
            }
            dc.fillRectangle(geometry[5], geometry[2],
                             geometry[6] - geometry[5], geometry[11]);
            dc.setColor(0xFFFFFF, -1);
          } else if (showColors == 2) {
            if (stepPower.toNumber() < targetLow) {
              dc.setColor(0x0000FF, -1);
            } else if (stepPower.toNumber() > targetHigh) {
              dc.setColor(0xAA0000, -1);
            } else {
              dc.setColor(0x00AA00, -1);
            }
          }
        }
      }
      dc.drawText(geometry[13], geometry[2] + fontOffset, fonts[0], "Step Pwr",
                  1);
      dc.drawText(geometry[13], geometry[2] + (fontOffset * 5) + 15, fonts[3],
                  stepPower == null ? 0 : stepPower.toNumber(), 1);

      if (getBackgroundColor() == 0x000000) {
        dc.setColor(0xFFFFFF, -1);
      } else {
        dc.setColor(0x000000, -1);
      }

      if (getBackgroundColor() == 0x000000) {
        dc.setColor(0xFFFFFF, -1);
      } else {
        dc.setColor(0x000000, -1);
      }

      dc.drawText(geometry[6] + 3, geometry[2] + fontOffset, fonts[0],
                  "Cadence", 2);
      dc.drawText(geometry[6] + 3, geometry[2] + (fontOffset * 5) + 15,
                  fonts[3], cadence == null ? 0 : cadence, 2);

      dc.drawText(5, geometry[2] + fontOffset, fonts[0], "Pace", 2);
      dc.drawText(
          geometry[5] - 3, geometry[2] + (fontOffset * 5) + 15, fonts[3],
          Activity.getActivityInfo().currentSpeed == null
              ? 0
              : convert_speed_pace(Activity.getActivityInfo().currentSpeed),
          0);
      if (showExtra) {
        if (useMetric) {
          dc.drawText(geometry[5] - 3, geometry[2] + fontOffset, fonts[0],
                      "min/km", 0);
        } else {
          dc.drawText(geometry[5] - 5, geometry[2] + fontOffset, fonts[0],
                      "min/mi", 0);
        }
      }

      dc.drawText(geometry[13], geometry[3] + fontOffset, fonts[0], "El. Time",
                  1);
      dc.drawText(geometry[13], geometry[3] + (fontOffset * 5) + 15, fonts[3],
                  format_duration(timer), 1);

      var lLocalDistance =
          Activity.getActivityInfo().elapsedDistance == null
              ? format_distance(0)
              : format_distance(Activity.getActivityInfo().elapsedDistance);

      dc.drawText(5, geometry[3] + fontOffset, fonts[0], "Distance", 2);
      if (lLocalDistance[2] == null) {
        dc.drawText(geometry[5] - 3, geometry[3] + (fontOffset * 5) + 15,
                    fonts[3], lLocalDistance[0], 0);
      } else {
        dc.drawText(geometry[5] - 3, geometry[3] + 20 + (fontOffset * 2),
                    fonts[2], lLocalDistance[2], 0);
        dc.drawText(geometry[5] - geometry[10] + 4 + fontOffset,
                    geometry[3] + (fontOffset * 5) + 15, fonts[3],
                    lLocalDistance[0], 0);
      }
      if (showExtra) {
        dc.drawText(geometry[5] - 3, geometry[3] + fontOffset, fonts[0],
                    lLocalDistance[1], 0);
      }

      var lMetricLabel = "";
      var lMetricValue = "";
      if (switchMetric == 2 || ((remainingDistance == 0 ||
                                 remainingDistance > remainingDistanceSpeed) &&
                                (remainingTime == 0 || remainingTime > 15))) {
        if (stepType == 5) {
          lMetricLabel = "Until";
          lMetricValue = "Lap Press";
        } else if (stepType == 99) {
          lMetricLabel = "Lap Time";
          lMetricValue = "" + format_duration(lapTime);
        } else if (stepType == 1) {
          var distance = format_distance(remainingDistance);
          lMetricLabel = "Rem. Dist";
        lMetricValue = "" + distance[0] + (distance[2] == null ? "" : distance[2]) + distance[1];
        } else {
          lMetricLabel = "Rem. Time";
          lMetricValue = "" + format_duration(remainingTime);
        }
      } else {
        lMetricLabel = "Next step";
        if (switchMetric == 0) {
          lMetricValue = nextTargetLow + "-" + nextTargetHigh;
        } else {
          if (nextTargetType == 5) {
            lMetricValue = "Lap Press";
          } else if (nextTargetType == 1) {
            var distance = format_distance(nextTargetDuration * 1.0);
            lMetricValue = distance[0] + (distance[2] == null ? "" : distance[2]) + distance[1];
          } else {
            lMetricValue = format_duration(nextTargetDuration.toNumber());
          }
        }
      }

      dc.drawText(geometry[1], geometry[4] + fontOffset, fonts[0], lMetricLabel,
                  1);
      dc.drawText(geometry[1], geometry[4] + (fontOffset * 5) + 15, fonts[3],
                  lMetricValue, 1);

      dc.setPenWidth(1);

      //! Horizontal seperators
      dc.drawLine(0, geometry[2], geometry[0], geometry[2]);
      dc.drawLine(0, geometry[3], geometry[0], geometry[3]);
      dc.drawLine(0, geometry[4], geometry[0], geometry[4]);

      //! vertical seperators
      dc.drawLine(geometry[5], geometry[2], geometry[5], geometry[4]);
      dc.drawLine(geometry[6], geometry[2], geometry[6], geometry[4]);

      //! The following code to draw the gauge is copied and adapted from
      //! Ravenfeld - Speed Gauge
      //! https://github.com/ravenfeld/Connect-IQ-DataField-Speed

      if (stepType != 99) {
        dc.setPenWidth(10);
        dc.setColor(0xFF0000, getBackgroundColor());
        dc.drawArc(geometry[1], geometry[1], geometry[7], 0, 30, 60);

        dc.setColor(0x00AAFF, getBackgroundColor());
        dc.drawArc(geometry[1], geometry[1], geometry[7], 0, 120, 150);

        dc.setColor(0x00FF00, getBackgroundColor());
        dc.drawArc(geometry[1], geometry[1], geometry[7], 0, 60, 120);

        if (getBackgroundColor() == 0x000000) {
          dc.setColor(0xFFFFFF, getBackgroundColor());
        } else {
          dc.setColor(0x000000, getBackgroundColor());
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
            percent = 0.15;
          }
          if (percent > 0.85) {
            percent = 0.85;
          }
        }

        var orientation = -Math.PI * percent - 3 * Math.PI / 2;
        var radius = geometry[9];
        var xy1 = pol2Cart(geometry[1], geometry[1], orientation, geometry[8]);
        var xy2 = pol2Cart(geometry[1], geometry[1],
                           orientation - 5 * Math.PI / 180, geometry[8]);
        var xy3 = pol2Cart(geometry[1], geometry[1],
                           orientation - 5 * Math.PI / 180, geometry[9]);
        var xy4 = pol2Cart(geometry[1], geometry[1], orientation, geometry[9]);
        dc.fillPolygon([ xy1, xy2, xy3, xy4 ]);
      }
    }
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
      var formatted = ((distance * 1.0) / (factor * 1.0)).format("%.2f");
      var index = formatted.find(".");
      if (index != null && showSmallDecimals) {
        return [
          formatted.substring(0, index), unit,
          formatted.substring(index, formatted.length())
        ];
      } else {
        return [ formatted, unit, null ];
      }
    } else {
      return [
        (distance / factor * smallunitfactor).toNumber() + "", smallunit,
        null
      ];
    }
  }
}
