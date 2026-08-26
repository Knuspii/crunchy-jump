pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
-- crunchy jump
-- pico-8

-- player sprites
-- 000 = going up
-- 002 = apex / standing
-- 004 = going down

-- platforms
-- 096 = normal
-- 098 = broken 1
-- 100 = broken 2
-- 102 = broken 3

-- grass
-- 064 065 066

-- items
-- 128 = spike 1
-- 129 = spike 2
-- 130 = coin
-- 131 = jump boost

-- sounds
-- 00 = jump
-- 01 = game over
-- 02 = jump boost
-- 03 = coin
-- 04 = platform broken


function _init()

    mode="menu"

    setup_game()

end


--------------------------------------------------
-- SETUP GAME
--------------------------------------------------

function setup_game()

    player={
        x=56,
        y=100,

        w=16,
        h=16,

        hw=12,
        hh=14,

        dx=0,
        dy=0,
        sprite=2
    }


    gravity=0.25

    normal_jump=-5.5
    boost_jump=-8.5

    jump=normal_jump

    camera_y=0

    height_score=0
    coin_score=0
    score=0

    game_over=false

    platforms={}
    particles={}
    items={}


    ------------------------------------------------
    -- GAME START GROUND
    ------------------------------------------------

    if mode=="game" then

        add_platform(
            0,
            120,
            128,
            "ground"
        )

    end


    ------------------------------------------------
    -- GAME PLATFORMS
    ------------------------------------------------

    local y=95


    for i=1,20 do

        local pw=16
        local px=flr(rnd(113))

        local type="normal"


        if rnd(1)<0.25 then

            local r=flr(rnd(3))


            if r==0 then

                type="broken1"

            elseif r==1 then

                type="broken2"

            else

                type="broken3"

            end

        end


        add_platform(
            px,
            y,
            pw,
            type
        )


        y-=20

    end


    ------------------------------------------------
    -- MENU SETUP
    ------------------------------------------------

    if mode=="menu" then

        setup_menu()

    end

end


--------------------------------------------------
-- MENU PLATFORMS
--------------------------------------------------

function setup_menu()

    platforms={}
    items={}
    camera_y=0

    -- menu ground
    add_platform(
        0,
        120,
        128,
        "ground"
    )

    -- static decoration platforms
    add_platform(
        8,
        108,
        16,
        "normal"
    )

    add_platform(
        38,
        88,
        16,
        "normal"
    )

    add_platform(
        76,
        100,
        16,
        "broken1"
    )

    add_platform(
        100,
        72,
        16,
        "normal"
    )

    add_platform(
        62,
        48,
        16,
        "broken2"
    )

    add_platform(
        20,
        30,
        16,
        "normal"
    )

    player.x=56
    player.y=95

    player.dx=0
    player.dy=normal_jump

end


--------------------------------------------------
-- START GAME
--------------------------------------------------

function start_game()

    mode="game"

    setup_game()

end


--------------------------------------------------
-- PLATFORM
--------------------------------------------------

function add_platform(x,y,w,type)

    local p={

        x=x,
        y=y,

        w=w,
        h=16,

        type=type

    }


    add(
        platforms,
        p
    )


    ------------------------------------------------
    -- NO ITEMS IN MENU
    ------------------------------------------------

    if mode=="menu" then

        return

    end


    ------------------------------------------------
    -- GROUND
    ------------------------------------------------

    if type=="ground" then

        return

    end


    ------------------------------------------------
    -- ITEM CHANCE
    ------------------------------------------------

    if rnd(1)<0.30 then

        spawn_item(p)

    end

end


--------------------------------------------------
-- ITEM
--------------------------------------------------

function spawn_item(p)

    local r=rnd(1)

    local type


    if r<0.15 then

        type="spike1"

    elseif r<0.30 then

        type="spike2"

    elseif r<0.65 then

        type="coin"

    else

        type="boost"

    end


    ------------------------------------------------
    -- ITEM 8x8
    ------------------------------------------------

    local ix=
        p.x+flr(rnd(9))


    add(items,{

        x=ix,
        y=p.y-8,

        w=8,
        h=8,

        type=type,

        platform=p

    })

