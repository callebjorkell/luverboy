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


### This module is for learning and then repeating certain key words and their definition
### mysql required!

bind pub -|- ! learnsave
bind pub -|- ? learnload

registerhelp "?" "Shows the definition for the given keyphrase if it is found in my database. An exact match is required." \
            "? <keyphrase>" \
            "? \"triggers\"" 1 "pub" "learn"
registerhelp "!" "Teaches me the definition for a certain keyphrase." \
            "! <keyphrase> <definition>" \
            "! \"triggers\" \"Triggers can be used in aprq2 scripts\"" 3 "pub" "learn"


proc learnload { nick host hand chan arg } {
    if { [hasaccess $nick "?"] } {
        set arg [getargs $arg 1]
        if { [llength $arg] > 0 } {
            set db [getdb]
            set def [mysqlsel $db "select definition,author from definitions where keyphrase like '[mysqlescape [lindex $arg 0]]'" -flatlist]
            if { [llength $def] > 0 } {
                luvmsg $chan "?" "\2[lindex $arg 0]\2: [lindex $def 0] (by [lindex $def 1])"
            } else {
                luvmsg $chan "?" "No definition for \2[lindex $arg 0]\2 found."
            }
        #} else {
        #    This would have generated a syntax check, but was commented out as ? is a quite frequent line in irc :)
        #    luvnotc $nick "?" "syntax: [gethelpsyntax ?]"
        }
    }
}


proc learnsave { nick host hand chan arg } {
    if { [hasaccess $nick "!"] } {
        set arg [getargs $arg 2]
        if { [llength $arg] > 1 } {
            set db [getdb]
            set author [mysqlescape [translateirc $nick $db]]
            set lines 0
            catch { set lines [mysqlexec $db "insert into definitions (keyphrase, definition, author, date) values ('[mysqlescape [lindex $arg 0]]', '[mysqlescape [lindex $arg 1]]', '$author', [clock seconds])"] }
            if { $lines == 1 } {
                luvmsg $chan "!" "Saved the definition for \2[lindex $arg 0]\2"
            } else {
                mysqlexec $db "update definitions set definition = '[mysqlescape [lindex $arg 1]]', author = '$author', date = [clock seconds] where keyphrase like '[mysqlescape [lindex $arg 0]]'"
                luvmsg $chan "!" "Updated the definition for \2[lindex $arg 0]\2"
            }
        } elseif { [llength $arg] > 0 } {
            luvnotc $nick "!" "syntax: [gethelpsyntax !]"
        }
    }
}
