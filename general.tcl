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


### GENERAL AND/OR "FUN" STUFF

bind pub -|- !highlight highlightchan
bind pub -|- !hl highlightchan
bind pub -|- !status showstatus
bind pub -|- !kick pubchankick
bind pub -|- !addquote setquote
bind pub -|- !whois askwhois
bind pub -|- !guessclan ircguessclan
#bind pub -|- !roll generateroll
bind pubm - "% s/*/*/*" sedreplace

bind pubm - "% $nick*" introduce

bind pubm - "% !?on?*" domatchsearch

bind time - "45 10 * * *" membergratz
bind time - "45 19 * * *" membergratz

bind notc - "*" checkz0rbug
bind join - "$privchan *" onjoin_checknick
bind nick - "$privchan *" onnick_addnick

bind pubm -|- "*" rememberquote

bind pubm - "$pchan \[CW\] #*" filtercwlist
bind pubm - "$pchan Message output disabled*" msgoutputdisabled
bind pubm - "$pchan Message output enabled*" msgoutputenabled

bind evnt -|- init-server qnet_auth

registerhelp "hl" "See the help for !highlight" \
            "!hl" \
            "!hl" 3 "pub" "general"
registerhelp "highlight" "Highlights every OP in the channel. Useful for screaming at people to play or the likes :)" \
            "!highlight \[message\]" \
            "!highlight Come play you lazy bastards!" 3 "pub" "general"
registerhelp "status" "Shows my current status" \
            "!status" \
            "!status" 0 "pub" "stats"
registerhelp "kick" "Kicks a user from the public channel" \
            "!kick <nick> \[reason\]" \
            "!kick Demoni pssiiiiiiit!" 3 "pub" "chan"
registerhelp "guessclan" "Tries to guess the clan that the given nick plays for based on previous matches and which irc channels they are on." \
            "!guessclan <nick>" \
            "!guessclan Caultier" 1 "pub" "general"
registerhelp "whois" "Does a basic whois on the given nick." \
            "!whois <nick>" \
            "!whois NRGizeR" 2 "pub" "general"
registerhelp "addquote" "Adds a new quote for the given ${myprefix}. Note: The quote HAS to be input exactly as the ${myprefix} said it, if it has not in fact been said by the given ${myprefix} it will be discarded." \
            "!addquote <${myprefix}> <quote>" \
            "!addquote NRGizeR \"Teh madness!\"" 3 "pub" "${myprefix}s"
registerhelp "correct" "Corrects a previous line with the help of a standard sed expression" \
            "s/faulty/correct/" \
            "s/my love/my sex/" 1 "pub" "general"
#registerhelp "roll" "Responds with a random number between the two numbers given as parameters (inclusive)." \
#            "!roll <lowlimit> <highlimit>" \
#            "!roll 1 6" 1 "pub" "general"


#the flag that keeps track of z0rbot output
set msgoutput 0
set lastz0rkick 0
set lastcwsearchcount -1
set lastcwsearchmsg ""

set quotequeue [list]

proc sedreplace { nick host hand chan arg } {
    global quotequeue SED_BIN
    set arg [getargs $arg 1]
    set sed [lindex $arg 0]
    if { [regexp {s/.+[^\\]/.*[^\\]/.*} $sed all] } {

        set caller [translateirc $nick [getdb]]

        foreach line $quotequeue {
            if { [regexp {s/.+[^\\]/.*} $line all] } {
                continue
            } else {
                if { [string match [lindex $line 0] $caller] } {
                    set result [exec $SED_BIN -re ${sed} << [lindex $line 1]]
                    if { ![string match $result [lindex $line 1]] && ![string match $result ""] } {
                        luvmsg $chan "correct" "$result"
                        break
                    }
                }
            }
        }

        catch { [close $io] }
    }
}

proc rememberquote { nick host hand chan arg } {
    global quotequeue maxquotes
    set quote [list [translateirc $nick [getdb]] [lindex [getargs $arg 1] 0]]
    set quotequeue [linsert $quotequeue 0 $quote]
    if { [llength $quotequeue] > $maxquotes } {
        set quotequeue [lreplace $quotequeue $maxquotes $maxquotes]
    }
}

proc ircguessclan { nick host hand chan arg } {
    if { [hasaccess $nick "guessclan"] } {
        set arg [getargs $arg 1]
        dowhois [lindex $arg 0] "guessclan_response" [list $chan]
    }
}

