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


source ${username}/web.tcl

set baseurl_oneliner "http://www.randomjoke.com/topic/oneliners.php?"
set maxindex 60000

bind pub -|- !oneliner oneliner
bind pub -|- !oneliners oneliners

registerhelp "oneliners" "Prints a number of random oneliner jokes." \
            "!oneliners <amount>" \
            "!oneliners" 2 "pub" "fun"
registerhelp "oneliner" "Prints a random oneliner joke. A specific oneliner can be specified with !oneliner \[id\]" \
            "!oneliner \[id\]" \
            "!oneliner" 1 "pub" "fun"

proc oneliners { nick host hand chan arg } {
    if { [hasaccess $nick "oneliners"] } {
        set arg [getargs $arg 1]
        if { [llength $arg] < 1 || ![string is integer [lindex $arg 0]]} {
            luvnotc $nick "oneliners" "syntax: [gethelpsyntax oneliners]"
        } else {
            set amount [lindex $arg 0]
            if { $amount < 1 } {
                set amount 1
            } elseif { $amount > 10 } {
                set amount 10
            }

            for {set i 0} {$i < $amount} {incr i} {
                set oneliner [getoneliner]
                if { [lindex $oneliner 0] != -1 } {
                    luvmsg $chan "oneliners" "(id #[lindex $oneliner 0]) [lindex $oneliner 1]"
                }
            }
        }
    }
}

proc oneliner { nick host hand chan arg } {
    global baseurl_oneliner maxindex
    if { [hasaccess $nick "oneliner"] } {
        set arg [getargs $arg 1]
        set index -1
        if { [llength $arg] > 0 } {
            if { [string is integer [lindex $arg 0]] } {
                if {[lindex $arg 0] <= $maxindex && [lindex $arg 0] > 0} {
                    set index [lindex $arg 0]
                } else {
                    luvmsg $chan "oneliner" "Index is out of bounds."
                    return
                }
            } else {
                luvnotc $nick "oneliner" "syntax: [gethelpsyntax oneliner]"
                return
            }
        }

        set oneliner [getoneliner $index]
        if { [lindex $oneliner 0] != -1 } {
            luvmsg $chan "oneliner" "(id #[lindex $oneliner 0]) [lindex $oneliner 1]"
        } else {
            luvmsg $chan "oneliner" "No oneliner found :<"
        }
    }
}

proc getoneliner {{index -1}} {
    global baseurl_oneliner maxindex
    if { $index == -1 } {
        set index [expr { round(rand()* $maxindex) }]
    }
    set html [join [gethtml "${baseurl_oneliner}$index"]]

    if { [regexp -- "<\/P> <P> (.+) <CENTER> <div align=\"center\">" $html all joke] } {
        regsub -all -nocase -- "<.+?>" $joke "" joke
        regsub -all -nocase -- "\ +" $joke " " joke
        return [list $index [string trim $joke]]
    } else {
        return [list -1]
    }
}

