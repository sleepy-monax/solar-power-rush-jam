gamepad = nil
as_gamepad = false

function setup_game()
  end_game = false
  delta_time = 0
  elapsed_time = 0
  is_game_finish = false
  is_game_win = false
  is_start_screen = true
  DEBUG = false
  nuclear_reactor_thrown = false
  nuclear_reactor_x = 0
  nuclear_reactor_y = love.graphics.getHeight()
  exploding = false
  exploding_time = 0
  fever_mode = false

  key_up = false
  key_down = false
  key_left = false
  key_right = false
  key_shoot = false
  spawn_disable = false
  spaceship_height = 64
  spaceship_width = 64
  spaceship_x = love.graphics.getWidth() / 2 - spaceship_width /2
  spaceship_y = 0
  spaceship_old_power = 10000
  spaceship_power = 10000
  spaceship_power_lost = 0
  spaceship_power_lost_sample = 0
  spaceship_max_heal = 100
  spaceship_heal = 50
  spaceship_max_speed = 10
  spaceship_speed_x = 0
  spaceship_speed_y = 0
  spaceship_speed_up_x = false
  spaceship_speed_up_y = false
  spaceship_bullet = {}
  spaceship_bullet_count = 0
  spaceship_takedamages = 0

  ennemies = {}
  ennemies_count = 0

  shoot_cooldown = 100
  background_location = 0
  error_message = "GAME_IS_OVER"

  boss_spawned = false
end

function handle_input()
  local past_key_shoot = key_shoot
  key_up = love.keyboard.isDown("w")
  key_down = love.keyboard.isDown("s")
  key_left = love.keyboard.isDown("a")
  key_right = love.keyboard.isDown("d")
  key_shoot = love.keyboard.isDown("space")

  key_trow_nuclear_reactor = love.keyboard.isDown("e")

  if as_gamepad then
    key_up = key_up or gamepad:isGamepadDown("dpup")
    key_down = key_down or gamepad:isGamepadDown("dpdown")

    key_left = key_left or gamepad:isGamepadDown("dpleft")
    key_right = key_right or gamepad:isGamepadDown("dpright")
    key_shoot = key_shoot or gamepad:isGamepadDown("a")
    key_trow_nuclear_reactor = key_trow_nuclear_reactor or gamepad:isGamepadDown("b")

    if gamepad:getGamepadAxis("triggerleft") > 0.75 then
      key_down = true
    end

    if gamepad:getGamepadAxis("triggerright") > 0.75 then
      key_up = true
    end

    if gamepad:getGamepadAxis("leftx") > 0.75 then
      key_right = true
    end

    if gamepad:getGamepadAxis("leftx") < -0.75 then
      key_left = true
    end

  end

    key_shoot_press = not past_key_shoot and key_shoot
end

function love.joystickadded(joystick)
   gamepad = joystick
   as_gamepad = true
end

function love.load(arg)
  love.graphics.setDefaultFilter("nearest", "nearest", 0)

  asset_background = love.graphics.newImage("assets/background/background.png")
  asset_background_cloud = love.graphics.newImage("assets/background/background_cloud.png")
  asset_background_stars_a = love.graphics.newImage("assets/background/background_stars_a.png")
  asset_background_stars_b = love.graphics.newImage("assets/background/background_stars_b.png")
  asset_background_stars_c = love.graphics.newImage("assets/background/background_stars_c.png")

  asset_spaceship = love.graphics.newImage("assets/spaceship.png")
  asset_spacerock = love.graphics.newImage("assets/spacerock.png")
  asset_spacerock_frag = love.graphics.newImage("assets/spacerock_frag.png")
  asset_spacestation = love.graphics.newImage("assets/spacestation.png")
  asset_spacestation_right = love.graphics.newImage("assets/spacestation_right.png")
  asset_truster = love.graphics.newImage("assets/truster.png")
  asset_shield = love.graphics.newImage("assets/shield.png")
  asset_bullet = love.graphics.newImage("assets/bullet.png")
  asset_warning = love.graphics.newImage("assets/warning.png")
  asset_power = love.graphics.newImage("assets/power.png")
  asset_heal = love.graphics.newImage("assets/healpack.png")
  asset_spacestation_frag = love.graphics.newImage("assets/spacestation_frag.png")
  asset_fever = love.graphics.newImage("assets/fever.png")
  asset_fever_overlay = love.graphics.newImage("assets/fever_overlay.png")
  asset_nuclear_reactor = love.graphics.newImage("assets/nuclear.png")
  asset_satellite = love.graphics.newImage("assets/satellite.png")
  asset_spacestation_big_frag = love.graphics.newImage("assets/spacestation_big_frag.png")
  asset_sun = love.graphics.newImage("assets/sun.png")
  asset_sun_power = love.graphics.newImage("assets/sun_power.png")
  asset_gameover = love.graphics.newImage("assets/gameover.png")
  asset_overlay = love.graphics.newImage("assets/overlay.png")
  asset_trow_msg = love.graphics.newImage("assets/throw_msg.png")
  asset_win = love.graphics.newImage("assets/win.png")
  asset_damage_overlay = love.graphics.newImage("assets/damage_overlay.png")
  asset_bad_spaceship_frag = love.graphics.newImage("assets/bad_spaceship_frag.png")
  asset_bad_spaceship = love.graphics.newImage("assets/bad_spaceship.png")
  asset_bad_bullet = love.graphics.newImage("assets/bad_bullet.png")

  -- Boss ----------------------------------------------------------------------
  assets_boss_a = love.graphics.newImage("assets/boss_a.png")
  assets_boss_b = love.graphics.newImage("assets/boss_b.png")
  assets_boss_c = love.graphics.newImage("assets/boss_c.png")
  assets_boss_shield = love.graphics.newImage("assets/boss_shield.png")

  assets_engine_a = love.graphics.newImage("assets/boss_engine_a.png")
  assets_engine_b = love.graphics.newImage("assets/boss_engine_b.png")

  asset_explosion = love.audio.newSource("assets/explosion.wav", "stream")
  asset_speedup = love.audio.newSource("assets/speed_up.wav", "stream")
  asset_loop = love.audio.newSource("assets/loop.wav", "stream")

  setup_game()
