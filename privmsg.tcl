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


### Stuff that gets said to luverboy through private msgs
bind msgm -|- * saytoprivchan
bind time - "10 * * * *" resetprivspam
bind time - "40 * * * *" resetprivspam


proc resetprivspam { min hour day month year } {
    global privspamarray
    catch { unset privspamarray }
}

proc privsaymatchunderway { nick arg } {
    global cwspyarray cwsearchregexp mytag
    if { [regexp -nocase -- $cwsearchregexp $arg] != 0 } {
        set saylist [list]
        set maxdate 0
        foreach { server cwspylist } [ array get cwspyarray ] {
            if { [lindex $cwspylist 6] > $maxdate } {
                set maxdate [lindex $cwspylist 6]
            }
            if { [lindex $cwspylist 2] != "" } {
                lappend saylist "against [lindex $cwspylist 2] at $server"
            } else {
                lappend saylist "at $server"
            }
        }

        if { [llength $saylist] > 0 } {
            if { [llength $saylist] > 1 } {
                lset saylist end "and [lindex $saylist end]"
                putmsg $nick "$mytag is playing [llength $saylist] CWs at the moment. We are playing [join $saylist {, }] right now."
            } else {
                putmsg $nick "$mytag is playing [lindex $saylist 0] right now."
            }
            return 1
        } else {
            return 0
        }
    } else {
        return 0
    }
}

proc saytoprivchan { nick host hand arg } {
    global privchan clanname privspamarray privspamlines

    set txt [join [split $arg]]

    if { ![onchan $nick $privchan] && ![regexp -- "^!.*" $txt] } {
        if { [privsaymatchunderway $nick [join [lrange $arg 1 end]]] == 1 } {
            putlog "Match request by private message from $nick"
            luvmsg $privchan "msg" "$nick said: \"$txt\". I told him that we were playing already."
        } else {
            if { [info exists privspamarray($hand)] } {
                set privspamarray($hand) [expr $privspamarray($hand) + 1]
            } else {
                set privspamarray($hand) 0
            }

            if { $privspamarray($hand) <= $privspamlines } {
                putlog "Forwarding the msg from $nick to $privchan"
                luvmsg $privchan "msg" "$nick said: \"$txt\""
                luvmsg $nick "msg" "Your message has been forwarded to the $clanname private channel. You can send \2[expr $privspamlines - $privspamarray($hand)]\2 more messages before being ignored."
            }
        }
    } else {
        set arg [split $txt]

        if { [string match "!op" [lindex $arg 0]] } {
            #see administration
            giveops $nick $host $hand [join [lrange $arg 1 end]]
        } elseif { [string match "!resetpass" [lindex $arg 0]] } {
            #see administration
            resetpass $nick $host $hand "" [join [lrange $arg 1 end]]
        } elseif { [string match "!setpass" [lindex $arg 0]] } {
            #see administration
            changepassword $nick $host $hand [join [lrange $arg 1 end]]
        } elseif { [string match "!vote" [lindex $arg 0]] } {
            #see vote
            dovote $nick $host $hand [join [lrange $arg 1 end]]
        } elseif { [string match "!setphone" [lindex $arg 0]] } {
            #see administration
            setphone $nick $host $hand "" [join [lrange $arg 1 end]]
        }
    }
}

