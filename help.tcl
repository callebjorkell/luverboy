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


### HELP FUNCTIONS

#access:
# 4 - Bot admin
# 3 - OP on the private channel
# 2 - OP or VOICE on either channel.
# 1 - Any user.

bind pub -|- !help printhelp

proc printhelp {nick host hand chan arg} {
    global privchan botnick
    set arg [split $arg]
    if { [llength $arg] > 0 } {
        if { [isop $nick $privchan] } {
            if { [lindex $arg 0] == "*" } {
                luvnotc $nick "help" "Sending help to everyone."

                set ignorenicks [list "Q" $botnick $nick]

                set nicks [chanlist $privchan]
                if { [llength $nicks] > 0 } {
                    foreach n $nicks {
                        if { [lsearch $ignorenicks $n] == -1 } {
                            if { [isop $nick $chan] || [isvoice $nick $privchan] || [isvoice $nick $chan] || [isop $nick $privchan] } {
                                printhelp $n "" "" $chan [lrange $arg 1 end]
                            }
                        }
                    }
                }
            } elseif { [onchan [lindex $arg 0] $chan] } {
                luvnotc $nick "help" "Sending help to [lindex $arg 0]."
                printhelp [lindex $arg 0] "" "" $chan [join [lrange $arg 1 end]]
            } else {
                gethelp [lindex $arg 0] $nick $chan
            }
        } else {
            gethelp [lindex $arg 0] $nick $chan
        }
    } else {
        gethelpcommandlist $nick $chan
    }
}

proc registerhelp {command helpstr syntax example access type {group ""} } {
    global helparray helpgroups
    set command [string trim $command]

    set helparray($command) [list $helpstr $syntax $example $access $type $group]

    if { $group != "" } {
        if { [array exists helpgroups] && [info exists helpgroups($group) ] } {
            set cmdlist $helpgroups($group)
            if { [lsearch $cmdlist $command] == -1 } {
                lappend cmdlist $command
                set helpgroups($group) $cmdlist
            }
        } else {
            set helpgroups($group) [list $command]
        }
    }
}

proc gethelpsyntax { command } {
    global helparray
    if { [array exists helparray] } {
        if { [info exists helparray($command)] } {
            set helplist $helparray($command)
            return [lindex $helplist 1]
        } else {
            putlog "gethelpsyntax: $command doesn't have a helparray entry..."
            return ""
        }
    } else {
        putlog "gethelpsyntax: No helparray found..."
        return ""
    }
}

proc gethelpcommandlist { nick chan } {
    global privchan pchan

    set hand [nick2hand $nick]
    if { [validuser $hand] && [matchattr $hand "m"] } {
        printhelpcommandlist $nick 4
    } elseif { [isop $nick $privchan] } {
        printhelpcommandlist $nick 3
    } elseif { [isvoice $nick $privchan] || [isvoice $nick $pchan] || [isop $nick $pchan] } {
        printhelpcommandlist $nick 2
    } else {
        printhelpcommandlist $nick 1
    }
    return
}

proc printhelpcommandlist { nick access } {
    global helparray
    if { [array exists helparray] } {
        set publist [list]
        set privlist [list]
        foreach {command helplist} [array get helparray] {
            if { [string length $command] > 1 } {
                set command "!$command"
            }

            if { [lindex $helplist 3] <= $access } {
                if { [lindex $helplist 4] == "priv" } {
                    lappend privlist "$command"
                } else {
                    lappend publist "$command"
                }
            }
        }
        if { [llength $publist] > 0 } {
            luvnotc $nick "help" "\2Public commands:\2 [join [lsort $publist] {, }]"
        }
        if { [llength $privlist] > 0 } {
            luvnotc $nick "help" "\2Private commands:\2 [join [lsort $privlist] {, }]"
        }
        luvnotc $nick "help" "Remember to put \"\" around all fields that contain spaces, and not to use \"\" inside the fields!"
        luvnotc $nick "help" "More information is available for most of the commands, try \2!help command\2"
    } else {
        putlog "printhelpcommandlist: No helparray found..."
    }
}

