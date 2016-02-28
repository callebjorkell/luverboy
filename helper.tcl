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


##############
#
# These are helper functions used by the Luverboy eggdrop script
# make sure that the script that are using these source config.tcl
# as these functions will not work properly without them.
#
##############

set MAXSTRLEN 450
set aliasarraytime 1

bind raw - 319 whoisresponse
bind raw - 401 whoisresponse

#we will reset this when script is rehashed, just in case.
set whoisqueue [list]

proc getdb { } {
    global dbhost dbuser dbpass dbname mysql
    set retries 0
    while { ![info exists mysql] || [mysqlstate $mysql -numeric] < 2 || ![mysqlping $mysql]} {
        catch {[mysqlclose $mysql]}
        set mysql [mysqlconnect -host $dbhost -user $dbuser -password $dbpass -db $dbname]
        if { $retries != 0 } {
            after 1000
        }
        if { $retries == 10 } {
            error "Could not connect to database!!"
        }
        incr retries
    }
    return $mysql
}

proc dowhois { nick hook {parms [list]} } {
    global whoisqueue

    lappend whoisqueue [list $nick $hook $parms]
    putserv "WHOIS $nick"
}

proc whoisresponse { from keyword arg } {
    global whoisqueue

    set nick [lindex $arg 1]
    for { set i 0 } { $i < [llength $whoisqueue]} { incr i } {
        set whois [lindex $whoisqueue $i]
        if { [string match -nocase $nick [lindex $whois 0]] } {
            set hook [lindex $whois 1]
            if { $hook != "" } {
                if { ![catch { set numargs [llength [split [info args $hook]]] }] } {
                    if { $numargs == 2 } {
                        $hook $arg [lindex $whois 2]
                        set whoisqueue [lreplace $whoisqueue $i $i]
                    } else {
                        putlog "whoisresponse: Number of arguments $numargs for hook $hook is invalid"
                    }
                } else {
                    putlog "whoisresponse: Hook $hook does not exist"
                }
            } else {
                putlog "whoisresponse: No hook exists for whois for $nick"
            }
        }
    }
}

proc checkvalid_www { url } {
    if { [regexp -- "^http://.*$" $url] == 0} {
        #putlog "Invalid URL checked ($url)"
        return 0
    } else {
        return 1
    }
}

proc checkvalid_irc { chan } {
    if { [regexp -- "^#.*$" $chan] == 0} {
        #putlog "Invalid IRC-chan checked ($chan)"
        return 0
    } else {
        return 1
    }
}

proc guessclan { nick channels } {
    global botnick pchan

    #clear away strange characters from the nick just to make sure we get a better hit in the database (we will get hits anyway, since wildcards are used for the matching).
    set clean_nick ""
    regexp {[_^'`'|-]*(.*?)[_^'`'|-]*} $nick all clean_nick

    if { $clean_nick != "" } {
        set nick $clean_nick
    }

    set opchannels [list]
    set regchannels [list]
    if { $nick != $botnick } {
        foreach channel $channels {
            #to fix a bug from the whois response
            set channel [string trimleft [string tolower $channel] ":"]
            if { [string index $channel 0] == "@" } {
                set channel [string range $channel 1 end]
                lappend opchannels "'[mysqlescape $channel]'"
            #we disregard the pchan to prevent this to affect the result below when returning if the user is only on one clan channel.
            } elseif { [string index $channel 0] != "+" && $channel != $pchan } {
                lappend regchannels "'[mysqlescape $channel]'"
            }
        }
        if { [llength $opchannels] > 0 || [llength $regchannels] > 0 } {
            set db [getdb]
            set opclans [list]
            set regclans [list]
            if { [llength $opchannels] > 0 } {
                catch { set opclans [mysqlsel $db "select tag,date from clans left join (select max(date) as date ,opponent from matches group by opponent) as a on opponent collate utf8_bin like tag where irc in ([join $opchannels {, }]) order by date desc" -list] }
            }
            if { [llength $regchannels] > 0 } {
                catch { set regclans [mysqlsel $db "select tag,date from clans left join (select max(date) as date ,opponent from matches group by opponent) as a on opponent collate utf8_bin like tag where irc in ([join $regchannels {, }]) order by date desc" -list] }
            }

            if { [llength $opclans] == 1 } {
                return [lindex [lindex $opclans 0] 0]
            } elseif { [llength $regclans] == 1 && [llength $opchannels] == 0 } {
                return [lindex [lindex $regclans 0] 0]
            } else {
                set matches [mysqlsel $db "select opponent from matchopponents inner join scores on scoreid = scores.id inner join matches on matchid = matches.id where name like '%[mysqlescape $nick]%' order by date desc limit 1" -flatlist]
                if { [llength $matches] > 0 } {
                    #check that this guy is, in fact, still on the clan channel, and thus in the clan.
                    foreach clan $opclans {
                        if { [lindex $matches 0] == [lindex $clan 0] } {
                            return [lindex $matches 0]
                        }
                    }
                    foreach clan $regclans {
                        if { [lindex $matches 0] == [lindex $clan 0] } {
                            return [lindex $matches 0]
                        }
                    }
                }
                if { [llength $opclans] > 0 } {
                    return [lindex [lindex $opclans 0] 0]
                }
            }
        }
    }
    return ""
}

