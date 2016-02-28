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


### TELL SYSTEM

bind pub -|- !tell addtell
bind pub -|- !listtell listtell
bind pub -|- !tellsearch tellsearch

registerhelp "tell" "Tells the message the another user when this person joins one of the channels I'm on. As <tonick> you can use either a IRC nick, or a $myprefix name." \
            "!tell <tonick> <message>" \
            "!tell NRGizeR Oot ihq" 3 "pub" "tell"
registerhelp "listtell" "Lists the last five tells for you in a private message." \
            "!listtell" \
            "!listtell" 3 "pub" "tell"
registerhelp "tellsearch" "Searches your tells for a substring. You can use ? and * to match one or many characters respectively." \
            "!tellsearch <searchstring>" \
            "!tellsearch mega" 3 "pub" "tell"

bind join - "$privchan *" onjoin_delivertells
bind join - "$pchan *" onjoin_delivertells
bind nick - "$pchan *" onnick_delivertells
bind nick - "$privchan *" onnick_delivertells

proc onnick_delivertells {nick host hand chan newnick } {
    delivertells $newnick $chan
}


proc onjoin_delivertells {nick host hand chan} {
    delivertells $nick $chan
}

proc delivertells { nick chan } {
    set db [getdb]
    set tonick [translateirc $nick $db]
    set tonickesc [mysqlescape [string map {_ \\_ \\ \\\\} $tonick]]

    set msgs [mysqlsel $db "select fromnick, message, date from tells where tonick like '[mysqlescape $tonickesc]' and delivered = 0 order by date asc" -list]
    if {[llength $msgs] > 0 } {
        if {[llength $msgs] == 1 } {
            luvmsg $chan "tell" "${nick}: I have 1 message for you. I'll send it to you in a private message."
        } else {
            luvmsg $chan "tell" "${nick}: I have [llength $msgs] messages for you. I'll send them to you in a private message."
        }
        foreach msg $msgs {
            set timeago [expr [clock seconds] - [lindex $msg 2]]
            set timestring [gettimestring $timeago]
            luvmsg $nick "tell" "[lindex $msg 0] told me to tell you \"[lindex $msg 1]\" $timestring ago."
        }

        mysqlexec $db "update tells set delivered = 1 where tonick like '[mysqlescape $tonickesc]' and delivered = 0"
    }
}

proc gettimestring { timeago } {
    if { $timeago > 86400 } {
        return "[expr $timeago / 86400] days"
    } elseif { $timeago > 3600 } {
        return "[expr $timeago / 3600] hours"
    } else {
        return "[expr $timeago / 60] minutes"
    }
}

proc listtell { nick host hand chan arg } {
    if { [hasaccess $nick "listtell"] } {
        set db [getdb]
        set tonick [translateirc $nick $db]
        set tonickesc [mysqlescape [string map {_ \\_ \\ \\\\} $tonick]]

        set msgs [mysqlsel $db "select fromnick, message, date from tells where tonick like '[mysqlescape $tonickesc]' order by date desc limit 5" -list]
        if {[llength $msgs] > 0 } {
            foreach msg $msgs {
                luvmsg $nick "tell" "[lindex $msg 0] told me to tell you \"[lindex $msg 1]\" on [clock format [lindex $msg 2] -format "%d.%m.%Y"]"
            }
        } else {
            luvmsg $chan "tell" "I have nothing to tell you."
        }
    }
}