end


--------------------------------------------------
-- PARTICLES
--------------------------------------------------

function add_particle(
    x,
    y,
    dx,
    dy,
    col,
    life
)

    add(particles,{

        x=x,
        y=y,

        dx=dx,
        dy=dy,

        col=col,

        life=life,
        maxlife=life

    })

end


function jump_particles(x,y)

    for i=1,7 do

        local side=1


        if i%2==0 then

            side=-1

        end


        add_particle(

            x+8+side*flr(rnd(4)),
            y+15,

            side*(0.3+rnd(0.8)),
            -0.3-rnd(0.8),

            7,

            10+flr(rnd(8))

        )

    end

end


function broken_particles(x,y)

    for i=1,14 do

        add_particle(

            x+8+rnd(16)-8,
            y+8+rnd(12)-6,

            rnd(2)-1,
            -1-rnd(2),

            11,

            12+flr(rnd(10))

        )

    end

end


--------------------------------------------------
-- PARTICLES UPDATE
--------------------------------------------------

function update_particles()

    for p in all(particles) do

        p.x+=p.dx
        p.y+=p.dy

        p.dy+=0.12

        p.life-=1


        if p.life<=0 then

            del(
                particles,
                p
            )

        end

    end

end


function draw_particles()

    for p in all(particles) do

        if p.life>p.maxlife*0.5 then

            pset(
                p.x,
                p.y,
                p.col
            )

        elseif p.life%2==0 then

            pset(
                p.x,
                p.y,
                p.col
            )

        end

    end

end


--------------------------------------------------
-- UPDATE
--------------------------------------------------

function _update()

    ------------------------------------------------
    -- MENU
    ------------------------------------------------

    if mode=="menu" then

        update_menu()

        update_particles()

        return

    end


    ------------------------------------------------
    -- GAME OVER
    ------------------------------------------------

    if mode=="gameover" then

        update_particles()


        if btnp(❎) then

            mode="menu"

            setup_game()

        end


        return

    end


    ------------------------------------------------
    -- GAME
    ------------------------------------------------

    update_player()

    update_camera()

    update_platforms()

    update_items()

    update_particles()


    ------------------------------------------------
    -- FALL OUT OF SCREEN
    ------------------------------------------------

    if player.y-camera_y>128 then

        game_over=true

        mode="gameover"

        sfx(1)

        return

    end


    ------------------------------------------------
    -- HEIGHT SCORE
    ------------------------------------------------

    height_score=max(
        height_score,
        flr(-camera_y/10)
    )


    score=
        height_score+
        coin_score

end


--------------------------------------------------
-- MENU UPDATE
--------------------------------------------------

function update_menu()

    ------------------------------------------------
    -- HORIZONTAL MOVEMENT
    ------------------------------------------------

    player.dx*=0.82

    player.x+=player.dx


    ------------------------------------------------
    -- SCREEN WRAP
    ------------------------------------------------

    if player.x < -player.w then

        player.x=128

    end


    if player.x > 128 then

        player.x=-player.w

    end


    ------------------------------------------------
    -- GRAVITY
    ------------------------------------------------

    player.dy+=gravity

    player.y+=player.dy


    ------------------------------------------------
    -- SPRITE
    ------------------------------------------------

    if player.dy < -0.5 then

        player.sprite=0

    elseif player.dy > 0.5 then

        player.sprite=4

    else

        player.sprite=2

    end


    ------------------------------------------------
    -- NO PLATFORM COLLISION
    ------------------------------------------------

    if player.y>104 then

        player.y=104

        player.dy=normal_jump

        player.sprite=2


        jump_particles(
            player.x,
            player.y
        )

    end


    ------------------------------------------------
    -- START
    ------------------------------------------------

    if btnp(❎) then

        start_game()

    end

