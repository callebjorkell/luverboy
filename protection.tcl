###
#
#  Copyright (c) 2008 Carl-Magnus "NRGizeR" Björkell
#
#
#  This file is part of the Luverboy eggdrop script.
#
#  The Luverboy eggdrop script is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  The Luverboy eggdrop script is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with the Luverboy eggdrop script.  If not, see <http://www.gnu.org/licenses/>.
#
###


### PROTECTION MODULE
bind mode - "$pchan*" channelmodechange
bind kick - "$pchan*" pubkick
bind kick - "$privchan*" privkick
bind mode - "$privchan*" channelmodechange

set lastqmessage 0

proc privkick { nick host hand chan target reason } {
    global botnick
    if { [validuser $hand] && [matchattr $hand "m"] } {
        putmsg $chan ":("
    } else {
        if { $nick != $target && $nick != $botnick } {
            punishuser $nick $chan "He who gives, shall receive..."
        }
    }
}

proc pubkick { nick host handle chan target reason } {
    global privchan botnick

    if { [onchan $target $privchan] } {
        if { $nick != $target && $nick != $botnick } {
            punishuser $nick $chan "No hate among luvers."
        }
    }
}

proc channelmodechange {nick uhost hand chan mc {victim ""}} {
    global pchan privchan botname botnick

    #nick can be "" if it's a server mode for example.
    if { $botnick == $victim || [string match $victim $botname] } {
        switch -- $mc {
            "+b" {
                luvmsg $chan "protection" "NOOOOOOOOOOOOOOOOOOOOOOOOOOoooooooooooooooo!"
                punishuser $nick $chan "Where's the luv?"
            }
            "-o" {
                luvmsg $chan "protection" "Oooh, now you've done it..."
                punishuser $nick $chan "This is my +o face!"
            }
        }
    } elseif { $victim != "" && $botnick != $nick && $nick != $victim && $nick != "Q" && $nick != "" } {
        if { !([validuser $hand] && [matchattr $hand "m"]) } {
            if { $chan == $privchan || ($chan == $pchan && [onchan $victim $privchan]) } {
                switch -- $mc {
                    "+b" {
                        punishuser $nick $chan "No hate among luvers."
                        if { [botisop $chan] } {
                            pushmode $chan -b $victim
                            flushmode $chan
                        }
                    }
                    "-o" {
                        if { [botisop $chan] } {
                            pushmode $chan +o $victim
                            flushmode $chan
                        }
                    }
                }
            }
        }
    }
}

proc punishuser { nick chan msg } {
    global punisharray

    if { $nick != "Q" && $nick != "" } {
        putlog "Punishing $nick"
        set punisharray($nick) [list $chan $msg]
        if { [lsearch -glob [utimers] "* dopunishusers *"] == -1 } {
            dopunishusers
        }
    }
}

proc dopunishusers { } {
    global punisharray auth lastqmessage

    if { [array exists punisharray] } {
        foreach {nick kicklist} [array get punisharray] {
            set chan [lindex $kicklist 0]
            if { ![botonchan $chan] } {
                if { $auth != 0 && [expr [clock seconds] - $lastqmessage] > 30 } {
                    putquick "PRIVMSG Q@Cserve.quakenet.org :UNBANME $chan"
                    set lastqmessage [clock seconds]
                }
            } elseif { ![botisop $chan] } {
                if { $auth != 0 && [expr [clock seconds] - $lastqmessage] > 30 } {
                    putquick "PRIVMSG Q@Cserve.quakenet.org :OP $chan"
                    set lastqmessage [clock seconds]
                }
            } elseif { [onchan $nick $chan] } {
                putlog "Kicking $nick from $chan"
                putkick $chan $nick [lindex $kicklist 1]
                array unset punisharray $nick
            }
        }
    }

    if { [array size punisharray] > 0 } {
        if { [lsearch -glob [utimers] "* dopunishusers *"] == -1 } {
            utimer 5 dopunishusers
        }
    }
}
