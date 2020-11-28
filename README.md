# RunPowerWorkout

[Screenshot](https://tommyvdz.github.io/runpowerworkout-scrn.png)

RunPowerWorkout is a datafield that allows you to follow structured workouts based on Power on Garmin watches that support power meters and ConnectIQ 3.2.

Garmin doesn't yet support power as target in structured workouts natively, but as of ConnectIQ 3.2 it does enable datafields to read structured workout information, including power targets. This datafield reads those powertargets and dispays a gauge to visualize your current power output in relation to the target. 

Through Garmin Connect Mobile or through Garmin Express you can edit the datafield settings, giving the option to display power output and targets as percentage of your Functional Treshold Power / Critical Power or as plain watts. 

It currently supports all watch models that are updated to ConnectIQ 3.2 and have support for power meters. You need to have your Stryd paired as a power meter in order for the datafield to access the power values. 

The datafield displays:
* A gauge showing your current power in relation to the workout step targets
* The target power boundary values
* Current lap power
* Current heart rate
* Cadence
* Remaining time for the current workout step

Later on I plan to add datafield alerts when you are under or over the target. Additionally I want to make the other values configurable. 

The datafield can be downloaded in the ConnectIQ Store:
https://apps.garmin.com/en-US/apps/8c2fce29-0c7c-41f3-9a8f-5d3093c9cf2f