end

function love.update(dt)
  handle_input()

  if is_start_screen then

    background_location = background_location + dt * 100

    if key_shoot then
      is_start_screen = false
    end
  else

  asset_speedup:play()
  asset_speedup:setLooping(true)
  asset_loop:play()
  asset_loop:setLooping(true)
  local pitch = 0.1 + (spaceship_heal / spaceship_max_heal)
  if pitch <= 0 then pitch = 0.1 end
    asset_loop:setPitch(pitch)

    if not is_game_finish then
      delta_time = delta_time + dt
      elapsed_time = elapsed_time + dt

      if spaceship_y > 47000 then
        spawn_disable = true
      end

      if spaceship_y > 50000 then
        spaceship_y = 50000
        spaceship_speed_y = 0
        end_game = true
      end

      update_soundmanager()
      update_spaceship(dt)
      update_bulet()
      update_ennemy(dt)
      update_ennemy_spawning(dt)
    else
      if key_shoot_press then
        asset_loop:setVolume(1)
        setup_game();
      end

      asset_speedup:stop()
    end
  end

  if spaceship_heal > spaceship_max_heal * 1.1 then
    spaceship_heal = spaceship_max_heal * 1.1
  end
  fever_mode = spaceship_max_heal < spaceship_heal

  if nuclear_reactor_y < 0 then
    nuclear_reactor_y = 100000000
    asset_loop:setVolume(0.5)
    exploding = true
  end
end

function love.draw()
  height_scale_factor = love.graphics.getHeight() / 600
  width_scale_factor =  love.graphics.getWidth() / 800

  love.graphics.draw(asset_background, 0, math.floor(background_location ) % love.graphics.getHeight() - love.graphics.getHeight(), 0, width_scale_factor, height_scale_factor)
  love.graphics.draw(asset_background, 0, math.floor(background_location ) % love.graphics.getHeight(), 0, width_scale_factor, height_scale_factor)

  love.graphics.draw(asset_background_cloud, 0, math.floor(background_location * 1.1 ) % love.graphics.getHeight() - love.graphics.getHeight(), 0, width_scale_factor, height_scale_factor)
  love.graphics.draw(asset_background_cloud, 0, math.floor(background_location * 1.1 ) % love.graphics.getHeight(), 0, width_scale_factor, height_scale_factor)

  love.graphics.draw(asset_background_stars_a, 0, math.floor(background_location * 1.2 ) % love.graphics.getHeight() - love.graphics.getHeight(), 0, width_scale_factor, height_scale_factor)
  love.graphics.draw(asset_background_stars_a, 0, math.floor(background_location * 1.2 ) % love.graphics.getHeight(), 0, width_scale_factor, height_scale_factor)

  love.graphics.draw(asset_background_stars_b, 0, math.floor(background_location * 1.5 ) % love.graphics.getHeight() - love.graphics.getHeight(), 0, width_scale_factor, height_scale_factor)
  love.graphics.draw(asset_background_stars_b, 0, math.floor(background_location * 1.5 ) % love.graphics.getHeight(), 0, width_scale_factor, height_scale_factor)

  love.graphics.draw(asset_background_stars_c, 0, math.floor(background_location * 1.9 ) % love.graphics.getHeight() - love.graphics.getHeight(), 0, width_scale_factor, height_scale_factor)
  love.graphics.draw(asset_background_stars_c, 0, math.floor(background_location * 1.9 ) % love.graphics.getHeight(), 0, width_scale_factor, height_scale_factor)


  if exploding then

    exploding_time = exploding_time + 1

    if exploding_time == 128 then
      asset_explosion:play()
      asset_explosion:setPitch(0.5)
      asset_explosion:setVolume(10)
      asset_explosion:setLooping(false)
    end

    if exploding_time > 128 and exploding_time < 180  then
      love.graphics.push()
      love.graphics.translate(math.random(-100, 100) / 100 * exploding_time / 2, 0)
    end


  end

  if is_start_screen then
    love.graphics.print("Spaceship OS BIOS v1.05 BUILD 265\n(c)2998 - 3017 Maker corp.\n\n\n\n\nQUANDTUM CPU at 9Ghz\nMemory Test: 94654654498444564 OK\nThis game was made by Nicolas \"TheMonax\" Van Bossuyt in 48h for the 39th Ludum Dare.", 32,  32)
    love.graphics.print("Press [SPACE] to play. Use [W/A/S/D] to move and [Space] to shoot.", 32,  love.graphics.getHeight() - 32)
    love.graphics.rectangle("line", 4, 4, love.graphics.getWidth() - 8, love.graphics.getHeight() - 8)
  else

  if not is_game_finish then
    love.graphics.draw(asset_sun, 0, spaceship_y - 50000, 0, width_scale_factor, height_scale_factor)

    love.graphics.push()
    love.graphics.translate(math.random(-1, 1) * (spaceship_speed_y / spaceship_max_speed), 0)
    draw_ennemy()
    draw_bulet()
    draw_spaceship()
    love.graphics.draw(asset_nuclear_reactor, nuclear_reactor_x, nuclear_reactor_y, 0, 1, 1)
    love.graphics.pop()
    if spaceship_max_heal < spaceship_heal then
      love.graphics.setColor(255, 255, 255, 200 * math.sin(elapsed_time * 10))
      love.graphics.draw(asset_fever_overlay, 0, 0, 0, width_scale_factor, height_scale_factor) -- , r, sx, sy, ox, oy, kx, ky)
      love.graphics.setColor(255, 255, 255, 255)
    end

    if (end_game and not exploding) then
      love.graphics.draw(asset_trow_msg, 0, 25 * math.sin(elapsed_time * 10), 0, width_scale_factor, height_scale_factor) -- , r, sx, sy, ox, oy, kx, ky)
    end

    draw_hud()
  else

    if is_game_win then
      love.graphics.setColor(0, 0, 0, 255)
    else
      love.graphics.setColor(0, 0, 128, 255)
    end

    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.rectangle("line", 4, 4, love.graphics.getWidth() - 8, love.graphics.getHeight() - 8)
    love.graphics.print(":(\nYour Spaceship ran into a problem that it could handle.\nYon can search for the error online: " .. error_message, 32,  32)
    love.graphics.print("Press SPACE to restart", 32,  love.graphics.getHeight() - 32)
    if is_game_win then love.graphics.draw(asset_win, 0, 0, 0, width_scale_factor, height_scale_factor) end
  end


