# RunPowerWorkout

RunPowerWorkout is a datafield that allows you to follow structured workouts based on Power on Garmin watches that support ConnectIQ 3.2.

Garmin doesn't yet support power as target in structured workouts natively, but as of ConnectIQ 3.2 it does enable datafields to read structured workout information, including power targets. This datafield reads those powertargets and dispays a gauge to visualize your current power output in relation to the target. 

It currently supports all watch models that are updated to ConnectIQ 3.2. For devices with capability level 3 or 4, you need to have your Stryd paired as a power meter in order for the datafield to access the power values. For devices with capability level 1 or 2, you need to enter your stryd ANT ID.


### Features

The datafield displays:
* A gauge showing your current power in relation to the workout step targets. For low memory devices (capabilities 1 and 3), the gauge is not displayed.
* The target power boundary values

If in 4 or 6 fields layout, it will also display the remaining time or distance for the current workout step, or lap time if outside of a workout.

For the 4 and 6 field layouts, you can choose the following metrics (in parenthesis, the number identifier for the string setting for low memory devices):

* Cadence (0)
* Current heart rate (1)
* Elapsed Time (2)
* Instance pace (3)
* Workout step pace (4)
* Lap pace (5)
* Workout step power (6)
* Lap power (7)
* Elapsed distance (8)
* Current time (9)

Datafield layout is the following

| 1   | 2   | 5   |
| --- | --- | --- |
| 3   | 4   | 6   |

If you have a device with low memory (level 1 or 2), you won't be able to choose fields individually. You will have to enter a string representing the fields in order. For instance `368201` will display 

| Pace     | Step Power   | Cadence    |
| -------- | ------------ | ---------- |
| Distance | Elapsed Time | Heart rate |

This datafield will trigger an alert and/or vibrate if you are outside of the target range (up to three times). Colors can be shown for some metrics : HR zone, Power zone, Lap Power.

Display of units will automatically use your device settings.

### Settings

Through Garmin Connect Mobile or through Garmin Express you can edit the datafield settings. You can set the following settings :
* Set your current FTP/CP
* Choose to display power output and targets as percentage of your Functional Treshold Power / Critical Power or as plain watts
* Choose datafield layout (1, 4 or 6 fields) and which metrics to display.
* Enable/disable workout alerts
* Enable/disable vibrations on workout alerts
* Enable/disable tones on workout alerts
* Enable/disable vibrations and/or tones on workout countdown (15 seconds before a new workout step)
* Choose the coloring behaviour: either no colors, text only, text and background.
* Enable/disable usage of custom fonts (for capability level 2 or 4)
* Enable/disable smaller decimal for the distance metric field
* Choose power average duration (from 1 to 30s)
* Power zone model to use when outside of a workout : Stryd, Jim Vance, Steve Palladino, 80/20, Van Dijk and Van Megen

### Download

The datafield can be downloaded in the ConnectIQ Store:
https://apps.garmin.com/en-US/apps/8c2fce29-0c7c-41f3-9a8f-5d3093c9cf2f

### Screenshots

##### 6 fields layout with custom fonts (capability level 2 or 4)
![](doc/img/HM6fieldsFGColorWorkout.png)
##### 6 fields layout with statute units (outside of a workout step)
![](doc/img/HM6FieldsStatute.png)
##### Single field layout, inside a workout
![](doc/img/HM1FieldBGColor.png)
##### 4 fields display on low memory devices (capability 1 or 3), inside a workout
![](doc/img/LM4fieldsBGColorWorkout.png)
##### Alert
![](doc/img/FullAlert.png)

### Capabilities level

| Level | Power support ? | Custom Fonts | Nice settings for data field layout ? |
| ----- | --------------- | ------------ | ------------------------------------- |
| 1     | No (ANT+)       | No           | No                                    |
| 2     | No (ANT+)       | Yes          | Yes                                   |
| 3     | Yes             | No           | No                                    |
| 4     | Yes             | Yes          | Yes                                   |

### Watch capability matrix

| Watch           | Multisport ? | Datafield Memory | Feature Level |
| --------------- | ------------ | ---------------- | ------------- |
| Enduro          | Yes          | 32KB             | 3             |
| Fenix 5 Plus    | Yes          | 128KB            | 4             |
| Fenix 6         | Yes          | 32KB             | 3             |
| Fenix 6S        | Yes          | 32KB             | 3             |
| Fenix 6 Pro     | Yes          | 128KB            | 4             |
| Fenix 6S Pro    | Yes          | 128KB            | 4             |
| Fenix 6X Pro    | Yes          | 128KB            | 4             |
| Forerunner 245  | No           | 32KB             | 1             |
| Forerunner 245M | No           | 64KB             | 2             |
| Forerunner 645M | No           | 64KB             | 2             |
| Forerunner 745  | Yes          | 64KB             | 4             |
| Forerunner 945  | Yes          | 128KB            | 4             |
| Forerunner 945  | Yes          | 128KB            | 4             |
| MARQ Adventurer | Yes          | 128KB            | 4             |
| MARQ Athlete    | Yes          | 128KB            | 4             |
| MARQ Aviator    | Yes          | 128KB            | 4             |
| MARQ Captain    | Yes          | 128KB            | 4             |
| MARQ Commander  | Yes          | 128KB            | 4             |
| MARQ Driver     | Yes          | 128KB            | 4             |
| MARQ Expedition | Yes          | 128KB            | 4             |
| MARQ Golfer     | Yes          | 128KB            | 4             |
| Venu            | No           | 32KB             | 1             |
| Venu 2          | No           | 256KB            | 2             |
| Venu 2s         | No           | 256KB            | 2             |
| Vivoactive 3M   | No           | 32KB             | 1             |
| Vivoactive 4    | No           | 32KB             | 1             |
| Vivoactive 4s   | No           | 32KB             | 1             |

### Pragati Font License

Copyright (c) 2012-2015, Omnibus-Type (www.omnibus-type.com omnibus.type@gmail.com)

Licensed under the [SIL Open Font License, 1.1](https://scripts.sil.org/cms/scripts/page.php?site_id=nrsi&id=OFL)
