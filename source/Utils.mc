
class Utils {
    static function replaceNull(nullableValue, defaultValue) {
        if (nullableValue != null) {
            return nullableValue;
        } else {
            return defaultValue;
        }
    }

    static function format_distance(distance, useMetric, showSmallDecimals) {
        var factor = 1000;
        var smallunitfactor = 1000;
        var unit = "KM";
        var smallunit = "M";

        if (!useMetric) {
            factor = 1609;
            smallunitfactor = 1760;
            unit = "MI";
            smallunit = "YD";
        }

        if ((distance / factor) >= 1 || !useMetric) {
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

    static function format_duration(seconds) {
        var hh = seconds / 3600;
        var mm = seconds / 60 % 60;
        var ss = seconds % 60;

        if (hh != 0) {
            return hh + ":" + mm.format("%02d") + ":" + ss.format("%02d");
        } else {
            return mm + ":" + ss.format("%02d");
        }
    }

  function convert_speed_pace(speed, useMetric, useSpeed) {
    if (speed != null && speed > 0) {
      var factor = useSpeed ? (useMetric ? 3.6 : 2.23694) : (useMetric ? 1000.0 : 1609.0);
      var secondsPerUnit = useSpeed ? speed * factor : factor / speed;
      if(!useSpeed){
        secondsPerUnit = (secondsPerUnit + 0.5).toNumber();
        var minutes = (secondsPerUnit / 60);
        var seconds = (secondsPerUnit % 60);
        return minutes + ":" + seconds.format("%02u");
      } else {
        return secondsPerUnit.format("%0.2f");
      }
    } else {
      return useSpeed ? "0.00" : "0:00";
    }
  }
}