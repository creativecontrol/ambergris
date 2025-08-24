-- Ambergris II
-- whale song and ambient loop.
-- K2 record toggle
-- K3 play/stop&reset

rate = 1.0
rec = 1.0
pre =  1.0
loop_len = 15
file_playing = 0
level_1 = 1.0
level_2 = 1.0
rate_slew = 0 -- seconds
file_len = 0


spds = {0, 1, 2, 0, 0.5, 0}

function init()
    params:add{
        type = "file",
        id = "sample_1",
        name = "sample 1",
        path = _path.audio,
        action = function(file) load_audio(file) end
    }

    -- a note on will light LED with the corrosponding color, last takes precedence
    -- another option could be a CC message where CC value = LED value
    -- params:add{ name="midi note red"}
    -- params:add{ name="midi note green"}
    -- params:add{ name="midi note blue"}
    -- audio file length - cue time, send message to LED
    params:add{
        type = "number",
        name="cue time (s)", 
        id="cue_time",
        minimum = 0,
        default = 30
    }
    softcut.enable(1,1) -- rec loop
    softcut.enable(2,1) -- sound file

    softcut.buffer(1,1)
    --softcut.buffer(file, 0, 0, -1, 1, 2)

    softcut.level(1, 1.0)
    softcut.level(2, 1.0)

    softcut.loop(1,1)
    softcut.loop(2,0)

    softcut.loop_start(1,1)
    softcut.loop_end(1,loop_len)

    softcut.position(1,1)
    softcut.fade_time(1,2)

    softcut.pan(1,-1)
    softcut.pan(2,1)

    softcut.level_input_cut(1,1, 0.5)
    softcut.rec_level(1, rec)
    softcut.pre_level(1, pre)

    softcut.phase_quant(2, 0.1)
    softcut.event_phase(poll_func)
    
    params:default()
    start_process()

end

function load_audio(file)
  loaded_file = file
  local ch,samples,samplerate=audio.file_info(file)
  local duration = (samples/48000) < 280 and (samples/48000) or 280
  file_len = duration
  print("loading "..file)
  softcut.buffer_clear_channel(2)
  softcut.buffer_read_mono(file,0,0,duration,1,2)
  softcut.loop_end(2,duration)
  softcut.position(2,0)
  softcut.rate_slew_time(2, rate_slew)
end

function start_process()
    softcut.rec(1,1)
    softcut.play(1,1)
    softcut.poll_start_phase()
    
    start_vari()
    redraw()
end

-- start via foot switch
function start_vari()
    clk = clock.run(change_speed)
end

function change_speed()
    local rate = rate
    
    while true do
        clock.sync(2/4)
        
        local rate = spds[math.random(#spds)]

        if rate ~= 0 then
    -- add some randomization to choose between 1, 2 and 0.5
            softcut.rate(1, rate)
        end
    end
end

function key(n,z)
    if n==2 and z == 1 then
        if rec==0 then rec = 1 else rec = 0 end
        softcut.rec_level(1,rec)
    end
    if n==3 and z==1 then
        if file_playing==0 then file_playing = 1 else file_playing = 0 end
        softcut.position(2,0)
        softcut.play(2,file_playing)
    end
    redraw()
end

function enc(n,d)
    if n==2 then
        level_1 = util.clamp(level_1+d/100,0,1.0)
        softcut.level(1,level_1)
    end
    if n==3 then
        level_2 = util.clamp(level_2+d/100,0,1.0)
        softcut.level(2,level_2)
    end
    redraw()
end

function redraw()
    screen.clear()
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
    screen.text("2 vol: ")
    screen.move(118,50)
    screen.text_right(string.format("%.2f",level_2))

    screen.update()
end

function poll_func()
    pos = softcut.query_position(2)
    if pos >= file_len-params:get("cue_time") then
        -- send LED message
    end
end