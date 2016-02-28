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


### MATCH EVALUATION SYSTEM

bind pub -|- !gg addgg
bind pub -|- !bg addbg
bind pub -|- !ggs ggs
bind pub -|- !bgs bgs

registerhelp "gg" "Marks this match as a GG. The name of the adder will not be shown." \
            "!gg <matchid> \[comment\]" \
            "!gg 1920 \"best game in a while\"" 3 "pub" "matcheval"
registerhelp "bg" "Marks this match as a BG. The name of the adder will not be shown." \
            "!bg <matchid> \[comment\]" \
            "!bg 1920 \"100% paskaa\"" 3 "pub" "matcheval"
registerhelp "bgs" "Shows the last 5 BGs vs the given clan." \
            "!bgs <clantag>" \
            "!bgs @no1" 3 "pub" "matcheval"
registerhelp "ggs" "Shows the last 5 GGs vs the given clan." \
            "!ggs <clantag>" \
            "!ggs @no1" 3 "pub" "matcheval"


proc ggs { nick host hand chan arg } {
    if { [hasaccess $nick "ggs"] } {
        set arg [getargs $arg 1]
        if { [llength $arg] < 1 } {
            luvnotc $nick "ggs" "syntax: [gethelpsyntax ggs]"
        } else {
            set db [getdb]
            set query [mysqlsel $db "select id from clans where tag collate utf8_bin like '[mysqlescape [lindex $arg 0]]'" -flatlist]
            if { [llength $query] > 0 } {
                set goodgames [mysqlsel $db "select matchid,comment from goodgames inner join matches on matchid = matches.id where opponent collate utf8_bin like '[mysqlescape [lindex $arg 0]]' order by matchid desc limit 5" -list]
                if { [llength $goodgames] > 0 } {
                    luvmsg $chan "ggs" "Last [llength $goodgames] GGs against \2[lindex $arg 0]\2:"
                    foreach gg $goodgames {
                        set commentstr "No comment"
                        if { [lindex $gg 1] != "" } {
                            set commentstr [lindex $gg 1]
                        }
                        luvmsg $chan "ggs" "(id #[lindex $gg 0]): $commentstr"
                    }
                } else {
                    luvmsg $chan "ggs" "No GGs registered vs \2[lindex $arg 0]\2"
                }
            } else {
                luvmsg $chan "ggs" "No clan with tag \2[lindex $arg 0]\2 found."
            }
        }
    }
}


proc bgs { nick host hand chan arg } {
    if { [hasaccess $nick "bgs"] } {
        set arg [getargs $arg 1]
        if { [llength $arg] < 1 } {
            luvnotc $nick "bgs" "syntax: [gethelpsyntax bgs]"
        } else {
            set db [getdb]
            set query [mysqlsel $db "select id from clans where tag collate utf8_bin like '[mysqlescape [lindex $arg 0]]'" -flatlist]
            if { [llength $query] > 0 } {
                set badgames [mysqlsel $db "select matchid,comment from badgames inner join matches on matchid = matches.id where opponent collate utf8_bin like '[mysqlescape [lindex $arg 0]]' order by matchid desc limit 5" -list]
                if { [llength $badgames] > 0 } {
                    luvmsg $chan "bgs" "Last [llength $badgames] BGs against \2[lindex $arg 0]\2:"
                    foreach bg $badgames {
                        set commentstr "No comment"
                        if { [lindex $bg 1] != "" } {
                            set commentstr [lindex $bg 1]
                        }
                        luvmsg $chan "bgs" "(id #[lindex $bg 0]): $commentstr"
                    }
                } else {
                    luvmsg $chan "bgs" "No BGs registered vs \2[lindex $arg 0]\2"
                }
            } else {
                luvmsg $chan "bgs" "No clan with tag \2[lindex $arg 0]\2 found."
            }
        }
    }
}