proc askwhois { nick host hand chan arg } {
    if { [hasaccess $nick "whois"] } {
        set arg [getargs $arg 1]
        dowhois [lindex $arg 0] "askwhois_response" [list $chan]
    }
}

proc guessclan_response { arg parms } {
    set chan [lindex $parms 0]
    set channels [lrange $arg 2 end]
    set nick [lindex $arg 1]

    if { ![string match [join $channels] ":No such nick"] } {
        set clan [guessclan $nick $channels]
        if { $clan != "" } {
            luvmsg $chan "guessclan" "My guess is that $nick plays for \2$clan\2"
        } else {
            luvmsg $chan "guessclan" "Sorry, I have no idea who $nick might play for."
        }
    } else {
        luvmsg $chan "guessclan" "$nick isn't on irc."
    }
}

proc askwhois_response { arg parms } {
    set channels [lrange $arg 2 end]
    set opchannels [list]
    set voicechannels [list]
    set regchannels [list]
    set nick [lindex $arg 1]

    if { ![string match [join $channels] ":No such nick"] } {
        foreach channel $channels {
            set channel [string tolower [string trim [string trimleft $channel ":"]]]
            set channelname [string range $channel 1 end]
            if { [string index $channel 0] == "@" } {
                lappend opchannels $channelname
            } elseif { [string index $channel 0] == "+" } {
                lappend voicechannels $channelname
            } else {
                lappend regchannels "#${channelname}"
            }
        }

        set ochanstr "isn't opped on any channels"
        if { [llength $opchannels] != 0 } {
            set ochanstr "is opped on [join $opchannels ", "]"
        }
        set vchanstr "and isn't voiced on any channels"
        if { [llength $voicechannels] != 0 } {
            set vchanstr "and is voiced on [join $voicechannels ", "]"
        }
        set rchanstr "and is a regular user on no channels"
        if { [llength $regchannels] != 0 } {
            set rchanstr "and is a regular user on [join $regchannels ", "]"
        }
        luvmsg [lindex $parms 0] "whois" "\2[lindex $arg 1]\2 $ochanstr $vchanstr $rchanstr"
    } else {
        luvmsg [lindex $parms 0] "whois" "$nick is not on irc."
    }
}

proc setquote { nick host hand chan arg } {
    global privchan quotequeue myprefix
    if { [hasaccess $nick "addquote"] } {
        set arg [getargs $arg 2]
        if { [llength $arg] < 2 } {
            luvnotc $nick "quote" "syntax: [gethelpsyntax addquote]"
        } else {
            set db [getdb]
            set member [translateirc [lindex $arg 0] $db ]
            set quote [lindex $arg 1]
            if { [lsearch -exact $quotequeue [list $member $quote]] != -1 } {
                set memberid [mysqlsel $db "select id from members where name like '[mysqlescape $member]'" -flatlist]
                if { [llength $memberid] > 0 } {
                    set oldquote [mysqlsel $db "select id from memberquotes where quote like '[mysqlescape $quote]' and memberid = '$memberid'" -flatlist]
                    if { [llength $oldquote] < 1 } {
                        putlog [encoding convertfrom "iso8859-15" $quote]
                        putlog $quote
                        mysqlexec $db "insert into memberquotes (memberid, quote) values ('$memberid', '[mysqlescape $quote]')"
                        luvmsg $chan "addquote" "\"$quote\" was added as a quote for \2$member\2."
                    } else {
                        luvmsg $chan "addquote" "This quote is already added for \2$member\2"
                    }
                } else {
                    luvmsg $chan "addquote" "I can't find a ${myprefix} with the name \2$member\2."
                }
            } else {
                luvmsg $chan "addquote" "I can't recall $member ever saying that..."
            }
        }
    }
}

proc generateroll { nick host hand chan arg } {
    if { [hasaccess $nick "roll"] } {
        set arg [getargs $arg 2]
        if { [llength $arg] < 2 || ![string is integer [lindex $arg 0]] || ![string is integer [lindex $arg 1]] } {
            luvnotc $nick "quote" "syntax: [gethelpsyntax roll]"
        } else {
            set num1 [lindex $arg 0]
            set num2 [lindex $arg 1]
            if { $num2 < $num1 } {
                set num1 [lindex $arg 1]
                set num2 [lindex $arg 0]
            }

            set result [expr int(rand()*($num2 - $num1 + 1)) + $num1]

            luvmsg $chan "roll" "$nick rolls \2$result\2."
        }
    }
}

