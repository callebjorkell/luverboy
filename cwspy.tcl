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


### CWSPY

bind pub -|- !cwspywo cwspywocw
bind pub -|- !cw cwsearchinserted
bind pub -|- !cwspy cwspyannounce
bind pub -|- !cwspyannounce cwspyannouncescores
bind pub -|- !cwspylineup cwspylineup
bind pub -|- !cwspyopponents cwspyopponents
bind pub -|- !cwspyok cwspyacceptsuggestion
bind pub -|- !find${myprefix}s findmembers
bind pub -|- !queryserver queryserver

bind pubm - "$pchan cw*" saymatchunderway
bind pubm - "$pchan mat*" saymatchunderway
for { set i 3 } { $i < 8 } { incr i } {
    bind pubm - "$pchan $i*" saymatchunderway
}

bind time - "05 * * * *" checkavailableservers
bind time - "20 * * * *" checkavailableservers
bind time - "35 * * * *" checkavailableservers
bind time - "50 * * * *" checkavailableservers


registerhelp "cwspywo" "Adds a partially completed CW. This can be used whenever a CW is won or lost by default" \
            "!cwspywo <tag> <\2l\2oss/\2w\2in>" \
            "!cwspywo \[TrP\] win" 3 "pub" "cwspy"
registerhelp "cwspyok" "Accept the cwspy suggestion, and enters the spied match into the database. If there are several open suggestions, save the one you want by specifying the clantag of the opposing clan. If no clantag is specified the newest CW will be accepted." \
            "!cwspyok \[tag\] \[tagcorrection\]" \
            "!cwspyok \"cB\" \"cB >\"" 3 "pub" "cwspy"
registerhelp "cwspy" "Prints information about the CW that is currently being watched by cwspy." \
            "!cwspy" \
            "!cwspy" 1 "pub" "cwspy"
registerhelp "cwspyannounce" "Toggles the announcer. When turned on, cwspy will automatically send a message to the channel whenever the scores in a spied CW change." \
            "!cwspyannounce" \
            "!cwspyannounce" 3 "pub" "cwspy"
registerhelp "cwspyopponents" "Prints the opponents that are currently playing in the spied CW(s)." \
            "!cwspyopponents" \
            "!cwspyopponents" 3 "pub" "cwspy"
registerhelp "cwspylineup" "Prints the ${myprefix}s that are currently playing in the spied CW(s)." \
            "!cwspylineup" \
            "!cwspylineup" 3 "pub" "cwspy"
registerhelp "queryserver" "Query a given server (prints the map played, and the players on the server)" \
            "!queryserver <server:port>" \
            "!queryserver 137.163.30.131:27910" 3 "pub" "cwspy"
registerhelp "find${myprefix}s" "Finds online ${myprefix}s and prints where they are playing at the moment." \
            "!find${myprefix}s" \
            "!find${myprefix}s" 2 "pub" "cwspy"

set cwspytochan 0
set cwspytochanchannel ""


# cwspyarray is an array of active cws. The structure of the lists it contains is as follows:
# key = server 
# 0 = t1score 
# 1 = t2score
# 2 = opptag 
# 3 = watchedrounds 
# 4 = t1probability
# 5 = map 
# 6 = date 
# 7 = cwourfragsarray
# 8 = cwoppfragsarray
# 9 = oldourfrags
# 10 = oldoppfrags
# 11 = timeouts.

#list containing the completed maps.
# 0 = tag, 1 = ourscore, 2 = oppscore, 3 = map, 4= date, 5 = ourfragsarray, 6 = oppfragsarray
if { ![info exists completedcws] } {
    uplevel #0 {set completedcws [list]}
}
#set completedcws {{Amb' 15 15 airport 1190657483 {Molteri 6 Eccu 12 Pono 27 Gilgalad 16 Montsa 10 Hazer 36 Poopy 2} {Amb'ilzu^ 22 Amb'Marine 32 {nameless jERk} 0 pwsnskle 0 Amb'Thuur 26 Amb'mato 2 mato 0 LM 0 Amb'Nexet 14 da-be-da 0 Amb'Grimmy 4 Pono 1 player 0 Amb'Jabber 0 Amb' 0 Amb'Heydrich 21}}}


set lastcwsearch 0

if { [lsearch -glob [timers] "* searchforactivecw *"] == -1 } { timer 1 searchforactivecw }


proc searchforactivecw { } {
    global mytag cwspyarray cwchecktime username QSTAT
    global msgoutput pchan

    set db [getdb]

    #select only type 1 (clanservers)
    set servers [mysqlsel $db "select address from servers where type = 1 and available = 1" -flatlist]

    foreach s $servers {
        # the second part of the if statement is just to restart the timer in case the checkactivecw proc generates an error.
        if { [llength [array names cwspyarray -exact $s]] == 0 || [lsearch -glob [utimers] "* checkactivecw *"] == -1 } {
            set foundmembers 0

            set io [open "|$QSTAT -u -ne -nh -utf8 -P -q2s $s" r]
            while { [gets $io line] != -1 } {
                set member ""
                if { [catch { regexp -- ".*($mytag.*)$" $line match member } ] } {
                    putlog "caught regexp0 at line: $line"
                }

                if { $member != "" } {
                    incr foundmembers
                    if { $foundmembers > 2 } {
                        #add a new entry into the array to be checked by "activecw"
                        set cwspyarray($s) [list 0 0 "" 0 0 "" [clock seconds] {} {} 0 0 0]
                        putlog "Found a possible CW at $s"
                        if {[lsearch -glob [utimers] "* checkactivecw *"] == -1} {
                            utimer $cwchecktime checkactivecw
                        }
                        if { $msgoutput == 1 } {
                            putmsg $pchan "!msgoutput"
                        }
                        break
                    }
                }
            }
            catch { close $io }
        }
    }
    if { [lsearch -glob [timers] "* searchforactivecw *"] == -1 } {
        timer 1 searchforactivecw
    }
}

