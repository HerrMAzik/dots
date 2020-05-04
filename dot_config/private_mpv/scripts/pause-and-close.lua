function pause_and_close()
    mp.set_property("pause", "yes")
    mp.command("quit-watch-later")
end

mp.add_key_binding("b", "pause-and-close", pause_and_close)
