using Toybox.WatchUi;
using Toybox.Attention;
using Toybox.UserProfile;
using Toybox.AntPlus;
using Toybox.System as Sys;

class RunPowerWorkoutView extends WatchUi.DataField {
  (:highmem) hidden var alternativeLayout;
  (:highmem) hidden var alternativeLayoutCounter = 0;
  (:highmem) hidden var altitude = 0;
  (:highmem) hidden var altitudeArray = new [arrayAltPrecision];
  (:highmem) hidden var arrayAltPointer = 0;
  (:highmem) hidden var arrayAltPrecision = 5;
  (:highmem) hidden var autoAlternate;
  (:highmem) hidden var bottomMetric;
  (:highmem) hidden var etaDistance = 0;
  (:highmem) hidden var etaElevation = 0;
  (:highmem) hidden var etaPower = 0;
  (:highmem) hidden var etaSpeed = 0;
  (:highmem) hidden var fieldsAlt;
  (:highmem) hidden var lapStartDistance;
  (:highmem) hidden var switchAlternativeLayout = 0;
  (:highmem) hidden var topMetric;
  (:highmem) hidden var totalAscent = 0;
  (:highmem) hidden var totalDescent = 0;
  (:highmem) hidden var useAlternativeLayout;
  (:highmem) hidden var verticalSpeed = 0;
  (:highmem) hidden var weight = 100;
  (:noworkout) hidden var inAlert = false;
  (:noworkout) hidden var targetZone = 0;
  (:noworkout) hidden var targetZoneHigh = 0;
  (:noworkout) hidden var targetZoneLow = 0;
  (:workout) hidden var nextTargetDuration;
  (:workout) hidden var nextTargetHigh;
  (:workout) hidden var nextTargetLow;
  (:workout) hidden var nextTargetType;
  (:workout) hidden var remainingDistance = 0;
  (:workout) hidden var remainingDistanceSpeed = -1;
  (:workout) hidden var remainingTime = 0;
  (:workout) hidden var stepPower = null;
  (:workout) hidden var stepSpeed = null;
  (:workout) hidden var stepStartDistance = 0;
  (:workout) hidden var stepStartTime = 0;
  (:workout) hidden var stepTime = 0;
  hidden var alertCount = 0;
  hidden var alertDelay = 10;
  hidden var alertDisplayed = false;
  hidden var alertTimer;
  hidden var avgPower = 0;
  hidden var avgSpeed = 0;
  hidden var cadence = 0;
  hidden var currentPower = 0;
  hidden var currentPowerAverage;
  hidden var currentPwrZone = 1;
  hidden var currentSpeed = 0;
  hidden var elapsedDistance = 0;
  hidden var fields;
  hidden var fontOffset = 0;
  hidden var fonts;
  hidden var FTP;
  hidden var hr = 0;
  hidden var hrZones;
  hidden var keepLast;
  hidden var lapPower = null;
  hidden var lapSpeed = null;
  hidden var lapStartTime = 0;
  hidden var lapTime = 0;
  hidden var layout;
  hidden var maxAlerts = 3;
  hidden var paused = true;
  hidden var powerAverage;
  hidden var pwrZones;
  hidden var pwrZonesColors;
  hidden var pwrZonesLabels;
  hidden var sensor;
  hidden var shouldDisplayAlert;
  hidden var showAlerts;
  hidden var showColors;
  hidden var showSmallDecimals;
  hidden var stepType = 99;
  hidden var switchCounter = 0;
  hidden var switchMetric = 0;
  hidden var targetHigh = 0;
  hidden var targetLow = 0;
  hidden var timer = 0;
  hidden var useMetric;
  hidden var usePercentage;
  hidden var useSpeed;
  hidden var vibrate;

  // [ Width, Center, 1st horizontal line, 2nd horizontal line
  // 3rd Horizontal line, 1st vertical, Second vertical, Radius,
  // Top Arc, Bottom Arc, Offset Target Y, Background rect height, Offset Target
  // X, Center mid field ]

  (:roundzero) const geometry =
      [ 218, 109, 77, 122, 167, 70, 161, 103, 114, 85, 27, 45, 30, 116 ];
  (:roundone) const geometry =
      [ 240, 120, 85, 135, 185, 77, 177, 105, 114, 96, 32, 50, 40, 127 ];
  (:roundtwo) const geometry =
      [ 260, 130, 91, 146, 201, 83, 192, 115, 124, 106, 37, 55, 45, 138 ];
  (:roundthree) const geometry =
      [ 280, 140, 98, 157, 216, 90, 207, 125, 134, 116, 42, 59, 50, 149 ];
  (:roundfour) const geometry =
      [ 390, 195, 140, 220, 300, 125, 289, 180, 189, 171, 45, 80, 55, 207 ];
  (:roundfive) const geometry =
      [ 360, 180, 127, 202, 277, 115, 266, 165, 174, 156, 50, 75, 52, 191 ];
  (:roundsix) const geometry =
      [ 416, 208, 147, 234, 320, 133, 308, 193, 202, 187, 55, 87, 60, 221 ];
  (:roundseven) const geometry =
      [ 208, 104, 73, 114, 158, 66, 152, 98, 109, 81, 25, 43, 27, 111 ];

  function initialize(strydsensor) {
    // read settings
    usePercentage = Utils.replaceNull(
        Application.getApp().getProperty("A"), false);
    FTP = Utils.replaceNull(Application.getApp().getProperty("B"), 330);
    showAlerts =
        Utils.replaceNull(Application.getApp().getProperty("C"), true);
    vibrate =
        Utils.replaceNull(Application.getApp().getProperty("D"), true);
    powerAverage =
        Utils.replaceNull(Application.getApp().getProperty("E"), 3);
    showColors =
        Utils.replaceNull(Application.getApp().getProperty("F"), 1);
    layout =
        Utils.replaceNull(Application.getApp().getProperty("M"), 3);

    alertDelay =
        Utils.replaceNull(Application.getApp().getProperty("AA"), 15);

    maxAlerts =
        Utils.replaceNull(Application.getApp().getProperty("AB"), 3);

    useMetric = System.getDeviceSettings().paceUnits == System.UNIT_METRIC
                    ? true
                    : false;

    useSpeed = Utils.replaceNull(Application.getApp().getProperty("V"), false);

    keepLast = Utils.replaceNull(Application.getApp().getProperty("Z"), false);

    showSmallDecimals = Utils.replaceNull(
        Application.getApp().getProperty("H"), true);

    set_fonts();
    set_layout();

    DataField.initialize();
    var zones = Utils.replaceNull(Application.getApp().getProperty("G"), 4);
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
    setupValues(strydsensor);
  }

  (:workout)
  function setupValues(strydsensor){
    hrZones = UserProfile.getHeartRateZones(UserProfile.HR_ZONE_SPORT_GENERIC);
    currentPowerAverage = new[powerAverage];
    sensor = strydsensor;
  }

  (:noworkout)
  function setupValues(strydsensor){

    hrZones = UserProfile.getHeartRateZones(UserProfile.HR_ZONE_SPORT_GENERIC);
    currentPowerAverage = new[powerAverage];
    sensor = strydsensor;
    targetZone = Utils.replaceNull(Application.getApp().getProperty("W"), 0);

    if(targetZone > 0 && targetZone < pwrZones.size()){
      if (usePercentage) {
        targetZoneLow = pwrZones[targetZone - 1].toNumber();
        targetZoneHigh = pwrZones[targetZone].toNumber();
      } else {
        targetZoneLow = (((pwrZones[targetZone - 1] * 1.0 * FTP) / 100) + 0.5).toNumber();
        targetZoneHigh = (((pwrZones[targetZone] * 1.0 * FTP) / 100) + 0.5).toNumber();
      }
    }
  }

  function onTimerStart() { paused = false; }

  function onTimerStop() { paused = true; }

  function onTimerResume() { paused = false; }

  function onTimerPause() { paused = true; }

  (:highmem)
  function onTimerLap() {
    lapTime = 0;
    lapStartTime = timer;
    lapStartDistance = Activity.getActivityInfo().elapsedDistance;
    lapPower = null;
    lapSpeed = null;
  }

