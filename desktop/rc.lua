-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
beautiful = require("beautiful")
vicious = require("vicious")


-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
-- beautiful.init("/usr/share/awesome/themes/default/theme.lua")
beautiful.init("/home/majin/.config/awesome/themes/default/theme.lua")





-- This is used later as the default terminal and editor to run.
terminal = "urxvt"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e sudo " .. editor


-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"


function run_once(cmd)
    findme = cmd
    firstspace = cmd:find(" ")
    if firstspace then
        findme = cmd:sub(0, firstspace-1)
    end
    awful.util.spawn_with_shell("pgrep -u $USER -x " .. findme .. " > /dev/null || (" .. cmd .. ")")
end

-- loading the Xresources for URxvt
awful.util.spawn_with_shell(terminal .. " -e xrdb ~/.Xresources" )

-- unagi compositing manager for true transparency for  urxvt
--awful.util.spawn_with_shell("unagi &")
run_once("unagi")
-- spawning conky because why not
--awful.util.spawn_with_shell("conky &")
run_once("conky")


-- Counter for controlling screen brigthness
brightness_counter=100
--volume_counter=100
-- battery warning flag if battery gets too low
battery_warning_flag=0

-- Functions

function get_conky()
    local clients = client.get()
    local conky = nil
    local i = 1
    while clients[i]
    do
        if clients[i].class == "Conky"
        then
            conky =clients[i]
        end
        i = i + 1
    end
    return conky   
end

function toogle_conky()
    local conky = get_conky()
    if conky
    then
        if conky.ontop
        then
            conky.ontop = false
        else
            conky.ontop = true
        end
    end
end









-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.floating,
    awful.layout.suit.magnifier
}
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9 }, s, layouts[1])
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock()

-- {{{ Battery state

-- Initialize widget
batwidget = wibox.widget.textbox()

-- Register widget
vicious.register(batwidget, vicious.widgets.bat,
	function (widget, args)
		if args[1] == "+" then
				state = "Charging:"
                battery_warning_flag = 0
			else
				state = "Battery:"
		end
		if args[2] == 0 then return ""
        elseif args[2] < 10 and state=="Battery:" then
            if( args[2] < 5 ) then
                naughty.notify({ preset = naughty.config.presets.critical,
                                 title = "Battery critical",
                                 text = "Only ".. args[3] .. " minutes are remaing before shutdown! Hibernation for safety is imminent!" })
                battery_warning_flag = 1
            end
            
            if( args[2] < 4 ) then
                awful.util.spawn(terminal .." -e systemctl suspend ")
            end
                
            if(battery_warning_flag == 0) then
                naughty.notify({ preset = naughty.config.presets.critical,
                                title = "Battery is getting low",
                                text = "Only ".. args[3] .. " minutes are remaing before shutdown!" })
                battery_warning_flag = 1
            end
            
            return "<span color='red'>".. state .. " " .. args[2] .."% ".. args[3].. "</span>"
		else
			return "<span color='green'>".. state .. " ".. args[2] .."% ".. args[3].. "</span>"
		end
	end, 61, "BAT1"
)

-- }}}

-- {{{ volume level

-- Initialize widget
volwidget = wibox.widget.textbox()

-- Register widget
vicious.register(volwidget, vicious.widgets.volume,
	function (widget, args)
		return args[2]..":".. args[1]
	end, 3600 ,"Master"
)

-- }}}

-- {{{ mpd widget

-- Initialize widget
mpdwidget = wibox.widget.textbox()

-- Register widget
vicious.register(mpdwidget, vicious.widgets.mpd,
        function (widget, args)
                if args["State"] == "Stop" then return ""
		else return '<span color="white">MPD:</span>' .. args["{Artist}"] .. ' - ' .. args["{Title}"]
		end
	end, 13 )

-- }}

-- {{ Used disk space widget 

-- Initialize widget
usedspacewidget = wibox.widget.textbox()

-- Register widget
vicious.register(usedspacewidget, vicious.widgets.fs, 
        function (widget, args)
		return '/: ' .. args["{/ used_gb}"] .. " / "..args["{/ size_gb}"].." GB   "
	end,769)



-- Create a wibox for each screen and add it
mywiboxtop = {}
mywiboxbottom = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({
                                                      theme = { width = 250 }
                                                  })
                                              end
                                          end),
                    awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywiboxtop[s] = awful.wibox({ position = "top", screen = s })
    mywiboxbottom[s] = awful.wibox({ position = "bottom", screen = s })
	
    -- Widgets that are aligned to the left
    local left_layout_top = wibox.layout.fixed.horizontal()
    left_layout_top:add(mylauncher)
    left_layout_top:add(mytaglist[s])
    left_layout_top:add(mypromptbox[s])

    -- Widgets that are aligned to the righ
    local right_layout_top = wibox.layout.fixed.horizontal()
    if s == 1 then right_layout_top:add(wibox.widget.systray()) end
    right_layout_top:add(batwidget)
    right_layout_top:add(mytextclock)
    right_layout_top:add(mylayoutbox[s])

    -- Now bring it all together (with the tasklist in the middle)
    local layout_top = wibox.layout.align.horizontal()
    layout_top:set_left(left_layout_top)
    layout_top:set_middle(mytasklist[s])
    layout_top:set_right(right_layout_top)

    mywiboxtop[s]:set_widget(layout_top)

    local left_layout_bottom = wibox.layout.fixed.horizontal()
    left_layout_bottom:add(usedspacewidget)

    local right_layout_bottom = wibox.layout.fixed.horizontal()
    --right_layout_bottom:add(mpdwidget)
    right_layout_bottom:add(volwidget)

    local layout_bottom = wibox.layout.align.horizontal()
    layout_bottom:set_left(left_layout_bottom)
    layout_bottom:set_right(right_layout_bottom)
   
    mywiboxbottom[s]:set_widget(layout_bottom)

end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end),
    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey,           }, "n", function() awful.util.spawn(terminal .. " -e sudo wifi-menu")  end),
    awful.key({ modkey,           }, "b", function() awful.util.spawn(terminal .. " -e ranger ") end),
    awful.key({ modkey,           }, "c", function() awful.util.spawn("chromium") end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),


