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

bind pub -|- !google google
bind pub -|- !googlefight googlefight

registerhelp "google" "Returns the first google result for the given query." \
            "!google <query>" \
            "!google \"Love messengers\"" 1 "pub" "general"
registerhelp "googlefight" "Starts a google fight between two queries" \
            "!googlefight <statement1> <statement2>" \
            "!googlefight \"Pizza is good\" \"Pizza is great\"" 1 "pub" "general"

set google_base "http://www.google.fi/search?hl=en&q="

proc google { nick host hand chan arg } {
    global google_base
    if { [hasaccess $nick "google"] } {
        set arg [getargs $arg 1]
        if { [llength $arg] < 1 } {
            luvnotc $nick "google" "syntax: [gethelpsyntax google]"
        } else {
            set html [gethtml ${google_base}[urlencode [lindex $arg 0]]]
            set printed 0
            foreach line $html {
                if { [regexp "<!--m-->.*?<a href=\"(\[^\"\]+)\".*?>(.*?)</a>" $line all link desc] } {
                    regsub -all -nocase -- "<.+?>" $desc "" desc
                    luvmsg $chan "google" "\2$link\2 - $desc"
                    set printed 1
                    break
                }
            }

            if { $printed == 0 } {
                luvmsg $chan "google" "Couldn't find or parse a result for the query \"[lindex $arg 0]\""
            }
        }
    }
}

proc googlefight { nick host hand chan arg } {
    global google_base
    if { [hasaccess $nick "googlefight"] } {
        set arg [getargs $arg 2]
        if { [llength $arg] != 2 } {
            luvnotc $nick "googlefight" "syntax: [gethelpsyntax googlefight]"
        } else {
            set html1 [gethtml ${google_base}[urlencode \"[lindex $arg 0]\"]]
            set html2 [gethtml ${google_base}[urlencode \"[lindex $arg 1]\"]]

            set results1 -1
            set results2 -1

            foreach line $html1 {
                if { [regexp "Results <b>1</b> - <b>\[0-9\]+</b> of (?:about )?<b>(\[0-9,\]+)</b>" $line all results] } {
                    set results1 [string map {, ""} $results]
                } elseif { [regexp "</b> - did not match any documents." $line all] } {
                    set results1 0
                }
            }
            foreach line $html2 {
                if { [regexp "Results <b>1</b> - <b>\[0-9\]+</b> of (?:about )?<b>(\[0-9,\]+)</b>" $line all results] } {
                    set results2 [string map {, ""} $results]
                } elseif { [regexp "</b> - did not match any documents." $line all] } {
                    set results2 0
                }
            }

            if { $results1 > -1 && $results2 > -1 } {
                if { $results1 > $results2 } {
                    luvmsg $chan "googlefight" "The winner is \2[lindex $arg 0]\2 with $results1 results! ($results2 results for [lindex $arg 1])"
                } elseif { $results2 > $results1 } {
                    luvmsg $chan "googlefight" "The winner is \2[lindex $arg 1]\2 with $results2 results! ($results1 results for [lindex $arg 0])"
                } else {
                    luvmsg $chan "googlefight" "However unlikely, this was a tie. Both queries had $results1 results each."
                }
            } else {
                luvmsg $chan "googlefight" "Hmm... I couldn't parse the results correctly :("
            }
        }
    }
}