proc reportcomment { chan tag matchid comment name } {
    luvmsg $chan "comment" "A new comment for the match against $tag (id #$matchid) was added by $name: \"${comment}\""
}

proc luvmsg { targ command str } {
    global MAXSTRLEN botnick
    set maxmsglen [expr $MAXSTRLEN - [string length "PRIVMSG $botnick $targ : \[\2$command\2\]"]]

    while { [string length $str] > $maxmsglen } {
            set m [string range $str 0 $maxmsglen]
            set lastspace [string last " " $m]
            set m [string trim [string range $m 0 $lastspace]]
            set str [string trim [string range $str $lastspace end]]
            putmsg $targ "\[\2$command\2\] $m"
    }
    putmsg $targ "\[\2$command\2\] $str"
}

proc checkclannumberofcws { mysql } {
    global pchan privchan
    set numberofmatches [mysqlsel $mysql "select count(1) from matches" -flatlist]


    set evenmatch [expr [lindex $numberofmatches 0] % 250]
    putlog "[lindex $numberofmatches 0] matches played. Evenmatch = $evenmatch"
    if { $evenmatch == 0 } {
        luvmsg $pchan "cw" "This was CW number \2[lindex $numberofmatches 0]\2! <3"
        luvmsg $privchan "cw" "This was CW number \2[lindex $numberofmatches 0]\2! <3"
    }
}

proc checkmembernumberofcws { mysql member chan } {
    set numberofmatches [mysqlsel $mysql "select count(distinct matchid) as matchcount from members inner join memberalias on members.id = memberid inner join matchfrags on matchfrags.name collate utf8_bin like memberalias.name where members.name collate utf8_bin like '[mysqlescape $member]' group by members.id" -flatlist]
    if { [llength $numberofmatches] > 0 } {
        set evenmatch [expr [lindex $numberofmatches 0] % 100]
        if { $evenmatch == 0 } {
            luvmsg $chan "cw" "This was CW number \2[lindex $numberofmatches 0]\2 for \2${member}\2! <3"
        }
    }
}

proc luvnotc { nick command str } {
    global MAXSTRLEN botnick
    set maxmsglen [expr $MAXSTRLEN - [string length "PRIVMSG $botnick $nick : \[\2$command\2\]"]]
    while { [string length $str] > $maxmsglen } {
            set m [string range $str 0 $maxmsglen]
            set lastspace [string last " " $m]
            set m [string trim [string range $m 0 $lastspace]]
            set str [string trim [string range $str $lastspace end]]
            putnotc $nick "\[\2$command\2\] $m"
    }
    putnotc $nick "\[\2$command\2\] $str"
}


proc getggbgratio { clan } {
    set db [getdb]
    set ggbgratio [mysqlsel $db "select count(goodgames.name) - count(badgames.name), matches.date from matches left join goodgames on matches.id = goodgames.matchid left join badgames on badgames.matchid = matches.id where opponent collate utf8_bin like '[mysqlescape $clan]' group by matches.id" -list]

    set ggbg 0.00

    set now [clock seconds]

    if { [llength $ggbgratio] > 0 } {
        set ratio 0.0
        set divisor 0.0
        foreach game $ggbgratio {
            set score [lindex $game 0]
            set multiplier [getmultiplier [lindex $game 1] $now]

            # for ok games, we don't add anything to the score, but we do add to the multiplier, so that the match gets counted.
            set divisor [expr $divisor + $multiplier]

            if { $score > 0 } {
                # we really do $multiplier * 1.0, but this is sort of the same thing :)
                set ratio [expr $ratio + $multiplier]
            } elseif { $score < 0 } {
                set ratio [expr $ratio - $multiplier]
            }
        }
        set ggbg [format "%.1f" [expr $ratio * 10 / $divisor]]

        if { $ggbg > 0 } {
            set ggbg "+$ggbg"
        }
    }
    return $ggbg
}

