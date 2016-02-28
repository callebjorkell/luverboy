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


### REMINDER SYSTEM

bind pub -|- !cancelremind remindercancel
bind pub -|- !listremind reminderlist
bind pub -|- !remind reminder

registerhelp "remind" "Reminds you about something in a given number of minutes." \
            "!remind <minutes> <message>" \
            "!remind 10 Fetch your pizza from the oven!" 3 "pub" "remind"
registerhelp "listremind" "Lists the active reminders that you have, and their ids." \
            "!listremind" \
            "!listremind" 3 "pub" "remind"
registerhelp "cancelremind" "Cancels the reminders that you have active. If an id is specified, only that reminder is cancelled. If no id is given, all reminders are cancelled." \
            "!cancelremind \[id\]" \
            "!cancelremind 20489" 3 "pub" "remind"

proc reminder { nick host hand chan arg } {
    global privchan maxremind
    if { [hasaccess $nick "remind"] } {
        set arg [getargs $arg 2]

        if { [llength $arg] > 1 && [string is integer [lindex $arg 0]] } {
            set count 0
            foreach remind [utimers] {
                set command [lindex $remind 1]
                if { [lindex $command 0] == "doremind" && [lindex $command 1] == $nick } {
                    incr count
                }
            }
            if { $count >= $maxremind } {
                luvmsg $chan "remind" "You have too many active reminders, cancel one it with !cancelremind \[id\], to add a new one."
                return 0;
            } else {
                utimer [expr [lindex $arg 0] * 60] "doremind $nick $chan {[lindex $arg 1]}"
                luvmsg $chan "remind" "OK..."
            }
        } else {
            luvnotc $nick "remind" "syntax: [gethelpsyntax remind]"
        }
    }
}

proc doremind { nick chan msg } {
    luvmsg $chan "remind" "$nick: $msg."
}

proc reminderlist { nick host hand chan arg } {
    global privchan
    if { [hasaccess $nick "listremind"] } {
        set printed 0
        putlog "Listing reminders for $nick"
        foreach remind [utimers] {
            set command [lindex $remind 1]
            if { [lindex $command 0] == "doremind" && [lindex $command 1] == $nick } {
                luvmsg $chan "listremind" "(id #[string range [lindex $remind 2] 5 end]) You need to remember \"[join [lindex $command 3]]\" in [expr round([lindex $remind 0] / 60)] minutes."
                set printed 1
            }
        }
        if { $printed == 0 } {
            luvmsg $chan "listremind" "You don't have an active reminder."
        }
    }
}

proc remindercancel { nick host hand chan arg } {
    global privchan
    if { [hasaccess $nick "cancelremind"] } {
        set arg [getargs $arg 1]
        set removeid ""

        if { [llength $arg] > 0 && [string is integer [lindex $arg 0]] } {
            set removeid "timer[lindex $arg 0]"
        }
        set killed 0
        putlog "Cancelling reminders for $nick"
        foreach remind [utimers] {
            set command [lindex $remind 1]
            if { [lindex $command 0] == "doremind" && [lindex $command 1] == $nick } {
                if { $removeid == "" || $removeid == [lindex $remind 2] } {
                    killutimer [lindex $remind 2]
                    luvmsg $chan "cancelremind" "Removed the the reminder \"[join [lindex $command 3]]\""
                    set killed 1
                }
            }
        }
        if { $killed == 0 } {
            if { $removeid == "" } {
                luvmsg $chan "cancelremind" "You don't have an active reminder."
            } else {
                luvmsg $chan "cancelremind" "You don't have an active reminder with the id [lindex $arg 0]."
            }
        }
    }
}
