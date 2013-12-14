// Include the Twilio Cloud Module and initialize it
var twilio = require("twilio");
// twilio.initialize("AC58433d0569f0c9b5b2688a4c3ff5b766","8f0fea99f073292ddd3609d5c531d98a");
// Live token
twilio.initialize("AC317a5e024218d1f4e822065ff022c77c","ae33ff40eaa5f04272e62bddcfc2ac89");
 
// Create the Cloud Function
Parse.Cloud.define("inviteWithTwilio", function(request, response) {
// Use the Twilio Cloud Module to send an SMS
twilio.sendSMS({
from: "+16462573605",
to: request.params.number,
body: "Your code is: " + request.params.code
}, {
success: function(httpResponse) { response.success("SMS sent!"); },
error: function(httpResponse) { response.error("Uh oh, something went wrong: " + request.params.code); }
});
});