proc userflooding { nick } {
    global floodarray banarray bantime floodlimit floodtime

    if { $floodlimit == 0 } {
        return 0
    } else {
        set now [clock seconds]
        set host [getchanhost $nick]
        set floodlist [list]

        if { [string match $host ""] } {
            set host $nick
        }

        if { [array exists banarray] } {
            if { [info exists banarray($host)] } {
                if { $banarray($host) > $now } {
                    # the user is banned, don't say or do anything, just return false.
                    return 1;
                } else {
                    # clear the users ban.
                    array unset banarray $host
                }
            }
        }

        if { [array exists floodarray] && [info exists floodarray($host)] } {
            set floodlist $floodarray($host)
        }

        #get the window for the flood.
        lappend floodlist $now

        # set the flood window to now - $floodtime seconds.
        set floodwindow [expr $now - $floodtime]

        while { [llength $floodlist] > 0 && [lindex $floodlist 0] < $floodwindow } {
            # remove the expired event
            set floodlist [lreplace $floodlist 0 0]
        }

        if { [llength $floodlist] == 0 } {
            array unset floodarray $host
        } else {
            set floodarray($host) $floodlist
        }

        if { [llength $floodlist] == [expr $floodlimit - 1] } {
            luvnotc $nick "flood" "Warning: If you continue to flood I will have to ban you from using my commands for a while..."
        }

        if { [llength $floodlist] > $floodlimit } {
            luvnotc $nick "flood" "Stop angsting and flooding! Since you can't behave, I'll ignore you for $bantime seconds..."
            set banarray($host) [expr $now + $bantime]
            return 1
        } else {
            return 0
        }
    }
}

proc hasaccess { nick function } {
    global helparray privchan pchan myprefix
    if { [userflooding $nick] } {
        return 0
    }

    if { [array exists helparray] } {
        if { [info exists helparray($function)] } {
            set helplist $helparray($function)
            switch -- [lindex $helplist 3] {
                2 {
                    if { [onchan $nick $privchan] || [isvoice $nick $privchan] || [isvoice $nick $pchan] || [isop $nick $pchan] || [isop $nick $privchan] } {
                        return 1
                    } else {
                        luvnotc $nick "$function" "You need to have VOICE to use this command!"
                        return 0
                    }
                }
                3 {
                    if { [isop $nick $privchan] } {
                        return 1
                    } else {
                        luvnotc $nick "$function" "You need to be a [string toupper $myprefix] to use this command!"
                        return 0
                    }
                }
                default {
                    return 1
                }
            }
        } else {
            putlog "hasaccess: no entry for $function"
            return 0
        }
    } else {
        putlog "hasaccess: no helparray!"
        return 0
    }
}

proc gethelp { command nick chan } {
    global helparray privchan pchan helpgroups

    if { [string length $command] > 1 } {
        set command [string tolower [string trimleft $command "!"]]
    } else {
        set command [string tolower $command]
    }

    if { [array exists helparray] && [info exists helparray($command)] } {
        set helplist $helparray($command)
        set allowed 0
        switch -- [lindex $helplist 3] {
            2 {
                if { [isvoice $nick $privchan] || [isvoice $nick $chan] || [isop $nick $chan] || [isop $nick $privchan] } {
                    set allowed 1
                }
            }
            3 {
                if { [isop $nick $privchan] } {
                    set allowed 1
                }
            }
            default {
                set allowed 1
            }
        }

        if { $allowed == 0 } {
            luvnotc $nick "help" "You don't have the neccessary status to use the command \2$command\2"
        } else {
            luvnotc $nick "help" "[lindex $helplist 0]"
            luvnotc $nick "help" "Syntax: [lindex $helplist 1]"
            luvnotc $nick "help" "Example: [lindex $helplist 2]"

            if { [lindex $helplist 5] != "" && [array exists helpgroups] && [info exists helpgroups([lindex $helplist 5])] } {
                set cmdlist $helpgroups([lindex $helplist 5])
                set cmdindex [lsearch $cmdlist $command]
                if { $cmdindex != -1 } {
                    set cmdlist [lreplace $cmdlist $cmdindex $cmdindex]
                }
                if { [llength $cmdlist] > 0 } {
                    luvnotc $nick "help" "Related commands: [join [lsort $cmdlist] {, }]"
                }
            }
        }
    } else {
        putlog "gethelp: No helparray found, or $command doesn't have a helparray entry..."
        luvnotc $nick "help" "There is no help available for the command $command."
    }
}