end

if exploding and exploding_time < 256 then
  love.graphics.setColor(255, 255, 255, exploding_time / 2)
  love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
end

if exploding and exploding_time > 225 then
  is_game_finish = true
  is_game_win = true
  error_message = "YOU_WIN"
  asset_loop:setPitch(1.1)
  exploding = false
  spaceship_heal = spaceship_max_heal * 1.1
end

if  exploding and exploding_time > 128 and exploding_time < 180  then
  love.graphics.pop()
end

love.graphics.draw(asset_overlay, 0, 0, 0, width_scale_factor, height_scale_factor)
end

-- HUD -------------------------------------------------------------------------
function draw_hud (args)
  if spaceship_power < 1000 then
    love.graphics.setColor( 255, 0, 0, 100 * math.sin(elapsed_time * 10) )
    love.graphics.rectangle("fill", 14, 12, 310, 24)
    love.graphics.setColor( 255, 255, 255, 255 )
  end

  -- Power progress bar
  love.graphics.print("Power ", 16, 16)
  love.graphics.setColor( 255 - 255 * spaceship_power / 10000, 255 * spaceship_power / 10000, 0, 255 )
  love.graphics.rectangle("line", 64, 16, 256, 16)
  love.graphics.rectangle("fill", 66, 18, (252 * spaceship_power / 10000) , 12)

  love.graphics.setColor( 0, 0, 255, 255 )
  love.graphics.rectangle("fill", 66 + (252 * spaceship_power / 10000), 18, (252 * spaceship_power_lost_sample / 10000) , 12)
  love.graphics.setColor( 255, 255, 255, 255 )

  love.graphics.print("Speed ", 16, 40)
  love.graphics.rectangle("line", 64, 40, 256, 16)
  love.graphics.rectangle("fill", 66, 42, 252 * spaceship_speed_y / spaceship_max_speed, 12)
  love.graphics.setColor( 255, 255, 255, 255 )

  love.graphics.print("Heal ", 16, 64)
  love.graphics.rectangle("line", 64, 64, 256, 16)
  if spaceship_max_heal < spaceship_heal then
    love.graphics.setColor( math.random(0, 255), math.random(0, 255), math.random(0, 255), math.random(0, 255) )
  end
  love.graphics.rectangle("fill", 66, 66, 252 * spaceship_heal / spaceship_max_heal, 12)
  love.graphics.setColor( 255, 255, 255, 255 )

if not nuclear_reactor_thrown then
  love.graphics.draw(asset_warning, 26, 94, math.sin(elapsed_time * 10) / 3, 1, 1, 8, 8) -- , r, sx, sy, ox, oy, kx, ky)
  love.graphics.print("Nuclear reactor damaged !",  64, 88)
end
  if end_game then
  love.graphics.draw(asset_sun_power, 12, 112) -- , r, sx, sy, ox, oy, kx, ky)
  love.graphics.print("Sun Powered !",  32, 112)
  end

  love.graphics.rectangle("line", love.graphics.getWidth() - 80, 16, 64, love.graphics.getHeight() - 32)
  love.graphics.draw(asset_sun, love.graphics.getWidth() - 80, 16, 0, 64 / 800)
  love.graphics.draw(asset_spaceship, love.graphics.getWidth() - 80 + 16, (love.graphics.getHeight() - 32) -  (love.graphics.getHeight() - 32) * spaceship_y / 50000)


  if spaceship_max_heal < spaceship_heal then
    love.graphics.draw(asset_fever, 64, 16, math.sin(elapsed_time * 10) / 10, 1, 1, 8, 8) -- , r, sx, sy, ox, oy, kx, ky)
  end

  love.graphics.print("spaceship OS 1.25.4846 BUILD 5465 - Use [W/A/S/D] to move and [Space] to shoot.", 16,  love.graphics.getHeight() - 32)
  love.graphics.rectangle("line", 4, 4, love.graphics.getWidth() - 8, love.graphics.getHeight() - 8)
  love.graphics.setColor( 255, 255, 255, 255 )
end

