import board
import usb_midi
import adafruit_midi
import neopixel

from adafruit_midi.note_off import NoteOff
from adafruit_midi.note_on import NoteOn
from adafruit_midi.midi_message import MIDIUnknownEvent

print(usb_midi.ports)
midi = adafruit_midi.MIDI(midi_in=usb_midi.ports[0], in_channel = 0)

pixel = neopixel.NeoPixel(board.NEOPIXEL, 1)

current = [0,0,0]

while True:
    msg = midi.receive()

    if msg is not None and not isinstance(msg, MIDIUnknownEvent):
        print(msg)
        if isinstance(msg,NoteOn):
            # change RGB color
            if msg.note is 60:
                pixel.fill((255,0,0))
                current[0] = 1
            elif msg.note is 61:
                pixel.fill((0,255,0))
                current[1] = 1
            elif msg.note is 62:
                pixel.fill((0,0,255))
                current[2] =1
        elif isinstance(msg,NoteOff):
            if msg.note is 60:
                current[0] = 0
            elif msg.note is 61:    
                current[1] = 0
            elif msg.note is 62:
                current[2] = 0

        pixel.fill((current[0]*255,current[1]*255,current[2]*255))
            
