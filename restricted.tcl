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


### PROCS RESTRICTED TO BOT-ADMIN USE
bind pub m|m !addtrial addtrial
bind pub m|m !del${myprefix} delmember
bind pub m|m !promotetrial promotetrial
bind pub m|m !rehash rehashb
bind pub m|m !add${myprefix}alias addmemberalias
bind pub m|m !debug debugmem

registerhelp "addtrial" "Adds a new ${myprefix} trial" \
            "!addtrial <name> <ircnick> <bday (YYYY-MM-DD)>" \
            "!addtrial NRGizeR eNeRGi 1982-08-02" 4 "pub" "manage"
registerhelp "del${myprefix}" "Deletes a ${myprefix} whe he/she leaves :(" \
            "!del${myprefix} <name> \[reason\]" \
            "!del${myprefix} NRGizeR \"The bastard left :<\"" 4 "pub" "manage"
registerhelp "promotetrial" "Promotes a trial to full ${myprefix} status" \
            "!promotetrial <name>" \
            "!promotetrial NRGizeR" 4 "pub" "manage"
registerhelp "rehash" "Rehashes the scripts and re-reads them into memory" \
            "!rehash" \
            "!rehash" 4 "pub" "manage"
registerhelp "add${myprefix}alias" "Adds a new player alias for the given ${myprefix}" \
            "!add${myprefix}alias <${myprefix}> <alias>" \
            "!add${myprefix}alias Montsa MoonElf" 4 "pub" "manage"

proc debugmem { nick host hand chan arg } {
    global quotequeue cwspyarray completedcws whoisqueue

    putlog "\nTimers:"
    foreach remind [utimers] {
        putlog $remind
    }

    putlog "\nQuotes:"
    foreach quote $quotequeue {
        putlog $quote
    }

    putlog "\ncwspyarray:"
    foreach {server cw} [array get cwspyarray] {
        putlog "server: $server ; cw: $cw"
    }

    putlog "\ncompletedcws:"
    foreach completed $completedcws {
        putlog $completed
    }

    putlog "\nwhoisqueue:"
    foreach whois $whoisqueue {
        putlog $whois
    }
}

proc addmemberalias { nick uhost hand chan arg } {
    global privchan myprefix
    if { [hasaccess $nick "add${myprefix}alias"] } {
        set arg [getargs $arg 2]
        if { [llength $arg] < 2 } {
            luvnotc $nick "add${myprefix}alias" "syntax: [gethelpsyntax add${myprefix}alias]"
            return 1
        } else {
            set db [getdb]
            set member [translateirc [lindex $arg 0] $db ]
            set alias [lindex $arg 1]
            set info [mysqlsel $db "select id,name from members where name like '[mysqlescape $member]'" -flatlist]

            if { [llength $info] < 1 } {
                luvmsg $chan "add${myprefix}alias" "I can't find any ${myprefix} by that name..."
            } else {
                mysqlexec $db "insert into memberalias (memberid, name) values ('[lindex $info 0]', '[mysqlescape $alias]')"
                luvmsg $chan "add${myprefix}alias" "The alias \2$alias\2 was added for ${myprefix} \2[lindex $info 1]\2."
            }
        }
    }
}


proc promotetrial { nick uhost hand chan arg } {
    global privchan pchan botnick myprefix
    set arg [getargs $arg 1]
    if { [llength $arg] < 1 } {
        luvnotc $nick "promotetrial" "syntax: [gethelpsyntax promotetrial]"
    } else {
        set db [getdb]
        set promoted [mysqlexec $db "update members set status = 0 where name like '[mysqlescape [lindex $arg 0]]'"]
        if { $promoted < 1 } {
            luvmsg $chan "promotetrial" "I don't have a trial by that name in the database."
        } else {
            set membername [mysqlsel $db "select name from members where name like '[mysqlescape [lindex $arg 0]]'" -flatlist]
            if { [llength $membername] > 0 } {
                set memname [lindex $membername 0]
                mysqlexec $db "insert into news (date, author,topic, text) values ([clock seconds], '${botnick}', '[mysqlescape $memname] was promoted', 'Our ex-trial of luuv, [mysqlescape $memname], was promoted to a fullblown member today. Congratulations [mysqlescape $memname] and may there be many luving times ahead!')"
            }
            luvmsg $pchan "promotetrial" "\2$memname\2 was promoted to a full ${myprefix}! Congratulations $memname! <3"
            luvmsg $privchan "promotetrial" "\2$memname\2 was promoted to a full ${myprefix}! Congratulations $memname! <3"
        }
    }
}

proc addtrial { nick uhost hand chan arg } {
    global privchan pchan
    set arg [getargs $arg 3]
    if { [llength $arg] < 3 || ![regexp -- "\[0-9]\{4\}-\[0-9\]\{2\}-\[0-9\]\{2\}" [lindex $arg 2]]} {
        luvnotc $nick "addtrial" "syntax: [gethelpsyntax addtrial]"
        return 1;
    }

    set db [getdb]
    mysqlexec $db "insert into members (name, birthday,status) values ('[mysqlescape [lindex $arg 0]]', '[mysqlescape [lindex $arg 2]]', 1)"
    set index [mysqlinsertid $db]
    mysqlexec $db "insert into ircnicks (memberid, nick) values ('$index', '[mysqlescape [lindex $arg 1]]')"
    mysqlexec $db "insert into memberalias (memberid, name) values ('$index', '[mysqlescape [lindex $arg 0]]')"

    luvmsg $privchan "addtrial" "A big welcome to our new trial \2[lindex $arg 0] <3"
    luvmsg $pchan "addtrial" "A big welcome to our new trial \2[lindex $arg 0] <3"
}

proc delmember { nick uhost hand chan arg } {
    global privchan pchan myprefix
    set arg [getargs $arg 2]
    if { [llength $arg] < 1 } {
        luvnotc $nick "del${myprefix}" "syntax: [gethelpsyntax del${myprefix}]"
        return 1;
    }

    set db [getdb]

    set membername [translateirc [lindex $arg 0] $db]
    set memberid [mysqlsel $db "select id from members where name like '[mysqlescape $membername]'" -flatlist]
    if { [llength $memberid] < 1 } {
        luvmsg $chan "del${myprefix}" "I couldn't find a ${myprefix} with that name..."
    } else {
        mysqlexec $db "delete from members where id = '[lindex $memberid 0]'"
        mysqlexec $db "delete from ircnicks where memberid = '[lindex $memberid 0]'"
        mysqlexec $db "delete from irchosts where memberid = '[lindex $memberid 0]'"
        mysqlexec $db "delete from memberalias where memberid = '[lindex $memberid 0]'"
        if { [llength $arg] > 1 } {
            luvmsg $pchan "del${myprefix}" "\2$membername\2 is no longer part of the luuv. Reason: [lindex $arg 1] :("
            luvmsg $privchan "del${myprefix}" "\2$membername\2 is no longer part of the luuv. Reason: [lindex $arg 1] :("
        } else {
            luvmsg $pchan "del${myprefix}" "*sniff* \2$membername\2 ran out of luuv and left :("
            luvmsg $privchan "del${myprefix}" "*sniff* \2$membername\2 ran out of luuv and left :("
        }
    }
}

proc rehashb { nick uhost handle chan arg } {
    rehash
    luvmsg $chan "rehash" "Done..."
}

