using Toybox.WatchUi;
using Toybox.Graphics as Gfx;
using Toybox.Time;


class RunPowerWorkoutView extends WatchUi.DataField {
	
	hidden var timer;
	hidden var lapTime;
	hidden var lapStartTime; 
	hidden var lapPower;
	hidden var targetHigh;
    hidden var targetLow;
    hidden var remainingTime;
    hidden var currentPower;
    hidden var paused;
    hidden var cadence;
    hidden var hr;
    hidden var usePercentage;
    hidden var FTP;

	hidden var DEBUG = false;


    function initialize() {
    	if (DEBUG) {
		System.println("Debug mode: setting default targets, and printing a lot.");
    	}
    	
    	//read settings
    	var percentagesetting = Utils.replaceNull(Application.getApp().getProperty("PERCENTAGE"), false);
        var ftpsetting = Utils.replaceNull(Application.getApp().getProperty("FTP"), 325);
		
		usePercentage = percentagesetting;
		FTP = ftpsetting;
    	
        DataField.initialize();
        lapTime = 0;
        lapStartTime = 0;
        targetHigh = 0;
    	targetLow = 0;
    	remainingTime = 0;
    	currentPower = 0;
    	cadence = 0;
    	hr = 0;
    	paused = true;
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
    
    function onTimerResume(){
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
    	
		lapStartTime = timer; 
		lapTime = 0;
		lapPower = null;
		remainingTime = 0;
	} 
	
	function onWorkoutStepComplete(){
		onTimerLap();
	}

	function onTimerReset() { 
		if (DEBUG) {
    	System.println("Timer Reset");
    	}

		lapStartTime = timer;
		lapTime = 0;
		lapPower = null;
		remainingTime = 0;
	} 
    

    // Set your layout here. Anytime the size of obscurity of
    // the draw context is changed this will be called.
    function onLayout(dc) {

        View.setLayout(Rez.Layouts.MainLayout(dc));

        var currentPowerLabel = View.findDrawableById("currentPower");
        var currentPowerValue = View.findDrawableById("currentPowerv");
        var lapPowerLabel = View.findDrawableById("lapPower");
        var lapPowerValue = View.findDrawableById("lapPowerv");
        var powerHighLabel = View.findDrawableById("powerHigh");
        var powerHighValue = View.findDrawableById("powerHighv");
        var powerLowLabel = View.findDrawableById("powerLow");
        var powerLowValue = View.findDrawableById("powerLowv");
        var remainingTimeLabel = View.findDrawableById("remainingTime");
        var remainingTimeValue = View.findDrawableById("remainingTimev");
        var cadenceLabel = View.findDrawableById("cadence");
        var cadenceValue = View.findDrawableById("cadencev");
        var hrLabel = View.findDrawableById("hr");
        var hrValue = View.findDrawableById("hrv");
		
		currentPowerValue.setText("0");
		lapPowerLabel.setText("Lap Pwr");
		lapPowerValue.setText("0");
		powerHighLabel.setText("Upper");
		powerHighValue.setText("-");
		powerLowLabel.setText("Lower");
		powerLowValue.setText("-");
		hrLabel.setText("HR");
		cadenceLabel.setText("Cadence");
		remainingTimeLabel.setText("Rem. Time");
		
		
        return true;
    }

    // The given info object contains all the current workout information.
    // Calculate a value and save it locally in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info) {
        // See Activity.Info in the documentation for available information.
        var workout = Activity.getCurrentWorkoutStep();
        var activityInfo = Activity.getActivityInfo();
		

        if (paused != true){
        
        	if (activityInfo != null){
        		timer = activityInfo.timerTime/1000;
       			lapTime = timer - lapStartTime;
	        	if (workout != null && DEBUG == false){
	        		targetHigh = workout.step.targetValueHigh - 1000;
	        		targetLow = workout.step.targetValueLow - 1000;
	        		if (targetHigh < 0){
	        			targetHigh = 0;
	        		}
	        		if (targetLow < 0){
	        			targetLow = 0;
	        		}
	        		if (usePercentage && targetHigh != null && targetLow != null){
	        			targetHigh = ((targetHigh / (FTP * 1.0))*100).toNumber();
	        			targetLow = ((targetLow / (FTP * 1.0))*100).toNumber();
	        		}
	        		if (workout.step.durationValue != null && DEBUG == false && remainingTime > 0){
	        			remainingTime = (workout.step.durationValue - lapTime).toNumber(); 
	        		}
	        		
	        	}
	        	
	        	if (DEBUG){

	        		targetHigh = 200;
	        		targetLow = 100;
	        		if (remainingTime > 0){
	        			remainingTime = (20 - lapTime).toNumber();
	        		}
	        		remainingTime = (20 - lapTime).toNumber();
	        		if (usePercentage && targetHigh != null && targetLow != null){
	        			targetHigh = ((targetHigh / (FTP * 1.0))*100).toNumber();
	        			targetLow = ((targetLow / (FTP * 1.0))*100).toNumber();
	        		}
	        	}
	        	
        		if (activityInfo has :currentCadence){
        			cadence = activityInfo.currentCadence;
        		}
        		if (activityInfo has :currentHeartRate){
        			hr = activityInfo.currentHeartRate;
        		}
        
        		if (activityInfo has :currentPower){
        			if (usePercentage && activityInfo.currentPower != null){
        				currentPower = ((activityInfo.currentPower/(FTP * 1.0))* 100).toNumber();
        				
        			}
        			else{
        				currentPower = activityInfo.currentPower;
        			}

        			if (currentPower != null){
	        			if (lapPower == null){
	        				lapPower = currentPower;
	        			}
	        			else{
							lapPower = (((lapPower * (lapTime - 1)) + currentPower) / (lapTime * 1.0));
	        			}
        			}
        			else{
        				currentPower = 0; // in order to prevent problems when using currentpower elsewhere
        			}
        			
        		}
        	}
        }
       
        return true;
    }