proc msgoutputenabled { nick host hand chan arg } {
    global msgoutput
    if { [string match "z0rbot*" $nick] } {
        putlog "z0rbot output was enabled"
        set msgoutput 1
    }
}

proc qnet_auth { event } {
    global botnick authuser authpass auth

    if { $auth == 1 } {
        putquick "PRIVMSG Q@Cserve.quakenet.org :AUTH $authuser $authpass"
        putquick "MODE $botnick +x"
    }
}

proc pubchankick { nick host hand chan arg } {
    global botnick pchan privchan
    if { [hasaccess $nick "kick"] } {
        set arg [getargs $arg 2]
        set kicknick [lindex $arg 0]
        if { [onchan $kicknick $pchan] } {
            if { $kicknick != $botnick } {
                if { [onchan $kicknick $privchan] } {
                    luvmsg $chan "kick" "I won't do that. Do your own dirty work."
                } else {
                    set msg "Anti-luv </3"
                    if { [llength $arg] > 1 } {
                        set msg [lindex $arg 1]
                    }
                    putkick $pchan $kicknick "$msg"
                }
            } else {
                luvmsg $chan "kick" "I won't kick myself :<"
            }
        } else {
            luvmsg $chan "kick" "$kicknick is not in ${pchan}."
        }
    }
}

proc onnick_addnick {nick host hand chan newnick } {
    global privchan

    set db [getdb]
    set idnewnick [mysqlsel $db "select memberid from ircnicks where nick like '[mysqlescape [string map {_ \\_ \\ \\\\} $newnick]]'" -flatlist]
    set idnick [mysqlsel $db "select memberid from ircnicks where nick like '[mysqlescape [string map {_ \\_ \\ \\\\} $nick]]'" -flatlist]
    if { [llength $idnewnick] == 0 && [llength $idnick] != 0 } {
        set sqlnick [mysqlsel $db "select name from members where id = '[lindex $idnick 0]'" -flatlist]
        luvmsg $chan "nickalias" "Mmkay, so $newnick is [lindex $sqlnick 0]..."
        putlog "$nick changed nick to $newnick. Adding the new nick to irc table."
        mysqlexec $db "insert into ircnicks (memberid, nick) values ('[lindex $idnick 0]', '[mysqlescape $newnick]')"
    } elseif { [llength $idnick] == 0 && [llength $idnewnick] != 0 } {
        set sqlnick [mysqlsel $db "select name from members where id = '[lindex $idnewnick 0]'" -flatlist]
        luvmsg $chan "nickalias" "Aah, so $nick was [lindex $sqlnick 0]..."
        putlog "$nick changed nick to $newnick. Adding the old nick to irc table."
        mysqlexec $db "insert into ircnicks (memberid, nick) values ('[lindex $idnewnick 0]', '[mysqlescape $nick]')"
    }
}

proc onjoin_checknick {nick host hand chan} {
    global privchan botnick myprefix

    if { $botnick != $nick } {
        set db [getdb]
        set memberid [mysqlsel $db "select memberid from ircnicks where nick like '[mysqlescape [string map {_ \\_ \\ \\\\} $nick]]'" -flatlist]
        if { [llength $memberid] == 0 } {
            putlog "New ${myprefix} found? $nick not found in irc table"
            luvmsg $privchan "joined" "Who is this \2$nick\2 guy?"
        }
    }
}

proc checkz0rbug { nick host hand arg dest } {
    global pchan lastz0rkick

    if { [string match "z0rbot*" $nick] && $lastz0rkick < [expr [clock seconds] - 20] } {
        if { [botisop $pchan] } {
            putlog "z0rbot sending CTCP. Assuming that there this is the split bug and issuing a kick."
            set lastz0rkick [clock seconds]
            putkick $pchan $nick "I can't feel the luv damn it!"
            bind join - "$pchan *" reissue_matchsearch
        }
    }
}