-- Space ship ------------------------------------------------------------------
function draw_spaceship()
  love.graphics.draw(asset_spaceship, spaceship_x + math.random(0, spaceship_speed_y) / 5, love.graphics.getHeight() - spaceship_height - 64, 0, 2, 2 - (spaceship_speed_y / spaceship_max_speed) / 10)
  love.graphics.setColor( 255, 255, 255, 255 * (spaceship_speed_y / spaceship_max_speed))
  love.graphics.draw(asset_truster, spaceship_x + math.random(0, spaceship_speed_y) / 5, love.graphics.getHeight() - spaceship_height - 64, 0, 2, 2 - (spaceship_speed_y / spaceship_max_speed) / 10)
  love.graphics.setColor( 255, 255, 255, spaceship_takedamages)
  love.graphics.draw(asset_shield, spaceship_x + math.random(0, spaceship_speed_y) / 5, love.graphics.getHeight() - spaceship_height - 64, 0, 2, 2 - (spaceship_speed_y / spaceship_max_speed) / 10)
  love.graphics.draw(asset_damage_overlay, 0, 0, 0, width_scale_factor, height_scale_factor)
  love.graphics.setColor( 255, 255, 255, 255 )
  if DEBUG then love.graphics.rectangle("line", spaceship_x, love.graphics.getHeight() - spaceship_height, spaceship_width, spaceship_height) end

end

function update_spaceship(dt)
  if key_shoot then
    spaceship_shootbullet(spaceship_x + 28)
  end

  if nuclear_reactor_thrown then
    nuclear_reactor_y = nuclear_reactor_y - 25
  end

  if (end_game) then
    spaceship_power = spaceship_power + 10
    if spaceship_power > 10000 then
      spaceship_power = 10000
    end

  end

  -- Get player input.
  spaceship_speed_up_y = false
  spaceship_speed_up_x = false
  if key_up then
    spaceship_speed_y = spaceship_speed_y + 5.0 * dt
    spaceship_speed_up_y = true
  end

  if key_trow_nuclear_reactor and end_game and not nuclear_reactor_thrown then
    nuclear_reactor_thrown = true
    nuclear_reactor_x = spaceship_x
  end

  if key_down then
    spaceship_speed_y = spaceship_speed_y - 5.0 * dt
    spaceship_speed_up_y = true
  end

  if key_left then
    spaceship_speed_x = spaceship_speed_x - 100.0 * dt
    spaceship_speed_up_x = true
  end

  if key_right then
    spaceship_speed_x = spaceship_speed_x + 100.0 * dt
    spaceship_speed_up_x = true
  end

  if not spaceship_speed_up_x then
    spaceship_speed_x = spaceship_speed_x / 1.1
  end

  -- Apply input to the space ship
  -- x speed
  if spaceship_speed_x > spaceship_max_speed then
    spaceship_speed_x = spaceship_max_speed
  end

  if spaceship_speed_x < 0 - spaceship_max_speed then
    spaceship_speed_x = 0 - spaceship_max_speed
  end

  spaceship_x = spaceship_x + spaceship_speed_x


  -- y speed
  if spaceship_speed_y > spaceship_max_speed then
    spaceship_speed_y = spaceship_max_speed
  end

  if spaceship_speed_y < 0 then
    spaceship_speed_y = 0
  end

  spaceship_y = spaceship_y + spaceship_speed_y
  background_location = background_location + spaceship_speed_y / 2

  if spaceship_x < 0 then
    spaceship_x = 0
  end

  if spaceship_x + spaceship_width > love.graphics.getWidth() then
    spaceship_x = love.graphics.getWidth() - spaceship_width
  end

  -- Update shield
  if spaceship_takedamages > 0 then
    spaceship_takedamages = spaceship_takedamages / 1.1
  end

  -- Update power
  spaceship_power = spaceship_power - 1
  if spaceship_speed_up_y then
    spaceship_power = spaceship_power - spaceship_speed_y
  end

  if spaceship_speed_up_x then
    spaceship_power = spaceship_power - math.abs(spaceship_speed_x)
  end

  spaceship_power_lost_sample = spaceship_power_lost_sample + spaceship_old_power - spaceship_power
  spaceship_old_power = spaceship_power

  if delta_time > 1 then
    spaceship_power_lost = spaceship_power_lost_sample
    delta_time = 0
    spaceship_power_lost_sample = 0
  end

  if spaceship_power <= 0 or spaceship_heal <= 0 then
    -- Game over
    is_game_finish = true
    is_game_win = false

  end


  asset_speedup:setVolume((spaceship_speed_y / spaceship_max_speed) / 2)
  asset_speedup:setPitch(1 + (spaceship_speed_y / spaceship_max_speed) / 2)
end



function spaceship_shootbullet(x)
  if (shoot_cooldown == 0) then
    spaceship_bullet[spaceship_bullet_count] = {x = x, y = love.graphics.getHeight() - 32 - 64, speed = 10}
    spaceship_bullet_count = spaceship_bullet_count + 1
    if fever_mode then
      spaceship_power = spaceship_power - 10
      shoot_cooldown = 10
    else
      spaceship_power = spaceship_power - 27
      shoot_cooldown = 20
    end

    soundmanager_play("assets/shoot.wav")
  end
end

function update_bulet()

  if shoot_cooldown > 0 then
    shoot_cooldown = shoot_cooldown - 1
  end

  for k,v in pairs(spaceship_bullet) do
    v["y"] = v["y"] - v["speed"]
    if v["y"] < -250 then
      spaceship_bullet[k] = nil
    else
      for i,e in pairs(ennemies) do
        if CheckCollision(e["x"], e["y"], e["width"], e["height"], v["x"], v["y"], 2, 2) and e["colide"] then
          spaceship_lazers_colide_ennemy(i,e)
          spaceship_bullet[k] = nil
        end
      end
    end
  end
end

function draw_bulet()
  for k,v in pairs(spaceship_bullet) do
    love.graphics.draw(asset_bullet, v["x"], v["y"], 0, 2, 2)
  end
end

-- Ennemy ----------------------------------------------------------------------