proc addgg { nick uhost hand chan arg } {
    if { [hasaccess $nick "gg"] } {
        set arg [getargs $arg 2]
        if { [llength $arg] < 1 || ![string is integer [lindex $arg 0]] } {
            luvnotc $nick "gg" "syntax: [gethelpsyntax gg]"
        } else {
            set db [getdb]
            set query [mysqlsel $db "select opponent from matches where id = '[lindex $arg 0]'" -flatlist]
            if { [llength $query] > 0 } {
                set author [translateirc $nick $db]
                set other [mysqlsel $db "select name from goodgames where matchid = '[lindex $arg 0]' and name collate utf8_bin like '[mysqlescape $author]'" -flatlist]

                set comment ""
                if { [llength $arg] > 1 } {
                    set comment [lindex $arg 1]
                }

                #remove any bg marking
                mysqlexec $db "delete from badgames where matchid = '[lindex $arg 0]' and name collate utf8_bin like '[mysqlescape $author]'"

                if { [llength $other] > 0 && $comment != "" } {
                    mysqlexec $db "update goodgames set comment = '[mysqlescape $comment]' where matchid = '[lindex $arg 0]' and name collate utf8_bin like '[mysqlescape $author]'"
                    luvmsg $chan "gg" "Marked the match vs \2[lindex $query 0]\2 (id #[lindex $arg 0]) as a GG"
                } elseif { [llength $other] == 0} {
                    mysqlexec $db "insert into goodgames (matchid,date,name,comment) values ('[lindex $arg 0]', '[clock seconds]', '[mysqlescape $author]', '[mysqlescape $comment]')"
                    if { $comment != "" } {
                        luvmsg $chan "gg" "Marked the match vs \2[lindex $query 0]\2 (id #[lindex $arg 0]) as a GG with the comment: \"[lindex $arg 1]\""
                    } else {
                        luvmsg $chan "gg" "Marked the match vs \2[lindex $query 0]\2 (id #[lindex $arg 0]) as a GG"
                    }
                } else {
                    luvmsg $chan "gg" "You've already marked this match as a GG"
                }
            } else {
                luvmsg $chan "gg" "No CW with that id."
            }
        }
    }
}

proc addbg { nick uhost hand chan arg } {
    if { [hasaccess $nick "bg"] } {
        set arg [getargs $arg 2]
        if { [llength $arg] < 1 || ![string is integer [lindex $arg 0]] } {
            luvnotc $nick "bg" "syntax: [gethelpsyntax bg]"
        } else {
            set db [getdb]
            set query [mysqlsel $db "select opponent from matches where id = '[lindex $arg 0]'" -flatlist]
            if { [llength $query] > 0 } {
                set author [translateirc $nick $db]
                set other [mysqlsel $db "select name from badgames where matchid = '[lindex $arg 0]' and name collate utf8_bin like '[mysqlescape $author]'" -flatlist]

                set comment ""
                if { [llength $arg] > 1 } {
                    set comment [lindex $arg 1]
                }

                #remove any gg marking
                mysqlexec $db "delete from goodgames where matchid = '[lindex $arg 0]' and name collate utf8_bin like '[mysqlescape $author]'"

                if { [llength $other] > 0 && $comment != "" } {
                    mysqlexec $db "update badgames set comment = '[mysqlescape $comment]' where matchid = '[lindex $arg 0]' and name collate utf8_bin like '[mysqlescape $author]'"
                    luvmsg $chan "bg" "Marked the match vs \2[lindex $query 0]\2 (id #[lindex $arg 0]) as a BG"
                } elseif { [llength $other] == 0} {
                    mysqlexec $db "insert into badgames (matchid,date,name,comment) values ('[lindex $arg 0]', '[clock seconds]', '[mysqlescape $author]', '[mysqlescape $comment]')"
                    if { $comment != "" } {
                        luvmsg $chan "bg" "Marked the match vs \2[lindex $query 0]\2 (id #[lindex $arg 0]) as a BG with the comment: \"[lindex $arg 1]\""
                    } else {
                        luvmsg $chan "bg" "Marked the match vs \2[lindex $query 0]\2 (id #[lindex $arg 0]) as a BG"
                    }
                } else {
                    luvmsg $chan "bg" "You've already marked this match as a BG"
                }
            } else {
                luvmsg $chan "bg" "No CW with that id."
            }
        }
    }
}