end


--------------------------------------------------
-- PLAYER
--------------------------------------------------

function update_player()

    ------------------------------------------------
    -- MOVEMENT
    ------------------------------------------------

    if btn(⬅️) then

        player.dx-=0.35

    end


    if btn(➡️) then

        player.dx+=0.35

    end


    player.dx*=0.82


    player.dx=mid(
        -3,
        player.dx,
        3
    )


    player.x+=player.dx


    ------------------------------------------------
    -- SCREEN WRAP
    ------------------------------------------------

    if player.x < -player.w then

        player.x=128

    end


    if player.x > 128 then

        player.x=-player.w

    end


    ------------------------------------------------
    -- OLD POSITION
    ------------------------------------------------

    local old_y=player.y


    ------------------------------------------------
    -- GRAVITY
    ------------------------------------------------

    player.dy+=gravity

    player.y+=player.dy


    ------------------------------------------------
    -- SPRITE
    ------------------------------------------------

    if player.dy < -0.5 then

        player.sprite=0

    elseif player.dy > 0.5 then

        player.sprite=4

    else

        player.sprite=2

    end


    ------------------------------------------------
    -- HITBOX
    ------------------------------------------------

    local hx=player.x+2
    local hy=player.y+1


    ------------------------------------------------
    -- PLATFORM COLLISION
    ------------------------------------------------

    if player.dy>0 then

        local old_bottom=
            old_y+1+player.hh


        local new_bottom=
            hy+player.hh


        for p in all(platforms) do

            local hit_x=
                hx+player.hw>p.x
                and hx<p.x+p.w


            local hit_y=
                old_bottom<=p.y
                and new_bottom>=p.y


            if hit_x and hit_y then

                ------------------------------------------------
                -- FIX
                -- player bottom = player.y + 15
                -- platform top = p.y
                -- therefore player.y = p.y - 15
                ------------------------------------------------

                player.y=
                    p.y-player.hh-2


                ------------------------------------------------
                -- BROKEN
                ------------------------------------------------

                if p.type=="broken1"
                or p.type=="broken2"
                or p.type=="broken3" then

                    player.dy=jump

                    player.sprite=2

                    sfx(4)


                    jump_particles(
                        player.x,
                        player.y
                    )


                    broken_particles(
                        p.x,
                        p.y
                    )


                    del(
                        platforms,
                        p
                    )


                    remove_platform_item(p)

                    break

                end


                ------------------------------------------------
                -- NORMAL
                ------------------------------------------------

                player.dy=jump

                player.sprite=2

                sfx(0)


                jump_particles(
                    player.x,
                    player.y
                )


                break

            end

        end

    end

end


--------------------------------------------------
-- REMOVE ITEM
--------------------------------------------------

function remove_platform_item(p)

    for item in all(items) do

        if item.platform==p then

            del(
                items,
                item
            )

        end

    end

end


--------------------------------------------------
-- ITEMS
--------------------------------------------------

function update_items()

    for item in all(items) do

        local hx=player.x+2
        local hy=player.y+1


        local hit_x=
            hx+player.hw>item.x
            and hx<item.x+item.w


        local hit_y=
            hy+player.hh>item.y
            and hy<item.y+item.h


        ------------------------------------------------
        -- SPIKES
        ------------------------------------------------

        if item.type=="spike1"
        or item.type=="spike2" then

            if player.dy>0 then

                local old_bottom=
                    player.y-player.dy+1+player.hh


                local spike_top=item.y


                local new_bottom=
                    hy+player.hh


                local crossed_top=
                    old_bottom<=spike_top
                    and new_bottom>=spike_top


                if hit_x and crossed_top then

                    game_over=true

                    mode="gameover"

                    sfx(1)

                    return

                end

            end


        ------------------------------------------------
        -- COIN / BOOST
        ------------------------------------------------

        elseif hit_x and hit_y then

            if item.type=="coin" then

                coin_score+=10

                sfx(3)

            end


            if item.type=="boost" then

                player.dy=boost_jump

                player.sprite=0

                sfx(2)


                jump_particles(
                    player.x,
                    player.y
                )

            end


            del(
                items,
                item
            )

        end

    end