--    awful.key({ modkey,           }, "a",     function () awful.util.spawn(terminal .. " -e systemctl suspend " ) end),

    awful.key({ modkey, "Control" }, "m",     function () awful.util.spawn(terminal .. " -e bash user_scripts/auto_xrandr " ) end),

    awful.key({ modkey,           }, "F1",    function () awful.screen.focus(2)        end),
    awful.key({ modkey,           }, "F2",    function () awful.screen.focus(1)        end),
    awful.key({ modkey, "Control" }, "Left",  function () awful.screen.focus_bydirection("left") end),
    awful.key({ modkey, "Control" }, "Right", function () awful.screen.focus_bydirection("right") end),


    awful.key({ modkey,           }, "F10",   function () toggle_conky() end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),

    --Multimedia Keys
    awful.key({ modkey,  }, "Up",
        function ()
            awful.util.spawn("amixer set Master 3%+", false)  vicious.force({volwidget}) 
        end),
    awful.key({ modkey,  }, "Down",
        function ()
            awful.util.spawn("amixer set Master 3%-", false)
            vicious.force({volwidget}) 
        end),    
--    awful.key({ modkey,  }, "m", function () awful.util.spawn("amixer set Master toggle", false) vicious.force({volwidget}) end),
    awful.key({ }, "XF86MonBrightnessUp",
              function ()
	         if brightness_counter==1 then 
		    brightness_counter = 5
                 elseif brightness_counter==5 then 
		    brightness_counter = 10
                 elseif brightness_counter==10 then 
		    brightness_counter = 15
                 elseif brightness_counter==15 then 
		    brightness_counter = 25
                 elseif brightness_counter==25 then 
		    brightness_counter = 50
                 elseif brightness_counter==50 then 
		    brightness_counter = 75
                 elseif brightness_counter==75 then 
		    brightness_counter = 100
		 else
                    brightness_counter = 100
		 end
                 awful.util.spawn("xbacklight -set "..brightness_counter) 
              end),
    awful.key({ }, "XF86MonBrightnessDown",
              function ()
	         if brightness_counter==100 then 
		    brightness_counter = 75
                 elseif brightness_counter==75 then 
		    brightness_counter = 50
                 elseif brightness_counter==50 then 
		    brightness_counter = 25
                 elseif brightness_counter==25 then 
		    brightness_counter = 15
                 elseif brightness_counter==15 then 
		    brightness_counter = 10
                 elseif brightness_counter==10 then 
		    brightness_counter = 5
                 elseif brightness_counter==5 then 
		    brightness_counter = 1
		 else
                    brightness_counter = 1
		 end
                 awful.util.spawn("xbacklight -set "..brightness_counter) 
    end),

    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end)    
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        local tag = awful.tag.gettags(screen)[i]
                        if tag then
                           awful.tag.viewonly(tag)
                        end
                  end),
        -- Toggle tag.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      local tag = awful.tag.gettags(screen)[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.movetotag(tag)
                          end
                     end
                  end),
        -- Toggle tag.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.toggletag(tag)
                          end
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    { rule = { class = "Conky" },
      properties = {
          floating = true,
          sticky = true,
          ontop = false,
          focusable = false,
          size_hints = {"program_position", "program_size" }
      } }
    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- buttons for the titlebar
        local buttons = awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                )

        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))
        left_layout:buttons(buttons)

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local middle_layout = wibox.layout.flex.horizontal()
        local title = awful.titlebar.widget.titlewidget(c)
        title:set_align("center")
        middle_layout:add(title)
        middle_layout:buttons(buttons)

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(middle_layout)

        awful.titlebar(c):set_widget(layout)
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