proc checkactivecw {} {
    global mytag mytagregexp cwspyarray cwchecktime cwwatchrounds cwspytochan cwspytochanchannel maxtimeouts myprefix username QSTAT
    set db [getdb]

    foreach {server cwspylist} [array get cwspyarray] {
        set io [open "|$QSTAT -retry 10 -u -ne -nh -utf8 -P -R -q2s $server" r]

        set foundmembers 0
        set foundopps 0
        catch { unset cwourfrags }
        catch { unset cwoppfrags }
        array set cwourfrags [lindex $cwspylist 7]
        array set cwoppfrags [lindex $cwspylist 8]
        set lastround 0
        set ourfrags 0
        set oppfrags 0
        set scorechanged 0
        set map ""

        while { [gets $io line] != -1 } {
            set t1score ""
            set t2score ""
            regexp -- "^(\[a-zA-Z0-9.-\]+:\[0-9\]+) +\[0-9\]+/\[\ 0-9\]+ +(\[a-zA-Z0-9_-\]+).*" $line match server map
            set map [string tolower $map]

            #this used to be all in the same regexp, but apparently the order of this can differ between
            #servers (cg uses one way, and the rest of the world the other)
            regexp -- ".*,t1=(\[0-9\]+),.*" $line match t1score
            regexp -- ".*,t2=(\[0-9\]+),.*" $line match t2score

            if { $t1score != "" && $t2score != "" } {
                if { $t1score < [lindex $cwspylist 0] || $t2score < [lindex $cwspylist 1] } {
                    set lastround 1
                } else {
                    if { [lindex $cwspylist 5] != $map } {
                        putlog "Map changed to $map"
                    }
                    lset cwspylist 5 $map
                    if { $t1score > [lindex $cwspylist 0] } {
                        set scorechanged 1
                    } elseif { $t2score > [lindex $cwspylist 1] } {
                        set scorechanged 2
                    }

                    lset cwspylist 0 $t1score
                    lset cwspylist 1 $t2score
                }

                #this was the line for the server settings, skip the rest of the checks (as these apply to other lines)
                continue
            }

            if { $lastround != 1 } {
                set member ""
                set frags 0

                regexp -- "^\[\t \]*(\[0-9-\]+) frags.*${mytagregexp}$" $line match frags member

                #trim away trailing or leading spaces.
                set member [translatealias [string trim $member]]

                if { $member != "" } {
                    if { $frags != 0 } {
                        set cwourfrags($member) $frags
                    }
                    incr foundmembers
                    incr ourfrags $frags
                } else {
                    set opponent ""
                    set frags 0

                    regexp -- "^\[\t \]*(\[0-9-\]+) frags\[\t \]+\[0-9\]+ms\[\t \]+(.*)$" $line match frags opponent
                    if { $opponent != "" } {
                        incr foundopps
                        incr oppfrags $frags
                        set cwoppfrags($opponent) $frags
                    }
                }
            }
        }

        #if there is no cwtag found, find it, else check the scores and try to figure out which of t1 and t2 is the lvuers
        if { [lindex $cwspylist 2] == "" } {
            if { [lindex $cwspylist 0] > 0 || [lindex $cwspylist 1] > 0 } {
                # set the tag in the cwlist
                lset cwspylist 2 [findtag [array names cwoppfrags]]

                #insert into the database so that it can be displayed on the homepage.
                if { [catch {mysqlexec $db "insert into activematches (server, opponent, ourscore, oppscore, lineup, map) values ('$server', '[mysqlescape [lindex $cwspylist 2]]', 0, 0, '[mysqlescape [join [array names cwourfrags] {, }]]', '[mysqlescape [lindex $cwspylist 5]]')" } ] } {
                    #too spammy message... so it was commented.
                    #putlog "Found a duplicate entry in the activematches table. Updating the old one."
                    mysqlexec $db "update activematches set opponent = '[mysqlescape [lindex $cwspylist 2]]', ourscore = 0, oppscore = 0, lineup = '[mysqlescape [join [array names cwourfrags] {, }]]', map = '[mysqlescape [lindex $cwspylist 5]]' where server like '$server'" 
                }
            }
        }
        if { $scorechanged != 0 } {
            putlog "Scores changed: [lindex $cwspylist 0] - [lindex $cwspylist 1]"

            if {[lindex $cwspylist 3] < $cwwatchrounds} {
                lset cwspylist 3 [expr [lindex $cwspylist 3] + 1]
                set difference 0

                if { $foundmembers > 0 && $foundopps > 0} {

                    putlog "ourfrags: $ourfrags oldfrags: [lindex $cwspylist 9] ${myprefix}s: $foundmembers - oppfrags: $oppfrags oldfrags: [lindex $cwspylist 10] opponents: $foundopps"
                    if { [expr $ourfrags - [lindex $cwspylist 9]] > [expr $oppfrags - [lindex $cwspylist 10]] } {
                        set difference 1
                    } elseif { [expr $ourfrags - [lindex $cwspylist 9]] < [expr $oppfrags - [lindex $cwspylist 10]] } {
                        set difference -1
                    } else {
                        set difference 0
                    }

                    #if luvers have more frags difference than the opposing team, and t1 gained points, it's likely that the luvers are t1, if t2 gained points, it's not likely that we are t1 :)
                    if { [lindex $cwspylist 9] == 0 && [lindex $cwspylist 10] == 0 } {

                        #first round that is checked, check the total scores, and not only the last round.
                        #if the scores are tied at this point, we will not touch the probability.
                        if { [lindex $cwspylist 0] > [lindex $cwspylist 1] } {
                            lset cwspylist 4 [expr [lindex $cwspylist 4] + $difference]
                        } elseif { [lindex $cwspylist 1] > [lindex $cwspylist 0] } {
                            lset cwspylist 4 [expr [lindex $cwspylist 4] - $difference]
                        }
                    } elseif { $scorechanged == 1 } {
                        lset cwspylist 4 [expr [lindex $cwspylist 4] + $difference]
                    } else {
                        lset cwspylist 4 [expr [lindex $cwspylist 4] - $difference]
                    }

                    putlog "t1prob now at [lindex $cwspylist 4]"

                } else {
                    putlog "WARNING: l: $foundmembers o: $foundopps"
                }

                set oldourfrags 0
                set oldoppfrags 0
                foreach {name frag} [array get cwourfrags] {
                    incr oldourfrags $frag
                }
                foreach {name frag} [array get cwoppfrags] {
                    incr oldoppfrags $frag
                }
                lset cwspylist 9 $oldourfrags
                lset cwspylist 10 $oldoppfrags

            }
            if { [lindex $cwspylist 3] > 1 } {
                if { [expr abs([lindex $cwspylist 4])] < 2 && [lindex $cwspylist 3] >= $cwwatchrounds } {
                    #we've failed to get a good enough guess, let's try it again. 
                    lset cwspylist 4 0
                    lset cwspylist 3 0
                    putlog "WARNING: Not good enough probability... Restarting."
                }
            }
            if { $cwspytochan == 1 } {
                cwspyannouncer $cwspylist $cwspytochanchannel $server
            }
            
            
            ##SAVE THIS TO THE DATABASE AS WELL!
            set ourscore 0
            set oppscore 0
            if { [lindex $cwspylist 4] > 0 } {
                set ourscore [lindex $cwspylist 0]
                set oppscore [lindex $cwspylist 1]
            } else {
                set ourscore [lindex $cwspylist 1]
                set oppscore [lindex $cwspylist 0]
            }
            set db [getdb]
            mysqlexec $db "update activematches set ourscore = $ourscore, oppscore = $oppscore, lineup = '[mysqlescape [join [array names cwourfrags] {, }]]', map = '[mysqlescape [lindex $cwspylist 5]]' where server like '$server'"
        }

        #save the info back into the cwspyarray
        if { $lastround == 1 || $foundmembers == 0 } {
            lset cwspylist 11 [expr [lindex $cwspylist 11] + 1]
        } else {
            lset cwspylist 11 0
        }

        lset cwspylist 7 [array get cwourfrags]
        lset cwspylist 8 [array get cwoppfrags]
        set cwspyarray($server) $cwspylist

        if { [lindex $cwspylist 11] >= $maxtimeouts } {
            # we've had too many timeouts or reported low scores. This has to be a new map and not just network problems. 
            # complete the map and start over.
            completemap $server
        }

        catch { close $io }
    }
    if { [array size cwspyarray] > 0 } {
        if {[lsearch -glob [utimers] "* checkactivecw *"] == -1} { utimer $cwchecktime checkactivecw }
    }
}

