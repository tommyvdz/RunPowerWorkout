using Toybox.Application;

class RunPowerWorkoutApp extends Application.AppBase {

  hidden var sensor;

  function initialize() { AppBase.initialize(); }

  // onStart() is called on application start up
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
  function onStop(state) {
    if(sensor != null){
      sensor.close();
    }
  }

  //! Return the initial view of your application here
  function getInitialView() { return [new RunPowerWorkoutView(sensor)]; }
}