proc addtell { nick host hand chan arg } {
    global pchan privchan
    if { [hasaccess $nick "tell"] } {
        set arg [getargs $arg 2]
        if { [llength $arg] > 1 } {
            set db [getdb]

            if { [lindex $arg 0] == "*" } {
                luvmsg $chan "tell" "I'll do that."

                set nicks [mysqlsel $db "select nick,name from ircnicks inner join members on memberid = members.id order by name" -list]
                set lastdelivered ""
                set lastseen ""

                set fromnick [translateirc $nick $db]
                set msg [lindex $arg 1]

                foreach arrnick $nicks {
                    if { [lindex $arrnick 1] == $fromnick } {
                        continue
                    }
                    if { [lindex $arrnick 1] != $lastdelivered } {
                        if { $lastseen != [lindex $arrnick 1] && $lastseen != $lastdelivered && $lastseen != ""} {
                            mysqlexec $db "insert into tells (tonick, fromnick, message, date, delivered) values ('[mysqlescape $lastseen]', '[mysqlescape $fromnick]', '[mysqlescape $msg]', [clock seconds], 0)"
                        }

                        if { [lindex $arrnick 1] != $fromnick } {
                            if { [onchan [lindex $arrnick 0] $privchan] || [onchan [lindex $arrnick 0] $pchan] } {
                                luvmsg [lindex $arrnick 0] "tell" "$fromnick told me to tell you \"$msg\"."
                                set lastdelivered [lindex $arrnick 1]
                            }
                        }
                    }
                    set lastseen [lindex $arrnick 1]
                }

                if { $lastseen != $lastdelivered && $lastseen != $fromnick} {
                    mysqlexec $db "insert into tells (tonick, fromnick, message, date, delivered) values ('[mysqlescape $lastseen]', '[mysqlescape $fromnick]', '[mysqlescape $msg]', [clock seconds], 0)"
                }
            } else {
                set tonick [translateirc [lindex $arg 0] $db ]
                set tonickesc [mysqlescape [string map {_ \\_ \\ \\\\} $tonick]]

                #check if the tonick is online.
                set online 0

                set nicks [mysqlsel $db "select nick from ircnicks inner join members on memberid = members.id where name like '$tonickesc'" -flatlist]

                #if this was not a member, just append the "original" nick and check that one.
                if { [llength $nicks] == 0 } {
                    lappend nicks [lindex $arg 0]
                }

                foreach arrnick $nicks {
                    if { [onchan $arrnick $privchan] || [onchan $arrnick $pchan] } {
                        luvmsg $chan "tell" "Why don't you do that yourself? $arrnick is online!"
                        set online 1
                        break
                    }
                }

                if { $online != 1 } {
                    set fromnick [translateirc $nick $db]
                    set msg [lindex $arg 1]

                    mysqlexec $db "insert into tells (tonick, fromnick, message, date, delivered) values ('[mysqlescape $tonick]', '[mysqlescape $fromnick]', '[mysqlescape $msg]', [clock seconds], 0)"
                    luvmsg $chan "tell" "I'll do that."
                }
            }
        } else {
            luvnotc $nick "tell" "syntax: [gethelpsyntax tell]"
        }
    }
}

proc tellsearch { nick host hand chan arg } {
    global privchan

    if { [hasaccess $nick "tellsearch"] } {
        set arg [getargs $arg 1]
        if { [llength $arg] > 0 } {
            set searchstr [lindex $arg 1]
            set mysqlsearchstr [string map {* % ? _} [mysqlescape [string map {% \\% _ \\_} $searchstr]]]
            set db [getdb]

            set tonick [translateirc $nick $db]
            set tonickesc [mysqlescape [string map {_ \\_ \\ \\\\} $tonick]]

            set msgs [mysqlsel $db "select fromnick, message, date from tells where tonick like '[mysqlescape $tonickesc]' and message like '%${mysqlsearchstr}%' order by date desc" -list]
            if {[llength $msgs] > 0 } {
                set count 0
                foreach msg $msgs {
                    if { $count >= 5 } {
                        break
                    }
                    luvmsg $nick "tellsearch" "[lindex $msg 0] told me to tell you \"[lindex $msg 1]\" on [clock format [lindex $msg 2] -format "%d.%m.%Y"]"
                    incr count
                }
                if { $count < [llength $msgs] } {
                    luvmsg $nick "tellsearch" "And [expr [llength $msgs] - $count] more..."
                }
            } else {
                luvmsg $chan "tellsearch" "No matches for $searchstr."
            }
        } else {
            luvnotc $nick "votesearch" "syntax: [gethelpsyntax tellsearch]"
        }
    }
}