proc completemap { server } {
    putlog "Completing map scores."
    global mytag privchan cwspyarray completedcws

    if { [llength [array names cwspyarray -exact $server]] > 0 } {
        set cwspylist $cwspyarray($server)

        #delete from the database so that it is removed from the homepage sidebar.
        set db [getdb]
        mysqlexec $db "delete from activematches where server like '$server'"

        if { [lindex $cwspylist 0] > 0 || [lindex $cwspylist 1] > 0} {
            if { [lindex $cwspylist 2] != "" } {
                # now save away the cw into the "completed" list, and print the results into the privchan.
                set cw [list [lindex $cwspylist 2] [lindex $cwspylist 0] [lindex $cwspylist 1] [lindex $cwspylist 5] [clock seconds] [lindex $cwspylist 7] [lindex $cwspylist 8]]

                set msg "I spied a possible CW at $server vs \2[lindex $cwspylist 2]\2 that ended"
                if { [lindex $cwspylist 4] < 0 } {
                    append msg " \2[lindex $cwspylist 1]\2-\2[lindex $cwspylist 0]\2"
                    lset cw 1 [lindex $cwspylist 1]
                    lset cw 2 [lindex $cwspylist 0]
                } else {
                    append msg " \2[lindex $cwspylist 0]\2-\2[lindex $cwspylist 1]\2"
                }
                append msg " on \2[lindex $cwspylist 5]\2."

                luvmsg $privchan "cwspy" $msg

                lappend completedcws $cw
                #cleancompleted

                completematch [lindex $cwspylist 2]
                # ADD SOME SORT OF NAG HERE?
            }
        }
        array unset cwspyarray $server
    }
    putlog "After completemap the cwspyarray has [array size cwspyarray] elements."
    if { [array size cwspyarray] > 0 } {
        putlog "cwspyarray: [array get cwspyarray]"
    }
}