end


--------------------------------------------------
-- CAMERA
--------------------------------------------------

function update_camera()

    local target=
        player.y-45


    if target<camera_y then

        camera_y=target

    end

end


--------------------------------------------------
-- PLATFORM UPDATE
--------------------------------------------------

function update_platforms()

    ------------------------------------------------
    -- REMOVE OLD
    ------------------------------------------------

    for p in all(platforms) do

        if p.type!="ground"
        and p.y-camera_y>140 then

            remove_platform_item(p)

            del(
                platforms,
                p
            )

        end

    end


    ------------------------------------------------
    -- HIGHEST
    ------------------------------------------------

    local highest=9999


    for p in all(platforms) do

        if p.y<highest then

            highest=p.y

        end

    end


    ------------------------------------------------
    -- GENERATE
    ------------------------------------------------

    while highest>camera_y-40 do

        highest-=20


        local pw=16

        local px=flr(rnd(113))

        local type="normal"


        if rnd(1)<0.25 then

            local r=flr(rnd(3))


            if r==0 then

                type="broken1"

            elseif r==1 then

                type="broken2"

            else

                type="broken3"

            end

        end


        add_platform(
            px,
            highest,
            pw,
            type
        )

    end

end


--------------------------------------------------
-- DRAW PLAYER
--------------------------------------------------

function draw_player()

    spr(
        player.sprite,
        player.x,
        player.y,
        2,
        2
    )

end


--------------------------------------------------
-- DRAW PLATFORM
--------------------------------------------------

function draw_platform(p)

    if p.type=="normal" then

        spr(
            96,
            p.x,
            p.y,
            2,
            2
        )


    elseif p.type=="broken1" then

        spr(
            98,
            p.x,
            p.y,
            2,
            2
        )


    elseif p.type=="broken2" then

        spr(
            100,
            p.x,
            p.y,
            2,
            2
        )


    elseif p.type=="broken3" then

        spr(
            102,
            p.x,
            p.y,
            2,
            2
        )

    end

end


--------------------------------------------------
-- DRAW GROUND
--------------------------------------------------

function draw_ground()

    for x=0,120,8 do

        -- fixed grass pattern
        local tile=64+(flr(x/8)%3)

        spr(
            tile,
            x,
            120,
            1,
            1
        )

    end

    rectfill(
        0,
        128,
        127,
        135,
        4
    )

end


--------------------------------------------------
-- DRAW ITEMS
--------------------------------------------------

function draw_items()

    for item in all(items) do

        if item.type=="spike1" then

            spr(
                128,
                item.x,
                item.y,
                1,
                1
            )


        elseif item.type=="spike2" then

            spr(
                129,
                item.x,
                item.y,
                1,
                1
            )


        elseif item.type=="coin" then

            spr(
                130,
                item.x,
                item.y,
                1,
                1
            )


        elseif item.type=="boost" then

            spr(
                131,
                item.x,
                item.y,
                1,
                1
            )

        end

    end

end


--------------------------------------------------
-- MENU
--------------------------------------------------

function draw_menu()

    -- GAME VERSION

    print(
        "V0.2",
        1,
        1,
        7
    )


    print(
        "MADE BY KNUSPII",
        68,
        1,
        7
    )


    print(
        "crunchy jump",
        40,
        15,
        9
    )


    print(
        "PRESS X",
        50,
        30,
        6
    )


    print(
        "⬅️ ➡️ TO MOVE",
        36,
        38,
        6
    )

end


--------------------------------------------------
-- DRAW
--------------------------------------------------

