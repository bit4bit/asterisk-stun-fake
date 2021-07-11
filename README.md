# asterisk stun fake/fix

This script start a fake stun server, for Asterisk chan_sip.

Asterisk for Webrtc clients requires configure a stun server for getting
public ip for ice candidates, when asterisk server run in a nat one-to-one like AWS,
 we not need a stun server, this scripts workaround this issue with a fake stun server.

Run this script on your asterisk server, edit **rtp.conf** and set "stunaddr=localhost".

Tested with Asterisk chan_sip on:
 - 14.x
 - 13.x

# Contributing

[Go to](https://chiselapp.com/user/bit4bit/repository/asterisk-stun-fake-fix/)