proc completematch { tag } {
    global completedcws privchan mytag
    cleancompleted

    set suggestion [getcompletedmatch $tag]
    #since these entries are removed by getcompletematch, we're readding them since we're not doing anything with them.
    foreach suggest $suggestion {
        lappend completedcws $suggest
    }


    if { [llength $suggestion] == 0 } {
        return
    } else {
        set l1 [lindex $suggestion 0]
        set l2 [lindex $suggestion 1]

        putlog "Found match suggestion for [lindex $l1 0]"
        catch { unset ourfrags1 }
        catch { unset ourfrags2 }
        array set ourfrags1 [lindex $l1 5]
        array set ourfrags2 [lindex $l2 5]

        set lineup [array names ourfrags1]
        foreach name [array names ourfrags2] {
            if { [lsearch -exact $lineup $name] == -1 } {
                lappend lineup $name
            }
        }

        luvmsg $privchan "cwspy" "A match ended. My guess is: $mytag vs [lindex $l1 0] [lindex $l2 1]-[lindex $l2 2] on [lindex $l2 3] and [lindex $l1 1]-[lindex $l1 2] on [lindex $l1 3] with the lineup [join $lineup {, }]"
        luvmsg $privchan "cwspy" "Type \2!cwspyok \[tag\] \[tagcorrection\]\2 to accept this suggestion, or if I'm wrong, do a regular \2!addcw\2"
    }
}

proc cleancompleted { } {
    #expire old maps, and clean away such maps that have been played against clans with more than 2 entries.
    putlog "Cleaning up old mapscores"
    global completedcws cwspymapexpire

    set completedcws [lsort -command sortcompletelist $completedcws]
    set index 0
    set now [clock seconds]
    array set tags {}

    while { $index < [llength $completedcws] } {
        set cw [lindex $completedcws $index]
        if { [expr [lindex $cw 4] + $cwspymapexpire] < $now } {
            putlog "Deleting old mapscore for match against [lindex [lindex $completedcws $index] 0]"
            set completedcws [lreplace $completedcws $index $index]
        } else {
            incr index
        }
    }
    putlog "After cleancompleted the completedlist has [llength $completedcws] elements."
    foreach cw $completedcws {
        putlog "Entry: $cw"
    }
}

proc sortcompletelisttag { list1 list2 } {
    set tag1 [lindex $list1 0]
    set tag2 [lindex $list2 0]
    if { $tag1 == $tag2 } { 
        return [sortcompletelist $list1 $list2]
    } else {
        return [string compare $tag1 $tag2]
    }
}

proc sortcompletelist { list1 list2 } {
    #sort the list by date, newest first
    return [expr [lindex $list2 4] - [lindex $list1 4]]
}

proc getcompletedmatch { {tag ""} } {
    global completedcws
    set returnlist [list]

    if { [llength $completedcws] < 2 } {
        return $returnlist
    } elseif { $tag != "" } {
        putlog "Finding the last completed match by tag"

        #create a list of maps that we have in the list.
        set maplist [list]
        set entries 0
        foreach map $completedcws {
            if { [lsearch $maplist [lindex $map 3]] == -1 && $tag == [lindex $map 0] } {
                lappend maplist [lindex $map 3]
                incr entries
            }
        }

        if { [llength $maplist] < 1 } {
            putlog "getcompletedmatch: maplist empty!"
            return [list]
        } elseif { $entries < 2 } {
            return [list]
        }

        #now chose the two first maps, (last played) and select the most likely of these
        set mapindex 0
        set bestindex -1
        while { [llength $returnlist] < 2 } {
            set map [lindex $maplist $mapindex]
            for {set i 0} {$i< [llength $completedcws]} {incr i} {
                #get the list at pos $i
                set listi [lindex $completedcws $i]

                if { [lindex $listi 0] != $tag || [lindex $listi 3] != $map } {
                    #wrong tag or map.
                    continue
                } else {
                    if { $bestindex == -1 } {
                        set bestindex $i
                    } else {
                        set bestnow [lindex $completedcws $bestindex]
                        if { [lindex $bestnow 4] < [lindex $listi 4] && [lindex $bestnow 1] <= [lindex $listi 1] && [lindex $bestnow 2] <= [lindex $listi 2] } {
                            set $bestindex $i
                        }
                    }
                }
            }

            if { $bestindex == -1 } {
                #readd the removed entries to the completedcws list
                foreach ret $returnlist {
                    lappend completedcws $ret
                }
                return [list]
            } else {
                lappend returnlist [lindex $completedcws $bestindex]
                set completedcws [lreplace $completedcws $bestindex $bestindex]
                set bestindex -1

                incr mapindex
                if { [llength $maplist] <= $mapindex } {
                    set mapindex 0
                }
            }
        }
        return $returnlist

    } else {
        putlog "Finding the last completed match by date"
        #first loop through the completecws once, find out which tags that exist, then
        #loop again to find the last cw played with a tag that has 2 entries.
        array set tags {}
        foreach cw $completedcws {
            if { [llength [array names tags -exact [lindex $cw 0]]] > 0 } {
                incr tags([lindex $cw 0])
            } else {
                set tags([lindex $cw 0]) 1
            }
        }

        foreach cw $completedcws {
            if { $tags([lindex $cw 0]) > 1 } {
                return [getcompletedmatch [lindex $cw 0]]
            }
        }
    }

    return $returnlist
}