function create_ennemy(x, y, speed_x, speed_y, type, state)
ennemies[ennemies_count] =  {
                              type = type, -- type of the ennemy.
                              x = x, -- X position
                              y = y, -- y position
                              height = 64,
                              width = 64,
                              speed_x = speed_x,
                              speed_y = speed_y,
                              rotation = 0,
                              rotation_speed = math.random(-100, 100) / 1000,
                              colide = true
                            }

  if type == "engine" then
    ennemies[ennemies_count]["height"] = 160
    ennemies[ennemies_count]["width"] = 40
    ennemies[ennemies_count]["state"] = state
    ennemies[ennemies_count]["rotation_speed"] = 0
    ennemies[ennemies_count]["speed_y"] = 1
    ennemies[ennemies_count]["speed_x"] = 0
  end

  if type == "boss" then
    ennemies[ennemies_count]["height"] = 256
    ennemies[ennemies_count]["width"] = 128
    ennemies[ennemies_count]["cooldown"] = 25
    ennemies[ennemies_count]["heal"] = 5
    ennemies[ennemies_count]["state"] = 0

    ennemies[ennemies_count]["rotation_speed"] = 0
    ennemies[ennemies_count]["speed_y"] = 10
    ennemies[ennemies_count]["speed_x"] = 0
    ennemies[ennemies_count]["take_damage"] = 0
  end

  if type == "satellite" then
    ennemies[ennemies_count]["height"] = 128
    ennemies[ennemies_count]["width"] = 128
    ennemies[ennemies_count]["rotation_speed"] = math.random(-10, 10) / 10000
  end

  if type == "bad_bullet" then
    ennemies[ennemies_count]["height"] = 8
    ennemies[ennemies_count]["width"] = 8
    ennemies[ennemies_count]["colide"] = false
    ennemies[ennemies_count]["speed_y"] = 10
    ennemies[ennemies_count]["not_speed_relative"] = true
  end

  if type == "bad_spaceship" then
    ennemies[ennemies_count]["height"] = 64
    ennemies[ennemies_count]["width"] = 64
    ennemies[ennemies_count]["cooldown"] = 25
    ennemies[ennemies_count]["lifetime"] = 300
    ennemies[ennemies_count]["rotation_speed"] = 0
    ennemies[ennemies_count]["speed_y"] = 10
    ennemies[ennemies_count]["speed_x"] = 0
    ennemies[ennemies_count]["not_speed_relative"] = true
  end

  if type == "spacestation" then
    ennemies[ennemies_count]["rotation_speed"] = 0
    ennemies[ennemies_count]["height"] = 43 * 2
    ennemies[ennemies_count]["width"] = 326 * 2
    ennemies[ennemies_count]["right"] = math.random(0, 1)
    if (ennemies[ennemies_count]["right"] == 0) then
      ennemies[ennemies_count]["x"] = love.graphics.getWidth() - ennemies[ennemies_count]["width"]
    end
  end

  if type == "smoke" then
    ennemies[ennemies_count]["height"] = 32
    ennemies[ennemies_count]["width"] = 32
    ennemies[ennemies_count]["lifetime"] = 255
    ennemies[ennemies_count]["colide"] = false
  end

  if type == "space_rock_frag" then
    ennemies[ennemies_count]["height"] = 32
    ennemies[ennemies_count]["width"] = 32
    ennemies[ennemies_count]["lifetime"] = 255
    ennemies[ennemies_count]["colide"] = false
  end

  if type == "bad_spaceship_frag" then
    ennemies[ennemies_count]["height"] = 32
    ennemies[ennemies_count]["width"] = 32
    ennemies[ennemies_count]["lifetime"] = 255
    ennemies[ennemies_count]["colide"] = false
  end

  if type == "spacestation_big_frag" then
    ennemies[ennemies_count]["height"] = 43 * 2
    ennemies[ennemies_count]["width"] = 97 * 2
    ennemies[ennemies_count]["lifetime"] = 255
    ennemies[ennemies_count]["colide"] = false
  end

  if type == "spacestation_frag" then
    ennemies[ennemies_count]["height"] = 32
    ennemies[ennemies_count]["width"] = 32
    ennemies[ennemies_count]["lifetime"] = 255
    ennemies[ennemies_count]["colide"] = false
  end

if type == "heal_pack" then
  ennemies[ennemies_count]["height"] = 32
  ennemies[ennemies_count]["width"] = 32
  ennemies[ennemies_count]["lifetime"] = 255
  ennemies[ennemies_count]["colide"] = false
end

if type == "power_pack" then
  ennemies[ennemies_count]["height"] = 32
  ennemies[ennemies_count]["width"] = 32
  ennemies[ennemies_count]["lifetime"] = 255
  ennemies[ennemies_count]["colide"] = false
end

  ennemies_count = ennemies_count + 1
end