proc reissue_matchsearch { nick host hand chan } {
    global pchan lastcwsearchcount lastcwsearch lastcwsearchmsg

    if { [string match "z0rbot*" $nick] } {
        putlog "Reissuing match search..."
        unbind join - "$pchan *" reissue_matchsearch

        if { $lastcwsearch < [expr [clock seconds] - 30] && $lastcwsearchcount != "" } {
            putmsg $pchan "!cw $lastcwsearchcount off $lastcwsearchmsg"
        }
    }
}

proc showstatus { nick host hand chan arg } {
    global botnick uptime version server username 
    if { [hasaccess $nick "status"] } {
        set up [expr [clock seconds] - $uptime]
        set hours [expr $up / 3600]
        set days [expr $hours / 24]
        set hours [expr $hours % 24]
        set upstring $days

        if { $days != 1 } {
            append upstring " days"
        } else {
            append upstring " day"
        }

        append upstring " and $hours"
        if { $hours != 1 } {
            append upstring " hours"
        } else {
            append upstring " hour"
        }

        if {[catch {exec cat /proc/cpuinfo | grep "cpu MHz"} cpuspeed]}         {set cpuspeed "Unknown"}
        if {[catch {exec cat /proc/cpuinfo | grep "model name"} cpumodel]}      {set cpumodel "Unknown"}
        if {[catch {exec cat /proc/meminfo | grep "MemTotal"} memtotal]}        {set memtotal "Unknown"}

        set coderows [getcoderows]

        if {[catch {exec cat /proc/uptime} compuptime]} {
            set compuptime "Unknown"
        } else {
            set compuptime [expr round([lindex [split $compuptime] 0])]
        }

        if { [string is integer $compuptime] } {
            set hours [expr round($compuptime / 3600)]
            set days [expr $hours / 24 ]
            set hours [expr $hours % 24]

            set compuptime $days

            if { $days != 1 } {
                append compuptime " days"
            } else {
                append compuptime " day"
            }

            append compuptime " and $hours"
            if { $hours != 1 } {
                append compuptime " hours"
            } else {
                append compuptime " hour"
            }
        }

        regsub -nocase -- "cpu MHz.*: " $cpuspeed "" cpuspeed
        regsub -nocase -- "model name.*: " $cpumodel "" cpumodel
        regsub -nocase -- "MemTotal.*: " $memtotal "" memtotal
        regsub -nocase -- " kB" $memtotal "" memtotal

        set cpuspeed [expr double(round($cpuspeed))]
        set memtotal [expr round($memtotal/1024.0)]

        if {$cpuspeed >= 1000} {
            set cpuspeed "[format %.2f [expr $cpuspeed/1000.0]]GHz"
        } else {
            set cpuspeed "[expr round($cpuspeed)]MHz"
        }
        if {$memtotal >= 1024} {
            set memtotal "[format %.1f [expr round($memtotal/1024.0)]]GB"
        } else {
            append memtotal "[format %d $memtotal]MB"
        }

        set outmsg "I am $botnick. I am an eggdrop (version [lindex [split $version] 0]) connected to $server and I have been awake for $upstring (since [clock format $uptime -format {%d.%m.%Y %H:%M}]). My home is a $cpuspeed $cpumodel with $memtotal RAM that currently has an uptime of $compuptime. My daddy NRGizeR has added $coderows lines of code to my brain."
        regsub -all -- {\s+} $outmsg " " outmsg

        luvmsg $chan "status" $outmsg
    }
}

proc getcoderows {} {
    global env username

    set rows 0
    set filelist [gettclfiles "$env(HOME)/eggdrop/${username}/" [list]]
    foreach fi $filelist {
        set io [open $fi "r"]
        while { [gets $io line] != -1 } {
            incr rows
        }
        close $io
    }

    if { $rows == 0 } {
        return "Unknown"
    } else {
        return $rows
    }
}