proc cwspyacceptsuggestion { nick uhost hand chan arg } {
    global mytag pchan privchan completedcws myprefix
    if { [hasaccess $nick "cwspyok"] } {
        if { [llength $completedcws] > 1 } {
            cleancompleted
            set arg [getargs $arg 2]
            set tag [lindex $arg 0]
            set tagcorrection $tag
            
            if { [llength $arg] > 1 } {
                set tagcorrection [lindex $arg 1]
            }

            set match [getcompletedmatch $tag]

            if { [llength $match] > 0} {

                set cwtag $tagcorrection
                if { $cwtag == "" } {
                    set cwtag [lindex [lindex $match 0] 0]
                }
                set db [getdb]
                set tagselect [mysqlsel $db "select id from clans where tag collate utf8_bin like '[mysqlescape $cwtag]'" -flatlist]
                if { [llength $tagselect] == 0 } {
                    luvmsg $chan "cwspyok" "No clan with tag $cwtag found. Please correct this tag with \2[gethelpsyntax cwspyok]\2 or add the clan to my database with \2!addclan\2."
                    #readd the matchlines to the completedcws list.
                    lappend completedcws [lindex $match 0]
                    lappend completedcws [lindex $match 1]
                    cleancompleted
                } else {
                    set map1 [lindex $match 0]
                    set map2 [lindex $match 1]
                    array set ourfrags1 [lindex $map1 5]
                    array set ourfrags2 [lindex $map2 5]

                    set date [clock seconds]

                    mysqlexec $db "INSERT INTO matches (date, opponent) VALUES ($date, '[mysqlescape $cwtag]')"
                    set index [mysqlinsertid $db]

                    mysqlexec $db "INSERT INTO scores (matchid, map, ourscore, oppscore) VALUES ('$index', '[mysqlescape [lindex $map1 3]]', '[mysqlescape [lindex $map1 1]]', '[mysqlescape [lindex $map1 2]]')"
                    set oldscoresid [mysqlinsertid $db]
                    mysqlexec $db "INSERT INTO scores (matchid, map, ourscore, oppscore) VALUES ('$index', '[mysqlescape [lindex $map2 3]]', '[mysqlescape [lindex $map2 1]]', '[mysqlescape [lindex $map2 2]]')"
                    set scoresid [mysqlinsertid $db]

                    set fragsinsert [list]
                    foreach {name frags} [array get ourfrags1] {
                        lappend fragsinsert "('$index', '$oldscoresid', '[mysqlescape $name]', '[mysqlescape $frags]')"
                    }
                    foreach {name frags} [array get ourfrags2] {
                        lappend fragsinsert "('$index', '$scoresid', '[mysqlescape $name]', '[mysqlescape $frags]')"
                    }

                    mysqlexec $db "INSERT INTO matchfrags (matchid, scoreid, name, frags) VALUES [join $fragsinsert { ,}]"

                    set oppinsert [list]
                    foreach {name frags} [lindex $map1 6] {
                        if { $frags > 0 } {
                            lappend oppinsert "('$oldscoresid', '[mysqlescape $name]', '[mysqlescape $frags]')"
                        }
                    }
                    foreach {name frags} [lindex $map2 6] {
                        if { $frags > 0 } {
                            lappend oppinsert "('$scoresid', '[mysqlescape $name]', '[mysqlescape $frags]')"
                        }
                    }

                    mysqlexec $db "INSERT INTO matchopponents (scoreid, name, frags) VALUES [join $oppinsert { ,}]"

                    #output to the private channel
                    set scorel [expr [lindex $map1 1] + [lindex $map2 1]]
                    set scoreo [expr [lindex $map1 2] + [lindex $map2 2]]

                    set playerlist [mysqlsel $db "select name,sum(frags) as frag from matchfrags where matchid = '$index' group by matchid, name order by frag desc" -list]

                    luvmsg $privchan "cwspyok" "(id #$index) $mytag vs $cwtag $scorel-$scoreo added to my database."
                    putlog "Added CW $index vs $cwtag ($scorel-$scoreo), by $nick"
                    luvmsg $pchan "cw" "(id #$index) $mytag vs $cwtag $scorel-$scoreo"
                    if { [llength $playerlist] > 0 } {
                        set lotm [lindex $playerlist 0]
                        luvmsg $privchan "cwspyok" "\2[capitalize $myprefix] of the Match\2 goes to \2[lindex $lotm 0]\2 with [lindex $lotm 1] frags"
                    }

                    checkclannumberofcws $db
                    foreach player $playerlist {
                        checkmembernumberofcws $db [lindex $player 0] $chan
                    }
                }
            } else {
                if { $tag != "" } {
                    luvmsg $chan "cwspyok" "There are no unaccepted CWs in my cwspy queue with the tag \2$tag\2."
                } else {
                    putlog "WARNING! cwspyacceptsuggestion: matches returned a zero length list. completedcws size: [llength $completedcws]"
                    luvmsg $chan "cwspyok" "There are no unaccepted CWs in my cwspy queue."
                }
            }
        } else {
            luvmsg $chan "cwspyok" "There are no unaccepted CWs in my cwspy queue."
        }
    }
}