function draw_ennemy()
  for i,e in pairs(ennemies) do
    if DEBUG then love.graphics.rectangle("line", e["x"], e["y"], e["width"], e["height"]) end
    if e["type"] == "space_rock" then
      love.graphics.draw(asset_spacerock, e["x"] + 32, e["y"] + 32, e["rotation"], 2, 2, 16, 16)
      e["rotation"] = e["rotation"] + e["rotation_speed"]
    end

    if e["type"] == "satellite" then
      love.graphics.draw(asset_satellite, e["x"] + 64, e["y"] + 64, e["rotation"], 2, 2, 32, 32)
      e["rotation"] = e["rotation"] + e["rotation_speed"]
    end

    if e["type"] == "bad_spaceship" then
      love.graphics.draw(asset_bad_spaceship, e["x"], e["y"], e["rotation"], 2, 2)
    end

    if e["type"] == "boss" then

      if e["state"] == 0 then
        love.graphics.draw(assets_boss_a, e["x"] - 64, e["y"], e["rotation"], 2, 2)
      end
      if e["state"] == 1 then
        love.graphics.draw(assets_boss_b, e["x"] - 64, e["y"], e["rotation"], 2, 2)
      end
      if e["state"] == 2 then
        love.graphics.draw(assets_boss_c, e["x"] - 64, e["y"], e["rotation"], 2, 2)
      end
      love.graphics.setColor(255, 255, 255, e["take_damage"])
      love.graphics.draw(assets_boss_shield, e["x"] - 64, e["y"], e["rotation"], 2, 2)
      love.graphics.setColor(255, 255, 255, 255)
    end

    if e["type"] == "engine" then
      if e["state"] == 0 then
        love.graphics.draw(assets_engine_a, e["x"], e["y"], e["rotation"], 2, 2)
      end
      if e["state"] == 1 then
        love.graphics.draw(assets_engine_b, e["x"], e["y"], e["rotation"], 2, 2)
      end
    end

    if e["type"] == "bad_bullet" then
      love.graphics.draw(asset_bad_bullet, e["x"], e["y"] - 60, 0, 2, 2)
    end

    if e["type"] == "space_rock_frag" then
      love.graphics.setColor( 255, 255, 255, e["lifetime"] )
      love.graphics.draw(asset_spacerock_frag, e["x"] + 16, e["y"] + 16, e["rotation"], 2, 2, 8, 8)
      e["rotation"] = e["rotation"] + e["rotation_speed"]
        love.graphics.setColor( 255, 255, 255, 255 )
    end

    if e["type"] == "bad_spaceship_frag" then
      love.graphics.setColor( 255, 255, 255, e["lifetime"] )
      love.graphics.draw(asset_bad_spaceship_frag, e["x"] + 16, e["y"] + 16, e["rotation"], 2, 2, 8, 8)
      e["rotation"] = e["rotation"] + e["rotation_speed"]
        love.graphics.setColor( 255, 255, 255, 255 )
    end

    if e["type"] == "spacestation_frag" then
      love.graphics.setColor( 255, 255, 255, e["lifetime"] )
      love.graphics.draw(asset_spacestation_frag, e["x"] + 16, e["y"] + 16, e["rotation"], 2, 2, 8, 8)
      e["rotation"] = e["rotation"] + e["rotation_speed"]
        love.graphics.setColor( 255, 255, 255, 255 )
    end

    if e["type"] == "spacestation_big_frag" then
      love.graphics.draw(asset_spacestation_big_frag, e["x"] + 16, e["y"] + 16, e["rotation"], 2, 2, 8, 8)
    end

    if e["type"] == "spacestation" then
      if e["right"] == 0 then
        love.graphics.draw(asset_spacestation_right, e["x"], e["y"], e["rotation"], 2, 2)
      else
        love.graphics.draw(asset_spacestation, e["x"], e["y"], e["rotation"], 2, 2)
      end

    end

    if e["type"] == "heal_pack" then
      love.graphics.setColor( 255, 255, 255, e["lifetime"] )
      love.graphics.draw(asset_heal, e["x"] + 16, e["y"] + 16, e["rotation"], 2, 2, 8, 8)
      e["rotation"] = e["rotation"] + e["rotation_speed"]
        love.graphics.setColor( 255, 255, 255, 255 )
    end

    if e["type"] == "power_pack" then
      love.graphics.setColor( 255, 255, 255, e["lifetime"] )
      love.graphics.draw(asset_power, e["x"] + 16, e["y"] + 16, e["rotation"], 2, 2, 8, 8)
      e["rotation"] = e["rotation"] + e["rotation_speed"]
        love.graphics.setColor( 255, 255, 255, 255 )
    end

  end
end