function _draw()

    cls(12)


    ------------------------------------------------
    -- WORLD
    ------------------------------------------------

    camera(
        0,
        camera_y
    )


    ------------------------------------------------
    -- PLATFORMS
    ------------------------------------------------

    for p in all(platforms) do

        if p.type=="ground" then

            draw_ground()

        else

            draw_platform(p)

        end

    end


    ------------------------------------------------
    -- ITEMS
    -- visible during game AND gameover
    ------------------------------------------------

    if mode!="menu" then

        draw_items()

    end


    ------------------------------------------------
    -- PARTICLES
    ------------------------------------------------

    draw_particles()


    ------------------------------------------------
    -- PLAYER
    ------------------------------------------------

    draw_player()


    camera()


    ------------------------------------------------
    -- MENU
    ------------------------------------------------

    if mode=="menu" then

        draw_menu()

    end


    ------------------------------------------------
    -- SCORE
    ------------------------------------------------

    if mode=="game" then

        print(
            "score "..score,
            4,
            4,
            7
        )

    end


    ------------------------------------------------
    -- GAME OVER
    ------------------------------------------------

    if mode=="gameover" then

        rectfill(
            20,
            48,
            108,
            80,
            0
        )


        print(
            "game over",
            41,
            55,
            8
        )


        print(
            "SCORE: "..score,
            42,
            63,
            7
        )


        print(
            "PRESS: X",
            42,
            71,
            7
        )

    end