proc cwsearchinserted { nick host hand chan arg } {
    global pchan lastcwsearch
    if { $chan == $pchan && [isop $nick $pchan] } {
        set lastcwsearch [clock seconds] 
    }
}

proc cwspywocw { nick host hand chan arg } {
    global privchan pchan completedcws botnick mytag myprefix
    if { [hasaccess $nick "cwspywo"] } {
        cleancompleted
        set arg [getargs $arg 2]
        if { [llength $arg] > 1 } {
            set win 1
            set tag [lindex $arg 0]
            set argcount 0

            switch -regexp -- [lindex $arg 1] {
                ^w(in)?\$       { set win 1 }
                ^l(oss)?\$      { set win 0 }
                default {
                    luvnotc $nick "cwspywo" "syntax: [gethelpsyntax cwspywo]"; return 0
                }
            }

            if { [llength $completedcws] == 0} {
                luvmsg $chan "cwspywo" "No CWs in the cwspy queue, so I can't add anything at all. Use !addcw to add the WO."
                return 0;
            } else {
                set db [getdb]
                set tagselect [mysqlsel $db "select id from clans where tag collate utf8_bin like '[mysqlescape $tag]'" -flatlist]
                if { [llength $tagselect] == 0 } {
                    luvmsg $chan "cwspywo" "No clan with tag $tag found. Please add this WO manually."
                } else {
                    array set tags {}
                    set maps [list]
                    set index 0
                    set tagpattern [string map {\[ \\\[ \] \\\] ? \\? * \\\*} $tag]

                    while { $index < [llength $completedcws] } {
                        set cw [lindex $completedcws $index]

                        if { [string match $tagpattern [lindex $cw 0]] && [llength $maps] < 2 } {
                            lappend maps $cw
                            set completedcws [lreplace $completedcws $index $index]
                        } else {
                            incr index
                        }
                        if { [llength [array names tags -exact [lindex $cw 0]]] > 0 } {
                            incr tags([lindex $cw 0])
                        } else {
                            set tags([lindex $cw 0]) 1
                        }
                    }

                    if { [llength $maps] == 0 } {
                        set saystring "The cwspy queue doesn't contain information about a match against $tag."
                        if { [llength [array names tags]] > 0 } {
                            append saystring " Did you mean any of [join [array names tags] {, }]?"
                        }
                        luvmsg $chan "cwspywo" "$saystring"
                    } else {
                        set ourscore 0
                        set oppscore 0
                        set addscore 0

                        foreach map $maps {
                            set ourscore [expr $ourscore + [lindex $map 1]]
                            set oppscore [expr $oppscore + [lindex $map 2]]

                            array set memberfrags [lindex $map 5]
                        }
                        #calculate if we need to add points to one of the maps.
                        if { $win != 0 } {
                            if { $ourscore <= $oppscore } {
                                set addscore [expr $oppscore - $ourscore + 1]
                            }
                        } else {
                            if { $oppscore <= $ourscore } {
                                set addscore [expr $oppscore - $ourscore - 1]
                            }
                        }

                        set date [clock seconds]

                        mysqlexec $db "INSERT INTO matches (date, opponent) VALUES ('$date', '[mysqlescape $tag]')"
                        set index [mysqlinsertid $db]

                        set ind 0
                        foreach map $maps {
                            incr ind

                            if { $ind == 2} {
                                if { $addscore > 0 } { 
                                    lset map 1 [expr [lindex $map 1] + $addscore]
                                    set ourscore [expr $ourscore + $addscore]
                                } else {
                                    lset map 2 [expr [lindex $map 2] - $addscore]
                                    set oppscore [expr $oppscore - $addscore]
                                }
                            }

                            mysqlexec $db "INSERT INTO scores (matchid, map, ourscore, oppscore) VALUES ('$index', '[mysqlescape [lindex $map 3]]', '[mysqlescape [lindex $map 1]]', '[mysqlescape [lindex $map 2]]')"
                            set scoresid [mysqlinsertid $db]

                            set fragsinsert [list]
                            set oppinsert [list]

                            array set memberfrags [lindex $map 5]
                            array set opponentfrags [lindex $map 6]

                            foreach {name frags} [array get memberfrags] {
                                lappend fragsinsert "('$index', '$scoresid', '[mysqlescape $name]', '[mysqlescape $frags]')"
                            }
                            mysqlexec $db "INSERT INTO matchfrags (matchid, scoreid, name, frags) VALUES [join $fragsinsert { ,}]"

                            foreach {name frags} [array get opponentfrags] {
                                if { $frags > 0 } {
                                    lappend oppinsert "('$scoresid', '[mysqlescape $name]', '[mysqlescape $frags]')"
                                }
                            }
                            mysqlexec $db "INSERT INTO matchopponents (scoreid, name, frags) VALUES [join $oppinsert { ,}]"
                        }

                        if { [llength $maps] < 2 } {
                            set lscore 0
                            set oscore 0
                            if { $addscore > 0 } {
                                set lscore $addscore
                                set ourscore [expr $ourscore + $addscore]
                            } else {
                                set oscore [expr 0 - $addscore]
                                set oppscore [expr $oppscore + $oscore]
                            }
                            mysqlexec $db "INSERT INTO scores (matchid, map, ourscore, oppscore) VALUES ('$index', 'nomap', '$lscore', '$oscore')"
                        }

                        mysqlexec $db "insert into matchcomments (matchid, date, name, comment) values ('$index', '$date', '$botnick', 'This match ended in a WO for some reason... </3')"

                        luvmsg $privchan "cwspywo" "(id #$index) $mytag vs $tag $ourscore-$oppscore (\2WO\2) added to my database."
                        putlog "Added WO $index vs $tag ($ourscore-$oppscore), by $nick"
                        luvmsg $pchan "cw" "(id #$index) $mytag vs $tag $ourscore-$oppscore (\2WO\2)"

                        checkclannumberofcws $db
                        set playerlist [mysqlsel $db "select name,sum(frags) as frag from matchfrags where matchid = '$index' group by matchid, name order by frag desc" -list]

                        if { [llength $playerlist] > 0 } {
                            set lotm [lindex $playerlist 0]
                            luvmsg $privchan "cwspywo" "\2[capitalize $myprefix] of the Match\2 goes to \2[lindex $lotm 0]\2 with [lindex $lotm 1] frags"
                        }

                        foreach player $playerlist {
                            checkmembernumberofcws $db [lindex $player 0] $chan
                        }
                    }
                }
            }
        } else {
            luvnotc $nick "cwspywo" "syntax: [gethelpsyntax cwspywo]"
        }
    }
}