test = 0
test_2 = 0
function update_ennemy(dt)
  for i,e in pairs(ennemies) do
    local is_death = false
    e["x"] = e["x"] + e["speed_x"]


    if not e["not_speed_relative"] then
      e["y"] = e["y"] + e["speed_y"] + spaceship_speed_y
    else
      e["y"] = e["y"] + e["speed_y"]
    end

    if e["type"] == "bad_spaceship" then

      e["lifetime"] = e["lifetime"] - 1
      e["speed_y"] = e["speed_y"] + 0.1



      if e["y"] > 16 and not (e["lifetime"] < 0) then
        e["speed_y"] = 0

        if not (math.abs(spaceship_x - e["x"]) > 128) then
          e["x"] = e["x"] + (spaceship_x - e["x"]) * 0.1
        else
          if spaceship_x > e["x"] then
            e["speed_x"] = e["speed_x"] + 1
          else
            e["speed_x"] = e["speed_x"] - 1
          end
        end

        if e["speed_x"] > spaceship_max_speed then
          e["speed_x"] = spaceship_max_speed
        end

        if e["speed_x"] < -spaceship_max_speed then
          e["speed_x"] = -spaceship_max_speed
        end

        if e["cooldown"] <= 0 then
          create_ennemy(e["x"] + 62, e["y"] + 30, 0, 1, "bad_bullet")
          soundmanager_play("assets/shoot.wav")
          e["cooldown"] = 25
        end

        e["cooldown"] = e["cooldown"] - 1
      end
    end

    -- Boss --------------------------------------------------------------------
    if e["type"] == "boss" then
      e["speed_y"] = e["speed_y"] + 0.1

      if e["take_damage"] > 0 then e["take_damage"] = e["take_damage"] / 1.1 end

      if e["y"] >= 16 then
        e["speed_y"] = 0
        e["y"] = 16

        if not (math.abs(spaceship_x - e["x"]) > 128) then
          e["x"] = e["x"] + (spaceship_x - e["x"]) * 0.1
        else
          if spaceship_x > e["x"] then
            e["speed_x"] = e["speed_x"] + 1
          else
            e["speed_x"] = e["speed_x"] - 1
          end
        end

        if e["speed_x"] > spaceship_max_speed then
          e["speed_x"] = spaceship_max_speed * 0.1
        end

        if e["speed_x"] < -spaceship_max_speed then
          e["speed_x"] = -spaceship_max_speed * 0.1
        end

        if e["cooldown"] <= 0 then

          create_ennemy(e["x"] + 62, e["y"] + 30, 0, 1, "bad_bullet")

          if e["state"] == 0 then
            create_ennemy(e["x"] + 62 - 41, e["y"] + 30, 0, 1, "bad_bullet")

          end

          if e["state"] < 2 then
            create_ennemy(e["x"] + 62 + 41, e["y"] + 30, 0, 1, "bad_bullet")
          end

          soundmanager_play("assets/shoot.wav")
          e["cooldown"] = 40
        end

        e["cooldown"] = e["cooldown"] - 1
      end

    end

    -- Ennemies bullets ----------------------------------------------------------------
    if e["type"] == "bad_bullet" then
      for k,v in pairs(ennemies) do
        if not (v["type"] == "bad_bullet" or v["type"] == "bad_spaceship" or v["type"] == "boss") then
          if CheckCollision(e["x"], e["y"], e["width"], e["height"], v["x"], v["y"], v["width"], v["height"]) then

            spaceship_lazers_colide_ennemy(k,v)

          end
        end
      end
    end

    -- Fragments ---------------------------------------------------------------
    if e["type"] == "space_rock_frag" or e["type"] == "spacestation_frag" or e["type"] == "bad_spaceship_frag" then
      e["lifetime"] = e["lifetime"] - 1
      if e["lifetime"] == 0 then
        is_death = true
      end
    end

    if CheckCollision(e["x"], e["y"], e["width"], e["height"], spaceship_x, love.graphics.getHeight() - spaceship_height - 64, spaceship_width, spaceship_height) then
      ennemy_colide_space_ship(i,e)
    end

    if (e["y"]) > love.graphics.getHeight() + 300 or is_death then
      ennemies[i] = nil
    end
  end
end

function update_ennemy_spawning(dt)
  if not spawn_disable then
    spawnrate = (spaceship_speed_y + 1) * width_scale_factor
    if fever_mode then spawnrate = spawnrate * 2 end

    if math.random(0, 500 / spawnrate) == 0 then
      create_ennemy(math.random(0, love.graphics.getWidth()),math.random(-500, -250), math.random(-100, 100) / 100,1,"space_rock")
    end

    if math.random(0, 10000 / spawnrate)  == 0 then
      create_ennemy(0, -500, 0, 1, "spacestation")
    end

    if math.random(0, 10000 / spawnrate)  == 0 then
      create_ennemy(math.random(0, love.graphics.getWidth()), -500, 0, 1, "bad_spaceship")
    end

    if math.random(0, 5000 / spawnrate)  == 0 then
      create_ennemy(math.random(0, love.graphics.getWidth()),math.random(-500, -250), math.random(-100, 100) / 100,1, "satellite")
    end

    if not boss_spawned and spaceship_y > 25000 then
      create_ennemy(math.random(0, love.graphics.getWidth()), -500, 0, 1, "boss")
      spawn_disable = true
      boss_spawned = true
    end
  end
end

function ennemy_colide_space_ship(ennemy_id, ennemy)
  if (ennemy["type"] == "space_rock") then
    ennemies[ennemy_id] = nil
    spaceship_heal = spaceship_heal - 10
    spaceship_power = spaceship_power - 10
    spaceship_takedamages = 255
    soundmanager_play("assets/explosion.wav")
    ennemies[ennemy_id] = nil
  end

  if (ennemy["type"] == "engine") then
    ennemies[ennemy_id] = nil
    spaceship_heal = spaceship_heal - 10
    spaceship_power = spaceship_power - 10
    spaceship_takedamages = 255
    soundmanager_play("assets/explosion.wav")
    ennemies[ennemy_id] = nil
  end

  if (ennemy["type"] == "satellite") then
    ennemies[ennemy_id] = nil
    spaceship_heal = spaceship_heal - 10
    spaceship_power = spaceship_power - 15
    spaceship_takedamages = 255
    soundmanager_play("assets/explosion.wav")
    ennemies[ennemy_id] = nil
  end

  if (ennemy["type"] == "heal_pack") then
    ennemies[ennemy_id] = nil
    spaceship_heal = spaceship_heal + 10
    soundmanager_play("assets/healpack.wav")
  end

  if (ennemy["type"] == "power_pack") then
    ennemies[ennemy_id] = nil
    spaceship_power = 250 + spaceship_power
    soundmanager_play("assets/powerpack.wav")
  end

  if (ennemy["type"] == "spacestation") then
    ennemies[ennemy_id] = nil
    spaceship_heal = spaceship_heal / 2
    spaceship_power = spaceship_power - 35
    spaceship_takedamages = 255
    soundmanager_play("assets/explosion.wav")
  end

  if (ennemy["type"] == "bad_bullet") then
    ennemies[ennemy_id] = nil
    spaceship_heal = spaceship_heal - 10
    spaceship_power = spaceship_power - 5
    spaceship_takedamages = 255
    soundmanager_play("assets/explosion.wav")
  end
end

