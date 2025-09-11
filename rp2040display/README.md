# Rp2040 Cueing Display
One drawback of the Norns monochromatic display is that is difficult to see small on-screen indications when not looking directly at the display; as might happen during a performance. In order to create a visual cuing system for live performance when using Norns as one of many instruments in a setup I thought it would be helpful to have a bright LED capable of multiple colors that I could see with my peripheral vision. This could be easily controllable by Norns using MIDI messages to indicate certain changes of state in Norns. Microcontroller devices like Adafruit's rp2040 Feather feature a bright RGB LED, allow for simple programming using Arduino or CircuitPython, and can appear as USB MIDI devices to the host. There are several other devices that meet these criteria but I happened to have a few rp2040 Feathers available in my collection.

This method may allow for visual cuing using other performance playback systems that support MIDI such as Sp404, 1010 Bluebox, etc.

This code should be generic enough to use on any circuitpython compatible controller with USB MIDI capability and onboard neopixel LED without changes. This was designed for the [Adafruit rp2040 Feather](https://www.adafruit.com/product/4884)

# Installation

1. Follow the Adafruit [Installing CircuitPython Guide](https://learn.adafruit.com/welcome-to-circuitpython/installing-circuitpython) for setting up your device.

2. Copy the code.py and Lib folder to your new CIRCUITPY Drive.

3. Profit

# Use

The default MIDI settings for the device are.

channel = 1
red = MIDI note 60
green = MIDI note 61
blue = MIDI note 62

A noteon message turns the color on and a noteoff turns the color off.