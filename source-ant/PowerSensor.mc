// FOUND ON GARMIN'S FORUM
// https://forums.garmin.com/developer/connect-iq/f/discussion/251742/how-to-acquire-stryd-s-power-data?ReplySortBy=CreatedDate&ReplySortOrder=Ascending
using Toybox.Ant;
using Toybox.Time;

class PowerSensor extends Ant.GenericChannel {
    var searching;
    var failedInit = false;

	var currentPower = null;

    var deviceNumber;
    var reopen = false;

    function initialize(devNumber) {
    	if (devNumber <= 0)
    	{
    		return;
    	}
    	deviceNumber = devNumber;

        var chanAssign = new Ant.ChannelAssignment(
            0 /*Ant.CHANNEL_TYPE_RX_NOT_TX*/,
            1 /*Ant.NETWORK_PLUS*/);

        try {
            GenericChannel.initialize(method(:onMessage), chanAssign);
        } catch(e instanceof Ant.UnableToAcquireChannelException) {
            System.println(e.getErrorMessage());
            failedInit = true;
            return;
        }

        var deviceCfg = new Ant.DeviceConfig( {
            :deviceNumber => deviceNumber,
            :deviceType => 11, //DEVICE_TYPE,
            :transmissionType => 5, //TRANSMISSION_TYPE,
            :messagePeriod => 8182, //PERIOD,
            :radioFrequency => 57,              //Ant+ Frequency
            :searchTimeoutLowPriority => 10,    //Timeout in 25s
            :searchThreshold => 0} );

        GenericChannel.setDeviceConfig(deviceCfg);
        open();
    }

    function open() {
        GenericChannel.open();
        currentPower = 0;
        searching = true;
    }

    function onMessage(msg) {
        // Parse the payload
        var payload = msg.getPayload();
        var payload0 = payload[0];
        var payload1 = payload[1];
        if (/*Ant.MSG_ID_BROADCAST_DATA */0x4e == msg.messageId) {
            if (/*PowerDataPage.PAGE_NUMBER*/ 0x10 == payload0) {
                // Were we searching?
                //if (searching) {
                searching = false;
                currentPower = payload[6] | ((payload[7]) << 8);
            }
        } else if (/*Ant.MSG_ID_CHANNEL_RESPONSE_EVENT*/0x40 == msg.messageId) {
            if (/*Ant.MSG_ID_RF_EVENT*/0x01 == payload0) {
                if (/*Ant.MSG_CODE_EVENT_CHANNEL_CLOSED*/0x07 == payload1) {
                    // Channel closed, re-open
                    reopen = true;
                } else if (/*Ant.MSG_CODE_EVENT_RX_FAIL_GO_TO_SEARCH*/0x08  == payload1) {
                	currentPower = 0;
                    searching = true;
                }
            } else {
            }
        }
    }
}