proc saymatchunderway { nick host hand chan arg } {
    global pchan cwspyarray mytag lastcwsearch privchan cwsearchregexp

    if { $pchan == $chan && ![isop $nick $pchan] && ![onchan $nick $privchan]} {
        set arg [join [split $arg]]
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

            if { [expr [clock seconds] - $lastcwsearch] < 1200 && $lastcwsearch > $maxdate } {
                dowhois $nick saymatchunderway_whoisresponse
                luvmsg $privchan "cwsearch" "in ${pchan}: <\2$nick\2> $arg"
            } elseif { [llength $saylist] > 0 } {
                if { [llength $saylist] > 1 } {
                    lset saylist end "and [lindex $saylist end]"
                    putmsg $pchan "$nick: $mytag is playing [llength $saylist] CWs at the moment. We are playing [join $saylist {, }] right now."
                } else {
                    putmsg $pchan "$nick: $mytag is playing [lindex $saylist 0] right now."
                }
            }
        }
    }
}

proc saymatchunderway_whoisresponse { arg parms } {
    global pchan botnick
    set channels [lrange $arg 2 end]
    if { ![string match [join $channels] ":No such nick"] } {
        set nick [lindex $arg 1]

        if { $botnick != $nick } {
            set clan [guessclan [lindex $arg 1] $channels]
            if { $clan == "" } {
                putmsg $pchan "$nick: clan, map, mm3?"
            } else {
                putmsg $pchan "$nick: ${clan}, map, mm3?"
            }
        }
    }
}


proc cwspyannouncer { cwspylist channel server } {

    set ourscore 0
    set oppscore 0
    if { [lindex $cwspylist 4] > 0 } {
        set ourscore [lindex $cwspylist 0]
        set oppscore [lindex $cwspylist 1]
    } else {
        set ourscore [lindex $cwspylist 1]
        set oppscore [lindex $cwspylist 0]
    }

    if { $ourscore > 0 || $oppscore > 0 } {
        if { [lindex $cwspylist 2] == "" } {
            luvmsg $channel "cwspy" "Right now the score is \2$ourscore\2-\2$oppscore\2 at $server on \2[lindex $cwspylist 5]\2."
        } else {
            luvmsg $channel "cwspy" "Right now the score is \2$ourscore\2-\2$oppscore\2 vs \2[lindex $cwspylist 2]\2 at $server on \2[lindex $cwspylist 5]\2."
        }
    } else {
        if { [lindex $cwspylist 2] == "" } {
            luvmsg $channel "cwspy" "I'm spying on a game that is about to start at $server."
        } else {
            luvmsg $channel "cwspy" "I'm spying on a game vs \2[lindex $cwspylist 2]\2 that just started at $server on \2[lindex $cwspylist 5]\2."
        }
    }
}

proc cwspyopponents { nick host hand chan arg } {
    global cwspyarray mytag
    if { [hasaccess $nick "cwspyopponents"] } {
        if { [array size cwspyarray] > 0 } {
            foreach {server cwspylist} [array get cwspyarray] {
                catch { unset cwoppfrags }
                array set cwoppfrags [lindex $cwspylist 8]

                set opplist [list]

                foreach {name frags} [array get cwoppfrags] {
                    if { $frags > 0 } {
                        set oppstr "$name ($frags frag"
                        if { $frags != 1} {
                            append oppstr "s"
                        }
                        append oppstr ")"

                        lappend opplist $oppstr
                    }
                }

                set opponents [join $opplist {, }]

                if { [lindex $cwspylist 2] != "" } {
                    luvmsg $chan "cwspyopponents" "Opponents playing for \2[lindex $cwspylist 2]\2 on $server: $opponents"
                } else {
                    luvmsg $chan "cwspyopponents" "Opponents playing on $server: $opponents"
                }
            }
        } else {
            luvmsg $chan "cwspyopponents" "I'm not spying on a CW right now..."
        }
    }
}