function spaceship_lazers_colide_ennemy(i,e)
  if e["type"] == "boss" then
    e["heal"] = e["heal"] - 1
    e["take_damage"] = 255
    if e["heal"] == 0 then
      if e["state"] == 0 then
        create_ennemy(e["x"] - 40, e["y"], 0, 0, "engine", 0)
      end

      if e["state"] == 1 then
        create_ennemy(e["x"] + 128, e["y"], 0, 0, "engine", 1)
      end

      for i=0,math.random(1, 5) do
        create_ennemy(e["x"], e["y"], math.random(-10, 10) / 10, math.random(-10, 10) / 10, "heal_pack")
      end

      for i=0,math.random(1, 5) do
        create_ennemy(e["x"], e["y"], math.random(-10, 10) / 10, math.random(-10, 10) / 10, "power_pack")
      end

      e["state"] = e["state"] + 1
      e["heal"] = 2
    end

    if e["state"] == 3 then
      spawn_disable = false
      ennemies[i] = nil

      for i=0,math.random(1, 5) do
        create_ennemy(e["x"], e["y"], math.random(-10, 10) / 10, math.random(-10, 10) / 10, "space_rock_frag")
      end

      for i=0,math.random(1, 5) do
        create_ennemy(e["x"], e["y"], math.random(-10, 10) / 10, math.random(-10, 10) / 10, "power_pack")
      end
    end

    soundmanager_play("assets/explosion.wav")
  end

  if e["type"] == "space_rock" then
    for i=0,math.random(1, 5) do
      create_ennemy(e["x"], e["y"], math.random(-1, 1), math.random(-1, 1), "space_rock_frag")
    end

    if math.random(0, 15) == 0 then
      create_ennemy(e["x"], e["y"], math.random(-1, 1), math.random(-1, 1), "heal_pack")
    end

    if math.random(0, 15) == 0 then
      create_ennemy(e["x"], e["y"], math.random(-1, 1), math.random(-1, 1), "power_pack")
    end

    ennemies[i] = nil
    soundmanager_play("assets/explosion.wav")
  end

  if e["type"] == "bad_spaceship" then
    for i=0,math.random(1, 3) do
      create_ennemy(e["x"], e["y"], math.random(-1, 1), math.random(-1, 1), "bad_spaceship_frag")
    end
    create_ennemy(e["x"], e["y"], math.random(-1, 1), math.random(-1, 1), "heal_pack")
    create_ennemy(e["x"], e["y"], math.random(-1, 1), math.random(-1, 1), "power_pack")
    create_ennemy(e["x"], e["y"], math.random(-1, 1), math.random(-1, 1), "power_pack")
    create_ennemy(e["x"], e["y"], math.random(-1, 1), math.random(-1, 1), "power_pack")

    ennemies[i] = nil
    soundmanager_play("assets/explosion.wav")
  end

  if e["type"] == "engine" then
    for i=0,math.random(1, 3) do
      create_ennemy(e["x"], e["y"], math.random(-1, 1), math.random(-1, 1), "bad_spaceship_frag")
    end

    for i=0,math.random(1, 10) do
      create_ennemy(e["x"], e["y"], math.random(-1, 1), math.random(-1, 1), "spacestation_frag")
    end
    for i=0,math.random(1, 5) do
      create_ennemy(e["x"], e["y"], math.random(-10, 10) / 10, math.random(-10, 10) / 10, "heal_pack")
    end

    for i=0,math.random(1, 5) do
      create_ennemy(e["x"], e["y"], math.random(-10, 10) / 10, math.random(-10, 10) / 10, "power_pack")
    end

    ennemies[i] = nil
    soundmanager_play("assets/explosion.wav")
  end

  if e["type"] == "spacestation" then

    create_ennemy(e["x"] +  100, e["y"], math.random(-10, 10) / 10, math.random(-10, 10) / 10, "spacestation_big_frag")
    create_ennemy(e["x"] +  200, e["y"], math.random(-10, 10) / 10, math.random(-10, 10) / 10, "spacestation_big_frag")
    create_ennemy(e["x"] +  300, e["y"], math.random(-10, 10) / 10, math.random(-10, 10) / 10, "spacestation_big_frag")

    for i=0,math.random(1, 5) do
      create_ennemy(e["x"] + 128, e["y"], math.random(-1, 1), math.random(-1, 1), "heal_pack")
    end

    for i=0,math.random(1, 3) do
      create_ennemy(e["x"] + 128, e["y"], math.random(-1, 1), math.random(-1, 1), "power_pack")
    end

    for i=0,math.random(1, 10) do
      create_ennemy(e["x"] +  math.random(100, 326), e["y"], math.random(-1, 1), math.random(-1, 1), "spacestation_frag")
    end

    ennemies[i] = nil
    soundmanager_play("assets/explosion.wav")
  end

  if e["type"] == "satellite" then
    for i=0,math.random(1, 3) do
      create_ennemy(e["x"], e["y"], math.random(-1, 1), math.random(-1, 1), "spacestation_frag")
    end

    for i=0,math.random(1, 3) do
      create_ennemy(e["x"], e["y"], math.random(-1, 1), math.random(-1, 1), "bad_spaceship_frag")
    end

    for i=0,math.random(1, 3) do
      create_ennemy(e["x"], e["y"], math.random(-1, 1), math.random(-1, 1), "power_pack")
    end

    ennemies[i] = nil
    soundmanager_play("assets/explosion.wav")
  end
end

-- Utils -----------------------------------------------------------------------
function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end

-- sound manager ---------------------------------------------------------------
soundmanager_sources = {}
function update_soundmanager()

  local remove = {}
  for _,s in pairs(soundmanager_sources) do
      if s:isStopped() then
          remove[#remove + 1] = s
      end
  end

  for i,s in ipairs(remove) do
      soundmanager_sources[s] = nil
  end
end

function soundmanager_play(source)
  src = love.audio.newSource(source, "stream")
  src:play()
  soundmanager_sources[source] = src
end
