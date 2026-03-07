.pragma library

// Copy this file to config.js and fill in the pactl sink names for your machine.
// Run `pactl list sinks short` to list available sinks.

// The sink routed to your desk speakers (e.g. a DAC or audio interface line out)
var speakerSink = "alsa_output.YOUR_SPEAKER_SINK_NAME_HERE"

// The sink routed to your headset / headphones
var headsetSink = "alsa_output.YOUR_HEADSET_SINK_NAME_HERE"