proc cwspylineup { nick host hand chan arg } {
    global cwspyarray myprefix
    if { [hasaccess $nick "cwspylineup"] } {
        if { [array size cwspyarray] > 0 } {
            foreach {server cwspylist} [array get cwspyarray] {
                catch { unset cwourfrags }
                array set cwourfrags [lindex $cwspylist 7]

                set memlist [list]
                foreach {name frags} [array get cwourfrags] {
                    set memstr "$name ($frags frag"
                    if { $frags != 1} {
                        append memstr "s"
                    }
                    append memstr ")"

                    lappend memlist $memstr
                }
                set lineup [join $memlist {, }]

                if { [lindex $cwspylist 2] != "" } {
                    luvmsg $chan "cwspylineup" "${myprefix}s playing against \2[lindex $cwspylist 2]\2 on $server: $lineup"
                } else {
                    luvmsg $chan "cwspylineup" "${myprefix}s playing on $server: $lineup"
                }
            }
        } else {
            luvmsg $chan "cwspylineup" "I'm not spying on a CW right now..."
        }
    }
}

proc cwspyannounce { nick host hand chan arg } {
    global cwspyarray
    if { [hasaccess $nick "cwspy"] } {
        if { [array size cwspyarray] > 0 } {
            foreach {server cwspylist} [array get cwspyarray] {
                cwspyannouncer $cwspylist $chan $server
            }
        } else {
            luvmsg $chan "cwspy" "I'm not spying on a CW right now..."
        }
    }
}

proc cwspyannouncescores {nick host hand chan arg} {
    global cwspytochan cwspytochanchannel
    if { [hasaccess $nick "cwspyannounce"] } {
        if { $cwspytochan == 1 } {
            set cwspytochan 0
            luvmsg $chan "cwspyannounce" "cwspy announce service turned \2off\2."
        } else {
            set cwspytochan 1
            set cwspytochanchannel $chan
            luvmsg $chan "cwspyannounce" "cwspy announce service turned \2on\2."
        }
    }
}

proc queryserver {nick host hand chan arg } {
    global privchan username QSTAT
    if { [hasaccess $nick "queryserver"] } {
        set arg [getargs $arg 1]
        if { [llength $arg] < 1 } {
            luvnotc $nick "queryserver" "syntax: [gethelpsyntax queryserver]"
        }
        set server [lindex $arg 0]
        set io [open "|$QSTAT -u -nh -utf8 -P -sort F -q2s $server" r]

        set map ""
        set name ""

        set count 0
        while { [gets $io line] != -1 } {
            if { $count == 0 } {
                if { ![regexp -- "^(\[A-Za-z0-9.-\]+(?::\[0-9\]+)?) +\[0-9\]+/\[0-9\]+ +(\[A-Za-z0-9\]+) +\[0-9\]+ */ *\[0-9\] +action +(.+)" $line match serv map name] } {
                    break
                } else {
                    luvmsg $chan "queryserver" "$server (\2$name\2) playing \2[string tolower $map]\2"
                }
            }
            set player ""
            set frags ""
            if { [regexp -- "\ +(\[0-9-\]+) frags\ +\[0-9\]+ms\ +(\[^ \].*)$" $line match frags player] } {
                luvmsg $chan "queryserver" "$frags frags, \2$player\2"
            }

            incr count
        }
        if { $count == 1 } {
            luvmsg $chan "queryserver" "Server is empty."
        } elseif { $count == 0 } {
            luvmsg $chan "queryserver" "Server didn't respond..."
        }

        catch { close $io }
    }
}

proc findmembers { nick uhost hand chan arg } {
    global privchan myprefix
    if { [hasaccess $nick "find${myprefix}s"] } {

        set db [getdb]
        set servers [mysqlsel $db "select address from servers where available = 1" -flatlist]
        set nummembers 0

        foreach s $servers {
            set nummembers [expr $nummembers + [findmembersatserver $s $chan]]
        }

        if { $nummembers < 1 } {
            luvmsg $chan "find${myprefix}s" "No ${myprefix}s found :("
        }
    }
}

proc findmembersatserver { server chan } {
    global mytag myprefix username mytagregexp QSTAT
    set io [open "|$QSTAT -u -ne -nh -utf8 -P -q2s $server" r]

    set foundmembers 0
    set map ""
    set name ""

    set count 0
    while { [gets $io line] != -1 } {
        set member ""
        if { $count == 0 } {
            set m ""
            set n ""
            regexp -- "^(\[A-Za-z0-9.-\]+:\[0-9\]+) +\[0-9\]+/\[0-9\]+ +(\[A-Za-z0-9\]+) +\[0-9\]+ */ *\[0-9\] +action +(.+)" $line match serv m n
            set map [string tolower $m]
            set name $n
        }
        if { [regexp -- "\ +(\[0-9-\]+) frags\ +\[0-9\]+ms\ +(\[^ \].*)$" $line match frags player] } {
            regexp -- "${mytagregexp}$" $player match member
            if { $member == "" } {
                set nick [translatealias $player]
                if { [nameinaliasarray $nick] } {
                    set member $nick
                }
            } else {
                set member [translatealias $member]
            }

            if { $member != "" } {
                incr foundmembers
                if { [string equal $map ""] || [string equal $name ""] } {
                    luvmsg $chan "find${myprefix}s" "Found \2$member\2 playing at $server"
                } else {
                    luvmsg $chan "find${myprefix}s" "Found \2$member\2 playing $map at $server ($name)"
                }
            }
        }

        incr count
    }

    catch { close $io }

    return $foundmembers
}

proc checkavailableservers { min hour day month year } {
    global username
    exec ${username}/bin/checkservers ${username} >& /dev/null &
}