    // Display the value you computed here. This will be called
    // once a second when the data field is visible.
    function onUpdate(dc) {


		//Set the background color
		View.findDrawableById("Background").setColor(getBackgroundColor());

        var lapTimeValue = View.findDrawableById("lapTimev");
        var currentPowerValue = View.findDrawableById("currentPowerv");
        var lapPowerValue = View.findDrawableById("lapPowerv");
        var powerHighValue = View.findDrawableById("powerHighv");
        var powerLowValue = View.findDrawableById("powerLowv");
        var remainingTimeValue = View.findDrawableById("remainingTimev");
        var cadenceValue = View.findDrawableById("cadencev");
        var hrValue = View.findDrawableById("hrv");
        
        if (cadence == null){
        	cadenceValue.setText("0");
        }
        else{
        	cadenceValue.setText("" + cadence);
        }
        if (hr == null){
        	hrValue.setText("0");
        }
        else{
        	hrValue.setText("" + hr);
        }

		if (currentPower == null){
			currentPowerValue.setText("0");
		}
		else{
			currentPowerValue.setText("" + currentPower);
		}
		if (lapPower == null){
			lapPowerValue.setText("0");
		}
		else{
			lapPowerValue.setText("" + lapPower.toNumber());
		}
		
		powerHighValue.setText("" + targetHigh);
		powerLowValue.setText("" + targetLow);
		remainingTimeValue.setText("" + format_duration(remainingTime));

        //! Call parent's onUpdate(dc) to redraw the layout
		View.onUpdate(dc);
		
		//! Draw the outline
		var width = dc.getWidth();
		var height = dc.getHeight();
		var x = width/2;
		var y = height/2;
		
       //! Draw separator lines
      	dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);