end
__gfx__
00044400004440000004440000444000000444000044400000000000000000000000000000000000000000000000000000000000000000000000000000000000
0049a944449a94000049a944449a94000049a944449a940000000000000000000000000000000000000000000000000000000000000000000000000000000000
04aaaa9999aaaa4004aaaa9999aaaa4004aaaa9999aaaa4000000000000000000000000000000000000000000000000000000000000000000000000000000000
04a9a9aaaa9aaa4004a9a9aaaa9aaa4004a9a9aaaa9aaa4000000000000000000000000000000000000000000000000000000000000000000000000000000000
04aaaaa9aaaaa94004aaaaa9aaaaa94004aaaaa9aaaaa94000000000000000000000000000000000000000000000000000000000000000000000000000000000
004aaaaaaaaa9400004aaaaaaaaa9400004aaaaaaaaa940000000000000000000000000000000000000000000000000000000000000000000000000000000000
004aaaaaaaaaa400004aaaaaaaaaa400004aaaaaaaaaa40000000000000000000000000000000000000000000000000000000000000000000000000000000000
004aa1aaaa1aa400004aa1aaaa1aa400404aa1aaaa1aa40400000000000000000000000000000000000000000000000000000000000000000000000000000000
044aa1aaaa1aa440444aa1aaaa1aa444044aa1aaaa1aa44000000000000000000000000000000000000000000000000000000000000000000000000000000000
404aeea11aeea404004aeea11aeea400004aeea11aeea40000000000000000000000000000000000000000000000000000000000000000000000000000000000
004aaaaaaaaaa400004aaaaaaaaaa400004aaaaaaaaaa40000000000000000000000000000000000000000000000000000000000000000000000000000000000
004a9aaaaaaaa400004a9aaaaaaaa400004a9aaaaaaaa40000000000000000000000000000000000000000000000000000000000000000000000000000000000
0049aaaaaaaa94000049aaaaaaaa94000049aaaaaaaa940000000000000000000000000000000000000000000000000000000000000000000000000000000000
00044444444440000004444444444000000444444444400000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000400004000000000040000400000000004000040000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00004400004400000000040000400000000044000044000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbbbbbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbbbbbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b4bb33bb33bbb4bbbbb4bb3300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
34434443444334434334434400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
43434444444443434443434400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444544454444444444444500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444444444444444444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
45444454445445445445444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbb00bbb0bbbbbbbbb00bbbbbbb000bbb00bbbbbbbbb0bb0000000000000000000000000000000000000000000000000000000000000000
b11111111111111bb11111111011111bb11100111111111bb11001111111101b0000000000000000000000000000000000000000000000000000000000000000
b11111111111111bb11111110111111bb11110111111111bb11101111111101b0000000000000000000000000000000000000000000000000000000000000000
b11111111111111bb11111110111111bb11110011111111bb11111111111101b0000000000000000000000000000000000000000000000000000000000000000
b11111111111111bb11111100111111bb11111011111111bb1111111111100100000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbbbbb0bbbbb00bb00bbb00bbbbbbbbbbbb00bbbbbb0bb00000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000790000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00001000000100000011110000007a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000110000001100001aaaa100007a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00011000000110001aa77aa100aaaaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00111100001111001a7aa9a10000a900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00111100001111001a7aa9a1000a9000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011111100111111001a99a1000a90000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111111111110011110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccc777ccccc77ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c7c7c7c7cccccc7ccccccccccccccccccccccccccccccccccccccccccccccccccccc777cc77c77cc777ccccc77cc7c7ccccc7c7c77cc7c7cc77cc77c777c777c
c7c7c7c7cccccc7ccccccccccccccccccccccccccccccccccccccccccccccccccccc777c7c7c7c7c77cccccc77cc777ccccc77cc7c7c7c7c7ccc7c7cc7ccc7cc
c777c7c7cccccc7ccccccccccccccccccccccccccccccccccccccccccccccccccccc7c7c777c7c7c7ccccccc7c7ccc7ccccc7c7c7c7c7c7ccc7c777cc7ccc7cc
cc7cc777cc7cc777cccccccccccccccccccccccccccccccccccccccccccccccccccc7c7c7c7c77ccc77ccccc777c77cccccc7c7c7c7cc77c77cc7ccc777c777c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccccccccccccccccc
cccccccccccccccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccccccccccccccccc
cccccccccccccccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccccccccccccccccc
cccccccccccccccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccccccccccccccccc
cccccccccccccccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccccccccccccccccc
cccccccccccccccccccc00000000000000000000099099909090990009909090909000009990909099909990000000000000000000000ccccccccccccccccccc
cccccccccccccccccccc00000000000000000000900090909090909090009090909000000900909099909090000000000000000000000ccccccccccccccccccc
cccccccccccccccccccc00000000000000000000900099009090909090009990999000000900909090909990000000000000000000000ccccccccccccccccccc
cccccccccccccccccccc00000000000000000000900090909090909090009090009000000900909090909000000000000000000000000ccccccccccccccccccc
cccccccccccccccccccc00000000000000000000099090900990909009909090999000009900099090909000000000000000000000000ccccccccccccccccccc
cccccccccccccccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccccccccccccccccc
cccccccccccccccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccccccccccccccccc
cccccccccccccccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccccccccccccccccc
cccccccccccccccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccccccccccccccccc
cccccccccccccccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccccccccccccccccc
cccccccccccccccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccccccccccccccccc
cccccccccccccccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccccccccccccccccc
cccccccccccccccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccccccccccccccccc
cccccccccccccccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccccccccccccccccc
cccccccccccccccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccccccccccccccccc
cccccccccccccccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccccccccccccccccc
cccccccccccccccccccc00000000000000000000000000000006606600666006600660000060600000000000000000000000000000000ccccccccccccccccccc
cccccccccccccccccccc00000000000000000000000000000060606060660060006000000006000000000000000000000000000000000ccccccccccccccccccc
cccccccccccccccccccc00000000000000000000000000000066606600600000600060000006000000000000000000000000000000000ccccccccccccccccccc
cccccccccccccccccccc00000000000000000000000000000060006060066066006600000060600000000000000000000000000000000ccccccccccccccccccc
cccccccccccccccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccccccccccccccccc
cccccccccccccccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccccccccccccccccc
cccccccccccccccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccccccccccccccccc
cccccccccccccccccccc00000000000000000666660000000666660000000000000000000000000000000000000000000000000000000ccccccccccccccccccc
cccccccccccccccccccc00000000000000006660066000006600666000006660066000006660066060606660000000000000000000000ccccccccccccccccccc
cccccccccccccccccccc00000000000000006600066000006600066000000600606000006660606060606600000000000000000000000ccccccccccccccccccc
cccccccccccccccccccc00000000000000006660066000006600666000000600606000006060606066606000000000000000000000000ccccccccccccccccccc
cccccccccccccccccccc00000000000000000666660000000666660000000600660000006060660006000660000000000000000000000ccccccccccccccccccc
cccccccccccccccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccccccccccccccccc
cccccccccccccccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccccccccccccccccc
cccccccccccccccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccbbbccbbbbbbbcccbcccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccb111cc111111111bcccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccb1111c111111111bcccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccb1111cc11111111bcccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccb11111c11111111bcccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccbccbbbccbbbbbbbbcccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccbbbbbbbbbbbbbbbbcccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccb11111111111111bcccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccb11111111111111bcccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccb11111111111111bcccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccb11111111111111bcccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccbbbbbbbbbbbbbbbbcccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccbbbbbbbbbbbbbbbbcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccb11111111111111bccccc444cccc444ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccb11111111111111bcccc49a944449a94cccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccb11111111111111bccc4aaaa9999aaaa4ccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccb11111111111111bccc4a9a9aaaa9aaa4ccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccbbbbbbbbbbbbbbbbccc4aaaaa9aaaaa94ccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccc4aaaaaaaaa94cccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccc4aaaaaaaaaa4cccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccc4c4aa1aaaa1aa4c4cccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccc44aa1aaaa1aa44ccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccc4aeea11aeea4cccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccc4aaaaaaaaaa4cccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccc4a9aaaaaaaa4ccccccbbbbccbbbcbbbbbbcccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccc49aaaaaaaa94ccccccb11111111c11111bcccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc4444444444cccccccb1111111c111111bcccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc4cccc4cccccccccb1111111c111111bcccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc44cccc44ccccccccb111111cc111111bcccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccbbbbbbbcbbbbbccbcccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccbbbbbbbbbbbbbbbbcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccb11111111111111bcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccb11111111111111bcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccb11111111111111bcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccb11111111111111bcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccbbbbbbbbbbbbbbbbcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
b4bb33bbb4bb33bbb4bb33bbb4bb33bbb4bb33bbb4bb33bbb4bb33bbb4bb33bbb4bb33bbb4bb33bbb4bb33bbb4bb33bbb4bb33bbb4bb33bbb4bb33bbb4bb33bb
34434443344344433443444334434443344344433443444334434443344344433443444334434443344344433443444334434443344344433443444334434443
43434444434344444343444443434444434344444343444443434444434344444343444443434444434344444343444443434444434344444343444443434444
44444544444445444444454444444544444445444444454444444544444445444444454444444544444445444444454444444544444445444444454444444544
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
45444454454444544544445445444454454444544544445445444454454444544544445445444454454444544544445445444454454444544544445445444454

__sfx__
000100000000000000000000040005400017500375005750077500a7500e75011750137501575016750187501775015750127500f7500b7500975007750057500475001750007500350002f0001f000000000000
00030000221502b050221502b05022150221502a050221502a0502215021150280501d15019150250500f1500a1501e05000150110500a1000410004050150001400000050010500105000050000500400002000
00010000002000020000200002000020000200011500115001150011500115001150021500415006150091500c1500f1501315016150191501e1502215025150271502b1502e1503015000000000000000000000
0001000000000000000000030700096000b6000d60016050116000f6000a60008600076000660006600046001d05001600006000a700057000a7002e050137000f70009700267002670026700267000000000000
0001000006650096500c65018600136501b6501b6501b6501b6501b6501a6501e60016650116500d6500b65005650036500365003650016500065000650056000660006600076000760008600086000860007600
