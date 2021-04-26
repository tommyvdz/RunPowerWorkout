# RunPowerWorkout

RunPowerWorkout is a datafield that allows you to follow structured workouts based on Power on Garmin watches that support power meters and ConnectIQ 3.2.

Garmin doesn't yet support power as target in structured workouts natively, but as of ConnectIQ 3.2 it does enable datafields to read structured workout information, including power targets. This datafield reads those powertargets and dispays a gauge to visualize your current power output in relation to the target. 

It currently supports all watch models that are updated to ConnectIQ 3.2 and have support for power meters. You need to have your Stryd paired as a power meter in order for the datafield to access the power values. 

### Features

The datafield displays:
* A gauge showing your current power in relation to the workout step targets
* The target power boundary values
* Current lap power
* Current heart rate
* Cadence
* Pace
* Total distance
* Elapsed time
* Remaining time or distance for the current workout step

This datafield will trigger an alert and/or vibrate if you are outside of the target range (up to three times). Colors can be shown for some metrics : HR zone, Power zone, Lap Power.

Display of units will automatically use your device settings.

### Settings

Through Garmin Connect Mobile or through Garmin Express you can edit the datafield settings. You can set the following settings :
* Set your current FTP/CP
* Choose to display power output and targets as percentage of your Functional Treshold Power / Critical Power or as plain watts.
* Enable/disable workout alerts
* Enable/disable vibrations on workout alerts
* Choose the coloring behaviour: either no colors, text only, text and background.
* Enable/disable usage of custom fonts (only applied for devices allowing 64KB of memory for datafields)
* Enable/disable smaller decimal for the distance metric field
* Power zone model to use when outside of a workout : Stryd, Jim Vance, Steve Palladino, 80/20, Van Dijk and Van Megen

### Download

The datafield can be downloaded in the ConnectIQ Store:
https://apps.garmin.com/en-US/apps/8c2fce29-0c7c-41f3-9a8f-5d3093c9cf2f

### Screenshots

<img src="doc/img/workout_metric.png" height="250">
Regular workout display
<img src="doc/img/workout_metric_low_mem.png" height="250">
Low memory device workout display (no custom fonts)
<img src="doc/img/outside_workout_statute.png" height="250">
Outside of a workout with statute units display
<img src="doc/img/alert.png" height="250">
Alert display

### Pragati Font License

Copyright (c) 2012-2015, Omnibus-Type (www.omnibus-type.com omnibus.type@gmail.com)

Licensed under the [SIL Open Font License, 1.1](https://scripts.sil.org/cms/scripts/page.php?site_id=nrsi&id=OFL)