proc getmultiplier { timestamp now } {
    global ggbgmultiplier ggbgstep

    set daysago [expr ($now - $timestamp)/60.0/60.0/24.0]
    set multiplier [expr $ggbgmultiplier - ($daysago * $ggbgstep)]
    if { $multiplier < 1 } {
        return 1.0;
    } else {
        return [expr $multiplier * $multiplier]
    }
}

#takes a standard eggdrop args input, and returns a list instead. The fields are delimited by spaces, and spaces are escaped by quoting the field.
proc getargs { arg {maxargs -1}} {
    set arg [split [string trim $arg]]
    set arglist [list]
    set argcount 0

    if {$maxargs == -1 } { 
        set maxargs [llength $arg]
    }

    while { $argcount < [llength $arg] } {
        if { [expr $maxargs -1] == [llength $arglist] } {
            set reststr [join [lrange $arg $argcount end]]
            if { [regsub -- "^\"(.*)\"$" $reststr {\1} reststr] } {
                lappend arglist $reststr
            } else {
                lappend arglist [string trim $reststr]
            }
            break
        }

        set thisarg [lindex $arg $argcount]

        if { [ regexp -- "^(\"+)" $thisarg quotestr] } {
            #found a starting "
            set quotes 0
            set subarglist [list]

            while { $argcount < [llength $arg] } {
                set thisarg [lindex $arg $argcount]
                if { [ regexp -- "^(\"+)" $thisarg quotestr] } {
                    set quotes [expr $quotes + [string length $quotestr]]
                }
                if { [ regexp -- "(\"+)$" $thisarg quotestr] } {
                    set quotes [expr $quotes - [string length $quotestr]]
                }

                if { $quotes <= 0 } {
                    lappend subarglist $thisarg
                    regsub -- "^\"(.*)\"$" [join $subarglist] {\1} argstr
                    lappend arglist $argstr
                    break
                } else {
                    lappend subarglist [string trim $thisarg]
                    if { [expr $argcount +1] == [llength $arg] } {
                        lappend arglist [join $subarglist]
                        break
                    }
                }
                incr argcount
            }
        } else {
            lappend arglist [string trim $thisarg]
        }
        incr argcount
    }

    return $arglist
}

proc correctname { nick } {
    if { $nick == "" } {
        return $nick
    } else {
        set nickesc [mysqlescape [string map {_ \\_ \\ \\\\} $nick]]
        set query [mysqlsel [getdb] "select name from members where name like '$nickesc'" -flatlist]
        if { [llength $query] > 0 } {
            return [lindex $query 0]
        } else {
            return $nick
        }
    }
}

proc updatealiasarray { } {
    global aliasarray aliasarraytime aliascachetime

    if {[expr [clock seconds] - $aliasarraytime] > $aliascachetime} {
        catch { unset aliasarray }

        set query [mysqlsel [getdb] "select members.name, memberalias.name from members inner join memberalias on members.id = memberalias.memberid" -list]
        foreach alias $query {
            set aliasarray([lindex $alias 1]) [lindex $alias 0]
        }

        set aliasarraytime [clock seconds]
    }
}

proc nameinaliasarray { nick } {
    global aliasarray

    updatealiasarray

    foreach {alias name} [array get aliasarray] {
        if { $nick == $name } {
            return 1
        }
    }

    return 0
}

proc translatealias { nick } {
    global aliasarray 

    if { $nick == "" } {
        return $nick
    }

    updatealiasarray

    if { [info exists aliasarray($nick)] } {
        return $aliasarray($nick)
    } else {
        return $nick
    }
}

#translate an irc nick into a member name
proc translateirc { nick mysql } {
    if { $nick == "" } { return $nick }
    set nickesc [mysqlescape [string map {_ \\_ \\ \\\\} $nick]]
    set query [mysqlsel $mysql "select members.name from members where members.id = (select memberid from ircnicks where nick like '$nickesc')" -flatlist]
    if { [llength $query] > 0 } {
        return [lindex $query 0]
    } else { return $nick }
}

