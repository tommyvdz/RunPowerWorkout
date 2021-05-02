using Toybox.Application;

class RunPowerWorkoutApp extends Application.AppBase {

  (:ant) hidden var sensor;

  function initialize() { AppBase.initialize(); }

  // onStart() is called on application start up
  (:noant)
  function onStart(state) {}

  (:noant)
  function onStop(state) {}

  (:ant)
  function onStart(state) {
    //Create the sensor object and open it
    var sensorsetting = Utils.replaceNull(Application.getApp().getProperty("L"), -1);
    if(sensorsetting != -1){
      sensor = new PowerSensor(sensorsetting);
      sensor.open();
    } else {
      sensor = null;
    }
  }

  // onStop() is called when your application is exiting
  (:ant)
  function onStop(state) {
    if(sensor != null){
      sensor.close();
    }
  }

  //! Return the initial view of your application here
  (:ant)
  function getInitialView() { return [new RunPowerWorkoutView(sensor)]; }

  (:noant)
  function getInitialView() { return [new RunPowerWorkoutView(null)]; }
}