-- Ambergris I
-- stereo whale song.
-- K3 play/stop&reset

rate = 1.0
sideA_playing = 0
sideB_playing = 0
file_split =  300 -- 5 min in seconds
level_1 = 1.0
level_2 = 1.0
rate_slew = 0 -- seconds
file_len = 0
cue_time = 0
curr_position = 0
has_switched = false

function init()
    params:add{
        type = "file",
        id = "sample_1",
        name = "sample 1",
        path = _path.audio,
        action = function(file) load_audio(file) end
    }

    params:add{
      type = "number",
      name = "split time(s)",
      id= "split_time",
      minimum = 1,
      maximum = 300,
      default = 300,
    }
    -- a note on will light LED with the corrosponding color, last takes precedence
    -- another option could be a CC message where CC value = LED value
    params:add{
        type = "number",
        name="midi note red",
        id="note_red",
        minimum = 0,
        maximum = 127
    }
    params:add{
        type = "number",
        name="midi note green",
        id="note_grn",
        minimum = 0,
        maximum = 127

    }
    params:add{
        type = "number",
        name="midi note blue",
        id="note_blu",
        minimum = 0,
        maximum = 127

    }
    -- audio file length - cue time, send message to LED
    params:add{
        type = "number",
        name="cue time (s)",
        id="cue_time",
        minimum = 0,
        default = 30
    }
    -- buffer 1
    softcut.enable(1,1) -- file player
    softcut.level(1, 1.0)
    softcut.loop(1,0)
    softcut.loop_start(1,0)
    softcut.rate(1,1.0)


    softcut.pan(1, 0)

    softcut.phase_quant(2, 1)
    softcut.event_phase(poll_func)

    -- buffer 2
    softcut.enable(2,1) -- file player
    softcut.level(2, 1.0)
    softcut.loop(2,0)
    softcut.loop_start(2,0)
    softcut.rate(2,1.0)


    softcut.pan(2, 0)

    softcut.phase_quant(2, 1)
    softcut.event_phase(poll_func)

    params:default()
    file_split = params:get("split_time")
    out_midi = midi.connect(1)

    start_process()

end

function load_audio(file)
  loaded_file = file
  local ch,samples,samplerate=audio.file_info(file)
  local duration = (samples/48000)   -- < 280 and (samples/48000) or 280
  file_len = duration
  print("loading "..file)
  print("duration: "..(samples/48000))
  softcut.buffer(1,1)
  softcut.buffer_clear_channel(1)
  softcut.buffer_read_mono(file,0,0,file_split,1,1)
  softcut.loop_end(1, file_split)
  softcut.buffer_clear_channel(2)
  softcut.buffer_read_mono(file,file_split, 0,-1,1,2)
  softcut.loop_end(2, file_len-file_split)
  softcut.position(1,0)
  softcut.position(2,0)
  cue_time = file_len-params:get("cue_time")
end

function start_process()
    redraw()
end


function key(n,z)
    if n==3 and z==1 then

        if sideA_playing == 1 then
          stop_sideA()
        elseif sideB_playing == 1 then
          stop_sideB()

        elseif sideA_playing==0 and sideB_playing==0 then
            play_sideA()
        end
    end
    redraw()
end

function play_sideA()
  print("playing side A")
  softcut.position(1,0)
  sideA_playing = 1
  softcut.play(1,sideA_playing)
  softcut.poll_start_phase()
end

function stop_sideA()
  print("stopping sideA")
  sideA_playing = 0
  softcut.play(1,sideA_playing)
end

function play_sideB()
  print("playing side B")
  softcut.position(2,0)
  sideB_playing = 1
  softcut.play(2,sideB_playing)
  softcut.poll_start_phase()
end

function stop_sideB()
  print("stopping sideB")
  sideB_playing = 0
  softcut.play(1,sideB_playing)
end

function enc(n,d)
    if n==2 then
        level_1 = util.clamp(level_1+d/100,0,1.0)
        softcut.level(1,level_1)
    end
    if n==3 then
        -- level_2 = util.clamp(level_2+d/100,0,1.0)
        -- softcut.level(2,level_2)
    end
    redraw()
end

function redraw()
    screen.clear()
    screen.move(10,10)
    screen.text("position: ")
    screen.move(118,10)
    screen.text_right(string.format("%d",curr_position))
    screen.move(10,20)
    screen.text("cue_time: ")
    screen.move(118,20)
    screen.text_right(string.format("%.2f",cue_time))
    screen.move(10,30)
    screen.text("rate: ")
    screen.move(118,30)
    screen.text_right(string.format("%.2f",rate))
    screen.move(10,40)
    screen.text("rec: ")
    screen.move(118,40)
    screen.text_right(string.format("%.2f",rec))
    screen.move(10,50)
    screen.text("1 vol: ")
    screen.move(50,50)
    screen.text_right(string.format("%.2f",level_1))
    screen.move(60,50)
    screen.text("playing?: ")
    screen.move(118,50)
    if sideA_playing==1 or sideB_playing==1 then
      screen.text_right("true")
    else
      screen.text_right("false")
    end

    screen.update()
end

-- check where we are in the file
-- if < file_split keep going
-- if >= file_split play buffer 2 and show blue LED check for cue_time
-- x senconds after switching change LED to GRN
-- if >= cue_time then send LED message
function poll_func(voice, position)
    if voice == 1 then
      curr_position = position
    elseif voice == 2 and sideB_playing==1 then
      curr_position = position+file_split
    end
    redraw()
    -- print("polling fuction")
    print("voice: "..voice.." pos: "..position)
     if file_len then
      if sideA_playing==1 and curr_position >= file_split then
        print("file has reached the end of sideA and will switch")
        sideA_playing = 0
        play_sideB()
      elseif sideB_playing==1 and curr_position >= file_split+10 and not has_switched then
        has_switched = true
      elseif sideB_playing==1 and curr_position >= cue_time then
        print("cue time reached")
        end
    end
end