       //! Horizontal seperators
        dc.drawLine(0,   ((height/3)+(0.02*height)),  width, ((height/3)+(0.02*height)));
        dc.drawLine(0, ((height/2)+(0.06*height)), width, ((height/2)+(0.06*height)));
        dc.drawLine(0, 0.77*height, width, 0.77*height);

        //! vertical seperators
        dc.drawLine(width/3, ((height/3)+(0.02*height)),  width/3, ((height/2)+(0.06*height)));
        dc.drawLine((width/3)*2, ((height/3)+(0.02*height)), (width/3)*2, ((height/2)+(0.06*height)));
        dc.drawLine(width/2, ((height/2)+(0.06*height)), width/2, 0.77*height);




//! The following code to draw the gauge is copied and adapted from Ravenfeld - Speed Gauge
//! https://github.com/ravenfeld/Connect-IQ-DataField-Speed


      	var SIZE = 20;
        
        dc.setPenWidth(SIZE);
		dc.setAntiAlias(true);
        dc.setColor( Graphics.COLOR_RED, getBackgroundColor() );
        dc.drawArc(x, y, dc.getWidth()/2-10-SIZE/2, Gfx.ARC_COUNTER_CLOCKWISE, 30, 60);
        
        dc.setColor( Graphics.COLOR_RED, getBackgroundColor() );
        dc.drawArc(x, y, dc.getWidth()/2-10-SIZE/2, Gfx.ARC_COUNTER_CLOCKWISE, 120, 150);
        
        dc.setColor( Graphics.COLOR_GREEN, getBackgroundColor() );
        dc.drawArc(x, y, dc.getWidth()/2-10-SIZE/2, Gfx.ARC_COUNTER_CLOCKWISE, 60, 120);

        dc.setColor(Graphics.COLOR_BLACK, getBackgroundColor() );  
		
		var percent=0.15;
		var power = 0.0;
		if( currentPower > 0 && targetHigh > 0 && targetLow > 0){
			var range = targetHigh - targetLow;
			var lowerlimit = 0;

			if (targetLow-range < 0){
				lowerlimit = 0;
			}
			else{
				lowerlimit = targetLow-range;
			}

			var upperlimit = targetHigh+range;
			power = currentPower - lowerlimit;	
        	if(power > 0.0 && (upperlimit-lowerlimit) > 0){
        		percent = power/(upperlimit-lowerlimit*1.0);
        	}
        	if (percent < 0.15){
        		System.println("percent is smaller than 0.15");
        		percent = 0.15;
        	}
        	if (percent > 0.85){
        		System.println("percent is lager than 0.85");
        		percent = 0.85;
        	}
        
    	}
    
        var orientation=-Math.PI*percent-3*Math.PI/2;
        var radius= dc.getWidth()/2-6;
        var xy1 = pol2Cart(x, y, orientation, radius);
		var xy2 = pol2Cart(x, y, orientation-5*Math.PI/180, radius);
		var xy3 = pol2Cart(x, y, orientation-5*Math.PI/180, radius-SIZE-8);
		var xy4 = pol2Cart(x, y, orientation, radius-SIZE-8);
		dc.fillPolygon([xy1, xy2, xy3, xy4]);
    
        	
	}
    	

	function pol2Cart(center_x, center_y, radian, radius) {
		var x = center_x - radius * Math.sin(radian);
		var y = center_y - radius * Math.cos(radian);
		 
		return [Math.ceil(x), Math.ceil(y)];
	}
    
    
    function format_duration(seconds) { 
		var hh = seconds / 3600; 
		var mm = seconds / 60 % 60; 
		var ss = seconds % 60; 
		
		if (hh != 0) { 
		return Lang.format("$1$:$2$:$3$", [ 
		hh, 
		mm.format("%02d"), 
		ss.format("%02d") 
		]); 
		} 
		else { 
		return Lang.format("$1$:$2$", [ 
		mm, 
		ss.format("%02d") 
		]); 
	} 
} 

}