  (:lowmem)
  function onTimerLap() {
    lapTime = 0;
    lapStartTime = timer;
    lapPower = null;
    lapSpeed = null;
  }

  (:workout)
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
    if(Activity.getNextWorkoutStep() == null){
      lapStartTime = timer;
      if(self has :lapStartDistance){
        lapStartDistance = Activity.getActivityInfo().elapsedDistance;
      } 
    }
  }

  (:workout)
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
    elapsedDistance = 0;
  }

  (:noworkout)
  function onTimerReset() {
    lapTime = 0;
    lapStartTime = timer;
    alertCount = 0;
    alertDisplayed = false;
    elapsedDistance = 0;
  }

  (:highmem) function set_fonts() {
    if (Utils.replaceNull(Application.getApp().getProperty("I"), true)) {
      fontOffset = -4;
      fonts = [
        WatchUi.loadResource(Rez.Fonts.A), WatchUi.loadResource(Rez.Fonts.C),
        WatchUi.loadResource(Rez.Fonts.C), WatchUi.loadResource(Rez.Fonts.D),
        WatchUi.loadResource(Rez.Fonts.E), WatchUi.loadResource(Rez.Fonts.F)
      ];
    } else {
      fonts = [ 0, 1, 2, 3, 6, 8 ];
    }
  }

  (:lowmemreg) function set_fonts() { fonts = [ 0, 1, 2, 3, 6, 8 ]; }

  (:lowmemlarge) function set_fonts() {
    fontOffset = 2;
    fonts = [ 0, 1, 2, 3, 6, 8 ];
  }

  (:lowmemlow) function set_fonts() {
    fontOffset = -1;
    fonts = [ 0, 1, 2, 3, 5, 7 ];
  }

  (:highmem) function set_layout() {
    fields = [
      Utils.replaceNull(Application.getApp().getProperty("N1"), 51).toChar(),
      Utils.replaceNull(Application.getApp().getProperty("N2"), 54).toChar(),
      Utils.replaceNull(Application.getApp().getProperty("N3"), 56).toChar(),
      Utils.replaceNull(Application.getApp().getProperty("N4"), 50).toChar(),
      Utils.replaceNull(Application.getApp().getProperty("N5"), 48).toChar(),
      Utils.replaceNull(Application.getApp().getProperty("N6"), 49).toChar()
    ];

    fieldsAlt = [
      Utils.replaceNull(Application.getApp().getProperty("O1"), 51).toChar(),
      Utils.replaceNull(Application.getApp().getProperty("O2"), 54).toChar(),
      Utils.replaceNull(Application.getApp().getProperty("O3"), 56).toChar(),
      Utils.replaceNull(Application.getApp().getProperty("O4"), 50).toChar(),
      Utils.replaceNull(Application.getApp().getProperty("O5"), 48).toChar(),
      Utils.replaceNull(Application.getApp().getProperty("O6"), 49).toChar()
    ];

    useAlternativeLayout = Utils.replaceNull(Application.getApp().getProperty("P"), false);
    autoAlternate = Utils.replaceNull(Application.getApp().getProperty("Q"), false);
    alternativeLayout = Utils.replaceNull(Application.getApp().getProperty("R"), 3);
    etaDistance = Utils.replaceNull(Application.getApp().getProperty("S"), 5000);
    etaElevation = Utils.replaceNull(Application.getApp().getProperty("T"), 0);
    weight = Utils.replaceNull(Application.getApp().getProperty("U"), 100);
    topMetric = Utils.replaceNull(Application.getApp().getProperty("X"), 1);
    bottomMetric = Utils.replaceNull(Application.getApp().getProperty("Y"), 1);
    lapStartDistance = 0;
  }

  (:lowmemreg) function set_layout() {
    fields = Utils.replaceNull(Application.getApp().getProperty("N"), "368201").toCharArray();
  }

  (:lowmemlow) function set_layout() {
    fields = Utils.replaceNull(Application.getApp().getProperty("N"), "368201").toCharArray();
  }

  (:lowmemlarge) function set_layout() {
    fields = Utils.replaceNull(Application.getApp().getProperty("N"), "368201").toCharArray();
  }

  function onLayout(dc) { }

  (:noworkout)
  function compute(info) {
    if (info has :currentCadence) {
      cadence = info.currentCadence;
    }
    if (info has :currentHeartRate) {
      hr = info.currentHeartRate;
    }

    if (info has :currentPower) {
      currentPower = info.currentPower;
    } else if(sensor != null){
      currentPower = sensor.currentPower;
    }

    if (info has :currentSpeed) {
      currentSpeed = info.currentSpeed;
    }

    if (usePercentage && currentPower != null) {
      currentPower =
          ((currentPower / (FTP * 1.0)) * 100).toNumber();
    }

    if (paused != true) {
      if (info != null) {
        timer = info.timerTime / 1000;
        lapTime = timer - lapStartTime;
        elapsedDistance = info.elapsedDistance;

        shouldDisplayAlert = (lapTime > alertDelay);

        stepType = 99;

        if (currentPower != null || sensor != null) {
          if (stepType >= 98) {
            var i = 1;
            var condition = true;
            while (currentPower != null && currentPower != 0 && i < pwrZones.size() && condition) {
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
            targetLow = "ZONE " + pwrZonesLabels[currentPwrZone];
          }

          if (currentSpeed != null) {
            if (lapSpeed == null) {
              lapSpeed = currentSpeed;
            } else if (lapTime > 5) {
              lapSpeed = ((lapSpeed * (lapTime - 1)) + currentSpeed) / (lapTime * 1.0);
            }
            if (avgSpeed == 0) {
              avgSpeed = currentSpeed;
            } else if (lapTime > 5) {
              avgSpeed = ((avgSpeed * (timer - 1)) + currentSpeed) / (timer * 1.0);
            }
          }

          if (currentPower != null) {
            for (var i = powerAverage - 1; i > 0; --i) {
              currentPowerAverage[i] = currentPowerAverage[i - 1];
            }

            currentPowerAverage[0] = currentPower;

            if (lapPower == null) {
              lapPower = currentPower;
            } else if (lapTime != 0) {
              lapPower = (((lapPower * (lapTime - 1)) + currentPower) / (lapTime * 1.0));
            }

           if (avgPower == 0) {
              avgPower = currentPower;
            } else if (lapTime != 0) {
              avgPower = (((avgPower * (timer - 1)) + currentPower) / (timer * 1.0));
            }

            var tempAverage = 0;
            var entries = powerAverage;

            for (var i = 0; i < powerAverage; ++i) {
              if (currentPowerAverage[i] != null){
                tempAverage += currentPowerAverage[i];
              } else {
                entries -= 1;
              }
            }
            currentPower = ((tempAverage * 1.0 / entries * 1.0) + 0.5).toNumber();
          } else {
            currentPower = 0;
          }

          // Show an alert if above of below
          if (shouldDisplayAlert) {
            if ((currentPower != null && (targetZoneHigh > 0) &&
                 (currentPower < targetZoneLow || currentPower > targetZoneHigh))) {
              if (alertDisplayed == false) {
                if (alertCount < maxAlerts) {
                  if (Attention has :vibrate && vibrate) {
                    Attention.vibrate([
                      new Attention.VibeProfile(100, 300),
                      new Attention.VibeProfile(0, 50),
                      new Attention.VibeProfile(100, 300),
                      new Attention.VibeProfile(0, 50),
                      new Attention.VibeProfile(100, 300)
                    ]);
                  }
                  alertDisplayed = true;
                  inAlert = true;
                  alertTimer = timer;
                  alertCount++;
                }
              } else {
                if(inAlert){
                  if ((timer - alertTimer) > 3){
                    inAlert = false;
                    alertTimer = timer;
                  }
                } else if ((timer - alertTimer) > alertDelay) {
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

    processExtraData(info);

    return true;
  }

  (:workout)
  function compute(info) {
    if (info has :currentCadence) {
      cadence = info.currentCadence;
    }
    if (info has :currentHeartRate) {
      hr = info.currentHeartRate;
    }

    if (info has :currentPower) {
      currentPower = info.currentPower;
    } else if(sensor != null){
      currentPower = sensor.currentPower;
    }

    if (info has :currentSpeed) {
      currentSpeed = info.currentSpeed;
    }

    if (usePercentage && currentPower != null) {
      currentPower =
          ((currentPower / (FTP * 1.0)) * 100).toNumber();
    }

    if (paused != true) {
      if (info != null) {

        var workout = Activity.getCurrentWorkoutStep();

        timer = info.timerTime / 1000;
        stepTime = timer - stepStartTime;
        lapTime = timer - lapStartTime;
        elapsedDistance = info.elapsedDistance;



        shouldDisplayAlert = (stepTime > alertDelay);

        if (workout != null) {

          var nextWorkout = Activity.getNextWorkoutStep();

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
              nextTargetHigh = (((nextTargetHigh / (FTP * 1.0)) * 100) + 0.5).toNumber();
              nextTargetLow = (((nextTargetLow / (FTP * 1.0)) * 100) + 0.5).toNumber();
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
            if(!keepLast || nextTargetHigh == null || nextTargetLow == null){
              nextTargetHigh = 0;
              nextTargetLow = 0;
            }
            nextTargetType = 5;
            nextTargetDuration = 0;
          }

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
            targetHigh = (((targetHigh / (FTP * 1.0)) * 100) + 0.5).toNumber();
            targetLow = (((targetLow / (FTP * 1.0)) * 100) + 0.5).toNumber();
          }

          if (workout.step.targetType != null &&
              workout.step.durationType == 5) {
            stepType = (targetHigh > 0 && targetLow > 0) ? 5 : 98;
          } else if (workout.step.targetType != null &&
                     workout.step.durationType == 1) {

            stepType = (targetHigh > 0 && targetLow > 0) ? 1 : 98;
            if (workout.step.durationValue != null && elapsedDistance != null && remainingDistance >= 0) {
              remainingDistance = workout.step.durationValue -
                                  (elapsedDistance.toNumber() -
                                   stepStartDistance);
              if (shouldDisplayAlert &&
                  remainingDistance < remainingDistanceSpeed) {
                shouldDisplayAlert = false;
              }
            }
          } else {
            stepType = (targetHigh > 0 && targetLow > 0) ? 0 : 98;
            if (workout.step.durationValue != null &&
                remainingTime >= 0) {
              remainingTime =
                  (workout.step.durationValue - stepTime).toNumber();
              if (shouldDisplayAlert && remainingTime < 20) {
                shouldDisplayAlert = false;
              }
            }
          }
        } else {
          if(keepLast && nextTargetLow != null && nextTargetHigh != null){
            stepType = 5;
            targetHigh = nextTargetHigh;
            targetLow = nextTargetLow;
          } else{
            stepType = 99;
            shouldDisplayAlert = false;
          }
        }

        switchCounter++;
        if (switchCounter > 1) {
          switchMetric = (switchMetric + 1 ) % 3;
          switchCounter = 0;
        }

        if (currentPower != null || sensor != null) {
          if (currentSpeed != null) {
            if (stepSpeed == null) {
              stepSpeed = currentSpeed;
            } else if (stepTime > 5) {
              stepSpeed = ((stepSpeed * (stepTime - 1)) + currentSpeed) / (stepTime * 1.0);
            }
            if (lapSpeed == null) {
              lapSpeed = currentSpeed;
            } else if (lapTime > 5) {
              lapSpeed = ((lapSpeed * (lapTime - 1)) + currentSpeed) / (lapTime * 1.0);
            }
            if (avgSpeed == 0) {
              avgSpeed = currentSpeed;
            } else if (lapTime > 5) {
              avgSpeed = ((avgSpeed * (timer - 1)) + currentSpeed) / (timer * 1.0);
            }
          }

          if (currentPower != null) {
            for (var i = powerAverage - 1; i > 0; --i) {
              currentPowerAverage[i] = currentPowerAverage[i - 1];
            }

            currentPowerAverage[0] = currentPower;

            if (stepPower == null) {
              stepPower = currentPower;
            } else if (stepTime != 0) {
              stepPower = ((((stepPower * (stepTime - 1)) + currentPower) * 1.0) / (stepTime * 1.0));
            }

            if (lapPower == null) {
              lapPower = currentPower;
            } else if (lapTime != 0) {
              lapPower = (((lapPower * (lapTime - 1)) + currentPower) / (lapTime * 1.0));
            }

           if (avgPower == 0) {
              avgPower = currentPower;
            } else if (timer != 0) {
              avgPower = (((avgPower * (timer - 1)) + currentPower) / (timer * 1.0));
            }

            if (stepType == 1 && remainingDistance < 100 &&
                remainingDistanceSpeed == -1 && stepSpeed != null &&
                stepSpeed != 0) {
              remainingDistanceSpeed = (15 * stepSpeed).toNumber();
            }

            var tempAverage = 0;
            var entries = powerAverage;

            for (var i = 0; i < powerAverage; ++i) {
              if (currentPowerAverage[i] != null){
                tempAverage += currentPowerAverage[i];
              } else {
                entries -= 1;
              }
            }

            currentPower = ((tempAverage * 1.0 / entries * 1.0) + 0.5).toNumber();
          } else {
            currentPower = 0;
          }

          if (stepType >= 98) {
            var i = 1;
            var condition = true;
            while (currentPower != null && currentPower != 0 && i < pwrZones.size() && condition) {
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
            targetLow = "ZONE " + pwrZonesLabels[currentPwrZone];
          }


          // Show an alert if above of below
          if (WatchUi.DataField has
              :showAlert && showAlerts && shouldDisplayAlert) {
            if (stepType < 98 &&
                (currentPower != null && (targetLow != 0 && targetHigh != 0) &&
                 (currentPower < targetLow || currentPower > targetHigh))) {
              if (alertDisplayed == false) {
                if (alertCount < maxAlerts) {
                  if (Attention has :vibrate && vibrate) {
                    Attention.vibrate([
                      new Attention.VibeProfile(100, 300),
                      new Attention.VibeProfile(0, 50),
                      new Attention.VibeProfile(100, 300),
                      new Attention.VibeProfile(0, 50),
                      new Attention.VibeProfile(100, 300)
                    ]);
                  }

                  WatchUi.DataField.showAlert(new RunPowerWorkoutAlertView(
                      targetHigh, targetLow, currentPower,
                      [ fonts[2], fonts[5] ]));
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

    processExtraData(info);

    return true;
  }

  (:workout)
  function onUpdate(dc) {
    if (dc has :setAntiAlias){
      dc.setAntiAlias(true);
    }
    var bgColor = getBackgroundColor();
    var fgColor = bgColor == 0x000000 ? 0xFFFFFF : 0x000000;
    var singleFieldColor = fgColor;

    var width = dc.getWidth();
    var height = dc.getHeight();

    var singleField = width == geometry[0] && height == geometry[0] && layout != 1;

    dc.setColor(fgColor,-1);

    var topField = getTopField();

    if (currentPower != null) {
      if (stepType >= 98) {
        if (showColors == 1) {
          dc.setColor(pwrZonesColors[currentPwrZone], -1);
          dc.fillRectangle(0, 0, singleField ? geometry[0] : width,
                           singleField ? geometry[2] : height);
          dc.setColor(0xFFFFFF, -1);
          singleFieldColor = 0xFFFFFF;
        } else if (showColors == 2) {
          dc.setColor(pwrZonesColors[currentPwrZone], -1);
        }
      } else if (targetHigh != 0 && targetLow != 0) {
        if (showColors == 1) {
          if (topField < targetLow) {
            dc.setColor(0x0000FF, -1);
          } else if (topField > targetHigh) {
            dc.setColor(0xAA0000, -1);
          } else {
            dc.setColor(0x00AA00, -1);
          }
          dc.fillRectangle(0, 0, singleField ? geometry[0] : width,
                           singleField ? geometry[2] : height);
          dc.setColor(0xFFFFFF, -1);
          singleFieldColor = 0xFFFFFF;
        } else if (showColors == 2) {
          if (topField < targetLow) {
            dc.setColor(0x0000FF, -1);
          } else if (topField > targetHigh) {
            dc.setColor(0xAA0000, -1);
          } else {
            dc.setColor(0x00AA00, -1);
          }
        }
      }
    }

    if (singleField) {
      drawTop(dc,topField);
    } else {
      var ratio = (((height / (geometry[0] * 1.0)) * 10) + 1).toNumber();
      var single = false;
      ratio = ratio < 6 ? ratio : 5;
      var labely = (height / 40) + (fontOffset);
      var metriclabely = (height / 7) + (fontOffset);
      var y = (height / 2) + (height / 15) - (fontOffset);
      var x = width / 2;
      var align = 1;
      var obscurityFlags = DataField.getObscurityFlags();

      if (obscurityFlags & OBSCURE_TOP) {
        labely = height - 10 - (height / 4) + (fontOffset);
        y = (height / 2) - height / 12 + fontOffset;
      }

      if(height == geometry[0]){
        single = true;
        y = geometry[1];
      }

      if (obscurityFlags == 1 ||
          obscurityFlags == 3 ||
          obscurityFlags == 9) {
        x = width - 5;
        align = 0;
      } else if (obscurityFlags == 4 ||
                 obscurityFlags == 6 ||
                 obscurityFlags == 12) {
        x = 5;
        align = 2;
      }

      if (obscurityFlags == 3 ||
          obscurityFlags == 6 ||
          obscurityFlags == 9 ||
          obscurityFlags == 12) {
        ratio -= 1;
        dc.drawText(x, labely - 5, fonts[ratio - 3 > 0 ? ratio - 3 : 0],
                    targetLow, align);
        dc.drawText(x, labely + 15, fonts[ratio - 3 > 0 ? ratio - 3 : 0],
                    targetHigh, align);
      } else {
        dc.drawText(x, labely, fonts[ratio - 3 > 0 ? ratio - 3 : 0],
                    targetLow + " - " + targetHigh, align);
      }
      dc.drawText(x, y, fonts[ratio], topField, 4 | align);
      if(single){
        drawMetric(dc,fields[0],0,metriclabely,geometry[0],geometry[11],1,-1,singleFieldColor);
      }
    }

    if (singleField) {

      drawLayout(dc,fgColor,bgColor);

      drawBottom(dc,fgColor,bgColor);

      //! The following code to draw the gauge is copied and adapted from
      //! Ravenfeld - Speed Gauge
      //! https://github.com/ravenfeld/Connect-IQ-DataField-Speed

      if(stepType < 98){
        drawGauge(dc, bgColor);
      }
    }
  }

  // Display the value you computed here. This will be called
  // once a second when the data field is visible.
  (:noworkout)
  function onUpdate(dc) {
    if (dc has :setAntiAlias){
      dc.setAntiAlias(true);
    }

    var width = dc.getWidth();
    var height = dc.getHeight();
    var singleField = width == geometry[0] && height == geometry[0] && layout != 1;

    var topField = getTopField();

    // Alerts are not supported by lower CIQ so we just change the datafield. Will be limited to the datafield though
    if(inAlert && singleField){
      dc.setColor(0xFFFFFF, 0x000000);
      dc.clear();
      dc.setColor(0xFFFFFF, -1);
      dc.drawText(geometry[1], geometry[6], fonts[2], topField < targetZoneLow ? "LOW POWER" : "HIGH POWER", 1);
      dc.drawText(geometry[1], geometry[10], fonts[2],
                  "TGT" + " " + targetZoneLow + "-" +
                      targetZoneHigh,
                  1);
      dc.drawText(geometry[1], geometry[1], fonts[5], topField,
                  4 | 1);
      dc.setColor(topField < targetZoneLow ? 0x00AAFF : 0xFF0000, -1);
      dc.setPenWidth(5);
      dc.drawCircle(geometry[1], geometry[1], geometry[1] - 2);
    } else {
      var bgColor = getBackgroundColor();
      var fgColor = bgColor == 0x000000 ? 0xFFFFFF : 0x000000;
      var singleFieldColor = fgColor;

      dc.setColor(fgColor,-1);

      if (currentPower != null) {
        if (showColors == 1) {
          dc.setColor(pwrZonesColors[currentPwrZone], -1);
          dc.fillRectangle(0, 0, singleField ? geometry[0] : width,
                            singleField ? geometry[2] : height);
          dc.setColor(0xFFFFFF, -1);
          singleFieldColor = 0xFFFFFF;
        } else if (showColors == 2) {
          dc.setColor(pwrZonesColors[currentPwrZone], -1);
        }
      }

      if (singleField) {
        drawTop(dc,topField);
      } else {
        var ratio = (((height / (geometry[0] * 1.0)) * 10) + 1).toNumber();
        var single = false;
        ratio = ratio < 6 ? ratio : 5;
        var labely = (height / 40) + (fontOffset);
        var metriclabely = (height / 7) + (fontOffset);
        var y = (height / 2) + (height / 15) - (fontOffset);
        var x = width / 2;
        var align = 1;
        var obscurityFlags = DataField.getObscurityFlags();

        if (obscurityFlags & OBSCURE_TOP) {
          labely = height - 10 - (height / 4) + (fontOffset);
          y = (height / 2) - height / 12 + fontOffset;
        }

        if(height == geometry[0]){
          single = true;
          y = geometry[1];
        }

        if (obscurityFlags == 1 ||
            obscurityFlags == 3 ||
            obscurityFlags == 9) {
          x = width - 5;
          align = 0;
        } else if (obscurityFlags == 4 ||
                  obscurityFlags == 6 ||
                  obscurityFlags == 12) {
          x = 5;
          align = 2;
        }

        if (obscurityFlags == 3 ||
            obscurityFlags == 6 ||
            obscurityFlags == 9 ||
            obscurityFlags == 12) {
          ratio -= 1;
          dc.drawText(x, labely - 5, fonts[ratio - 3 > 0 ? ratio - 3 : 0],
                      targetLow, align);
          dc.drawText(x, labely + 15, fonts[ratio - 3 > 0 ? ratio - 3 : 0],
                      targetHigh, align);
        } else {
          dc.drawText(x, labely, fonts[ratio - 3 > 0 ? ratio - 3 : 0],
                      targetLow + " - " + targetHigh, align);
        }
        dc.drawText(x, y, fonts[ratio],topField, 4 | align);
        if(single){
          drawMetric(dc,fields[0],0,metriclabely,geometry[0],geometry[11],1,-1,singleFieldColor);
        }
      }

      if (singleField) {

        drawLayout(dc,fgColor,bgColor);

        drawBottom(dc,fgColor,bgColor);

        //! The following code to draw the gauge is copied and adapted from
        //! Ravenfeld - Speed Gauge
        //! https://github.com/ravenfeld/Connect-IQ-DataField-Speed

        if(stepType < 98){
          drawGauge(dc, bgColor);
        }
      }
    }
  }

  (:lowmem)
  function getTopField(){
    return currentPower == null ? 0 : currentPower;
  }

  (:highmem)
  function getTopField(){
      if(topMetric == 2){
        if(stepType >= 98){
           return (lapPower == null ? 0 : (lapPower + 0.5).toNumber());
        } else {
           return (stepPower == null ? 0 : (stepPower + 0.5).toNumber());
        }
      }else{
        return currentPower == null ? 0 : currentPower;
      }
  }

  (:lowmem)
  function drawTop(dc,metric){
      dc.drawText(25, geometry[2] - geometry[10], fonts[2], targetLow, 2);
      dc.drawText(geometry[0] - 25, geometry[2] - geometry[10], fonts[2], targetHigh, 0);
      dc.drawText(geometry[1] + 2,
                  stepType >= 98 ? 3 + (fontOffset * 4) : 0 + 15 + fontOffset,
                  fonts[4], metric, 1);
  }

  (:highmem)
  function drawTop(dc,metric){
      dc.drawText(stepType >= 98 ? 25 : geometry[12],
                  geometry[2] - geometry[10], fonts[2], targetLow, 2);
      dc.drawText(
          stepType >= 98 ? geometry[0] - 25 : geometry[0] - geometry[12],
          geometry[2] - geometry[10], fonts[2], targetHigh, 0);
          
      dc.drawText(geometry[1] + 2,
                  stepType >= 98 ? 3 + (fontOffset * 4) : 0 + 15 + fontOffset,
                  fonts[4], metric, 1);
  }

  (:lowmem :workout)
  function drawBottom(dc,fgColor,bgColor){
    var lMetricLabel = "";
    var lMetricValue = "";
    if (stepType == 99) {
      lMetricLabel = "LAP TIME";
      lMetricValue = Utils.format_duration(lapTime);
    } else if (switchMetric == 2 ||
                ((remainingDistance == 0 ||
                  remainingDistance > remainingDistanceSpeed) &&
                (remainingTime == 0 || remainingTime > 15))) {
      if (stepType == 5) {
        lMetricLabel = "LAP PRESS";
        lMetricValue = Utils.format_duration(stepTime);
      } else if (stepType == 1) {
        var distance = Utils.format_distance(remainingDistance,useMetric,false);
        lMetricLabel = "REM. DIST";
        lMetricValue = distance[0] + (distance[2] == null ? "" : distance[2]) + distance[1];
      } else {
        lMetricLabel = "REM. TIME";
        lMetricValue = Utils.format_duration(remainingTime);
      }
    } else {
      lMetricLabel = "NEXT STEP";

      if (switchMetric == 0) {
        lMetricValue = nextTargetLow + "-" + nextTargetHigh;
      } else {
        if (nextTargetType == 5) {
          lMetricValue = "LAP PRESS";
        } else if (nextTargetType == 1) {
          var distance = Utils.format_distance(nextTargetDuration * 1.0, useMetric, false);
          lMetricValue = distance[0] +
                          (distance[2] == null ? "" : distance[2]) +
                          distance[1];
        } else {
          lMetricValue = Utils.format_duration(nextTargetDuration.toNumber());
        }
      }
    }

    dc.setColor(fgColor,-1);

    dc.drawText(geometry[1], geometry[4] + fontOffset, fonts[0], lMetricLabel,
                1);
    dc.drawText(geometry[1], geometry[4] + (fontOffset * 5) + 15, fonts[3],
                lMetricValue, 1);
  }

  (:highmem :workout)
  function drawBottom(dc,fgColor,bgColor){
    var lMetricLabel = "";
    var lMetricValue = "";
    if (stepType == 99) {
      lMetricLabel = bottomMetric == 1 ? "LAP TIME" : "LAP DIST";
      if(bottomMetric == 1){
        lMetricValue = Utils.format_duration(lapTime);
      } else {
        if(elapsedDistance == null || elapsedDistance == 0 || lapStartDistance == null){
          lMetricValue = 0;
        } else {
          var distance = Utils.format_distance(elapsedDistance - lapStartDistance,useMetric,false);
          lMetricValue = distance[0] + (distance[2] == null ? "" : distance[2]) + distance[1];
        }
      }
    } else if (switchMetric == 2 ||
                ((remainingDistance == 0 ||
                  remainingDistance > remainingDistanceSpeed) &&
                (remainingTime == 0 || remainingTime > 15))) {
      if (stepType == 5) {
        lMetricLabel = "LAP PRESS";
        lMetricValue = Utils.format_duration(stepTime);
      } else if (stepType == 1) {
        var distance = Utils.format_distance(remainingDistance,useMetric,false);
        lMetricLabel = "REM. DIST";
        lMetricValue = distance[0] + (distance[2] == null ? "" : distance[2]) + distance[1];
      } else {
        lMetricLabel = "REM. TIME";
        lMetricValue = Utils.format_duration(remainingTime);
      }
    } else {
      lMetricLabel = "NEXT STEP";

      if (switchMetric == 0) {
        lMetricValue = nextTargetLow + "-" + nextTargetHigh;
      } else {
        if (nextTargetType == 5) {
          lMetricValue = "LAP PRESS";
        } else if (nextTargetType == 1) {
          var distance = Utils.format_distance(nextTargetDuration * 1.0, useMetric, false);
          lMetricValue = distance[0] +
                          (distance[2] == null ? "" : distance[2]) +
                          distance[1];
        } else {
          lMetricValue = Utils.format_duration(nextTargetDuration.toNumber());
        }
      }
    }

    dc.setColor(fgColor,-1);

    dc.drawText(geometry[1], geometry[4] + fontOffset, fonts[0], lMetricLabel,
                1);
    dc.drawText(geometry[1], geometry[4] + (fontOffset * 5) + 15, fonts[3],
                lMetricValue, 1);
  }

  (:lowmem :noworkout)
  function drawBottom(dc,fgColor,bgColor){
    var lMetricLabel = "";
    var lMetricValue = "";
    if (stepType == 99) {
      lMetricLabel =  "LAP TIME";
      lMetricValue = Utils.format_duration(lapTime);
    }

    dc.setColor(fgColor,-1);

    dc.drawText(geometry[1], geometry[4] + fontOffset, fonts[0], lMetricLabel,
                1);
    dc.drawText(geometry[1], geometry[4] + (fontOffset * 5) + 15, fonts[3],
                lMetricValue, 1);
  }

  (:highmem :noworkout)
  function drawBottom(dc,fgColor,bgColor){
    var lMetricLabel = "";
    var lMetricValue = "";

    if (stepType == 99) {
      lMetricLabel = bottomMetric == 1 ? "LAP TIME" : "LAP DIST";
      if(bottomMetric == 1){
        lMetricValue = Utils.format_duration(lapTime);
      } else {
        if(elapsedDistance == null || elapsedDistance == 0 || lapStartDistance == null){
          lMetricValue = 0;
        } else {
          var distance = Utils.format_distance(elapsedDistance - lapStartDistance,useMetric,false);
          lMetricValue = distance[0] + (distance[2] == null ? "" : distance[2]) + distance[1];
        }
      }
    }

    dc.setColor(fgColor,-1);

    dc.drawText(geometry[1], geometry[4] + fontOffset, fonts[0], lMetricLabel,
                1);
    dc.drawText(geometry[1], geometry[4] + (fontOffset * 5) + 15, fonts[3],
                lMetricValue, 1);
  }

  (:lowmem)
  function drawGauge(dc, bgColor){
  }

  (:highmem)
  function drawGauge(dc, bgColor){
    dc.setPenWidth(10);
    dc.setColor(0xFF0000, bgColor);
    dc.drawArc(geometry[1], geometry[1], geometry[7], 0, 30, 60);

    dc.setColor(0x00FF00, bgColor);
    dc.drawArc(geometry[1], geometry[1], geometry[7], 0, 60, 120);

    dc.setColor(0x00AAFF, bgColor);
    dc.drawArc(geometry[1], geometry[1], geometry[7], 0, 120, 150);

    if (bgColor== 0x000000) {
      dc.setColor(0xFFFFFF, bgColor);
    } else {
      dc.setColor(0x000000, bgColor);
    }

    var percent = 0.15;
    var power = 0.0;
    if (currentPower != null && currentPower > 0 && targetHigh > 0 && targetLow > 0) {
      var range = targetHigh - targetLow;
      var lowerlimit = targetLow - range < 0 ? 0 : targetLow - range;

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
    var xy23 = orientation - 5 * Math.PI / 180;
    var xy1 = pol2Cart(geometry[1], geometry[1], orientation, geometry[8]);
    var xy2 = pol2Cart(geometry[1], geometry[1], xy23, geometry[8]);
    var xy3 = pol2Cart(geometry[1], geometry[1], xy23, geometry[9]);
    var xy4 = pol2Cart(geometry[1], geometry[1], orientation, geometry[9]);
    dc.fillPolygon([ xy1, xy2, xy3, xy4 ]);
  }

  (:lowmem)
  function processExtraData(info){
  }

  // FROM https://forums.garmin.com/developer/connect-iq/f/discussion/206579/vertical-speed
  (:highmem)
  function processExtraData(info){

    if (info has :totalAscent) {
      totalAscent = info.totalAscent == null ? 0 : info.totalAscent;
    }

    if (info has :totalDescent) {
      totalDescent = info.totalDescent == null ? 0 : info.totalDescent;
    }

    if (info has :altitude) {
      altitude = info.altitude == null ? 0 : info.altitude;
    }

    if(altitudeArray[0] == null){
      for (var i = 0; i < arrayAltPrecision; i++){
        altitudeArray[i] = altitude.toNumber();
      }
    }

    if (altitude != null)
    {
      var index = arrayAltPointer % arrayAltPrecision;
      var calculatedAltitude = altitude.toNumber() - altitudeArray[index];
      altitudeArray[index] = altitude.toNumber();

      arrayAltPointer++;
      verticalSpeed = 25 * ((calculatedAltitude * 1.0 / arrayAltPrecision * 1.0) * 144).toNumber() ;
    }

    if(elapsedDistance != null && elapsedDistance > 0 && avgSpeed != 0){
      etaSpeed = ((etaDistance * 1.0 - elapsedDistance * 1.0) / avgSpeed).toNumber();
    }
    if(elapsedDistance != null && elapsedDistance > 0 && avgPower != 0){
      var remElevation = etaElevation - totalAscent;
      var remDistance = etaDistance - elapsedDistance;
      if (remElevation > 0 && remDistance > 0){
        remDistance = remDistance + (remElevation * 10);
      }

      // method from https://blog.stryd.com/2020/01/10/how-to-calculate-your-race-time-from-your-target-power/ + adding the elevation in
      etaPower = ((1.04 * remDistance ) / ((avgPower * 1.0) / (weight * 1.0)) + 0.5).toNumber();
    }

    etaSpeed = etaSpeed < 0 ? 0 : etaSpeed;
    etaPower = etaPower < 0 ? 0 : etaPower;
  }

  (:highmem)
  function pol2Cart(center_x, center_y, radian, radius) {
    var x = center_x - radius * Math.sin(radian);
    var y = center_y - radius * Math.cos(radian);
    return [ Math.ceil(x), Math.ceil(y) ];
  }

  (:lowmem)
  function drawLayout(dc,fgColor,bgColor){
    drawMetric(dc,fields[0],0,geometry[2],layout == 3 ? geometry[5] : geometry[1],geometry[11],layout == 3 ? 0 : 1,bgColor,fgColor);
    drawMetric(dc,fields[1],0,geometry[3],layout == 3 ? geometry[5] : geometry[1],geometry[11],layout == 3 ? 0 : 1,bgColor,fgColor);
    drawMetric(dc,fields[2],layout == 3 ? geometry[5] : geometry[1],geometry[2],layout == 3 ? geometry[6] - geometry[5] : geometry[1],geometry[11], 1, bgColor,fgColor);
    drawMetric(dc,fields[3],layout == 3 ? geometry[5] : geometry[1],geometry[3],layout == 3 ? geometry[6] - geometry[5]: geometry[1],geometry[11], 1, bgColor,fgColor);

    if(layout == 3){
      drawMetric(dc,fields[4],geometry[6],geometry[2],geometry[0] - geometry[6],geometry[11],2,bgColor,fgColor);
      drawMetric(dc,fields[5],geometry[6],geometry[3],geometry[0] - geometry[6],geometry[11],2,bgColor,fgColor);
    }

    dc.setColor(fgColor,-1);
    dc.setPenWidth(1);

    //! Horizontal seperators
    dc.drawLine(0, geometry[2], geometry[0], geometry[2]);
    dc.drawLine(0, geometry[3], geometry[0], geometry[3]);
    dc.drawLine(0, geometry[4], geometry[0], geometry[4]);

    //! vertical seperators
    dc.drawLine(layout == 3 ? geometry[5] : geometry[1], geometry[2], layout == 3 ? geometry[5] : geometry[1], geometry[4]);
    if(layout == 3){
      dc.drawLine(geometry[6], geometry[2], geometry[6], geometry[4]);
    }
  }

  (:highmem)
  function drawLayout(dc,fgColor,bgColor){

    var useFields;
    var useLayout;

    if(autoAlternate && !paused){
      alternativeLayoutCounter++;
      if (alternativeLayoutCounter > 4) {
        switchAlternativeLayout = switchAlternativeLayout == 0 ? 1 : 0;
        alternativeLayoutCounter = 0;
      }
      useFields = switchAlternativeLayout == 0 ? fields : fieldsAlt;
      useLayout = switchAlternativeLayout == 0 ? layout : alternativeLayout;
    } else {
      useFields = useAlternativeLayout ? fieldsAlt : fields;
      useLayout = useAlternativeLayout ? alternativeLayout : layout;
    }

    drawMetric(dc,useFields[0],0,geometry[2],useLayout == 3 ? geometry[5] : geometry[1],geometry[11],useLayout == 3 ? 0 : 1,bgColor,fgColor);
    drawMetric(dc,useFields[1],0,geometry[3],useLayout == 3 ? geometry[5] : geometry[1],geometry[11],useLayout == 3 ? 0 : 1,bgColor,fgColor);
    drawMetric(dc,useFields[2],useLayout == 3 ? geometry[6] : geometry[1],geometry[2],useLayout == 3 ? geometry[0] - geometry[6] : geometry[1],geometry[11], useLayout == 3 ? 2 : 1, bgColor,fgColor);
    drawMetric(dc,useFields[3],useLayout == 3 ? geometry[6] : geometry[1],geometry[3],useLayout == 3 ? geometry[0] - geometry[6]: geometry[1],geometry[11], useLayout == 3 ? 2 : 1, bgColor,fgColor);

    if(useLayout == 3){
      drawMetric(dc,useFields[4],geometry[5],geometry[2],geometry[6] - geometry[5],geometry[11],1,bgColor,fgColor);
      drawMetric(dc,useFields[5],geometry[5],geometry[3],geometry[6] - geometry[5],geometry[11],1,bgColor,fgColor);
    }

    dc.setColor(fgColor,-1);
    dc.setPenWidth(1);

    //! Horizontal seperators
    dc.drawLine(0, geometry[2], geometry[0], geometry[2]);
    dc.drawLine(0, geometry[3], geometry[0], geometry[3]);
    dc.drawLine(0, geometry[4], geometry[0], geometry[4]);

    //! vertical seperators
    dc.drawLine(useLayout == 3 ? geometry[5] : geometry[1], geometry[2], useLayout == 3 ? geometry[5] : geometry[1], geometry[4]);
    if(useLayout == 3){
      dc.drawLine(geometry[6], geometry[2], geometry[6], geometry[4]);
    }
  }

  (:lowmem :workout)
  function drawMetric(dc,type,x,y,width,height,align,bgColor,fgColor) {
    dc.setColor(bgColor,bgColor);
    dc.fillRectangle(x, y, width, height);
    dc.setColor(fgColor,-1);
    var paceLabel = useSpeed ? (useMetric ? "SPD KM/H" : "SPD MI/H") : (useMetric ? "PC /KM" : "PC /MI");

    var single = width == geometry[0];
    var label = "";
    var value = "";
    var textx = x + (width / 2);
    var labelx = textx;

    if(align == 0){
      textx = x + width - 3;
      labelx = textx;
    } else if(align == 2){
      textx = x + 3;
      labelx = textx;
    }

    if(type == '0') {
      label = "CADENCE";
      value = cadence == null ? 0 : cadence;
    } else if (type == '1'){
      label = "HR";
      value = hr == null ? 0 : hr;
      if (hr != null) {
        if (showColors == 1 && !single) {
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
          dc.fillRectangle(x, y, width, height);
          dc.setColor(0xFFFFFF, -1);
        } else if (showColors == 2 && !single) {
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
    } else if(type == '2'){
      label = "EL. TIME";
      value = Utils.format_duration(timer);
    } else if (type == '3'){
      label = paceLabel;
      value = currentSpeed == null ? 0 : Utils.convert_speed_pace(currentSpeed, useMetric, useSpeed);
    } else if (type == '4'){
      label = "ST "+paceLabel;
      value = stepSpeed == null ? 0 : Utils.convert_speed_pace(stepSpeed, useMetric, useSpeed);
    } else if (type == '5'){
      label = "LP "+paceLabel;
      value = lapSpeed == null ? 0 : Utils.convert_speed_pace(lapSpeed, useMetric, useSpeed);
    } else if (type == '6') {
      if (stepPower != null) {
        if (stepType < 98 && targetHigh != 0 && targetLow != 0) {
          if (showColors == 1 && !single) {
            if (stepPower < targetLow) {
              dc.setColor(0x0000FF, -1);
            } else if (stepPower > targetHigh) {
              dc.setColor(0xAA0000, -1);
            } else {
              dc.setColor(0x00AA00, -1);
            }
            dc.fillRectangle(x, y, width, height);
            dc.setColor(0xFFFFFF, -1);
          } else if (showColors == 2 && !single) {
            if (stepPower < targetLow) {
              dc.setColor(0x0000FF, -1);
            } else if (stepPower > targetHigh) {
              dc.setColor(0xAA0000, -1);
            } else {
              dc.setColor(0x00AA00, -1);
            }
          }
        }
      }
      label = "STP PWR";
      value = stepPower == null ? 0 : (stepPower + 0.5).toNumber();
    } else if(type == '7') {
      label = "LAP PWR";
      value = lapPower == null ? 0 : (lapPower + 0.5).toNumber();
    } else if(type == '8'){
      var lLocalDistance = elapsedDistance == null ? Utils.format_distance(0,useMetric,showSmallDecimals) : Utils.format_distance(elapsedDistance,useMetric,showSmallDecimals);
      label = "DIST "+lLocalDistance[1];
      value = lLocalDistance[0];
      if(lLocalDistance[2] != null){
        var decimalx = textx;
        if(align == 2) {
          decimalx = lLocalDistance[0].length() > 2 ? decimalx + 32 : decimalx + 16;
        } else if (align == 1) {
          decimalx = lLocalDistance[0].length() > 2 ? decimalx + 18 : decimalx + 8;
          textx = lLocalDistance[0].length() > 2 ? textx - 8 - fontOffset : textx - 18 - fontOffset;
        } else if (align == 0){
          textx = textx - 32 - fontOffset;
        }
        dc.drawText(decimalx,y + (fontOffset * 2) + 20, fonts[2],
                lLocalDistance[2], align);
      }
    } else if(type == '9') {
      label = "TIME";
      var time = Sys.getClockTime();
      value = time.hour.format("%02d") + ":" + time.min.format("%02d");
    } else if(type == 'A') {
      label = "AV "+paceLabel;
      value = avgSpeed == null ? 0 : Utils.convert_speed_pace(avgSpeed, useMetric, useSpeed);
    } else if(type == 'B') {
      label = "AV PWR";
      value = avgPower == null ? 0 : (avgPower + 0.5).toNumber();
    }

    dc.drawText(labelx, y + fontOffset, fonts[0], label, align);
    dc.drawText(textx, y + (fontOffset * 5) + 15, fonts[3], value, align);
  }

  (:highmem :workout)
  function drawMetric(dc,type,x,y,width,height,align,bgColor,fgColor) {
    dc.setColor(bgColor,bgColor);
    dc.fillRectangle(x, y, width, height);
    dc.setColor(fgColor,-1);
    var paceLabel = useSpeed ? (useMetric ? "SPD KM/H" : "SPD MI/H") : (useMetric ? "PC /KM" : "PC /MI");

    var single = width == geometry[0];
    var label = "";
    var value = "";
    var textx = x + (width / 2);
    var labelx = textx;

    if(align == 0){
      textx = x + width - 3;
      labelx = textx;
    } else if(align == 2){
      textx = x + 3;
      labelx = textx;
    }

    if(type == '0') {
      label = "CADENCE";
      value = cadence == null ? 0 : cadence;
    } else if (type == '1'){
      label = "HR";
      value = hr == null ? 0 : hr;
      if (hr != null) {
        if (showColors == 1 && !single) {
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
          dc.fillRectangle(x, y, width, height);
          dc.setColor(0xFFFFFF, -1);
        } else if (showColors == 2 && !single) {
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
    } else if(type == '2'){
      label = "EL. TIME";
      value = Utils.format_duration(timer);
    } else if (type == '3'){
      label = paceLabel;
      value = currentSpeed == null ? 0 : Utils.convert_speed_pace(currentSpeed, useMetric, useSpeed);
    } else if (type == '4'){
      label = "ST "+paceLabel;
      value = stepSpeed == null ? 0 : Utils.convert_speed_pace(stepSpeed, useMetric, useSpeed);
    } else if (type == '5'){
      label = "LP "+paceLabel;
      value = lapSpeed == null ? 0 : Utils.convert_speed_pace(lapSpeed, useMetric, useSpeed);
    } else if (type == '6') {
      if (stepPower != null) {
        if (stepType < 98 && targetHigh != 0 && targetLow != 0) {
          if (showColors == 1 && !single) {
            if (stepPower < targetLow) {
              dc.setColor(0x0000FF, -1);
            } else if (stepPower > targetHigh) {
              dc.setColor(0xAA0000, -1);
            } else {
              dc.setColor(0x00AA00, -1);
            }
            dc.fillRectangle(x, y, width, height);
            dc.setColor(0xFFFFFF, -1);
          } else if (showColors == 2 && !single) {
            if (stepPower < targetLow) {
              dc.setColor(0x0000FF, -1);
            } else if (stepPower > targetHigh) {
              dc.setColor(0xAA0000, -1);
            } else {
              dc.setColor(0x00AA00, -1);
            }
          }
        }
      }
      label = "STP PWR";
      value = stepPower == null ? 0 : (stepPower + 0.5).toNumber();
    } else if(type == '7') {
      label = "LAP PWR";
      value = lapPower == null ? 0 : (lapPower + 0.5).toNumber();
    } else if(type == '8'){
      var lLocalDistance = elapsedDistance == null ? Utils.format_distance(0,useMetric,showSmallDecimals) : Utils.format_distance(elapsedDistance,useMetric,showSmallDecimals);
      label = "DIST "+lLocalDistance[1];
      value = lLocalDistance[0];
      if(lLocalDistance[2] != null){
        var decimalx = textx;
        if(align == 2) {
          decimalx = lLocalDistance[0].length() > 2 ? decimalx + 32 : decimalx + 16;
        } else if (align == 1) {
          decimalx = lLocalDistance[0].length() > 2 ? decimalx + 18 : decimalx + 8;
          textx = lLocalDistance[0].length() > 2 ? textx - 8 - fontOffset : textx - 18 - fontOffset;
        } else if (align == 0){
          textx = textx - 32 - fontOffset;
        }
        dc.drawText(decimalx,y + (fontOffset * 2) + 20, fonts[2],
                lLocalDistance[2], align);
      }
    } else if(type == '9') {
      label = "TIME";
      var time = Sys.getClockTime();
      value = time.hour.format("%02d") + ":" + time.min.format("%02d");
    } else if(type == 'A') {
      label = "AV "+paceLabel;
      value = avgSpeed == null ? 0 : Utils.convert_speed_pace(avgSpeed, useMetric, useSpeed);
    } else if(type == 'B') {
      label = "AV PWR";
      value = avgPower == null ? 0 : (avgPower + 0.5).toNumber();
    } else if(type == 'C') {
      label = useMetric ? "ALT M" : "ALT FT";
      value = useMetric ? altitude.toNumber() : (altitude * 3.2808399).toNumber();
    } else if(type == 'D') {
      label = useMetric ? "ASC M" : "ASC FT";
      value = useMetric ? totalAscent.toNumber() : (totalAscent * 3.2808399).toNumber();
    } else if(type == 'E') {
      label = useMetric ? "DESC M" : "DESC FT";
      value = useMetric ? totalDescent.toNumber() : (totalDescent * 3.2808399).toNumber();
    } else if(type == 'F') {
      label = "VAM M/H";
      value = (verticalSpeed + 0.5).toNumber();
    } else if(type == 'G') {
      label = "ETA PC "+(etaDistance * 1.0 / 1000).format("%0.2f")+"K";
      value = Utils.format_duration(etaSpeed);
    } else if(type == 'H') {
      label = "ETA PWR "+(etaDistance * 1.0 / 1000).format("%0.2f")+"K";
      value = Utils.format_duration(etaPower);
    }

    dc.drawText(labelx, y + fontOffset, fonts[0], label, align);
    dc.drawText(textx, y + (fontOffset * 5) + 15, fonts[3], value, align);
  }

  (:highmem :noworkout)
  function drawMetric(dc,type,x,y,width,height,align,bgColor,fgColor) {
    dc.setColor(bgColor,bgColor);
    dc.fillRectangle(x, y, width, height);
    dc.setColor(fgColor,-1);

    var single = width == geometry[0];
    var label = "";
    var value = "";
    var textx = x + (width / 2);
    var labelx = textx;
    var paceLabel = useSpeed ? (useMetric ? "SPD KM/H" : "SPD MI/H") : (useMetric ? "PC /KM" : "PC /MI");

    if(align == 0){
      textx = x + width - 3;
      labelx = textx;
    } else if(align == 2){
      textx = x + 3;
      labelx = textx;
    }

    if(type == '0') {
      label = "CADENCE";
      value = cadence == null ? 0 : cadence;
    } else if (type == '1'){
      label = "HR";
      value = hr == null ? 0 : hr;
      if (hr != null) {
        if (showColors == 1 && !single) {
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
          dc.fillRectangle(x, y, width, height);
          dc.setColor(0xFFFFFF, -1);
        } else if (showColors == 2 && !single) {
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
    } else if(type == '2'){
      label = "EL. TIME";
      value = Utils.format_duration(timer);
    } else if (type == '3'){
      label = paceLabel;
      value = currentSpeed == null ? 0 : Utils.convert_speed_pace(currentSpeed, useMetric, useSpeed);
    } else if (type == '5'){
      label = "LP "+paceLabel;
      value = lapSpeed == null ? 0 : Utils.convert_speed_pace(lapSpeed, useMetric, useSpeed);
    } else if(type == '7') {
      label = "LAP PWR";
      value = lapPower == null ? 0 : (lapPower + 0.5).toNumber();
    } else if(type == '8'){
      var lLocalDistance = elapsedDistance == null ? Utils.format_distance(0,useMetric,showSmallDecimals) : Utils.format_distance(elapsedDistance,useMetric,showSmallDecimals);
      label = "DIST "+lLocalDistance[1];
      value = lLocalDistance[0];
      if(lLocalDistance[2] != null){
        var decimalx = textx;
        if(align == 2) {
          decimalx = lLocalDistance[0].length() > 2 ? decimalx + 32 : decimalx + 16;
        } else if (align == 1) {
          decimalx = lLocalDistance[0].length() > 2 ? decimalx + 18 : decimalx + 8;
          textx = lLocalDistance[0].length() > 2 ? textx - 8 - fontOffset : textx - 18 - fontOffset;
        } else if (align == 0){
          textx = textx - 32 - fontOffset;
        }
        dc.drawText(decimalx,y + (fontOffset * 2) + 20, fonts[2],
                lLocalDistance[2], align);
      }
    } else if(type == '9') {
      label = "TIME";
      var time = Sys.getClockTime();
      value = time.hour.format("%02d") + ":" + time.min.format("%02d");
    } else if(type == 'A') {
      label = "AV "+paceLabel;
      value = avgSpeed == null ? 0 : Utils.convert_speed_pace(avgSpeed, useMetric, useSpeed);
    } else if(type == 'B') {
      label = "AV PWR";
      value = avgPower == null ? 0 : (avgPower + 0.5).toNumber();
    } else if(type == 'C') {
      label = useMetric ? "ALT M" : "ALT FT";
      value = useMetric ? altitude.toNumber() : (altitude * 3.2808399).toNumber();
    } else if(type == 'D') {
      label = useMetric ? "ASC M" : "ASC FT";
      value = useMetric ? totalAscent.toNumber() : (totalAscent * 3.2808399).toNumber();
    } else if(type == 'E') {
      label = useMetric ? "DESC M" : "DESC FT";
      value = useMetric ? totalDescent.toNumber() : (totalDescent * 3.2808399).toNumber();
    } else if(type == 'F') {
      label = "VAM M/H";
      value = (verticalSpeed + 0.5).toNumber();
    } else if(type == 'G') {
      label = "ETA PC "+(etaDistance * 1.0 / 1000).format("%0.2f")+"K";
      value = Utils.format_duration(etaSpeed);
    } else if(type == 'H') {
      label = "ETA PWR "+(etaDistance * 1.0 / 1000).format("%0.2f")+"K";
      value = Utils.format_duration(etaPower);
    }

    dc.drawText(labelx, y + fontOffset, fonts[0], label, align);
    dc.drawText(textx, y + (fontOffset * 5) + 15, fonts[3], value, align);
  }

  (:lowmem :noworkout)
  function drawMetric(dc,type,x,y,width,height,align,bgColor,fgColor) {
    dc.setColor(bgColor,bgColor);
    dc.fillRectangle(x, y, width, height);
    dc.setColor(fgColor,-1);

    var single = width == geometry[0];
    var label = "";
    var value = "";
    var textx = x + (width / 2);
    var labelx = textx;
    var paceLabel = useSpeed ? (useMetric ? "SPD KM/H" : "SPD MI/H") : (useMetric ? "PC /KM" : "PC /MI");

    if(align == 0){
      textx = x + width - 3;
      labelx = textx;
    } else if(align == 2){
      textx = x + 3;
      labelx = textx;
    }

    if(type == '0') {
      label = "CADENCE";
      value = cadence == null ? 0 : cadence;
    } else if (type == '1'){
      label = "HR";
      value = hr == null ? 0 : hr;
      if (hr != null) {
        if (showColors == 1 && !single) {
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
          dc.fillRectangle(x, y, width, height);
          dc.setColor(0xFFFFFF, -1);
        } else if (showColors == 2 && !single) {
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
    } else if(type == '2'){
      label = "EL. TIME";
      value = Utils.format_duration(timer);
    } else if (type == '3'){
      label = paceLabel;
      value = currentSpeed == null ? 0 : Utils.convert_speed_pace(currentSpeed, useMetric, useSpeed);
    } else if (type == '5'){
      label = "LP "+ paceLabel;
      value = lapSpeed == null ? 0 : Utils.convert_speed_pace(lapSpeed, useMetric, useSpeed);
    } else if(type == '7') {
      label = "LAP PWR";
      value = lapPower == null ? 0 : (lapPower + 0.5).toNumber();
    } else if(type == '8'){
      var lLocalDistance = elapsedDistance == null ? Utils.format_distance(0,useMetric,showSmallDecimals) : Utils.format_distance(elapsedDistance,useMetric,showSmallDecimals);
      label = "DIST "+lLocalDistance[1];
      value = lLocalDistance[0];
      if(lLocalDistance[2] != null){
        var decimalx = textx;
        if(align == 2) {
          decimalx = lLocalDistance[0].length() > 2 ? decimalx + 32 : decimalx + 16;
        } else if (align == 1) {
          decimalx = lLocalDistance[0].length() > 2 ? decimalx + 18 : decimalx + 8;
          textx = lLocalDistance[0].length() > 2 ? textx - 8 - fontOffset : textx - 18 - fontOffset;
        } else if (align == 0){
          textx = textx - 32 - fontOffset;
        }
        dc.drawText(decimalx,y + (fontOffset * 2) + 20, fonts[2],
                lLocalDistance[2], align);
      }
    } else if(type == '9') {
      label = "TIME";
      var time = Sys.getClockTime();
      value = time.hour.format("%02d") + ":" + time.min.format("%02d");
    } else if(type == 'A') {
      label = "AV "+paceLabel;
      value = avgSpeed == null ? 0 : Utils.convert_speed_pace(avgSpeed, useMetric, useSpeed);
    } else if(type == 'B') {
      label = "AV PWR";
      value = avgPower == null ? 0 : (avgPower + 0.5).toNumber();
    }

    dc.drawText(labelx, y + fontOffset, fonts[0], label, align);
    dc.drawText(textx, y + (fontOffset * 5) + 15, fonts[3], value, align);
  }
}