proc gettclfiles { dir filelist } {
    set newfiles [list]
    catch { set newfiles [glob ${dir}/*.tcl] }

    foreach d [glob -directory $dir *] {
        if { [file isdirectory $d] } {
            set newfiles [gettclfiles $d $newfiles]
        }
    }

    return [concat $filelist $newfiles]
}

proc msgoutputdisabled { nick host hand chan arg } {
    global msgoutput
    if { [string match "z0rbot*" $nick] } {
        putlog "z0rbot output was disabled"
        set msgoutput 0
    }
}

proc membergratz { min hour day month year } {
    global pchan privchan myprefix

    #using own date since the month given to this proc is buggy and is in the range 00-11,
    #to avoid buggy behavior later on if this bug is fixed.
    set nowdate [clock format [unixtime] -format "%m-%d"]

    putlog "Checking for birthdays today $year-$nowdate"

    set db [getdb]
    set bdays [mysqlsel $db "select name,UNIX_TIMESTAMP(birthday),status from members where birthday like '____-$nowdate'" -list]

    foreach bday $bdays {
        putlog "Congratulating [lindex $bday 0]!"
        set age [expr $year - [clock format [lindex $bday 1] -format "%Y"]]
        if { [lindex $bday 2] != -1 } {
            luvmsg $pchan "${myprefix}gratz" "Our own ${myprefix} \2[lindex $bday 0]\2 turns \2$age\2 today! <3 <3 <3"
            luvmsg $pchan "${myprefix}gratz" "*sings* Happy birthday to you, happy birthday to you, happy birthday dear \2[lindex $bday 0]\2, happy birthday to you! *sings*"
            luvmsg $privchan "${myprefix}gratz" "Our own ${myprefix} \2[lindex $bday 0]\2 turns \2$age\2 today! <3 <3 <3"
            luvmsg $privchan "${myprefix}gratz" "*sings* Happy birthday to you, happy birthday to you, happy birthday dear \2[lindex $bday 0]\2, happy birthday to you! *sings*"
        } else {
            luvmsg $pchan "${myprefix}gratz" "\2[lindex $bday 0]\2 turns \2$age\2 today! <3 <3 <3"
            luvmsg $pchan "${myprefix}gratz" "*sings* Happy birthday to you, happy birthday to you, happy birthday dear \2[lindex $bday 0]\2, happy birthday to you! *sings*"
            luvmsg $privchan "${myprefix}gratz" "\2[lindex $bday 0]\2 turns \2$age\2 today! <3 <3 <3"
            luvmsg $privchan "${myprefix}gratz" "*sings* Happy birthday to you, happy birthday to you, happy birthday dear \2[lindex $bday 0]\2, happy birthday to you! *sings*"
        }
    }
}

proc filtercwlist { nick host hand chan arg } {
    global privchan lastcwsearch msgoutput lastcwsearchcount
    if { [string match "z0rbot*" $nick] } {
        if { $msgoutput == 1 } {
            set arg [getargs $arg 1]
            putlog "Filtering CW [lindex $arg 0]"
            if { [regexp -- "^\\\[CW\\\] (#\\S+) (?:@ irc.quakenet.org )?- (\\S+) - Requested a (\\d+)on\\d+ Official \\\(Additional info: (\[^\\\)\]*)\\\)( - (\\d+) minutes ago)?$" [lindex $arg 0] match ircchan person size moreinfo agegroup age] } {
                if { [expr {abs($lastcwsearchcount - $size)}] <= 1 || $lastcwsearchcount == -1 } {
                    set db [getdb]

                    set tag ""
                    set chan $ircchan
                    set ggbg "N/A"

                    set ircchan [mysqlescape [string map {_ \\_ \\ \\\\} $ircchan]]
                    set clan [mysqlsel $db "select tag,irc from clans where irc like '$ircchan'" -flatlist]

                    if { [llength $clan] > 0 } {
                        set tag [lindex $clan 0]
                        set chan [lindex $clan 1]
                        set ggbg [getggbgratio [lindex $clan 0]]
                    }

                    set msg ""
                    if { $tag != "" } {
                        append msg "\2$tag\2 ($chan)"
                    } else {
                        append msg "$chan"
                    }
                    append msg " searched for a \2${size}on${size}\2"
                    if { $age != "" } {
                        append msg " $age "
                        if { $age == 1 } {
                            append msg "minute ago."
                        } else {
                            append msg "minutes ago."
                        }
                    } else {
                        append msg "."
                    }
                    append msg " GG/BG ratio: \2${ggbg}\2."

                    if { $moreinfo != "" && ![string match $moreinfo "none"]} {
                        append msg " (Extra info: ${moreinfo})"
                    }

                    luvmsg $privchan "cwsearch" "$msg"
                }
            }
        }
    }
}

proc domatchsearch { nick host hand chan arg } {
    global privchan pchan msgoutput lastcwsearch lastcwsearchcount lastcwsearchmsg myprefix
    if { [isop $nick $privchan] } {
        set arg [split $arg]
        set many1 0
        set many2 0

        if { ![regexp -- "^.(\[0-9\])on(\[0-9\]).*" [lindex $arg 0] match many1 many2] } {
            return 0
        } elseif { $many1 != $many2 || $many1 < 3 } {
            luvnotc $nick "[format "%son%s" $many1 $many1]" "syntax: !<num>on<num> \[message\] (where num is greater than 2)"
            return 0
        } else {
            if { [expr $lastcwsearch + 60] > [clock seconds] } {
                luvmsg $chan "[format "%son%s" $many1 $many1]" "Well keep your pants on, a match search was just made..."
            } else {
                if { [lsearch -regexp [chanlist $pchan] "^z0rbot.*"] != -1 } {
                    set msg [join [lrange $arg 1 end]]
                    #update the search time so that saymatchunderway works properly
                    set lastcwsearch [clock seconds]
                    luvmsg $chan "[format "%son%s" $many1 $many1]" "Doing a match search for a [format "%son%s" $many1 $many1]..."
                    set lastcwsearchcount $many1
                    set lastcwsearchmsg $msg

                    if { $msgoutput == 0 } {
                        putmsg $pchan "!msgoutput"
                    }
                    putmsg $pchan "!cw $lastcwsearchcount off $lastcwsearchmsg"
                    putmsg $pchan "!cwlist"
                } else {
                    luvmsg $chan "[format "%son%s" $many1 $many1]" "z0rbot - the lazy bastard - is taking a break at the moment..."
                }
            }
        }
    } else {
        luvnotc $nick "matchsearch" "You need to be a [string toupper $myprefix] to use this command!"
    }
}

proc highlightchan { nick host hand chan arg } {
    global privchan cwspyarray mytag ignorenicks botnick username mytagregexp QSTAT
    if { [hasaccess $nick "highlight"] } {
        set saystring ""
        set db [getdb]
        set nicks [chanlist $privchan]

        if { [llength $nicks] > 0 } {
            if { [array size cwspyarray] == 0 } {
                foreach n $nicks {
                    if { $n != $nick && $n != $botnick && [lsearch $ignorenicks $n] == -1 && [isop $n $privchan] } {
                        append saystring "$n "
                    }
                }
            } else {
                #query the server if a match is ongoing to prevent players from being highlighted.
                set playingmembers [list]
                foreach {server cwspylist} [array get cwspyarray] {
                    set io [open "|$QSTAT -u -ne -nh -utf8 -P -q2s $server" r]

                    while { [gets $io line] != -1 } {
                        set member ""
                        set frags 0
                        regexp -- "^\[\t \]*(\[0-9\]+) frags.*${mytagregexp}$" $line match frags member
                        if { $member != "" && $frags != 0} {
                            lappend playingmembers [translatealias $member]
                        }
                    }
                    catch { close $io }
                }

                foreach n $nicks {
                    if { $n != $nick && $botnick != $n && [lsearch $ignorenicks $n] == -1 && [isop $n $privchan] } {
                        if { [lsearch $playingmembers [translateirc $n $db]] == -1 } {
                            append saystring "$n "
                        }
                    }
                }
            }
            luvmsg $chan "highlight" "$saystring\2$arg\2"
        }
    }
}

proc introduce { nick host hand chan arg } {
    global botnick privchan opanswers
    set arg [split [join $arg]]
    if { [string first "NRGizeR" $arg] != -1 || [string first "master" $arg] != -1 || [string first "daddy" $arg] != -1} {
        putmsg $chan "$nick: NRGizeR is my mastah! <3"
    } elseif { [string match $nick "NRGizeR"] } {
        putmsg $chan "$nick: Yes mastah!"
    } elseif { [onchan $nick $privchan] } {
        set msgid [ expr { int(rand()*[llength $opanswers]) } ]
        if { $msgid == [llength $opanswers] } {
            set $msgid [expr $msgid - 1]
        }
        putmsg $chan "$nick: [lindex $opanswers $msgid]"
    } else {
        putmsg $chan "$nick: I am $botnick, destroyer of wo... erm, LOVER of worlds!"
        #do a check to output the cwspy status IF the second word matches the given cw triggers
        saymatchunderway $nick $host $hand $chan "[lrange $arg 1 end]"
        if { ![isop $nick $chan] } {
            printhelp $nick $host $hand $chan ""
        }
    }
}