proc findtag { namelist } {
    putlog "Finding tag for $namelist"
    #Finds the most common substring (probably the tag) in a list of nicknames
    global mytag completedcws

    if { [llength $namelist] < 3 } {
        return ""
    } else {
        array set tags_back {}
        array set tags_front {}
        array set tagscore {}

        for { set i 0 } { $i < [llength $namelist] } { incr i } {
            for { set j [expr $i +1] } { $j < [llength $namelist] } { incr j } {

                set tag_forward [string trim [findtag_forward [lindex $namelist $i] [lindex $namelist $j]]]
                set tag_backward [string trim [findtag_backward [lindex $namelist $i] [lindex $namelist $j]]]

                if { $tag_forward != "" } {
                    if { [info exists tags_front($tag_forward)] } {
                        incr tags_front($tag_forward)
                    } else {
                        set tags_front($tag_forward) 1
                    }
                }
                if { $tag_backward != "" } {
                    if { [info exists tags_back($tag_backward)] } {
                        incr tags_back($tag_backward)
                    } else {
                        set tags_back($tag_backward) 1
                    }
                }
            }
        }
        set db [getdb]
        set taglist [mysqlsel $db "select tag from clans" -flatlist]

        #transferr the tag scores to a common array, as well as make the tags more biased towards tags that
        #we already have in the completedcws array. This will ensure that the tag is detected in the same way
        #even if it is the wrong one (which is easily corrected with cwspyok tag tagcorrection.)
        foreach tag [array names tags_front] {
            foreach cw $completedcws {
                if { [lindex $cw 0] == $tag } {
                    incr tags_front($tag) 4
                }
            }
            set tagscore($tag) $tags_front($tag)
        }
        foreach tag [array names tags_back] {
            foreach cw $completedcws {
                if { [lindex $cw 0] == $tag } {
                    incr tags_back($tag) 4
                }
            }
            set tagscore($tag) $tags_back($tag)
        }

        #bias the detection more towards already existing tags.
        foreach existingtag $taglist {
            #escape the new tag so that the regexp doesn't fuck up.
            set regexptag [string map {( \\( ) \\) ' \\' ? \\? ^ \\^ | \\| \$ \\\$ . \\. * \\* \[ \\\[ \] \\\] \{ \\\{ \} \\\} + \\+} $existingtag]
            foreach tag [array names tags_front] {
                if { $tag == $existingtag } {
                    #found the exact tag in the database, weigh this by 10
                    set tagscore($tag) [expr $tags_front($tag) + 10]
                } elseif { [regexp -- "^$regexptag" $tag] != 0} {
                    #found a tag that matches a substring of the tag the we calculated. This is probably the right tag, so put extra weight on it.
                    set tagscore($existingtag) [expr $tags_front($tag) + 6]
                }

            }
            foreach tag [array names tags_back] {
                if { $tag == $existingtag } {
                    #found the exact tag in the database, weigh this by 10
                    set tagscore($tag) [expr $tags_back($tag) + 10]
                } elseif { [regexp -- "$regexptag$" $tag] != 0} {
                    #found a tag that matches a substring of the tag the we calculated. This is probably the right tag, so put extra weight on it.
                    set tagscore($existingtag) [expr $tags_back($tag) + 6]
                }

            }
        }

        set likelytag ""
        set tagcount 0
        foreach { tag value } [array get tagscore] {
            putlog "$tag with $value"
            if { $value > $tagcount || ($value == $tagcount && [string length $tag] > [string length $likelytag]) } {
                set likelytag $tag
                set tagcount $value
            }
        }

        putlog "Returning the likely opponent tag: $likelytag"
        return $likelytag
    }
}

proc findtag_forward { nick1 nick2 } {
    set tag ""
    set index 0
    while { [string length $nick1] > $index && [string length $nick2] > $index && [string index $nick1 $index] == [string index $nick2 $index] } {
        append tag [string index $nick1 $index]
        incr index
    }

    set tag [string trim $tag]
    if { [string length $tag] > 0 } {
        return $tag
    } else {
        return ""
    }
}

proc findtag_backward { nick1 nick2 } {
    set tag ""
    set index 1
    while { [string length $nick1] >= $index && [string length $nick2] >= $index && [string index $nick1 [expr [string length $nick1] - $index]] == [string index $nick2 [expr [string length $nick2] - $index]] } {
        set tag "[string index $nick1 [expr [string length $nick1] - $index]]$tag"
        incr index
    }
    set tag [string trim $tag]
    if { [string length $tag] > 0 } {
        return $tag
    } else {
        return ""
    }
}

proc getage { timestamp } {
    set diff [expr [clock format [clock seconds] -format "%Y"] - [clock format $timestamp -format "%Y"]]
    set nowmd [clock format [clock seconds] -format "%m%d"]
    set thenmd [clock format $timestamp -format "%m%d"]
    if { $nowmd < $thenmd } {
        set diff [expr $diff - 1]
    }
    return $diff
}

proc capitalize { str } {
    return [string toupper [string index $str 0]][string tolower [string range $str 1 end]]
}
