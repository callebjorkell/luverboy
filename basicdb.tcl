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


### BASIC DB DEPENDANT PROCS

bind pub -|- !addclan sqladdclan
bind pub -|- !addcomment sqladdwarcomment
bind pub -|- !addcw sqladdwar
bind pub -|- !addlineup sqladdlineup
bind pub -|- !addnews sqladdnews
bind pub -|- !addserver addserver
bind pub -|- !claninfo claninfo
bind pub -|- !cwcomments sqlwarcomments
bind pub -|- !cwinfo sqlcwinfo
bind pub -|- !cwfrags cwfrags
bind pub -|- !cwopponents cwopponents
bind pub -|- !cwstats sqlwarstats
bind pub -|- !cws cws
bind pub -|- !delcw sqldelwar
bind pub -|- !delnews sqldelnews
bind pub -|- !editclan sqleditclan
bind pub -|- !last10cws sqllast10wars
bind pub -|- !lastcw sqllastwars
bind pub -|- !lastnews sqllastnews
bind pub -|- !list${myprefix}s listmembers
bind pub -|- !listservers listservers
bind pub -|- !tagsearch tagsearch
bind pub -|- !listtags tagsearch
bind pub -|- !${myprefix}info memberinfo
bind pub -|- !${myprefix}stats memberstats
bind pub -|- !${myprefix}phone memberphone
bind pub -|- !mapstats sqlmapstats
bind pub -|- !fragstats fragstats
bind pub -|- !addcountdown addcountdown
bind pub -|- !countdown countdown
bind pub -|- !randomquote memberquote
bind pub -|- !randomquotes memberquotes
bind pub -|- !lastquote lastmemberquote
bind pub -|- !quotesearch searchmemberquote

registerhelp "addclan" "Adds a new clan into my database." \
            "!addclan <tag> <name> \[ircchan\] \[url\]" \
            "!addclan \"A ^\" \"Alteregos mega\" #alter http://loveme.net" 3 "pub" "clan"
registerhelp "addcomment" "Adds a comment to the given CW. They are shown on the webpage and also available via !cwcomments" \
            "!addcomment <cwid> <comment>" \
            "!addcomment 40 \"Bah! We should have won this one :(\"" 2 "pub" "comment"
registerhelp "addcountdown" "Adds a new countdown. You can only have one active countdown, so if you already have one, it will be overwritten." \
            "!addcountdown <dd.mm.yyyy> <hh:mm> \[description\]" \
            "!addcountdown 02.08.2008 12:00 \"Mah birthday!\"" 3 "pub" "countdown"
registerhelp "addcw" "Adds a CW to my database. Fields containing spaces (for example the tag > F <) MUST be enclosed in \"\" in order to be recognized as one field." \
            "!addcw <opponent> <map1> <our map 1 score> <opp map 1 score> <map2> <our map 2 score> <opp map 2 score>" \
            "!addcw ^FwD wargroun 15 14 rooftops 15 10" 3 "pub" "cwmanage"
registerhelp "addlineup" "Adds a ${myprefix} lineup to the given CW, so that you can see who played in this CW." \
            "!addlineup <cwid> <list of players>" \
            "!addlineup 40 NRGizeR Remo Gilgalad" 3 "pub" "cwmanage"
registerhelp "addnews" "Adds a new newsitem to my database." \
            "!addnews <topic> <text>" \
            "!addnews \"The new way\" \"This is the new way to add news, better believe it!\"" 3 "pub" "news"
registerhelp "addserver" "Adds a new server to the database." \
            "!addserver <address> <clan|pub>" \
            "!addserver 192.168.0.1 pub" 3 "pub" "server"
registerhelp "claninfo" "Shows the information that I have on a given clan." \
            "!claninfo \[tag\]" \
            "!claninfo ^FwD" 1 "pub" "clan"
registerhelp "countdown" "Shows your (or the specified ${myprefix}s) countdown. If you haven't set a countdown, it shows the last one set by someone else." \
            "!countdown \[${myprefix}\]" \
            "!countdown" 3 "pub" "countdown"
registerhelp "cwcomments" "Shows the comments that I have recorded for a given CW." \
            "!cwcomments <cwid>" \
            "!cwcomments 40" 3 "pub" "cwinfo"
registerhelp "cwinfo" "Shows the scores and mapscores for a given CW id." \
            "!cwinfo <cwid>" \
            "!cwinfo 620" 2 "pub" "cwinfo"
registerhelp "cwfrags" "Shows the map frags for the given CW. If an argument is given, nicks will be matched first, and if this doesn't yield results, maps will be matched." \
            "!cwfrags <cwid> \[${myprefix}/map\]" \
            "!cwfrags 1086 NRGizeR" 3 "pub" "cwinfo"
registerhelp "cwopponents" "Shows the opponents in the given CW." \
            "!cwopponents <cwid>" \
            "!cwopponents 1292" 2 "pub" "cwinfo"
registerhelp "cwstats" "Shows total CW statistics. Shows the number and percentage of wins, losses and ties. If an argument is specified, the stats for CWs against this clan is showed. It is also possible to specify a ${myprefix} to see individual stats against this clan. Synonymous to !cwstats" \
            "!cwstats \[clantag\]" \
            "!cwstats" 2 "pub" "stats"
registerhelp "cws" "Shows total CW statistics. Shows the number and percentage of wins, losses and ties. If an argument is specified, the stats for CWs against this clan is showed. It is also possible to specify a ${myprefix} to see individual stats against this clan. Synonymous to !cwstats" \
            "!cws \[clantag\] \[${myprefix}\]" \
            "!cws \"> F <\"" 2 "pub" "stats"
registerhelp "delcw" "Deletes a CW from my database." \
            "!delcw <cwid>" \
            "!delcw 40" 3 "pub" "cwmanage"
registerhelp "delnews" "Deletes a given newsitem from my database." \
            "!delnews <newsid>" \
            "!delnews 2" 3 "pub" "news"
registerhelp "editclan" "Edits the information for a given clan. The possible attributes are: \2tag\2, \2name\2, \2irc\2, and \2www\2. If the value is ommitted, the attribute is blanked." \
            "!editclan <tag> <attribute> \[value\]" \
            "!editclan LM// irc #lovemessengers" 3 "pub" "clan"
registerhelp "last10cws" "Shows a summary of the 10 last CWs that have been played." \
            "!last10cws \[member/clan\] \[clan\]" \
            "!last10cws" 3 "pub" "cwinfo"
registerhelp "lastcw" "This command shows you the last cw against a given opponent, or if typed without arguments it will show the last cw played sorted by date." \
            "!lastcw \[clantag/membername\] \[clantag\]" \
            "!lastcw NRGizeR ^FwD" 1 "pub" "cwinfo"
registerhelp "lastnews" "Prints the last newsentry to the channel" \
            "!lastnews" \
            "!lastnews" 2 "pub" "news"
registerhelp "list${myprefix}s" "Shows the names of all registered ${myprefix}s" \
            "!list${myprefix}s" \
            "!list${myprefix}s" 3 "pub" "${myprefix}s"
registerhelp "listservers" "Lists the public (online) servers that I have in my database." \
            "!listservers" \
            "!listservers" 3 "pub" "server"
registerhelp "listtags" "See !tagsearch" \
            "" \
            "" 2 "pub" "clan"
registerhelp "tagsearch" "Lists the clantags in my database that matches the given substring. If no tags can be matched, the name, irc chan and homepage is also searched." \
            "!tagsearch <searchstring>" \
            "!tagsearch fw" 2 "pub" "clan"
registerhelp "${myprefix}info" "Shows the available information about this ${myprefix}" \
            "!${myprefix}info <membername/ircnick>" \
            "!${myprefix}info Gilgalad" 2 "pub" "${myprefix}s"
registerhelp "${myprefix}stats" "Shows stats for the given ${myprefix}. If a ${myprefix} is not specified, general statistics about the ${myprefix}s is printed." \
            "!${myprefix}stats \[membername/ircnick\]" \
            "!${myprefix}stats Remo" 2 "pub" "${myprefix}s"
registerhelp "${myprefix}phone" "Sends you the phone number of the given ${myprefix} in a private message" \
            "!${myprefix}phone <membername/ircnick>" \
            "!${myprefix}phone Troodon" 3 "pub" "${myprefix}s"
registerhelp "mapstats" "This command shows wins/losses/ties for a given map, and alternatively only against a given clan." \
            "!mapstats <mapname> \[clantag\]" \
            "!mapstats wargroun" 2 "pub" "stats"
registerhelp "fragstats" "This command frag statistics for a given ${myprefix} or map." \
            "!fragstats <${myprefix}/map> \[map\]" \
            "!fragstats Poopy wargroun" 3 "pub" "stats"
registerhelp "randomquotes" "Prints a given number of random quotes by the given ${myprefix}. If no ${myprefix} is specified, totally random quotes will be displayed." \
            "!randomquotes \[${myprefix}\] \[number of quotes\]" \
            "!randomquotes Troodon 5" 1 "pub" "${myprefix}s"
registerhelp "randomquote" "Prints a random quote by the given ${myprefix}, or if no ${myprefix} is specified, a totally random quote will be displayed." \
            "!randomquote \[${myprefix}\]" \
            "!randomquote Troodon" 2 "pub" "${myprefix}s"
registerhelp "quotesearch" "Searches for a given substring in the database of ${myprefix}quotes." \
            "!quotesearch <substring> \[${myprefix}\]" \
            "!quotesearch \"apina\" Molteri" 2 "pub" "${myprefix}s"
registerhelp "lastquote" "Prints the last quote added, or the last quote added for a given ${myprefix}" \
            "!lastquote \[${myprefix}\]" \
            "!lastquote Troodon" 2 "pub" "${myprefix}s"

if { [lsearch -glob [timers] "* checkwebcomments *"] == -1 } { timer 1 checkwebcomments }

proc countdown { nick uhost hand chan arg } {
    if { [hasaccess $nick "countdown"] } {
        set arg [getargs $arg 1]
        set db [getdb]
        set countdown [list]

        if { [llength $arg] > 0 } {
            set countdown [mysqlsel $db "select owner,description,date from countdowns where owner like '[mysqlescape [translateirc [lindex $arg 0] $db]]' and date > [clock seconds]" -flatlist]
            if { [llength $countdown] < 1 } {
                luvmsg $chan "countdown" "[translateirc [lindex $arg 0] $db] doesn't have an active countdown."
            }
        } else {
            set countdown [mysqlsel $db "select owner,description,date from countdowns where owner like '[mysqlescape [translateirc $nick $db]]' and date > [clock seconds]" -flatlist]

            if { [llength $countdown] < 1 } {
                set countdown [mysqlsel $db "select owner,description,date from countdowns where date > [clock seconds] order by addeddate desc limit 1" -flatlist]
            }
            if { [llength $countdown] < 1 } {
                luvmsg $chan "countdown" "There are no active countdowns."
            }
        }
        if { [llength $countdown] > 0 } {
            set timeleft [expr int(floor(([lindex $countdown 2] - [clock seconds]) / 60))]

            set min_left [expr int($timeleft % 60)]
            set timeleft [expr int(floor($timeleft/60))]
            set hrs_left [expr int($timeleft % 24)]
            set timeleft [expr int(floor($timeleft/24))]
            set day_left [expr int($timeleft % 7)]
            set week_left [expr int(floor($timeleft/7))]

            luvmsg $chan "countdown" "(by [lindex $countdown 0]) \2[lindex $countdown 1]\2 in ${week_left}w ${day_left}d ${hrs_left}h ${min_left}m"
        }
    }
}

proc addcountdown { nick host hand chan arg } {
    if { [hasaccess $nick "addcountdown"] } {
        set arg [getargs $arg 3]

        if { [llength $arg] < 2 } {
            luvnotc $nick "addcountdown" "syntax: [gethelpsyntax addcountdown]"
        } else {
            set todate 0
            set datestr "a "
            if { ![regsub -- "(\[0-9\]{2})\.(\[0-9\]{2})\.(\[0-9\]{4})" [lindex $arg 0] {\3-\2-\1} datestr] || [catch { set todate [clock scan "$datestr [lindex $arg 1]"] }]} {
                luvnotc $nick "addcountdown" "syntax: [gethelpsyntax addcountdown]"
            } else {
                set db [getdb]
                set already [mysqlsel $db "select owner from countdowns where owner like '[translateirc $nick $db]'" -flatlist]
                if { [llength $already] > 0 } {
                    mysqlexec $db "delete from countdowns where owner like '[lindex $already 0]'"
                }

                set description ""
                if { [llength $arg] > 2 } {
                    set description [lindex $arg 2]
                }

                mysqlexec $db "insert into countdowns (owner, date, description, addeddate) values ('[translateirc $nick $db]', '$todate', '$description', '[clock seconds]')"
                luvmsg $chan "addcountdown" "Your countdown was added successfully."
            }
        }
    }
}


proc listmembers { nick uhost hand chan arg } {
    global privchan myprefix
    if { [hasaccess $nick "list${myprefix}s"] } {
        set db [getdb]
        set members [mysqlsel $db "SELECT name,status FROM members where status >= 0 order by name" -list]

        if { [llength $members] < 1 } {
            luvmsg $chan "list${myprefix}s" "I can't find any ${myprefix}s :("
        } else {
            set memlist [list]
            set count 0
            foreach mem $members {
                set member "[lindex $mem 0]"
                if { [lindex $mem 1] == 1 } {
                    append member " \2(t)\2"
                }
                lappend memlist $member
            }
            luvmsg $chan "list${myprefix}s" "${myprefix}s: [join $memlist ", "]"
        }
    }
}


proc checkwebcomments { } {
    global privchan pchan
    if { [lsearch -glob [timers] "* checkwebcomments *"] == -1 } { timer 2 checkwebcomments }

    set db [getdb]
    set comments [mysqlsel $db "select opponent,matchid, name,comment from matches inner join matchcomments on matchid = matches.id where printed = 0 order by matchcomments.date desc" -list]
    if { [llength $comments] > 0 } {
        putlog "Printing web-added comments..."
        foreach comment $comments {
            reportcomment $privchan [lindex $comment 0] [lindex $comment 1] [lindex $comment 3] [lindex $comment 2]
            reportcomment $pchan [lindex $comment 0] [lindex $comment 1] [lindex $comment 3] [lindex $comment 2]
        }
        mysqlexec $db "update matchcomments set printed = 1 where printed = 0";
    }
}


proc claninfo { nick uhost hand chan arg } {
    global privchan mytag
    if { [hasaccess $nick "claninfo"] } {
        set arg [getargs $arg 1]
        if {[llength $arg] > 0} {
            set db [getdb]
            set cleantag [lindex $arg 0]
            set tag [mysqlescape $cleantag]

            set info [mysqlsel $db "select tag,name,irc,url,id from clans where tag collate utf8_bin like '$tag' " -flatlist]

            if { [llength $info] > 0 } {

                set irc [lindex $info 2]
                if { $irc == "" } {
                    set irc "no chan"
                } else {
                    set irc "chan $irc"
                }

                set www [lindex $info 3]
                if { $www == "" } {
                    set www "no homepage"
                } else {
                    set www "homepage $www"
                }

                set ggbg [getggbgratio [lindex $arg 0]]
                luvmsg $chan "claninfo" "[lindex $info 1] ([lindex $info 0]) has $irc and ${www} (GG/BG ratio: $ggbg)"
            } else {
                luvmsg $chan "claninfo" "No clan with tag $cleantag in my database"
            }
        } else {
            claninfo $nick $uhost $hand $chan $mytag
        }
    }
}

proc sqleditclan {nick uhost hand chan arg} {
    global privchan
    if { [hasaccess $nick "editclan"] } {
        set arg [getargs $arg 3]

        if { [llength $arg] < 3 } {
            luvnotc $nick "editclan" "syntax: [gethelpsyntax editclan]"
        } else {

            set tag [lindex $arg 0]
            set esctag [mysqlescape $tag]

            set db [getdb]

            set tagselect [mysqlsel $db "select id from clans where tag collate utf8_bin like '$esctag'" -flatlist]
            if { [llength $tagselect] == 0 } {
                luvmsg $chan "editclan" "Tag $tag doesn't exist in my database."
            } else {
                set attribute [lindex $arg 1]

                set value [lindex $arg 2]
                set escvalue [mysqlescape $value]

                set query "update clans "
                switch -- $attribute {
                    "tag" {
                        set othertag [mysqlsel $db "select id from clans where tag collate utf8_bin like '$escvalue'" -flatlist]
                        if { [llength $othertag] > 0 } {
                            luvmsg $chan "editclan" "The tag \"$value\" is already present in my database."
                        } elseif { [string length $tag] == 0 } {
                            luvmsg $chan "editclan" "The tag cannot be blanked. Please give a new value for the clantag."
                        } else {
                            mysqlexec $db "update clans set tag = '$escvalue' where tag collate utf8_bin like '$esctag'"
                            mysqlexec $db "update matches set opponent = '$escvalue' where opponent collate utf8_bin like '$esctag'"
                            luvmsg $chan "editclan" "The tag $tag was changed to \2$value\2 in my database."
                        }
                    }
                    "www" {
                        if { [string length $value] == 0 || [checkvalid_www $value] } {
                            mysqlexec $db "update clans set url = '$escvalue' where tag collate utf8_bin like '$esctag'"
                            if { [string length $value] == 0 } {
                                luvmsg $chan "editclan" "The clan $tag was updated with no webpage in my database."
                            } else {
                                luvmsg $chan "editclan" "The clan $tag was updated with webpage $value in my database."
                            }
                        } else {
                            luvmsg $chan "editclan" "The URL \"$value\" is invalid. The URL needs to be in the form \2http://this.is.an/example\2"
                        }
                    }
                    "irc" {
                        if { [string length $value] == 0 || [checkvalid_irc $value] } {
                            mysqlexec $db "update clans set irc = '$escvalue' where tag collate utf8_bin like '$esctag'"
                            if { [string length $value] == 0 } {
                                luvmsg $chan "editclan" "The clan $tag was updated with no irc channel in my database."
                            } else {
                                luvmsg $chan "editclan" "The clan $tag was updated with irc channel $value in my database."
                            }
                        } else {
                            luvmsg $chan "editclan" "The irc channel \"$value\" is invalid. The channel needs to be in the form \2#channame\2"
                        }
                    }
                    "name" {
                        mysqlexec $db "update clans set name = '$escvalue' where tag collate utf8_bin like '$esctag'"
                        luvmsg $chan "editclan" "The clan $tag was updated with the name $value in my database."
                    }
                    default {
                        luvnotc $nick "editclan" "syntax: [gethelpsyntax editclan]"
                        luvnotc $nick "editclan" "Valid attributes are: tag, name, irc, and www"
                    }
                }
            }
        }
    }
}

proc sqladdclan {nick uhost hand chan arg} {
    global privchan
    if { [hasaccess $nick "addclan"] } {
        set arg [getargs $arg 4]

        if { [llength $arg] < 2 } { luvnotc $nick "addclan" "syntax: [gethelpsyntax addclan]"; return 1 }

        set tag [lindex $arg 0]
        set esctag [mysqlescape $tag]

        set db [getdb]

        set tagselect [mysqlsel $db "select id from clans where tag collate utf8_bin like '$esctag'" -flatlist]
        if { [llength $tagselect] != 0 } {
            luvmsg $chan "addclan" "Tag $tag already exist in my database."
        } else {
            set name [lindex $arg 1]
            set escname [mysqlescape $name]

            set irc [string tolower [lindex $arg 2]]
            set escirc [mysqlescape $irc]
            set url [string tolower [lindex $arg 3]]
            set escurl [mysqlescape $url]

            if { $url == "" } {
                set url "\2no\2 homepage"
            } else {
                if { [checkvalid_www $url] } {
                    set url "the homepage \2$url\2"
                } else {
                    luvnotc $nick "addclan" "The argument \2$url\2 is not a valid homepage. The URL needs to start with \2http://\2"
                    set url ""
                }
            }

            if { $irc == "" } {
                set irc "\2no\2 irc channel"
            } else {
                if { [checkvalid_irc $irc] } {
                    set irc "the irc channel \2$irc\2"
                } else {
                    luvnotc $nick "addclan" "The argument \2$irc\2 is not a valid irc channel. The channel needs to start with \2#\2"
                    set irc ""
                }
            }

            if { $irc != "" && $url != "" } {
                mysqlexec $db "insert into clans (tag, name, irc, url) values ('$esctag','$escname','$escirc','$escurl')"
                set index [mysqlinsertid $db]

                luvmsg $chan "addclan" "Added \2$tag\2 (\2$name\2) into my database with $irc and $url (id #$index)."
            } else {
                luvnotc $nick "addclan" "syntax: [gethelpsyntax addclan]"
            }
        }
    }
}

proc tagsearch {nick uhost hand chan arg} {
    global privchan
    if { [hasaccess $nick "tagsearch"] } {
        set arg [getargs $arg 1]
        if { [llength $arg] < 1 } { 
            luvnotc $nick "tagsearch" "syntax: [gethelpsyntax tagsearch]"
        } else {
            set tag [mysqlescape [lindex $arg 0]]

            set db [getdb]

            set tags [mysqlsel $db "SELECT tag FROM clans where tag like '%$tag%'" -flatlist]
            set count [llength $tags]

            if { $count == 0} {
                set tags [mysqlsel $db "SELECT tag FROM clans where name like '%$tag%' or url like '%$tag%' or irc like '%$tag%'" -flatlist]
                set count [llength $tags]
            }
            if { $count == 0 } {
                luvmsg $chan "tagsearch" "No matching tags."
            } else {
                set taglist [join $tags "\" \""]
                set taglist "\"$taglist\""
                luvmsg $chan "tagsearch" "($count tags) $taglist"
            }
        }
    }
}

proc sqladdnews {nick uhost hand chan arg} {
    global pchan privchan
    if { [hasaccess $nick "addnews"] } {
        set arg [getargs $arg 2]

        if { [llength $arg] < 2 } { 
            luvnotc $nick "addnews" "syntax: [gethelpsyntax addnews]"
        } else {

            set db [getdb]

            set topic [lindex $arg 0]
            set esctopic [mysqlescape $topic]
            set esctext [mysqlescape [lindex $arg 1]]
            set author [mysqlescape [translateirc $nick $db]]

            mysqlexec $db "INSERT INTO news (date, topic, author, text) VALUES ([unixtime],'$esctopic','$author','$esctext')";
            set newsid [mysqlinsertid $db]


            luvmsg $chan "addnews" "Added news item \"$topic\" to database with id $newsid"
        }
    }
}

proc sqldelnews {nick uhost hand chan arg} {
    global privchan
    if { [hasaccess $nick "delnews"] } {
        set arg [getargs $arg 1]
        if { [llength $arg] < 1 || ![string is integer [lindex $arg 0]]} { 
            luvnotc $nick "delnews" "syntax: [gethelpsyntax delnews]"
        } else {
            set newsid [lindex $arg 0]
            set db [getdb]
            set topic [mysqlsel $db "select topic from news where id = '$newsid'" -flatlist]
            if { [llength $topic] > 0 } {
                mysqlexec $db "delete from news where id = '$newsid'"
                luvmsg $chan "delnews" "Deleted newsitem #$newsid (topic: [lindex $topic 0])"
            } else {
                luvmsg $chan "delnews" "I couldn't find a newsitem with id $newsid in my database"
            }
        }
    }
}

proc sqllastnews { nick uhost hand chan arg } {
    global privchan
    if { [hasaccess $nick "lastnews"] } {
        set db [getdb]
        set newsitem [mysqlsel $db "SELECT id,date,author,topic,text FROM news order by date desc limit 1" -flatlist]

        if { [llength $newsitem] < 0 } {
            luvmsg $chan "lastnews" "I don't have any news :("
        } else {
            set newsdate [clock format [lindex $newsitem 1] -format "%d.%m.%Y %H:%M"]
            luvmsg $chan "lastnews" "(id #[lindex $newsitem 0]) from $newsdate by [lindex $newsitem 2]"
            luvmsg $chan "lastnews" "Topic: [lindex $newsitem 3]"
            luvmsg $chan "lastnews" "[lindex $newsitem 4]"
        }
    }
}

proc listservers { nick uhost hand chan arg } {
    global privchan
    if { [hasaccess $nick "listservers"] } {
        set db [getdb]
        set servers [mysqlsel $db "SELECT address FROM servers where available = 1 AND type = 0 order by address" -flatlist]

        if { [llength $servers] < 0 } {
            luvmsg $chan "listservers" "I can't find any servers :("
        } else {
            luvmsg $chan "listservers" "Public servers: [join $servers ", "]"
        }
    }
}

proc cwopponents {nick host hand chan arg} {
    global mytag
    if { [hasaccess $nick "cwopponents"] } {
        set arg [getargs $arg 1]
        if { [llength $arg] < 1 || ![string is integer [lindex $arg 0]] } {
            luvnotc $nick "cwopponents" "syntax: [gethelpsyntax cwopponents]"
        } else {
            set id [lindex $arg 0]
            set db [getdb]

            set match [mysqlsel $db "select opponent,date from matches where id like '$id'" -flatlist]
            if { [llength $match] > 0 } {
                set opponents [mysqlsel $db "select name,sum(frags) from matchopponents inner join scores on scoreid = scores.id where matchid = '$id' group by name" -list]
                if { [llength $opponents] > 0 } {
                    set opplist [list]
                    foreach opponent $opponents {
                        lappend opplist "[lindex $opponent 0] ([lindex $opponent 1] frags)"
                    }
                    luvmsg $chan "cwopponents" "Opponents in CW #$id vs. \2[lindex $match 0]\2 on [clock format [lindex $match 1] -format %d.%m.%Y]: [join $opplist {, }]"
                } else {
                    luvmsg $chan "cwopponents" "No opponent information for that CW."
                }
            } else {
                luvmsg $chan "cwopponents" "No CW with that id."
            }
        }
    }
}

proc cwfrags {nick uhost hand chan arg} {
    global mytag privchan
    if { [hasaccess $nick "cwfrags"] } {
        set arg [getargs $arg 2]
        if { [llength $arg] < 1 || ![string is integer [lindex $arg 0]] } {
            luvnotc $nick "cwfrags" "syntax: [gethelpsyntax cwfrags]"
        } else {
            set db [getdb]
            set index [lindex $arg 0]
            set member [translateirc [lindex $arg 1] $db]

            if { $member == "" } {
                set match [mysqlsel $db "select id,opponent,date from matches where id = '$index'" -flatlist]
                set frags [mysqlsel $db "select name,sum(frags) as f from matchfrags where matchid = '$index' and frags is not NULL group by name order by f desc" -list]

                if { [llength $match] > 0 && [llength $frags] > 0 } {
                    luvmsg $chan "cwfrags" "Frags for CW #[lindex $match 0] vs. \2[lindex $match 1]\2 on [clock format [lindex $match 2] -format %d.%m.%Y]:"
                    foreach frag $frags {
                        luvmsg $chan "cwfrags" "[lindex $frag 1] frags: \2[lindex $frag 0]\2"
                    }
                } else {
                    luvmsg $chan "cwfrags" "No frag information for that game."
                }
            } else {
                set frags [mysqlsel $db "select name,frag.matchid,opponent,date,frags,map from (select scores.matchid as matchid,frags,map,name from matchfrags inner join scores on matchfrags.scoreid = scores.id where matchfrags.name like '$member' and scores.matchid = '$index') as frag inner join matches on frag.matchid = matches.id" -list]
                if { [llength $frags] > 0 } {
                    set first [lindex $frags 0]
                    luvmsg $chan "cwfrags" "Frags for \2[lindex $first 0]\2 in CW #[lindex $first 1] vs. \2[lindex $first 2]\2 on [clock format [lindex $first 3] -format %d.%m.%Y]:"
                    foreach frag $frags {
                        luvmsg $chan "cwfrags" "[lindex $frag 4] frags on \2[lindex $frag 5]\2"
                    }
                } else {
                    set frags [mysqlsel $db "select name,frag.matchid,opponent,date,frags,map from (select scores.matchid as matchid,frags,map,name from matchfrags inner join scores on matchfrags.scoreid = scores.id where scores.map like '$member' and scores.matchid = '$index') as frag inner join matches on frag.matchid = matches.id order by frags desc" -list]
                    if { [llength $frags] > 0 } {
                        set first [lindex $frags 0]
                        luvmsg $chan "cwfrags" "Frags on \2[lindex $first 5]\2 in CW #[lindex $first 1] vs. \2[lindex $first 2]\2 on [clock format [lindex $first 3] -format %d.%m.%Y]:"
                        foreach frag $frags {
                            luvmsg $chan "cwfrags" "[lindex $frag 4] frags: \2[lindex $frag 0]\2"
                        }
                    } else {
                        luvmsg $chan "cwfrags" "No frag information for $member in CW #$index"
                    }
                }
            }
        }
    }
}

proc memberstats { nick host hand chan arg } {
    global privchan myprefix
    if { [hasaccess $nick "${myprefix}stats"] } {
        set arg [getargs $arg]
        set db [getdb]
        if { [llength $arg] < 1 } {
            set matchcount [mysqlsel $db "select members.name, count(distinct matchid) as matchcount from members inner join memberalias on members.id = memberid inner join matchfrags on matchfrags.name collate utf8_bin like memberalias.name group by name order by matchcount desc" -list]
            set matchweekcount [mysqlsel $db "select members.name,count(distinct matches.id) as matchcount from members inner join memberalias on members.id = memberid inner join matchfrags on matchfrags.name collate utf8_bin like memberalias.name inner join matches on matches.id = matchid where date > (unix_timestamp(now()) - 604800) group by members.name order by matchcount desc" -list]
            set maxfrags [mysqlsel $db "select members.name, max(frags) as maxfrags,matchfrags.name from matchfrags left join memberalias on memberalias.name = matchfrags.name left join members on members.id = memberid group by matchfrags.name order by maxfrags desc" -list]
            set ages [mysqlsel $db "select name,unix_timestamp(birthday) as bday, status from members where status != -1 order by bday" -list]
            set victories [mysqlsel $db "select members.name, sum(wins), count(1) from (select matchid, sum(ourscore) > sum(oppscore) as wins from matches inner join scores on matchid = matches.id group by matchid) as a inner join matchfrags on a.matchid = matchfrags.matchid inner join memberalias on memberalias.name collate utf8_bin like matchfrags.name inner join members on memberid = members.id group by name" -list]

            set mostmatches [lindex $matchcount 0]
            set mostmatchesweek [lindex $matchweekcount 0]

            set mostfrags [lindex $maxfrags 0]

            set avgage 0
            set trials 0
            set membrs 0

            set mostwinmember ""
            set mostwinproc 0

            foreach age $ages {
                set avgage [expr $avgage + ([lindex $age 1] / [llength $ages])]

                if { [lindex $age 2] == 0 } {
                    incr membrs
                } elseif { [lindex $age 2] == 1 } {
                    incr trials
                }
            }

            foreach victory $victories {
                set winproc [expr ([lindex $victory 1] * 100.0) / [lindex $victory 2]]
                if { $winproc > $mostwinproc } {
                    set mostwinmember [lindex $victory 0]
                    set mostwinproc $winproc
                }
            }

            set mostwinproc "[format %.1f $mostwinproc]%"

            set members [llength $ages]

            set msg "Number of ${myprefix}s: $members"
            if { $trials == 0 } {
                append msg " (all members)"
            } else {
                append msg " ($membrs members and $trials"
                if { $trials > 1 } {
                    append msg " trials)"
                } else {
                    append msg " trial)"
                }
            }

            luvmsg $chan "${myprefix}stats" "$msg. Average age: [getage $avgage]."
            set mostfragsmember [lindex $mostfrags 0]
            if { $mostfragsmember == "" } {
                set mostfragsmember [lindex $mostfrags 2]
            }

            luvmsg $chan "${myprefix}stats" "Most matches played: [lindex $mostmatches 0] ([lindex $mostmatches 1] matches). Most matches the past week: [lindex $mostmatchesweek 0] ([lindex $mostmatchesweek 1] matches). Most frags in a single map: $mostfragsmember ([lindex $mostfrags 1] frags). Most victorious ${myprefix}: $mostwinmember ($mostwinproc wins)."

        } else {
            set membsql [list]
            set namelist [list]
            foreach memb $arg {
                set name "[correctname [translateirc $memb $db]]"
                lappend membsql "'[mysqlescape $name]'"
                lappend namelist $name
            }

            if { [llength $membsql] > 0 } {
                #haxx0r query :)
                set scores [mysqlsel $db "select sum(ourscore > oppscore) as wins, sum(ourscore = oppscore) as ties, sum(ourscore < oppscore) as losses,  count(1) as total from (select b.matchid, num, sum(ourscore)as ourscore, sum(oppscore) as oppscore from (select matchid, count(1) as num from (select distinct matchfrags.matchid, members.name from matchfrags inner join memberalias on memberalias.name collate utf8_bin like matchfrags.name inner join members on members.id = memberalias.memberid where members.name in ([join $membsql ","])) as a group by a.matchid) as b inner join scores on scores.matchid = b.matchid where num = '[llength $membsql]' group by b.matchid) as c" -flatlist]
                set bestworst [list]
                if { [llength $membsql] == 1 } {
                    set bestworst [mysqlsel $db "select map,avg(frags),max(frags),count(1) from matchfrags inner join memberalias on memberalias.name collate utf8_bin like matchfrags.name inner join members on members.id = memberalias.memberid inner join scores on matchfrags.scoreid = scores.id where members.name collate utf8_bin like [lindex $membsql 0] group by scores.map" -list]
                }
                set lastcw [mysqlsel $db "select opponent, matches.id, date from (select matchid, count(1) as num from (select distinct matchfrags.matchid, members.name from matchfrags inner join memberalias on memberalias.name collate utf8_bin like matchfrags.name inner join members on members.id = memberalias.memberid where members.name in ([join $membsql ","])) as a group by a.matchid) as b inner join matches on matches.id = b.matchid and num = '[llength $membsql]' order by date desc limit 1" -flatlist]
                set matchespermonth [mysqlsel $db "select sum(num='[llength $membsql]') from (select matchid, count(1) as num from (select distinct matchfrags.matchid, members.name from matchfrags inner join memberalias on memberalias.name collate utf8_bin like matchfrags.name inner join members on members.id = memberalias.memberid where members.name in ([join $membsql ","])) as a group by a.matchid) as b inner join matches on b.matchid = matches.id where date > '[clock scan "-1 month"]'" -flatlist]
                if { [llength $namelist] == 1 } {
                    luvmsg $chan "${myprefix}stats" "Stats for ${myprefix} \2[lindex $namelist 0]\2:"
                } else {
                    luvmsg $chan "${myprefix}stats" "Stats for ${myprefix}s \2[join $namelist ", "]\2:"
                }

                set printed 0
                set wins [lindex $scores 0]
                set ties [lindex $scores 1]
                set losses [lindex $scores 2]
                set count [lindex $scores 3]

                if { $count > 0 } {
                    set winproc [format "%.1f" [expr ($wins * 100.0) / $count ]]
                    set lossproc [format "%.1f" [expr ($losses * 100.0) / $count]]
                    set tieproc [format "%.1f" [expr ($ties * 100.0) / $count ]]
                    set matcheslastmonth 0
                    if { [lindex $matchespermonth 0] != "" } {
                        set matcheslastmonth [lindex $matchespermonth 0]
                    }
                    luvmsg $chan "${myprefix}stats" "Matches played: $count. $wins wins ($winproc%), $ties ties ($tieproc%), and $losses losses ($lossproc%). Matches played in the last month: ${matcheslastmonth}."
                    set printed 1
                }
                if { [llength $lastcw] > 0 } {
                    luvmsg $chan "${myprefix}stats" "Last played CW: [clock format [lindex $lastcw 2] -format %d.%m.%Y] (#[lindex $lastcw 1] against [lindex $lastcw 0])"
                    set printed 1
                }
                if { [llength $bestworst] > 0 } {
                    set avgtotal 0
                    set bestval [lindex [lindex $bestworst 0] 2]
                    set avgval 0 

                    set bestmap [lindex [lindex $bestworst 0] 0]
                    set avgmap ""

                    foreach map $bestworst {
                        if { [string is double -strict [lindex $map 1]] || [string is integer -strict [lindex $map 2]] } {
                            set avgtotal [expr $avgtotal + [lindex $map 1]]
                            if { [lindex $map 1] > $avgval && [lindex $map 3] > 2} {
                                set avgval [lindex $map 1]
                                set avgmap [lindex $map 0]
                            }
                            if { [lindex $map 2] > $bestval } {
                                set bestval [lindex $map 2]
                                set bestmap [lindex $map 0]
                            }
                        }
                    }

                    set avgtotal [expr round($avgtotal / [llength $bestworst])]
                    luvmsg $chan "${myprefix}stats" "Most frags: [format %d $bestval] (on $bestmap). Best map overall: $avgmap ([format %.1f $avgval] frags average). Average frags per map: $avgtotal"
                    set printed 1
                }
                if { $printed == 0 } { 
                    luvmsg $chan "${myprefix}stats" "No stats available..."
                }
            } else {
                luvmsg $chan "${myprefix}stats" "No ${myprefix} by that name found..."
            }
        }
    }
}

proc memberphone { nick uhost hand chan arg } {
    global privchan myprefix
    if { [hasaccess $nick "${myprefix}phone"] } {
        set arg [getargs $arg 1]
        if { [llength $arg] < 1 } {
            luvnotc $nick "${myprefix}phone" "syntax: [gethelpsyntax ${myprefix}phone]"
        } else {
            set db [getdb]
            set member [translateirc [lindex $arg 0] $db ]
            set info [mysqlsel $db "select name,phone from members where name like '[mysqlescape $member]'" -flatlist]

            if { [llength $info] < 1 } {
                luvmsg $chan "${myprefix}phone" "I can't find any ${myprefix} by that name..."
            } else {
                if { [lindex $info 1] != "" } {
                    luvmsg $chan "${myprefix}phone" "Sending [lindex $info 0]s phone number to $nick"
                    luvmsg $nick "${myprefix}phone" "[lindex $info 0]s phone number is: \2[lindex $info 1]\2"
                } else {
                    luvmsg $chan "${myprefix}phone" "[lindex $info 0] hasn't specified a phone number."
                }
            }
        }
    }
}

proc memberquote { nick host hand chan arg } {
    global myprefix
    if { [hasaccess $nick "randomquote"] } {
        set arg [getargs $arg 1]
        if { [llength $arg] < 1 } {
            set db [getdb]
            set quote [mysqlsel $db "select name,quote from members inner join memberquotes on memberid = members.id order by rand() limit 1" -flatlist]
            if { [llength $quote] > 1 } {
                luvmsg $chan "randomquote" "Quote by \2[lindex $quote 0]\2: \"[lindex $quote 1]\""
            } else {
                luvmsg $chan "randomquote" "No quotes in my database."
            }
        } else {
            set db [getdb]
            set member [translateirc [lindex $arg 0] $db ]
            set memberid [mysqlsel $db "select id,name from members where name like '[mysqlescape $member]'" -flatlist]
            if { [llength $memberid] < 1} {
                luvmsg $chan "randomquote" "I can't find any ${myprefix} by that name..."
            } else {
                set quote [mysqlsel $db "select quote from memberquotes where memberid = '[lindex $memberid 0]' order by rand() limit 1" -flatlist]
                if { [llength $quote] < 1 } {
                    luvmsg $chan "randomquote" "$member has no quotes set."
                } else {
                    luvmsg $chan "randomquote" "Quote by \2[lindex $memberid 1]\2: \"[lindex $quote 0]\""
                }
            }
        }
    }
}

proc memberquotes { nick host hand chan arg } {
    global myprefix
    if { [hasaccess $nick "randomquotes"] } {
        set db [getdb]
        set arg [getargs $arg 2]
        set member ""
        set limit 5
        if { [llength $arg] == 1 } {
            if { [string is integer [lindex $arg 0]] } {
                set limit [lindex $arg 0]
                if { $limit > 10 } {
                    set limit 10
                }
            } else {
                set member [lindex $arg 0]
            }
        } elseif { [llength $arg] == 2 } {
            if { [string is integer [lindex $arg 1]] } {
                set limit [lindex $arg 1]
                if { $limit > 10 } {
                    set limit 10
                }
            } else {
                luvnotc $nick "randomquotes" "syntax: [gethelpsyntax randomquotes]"
                return
            }
            set member [lindex $arg 0]
        }

        if { $member == "" } {
            set quotes [mysqlsel $db "select name,quote from members inner join memberquotes on memberid = members.id order by rand() limit [mysqlescape $limit]" -list]
            if { [llength $quotes] > 1 } {
                foreach quote $quotes {
                    luvmsg $chan "randomquotes" "Quote by \2[lindex $quote 0]\2: \"[lindex $quote 1]\""
                }
            } else {
                luvmsg $chan "randomquotes" "No quotes in my database."
            }
        } else {
            set member [translateirc $member $db ]
            set memberid [mysqlsel $db "select id,name from members where name like '[mysqlescape $member]'" -flatlist]
            if { [llength $memberid] < 1} {
                luvmsg $chan "randomquotes" "I can't find any ${myprefix} by that name..."
            } else {
                set quotes [mysqlsel $db "select quote from memberquotes where memberid = '[lindex $memberid 0]' order by rand() limit [mysqlescape $limit]" -list]
                if { [llength $quotes] < 1 } {
                    luvmsg $chan "randomquotes" "$member has no quotes set."
                } else {
                    foreach quote $quotes {
                        luvmsg $chan "randomquotes" "Quote by \2[lindex $memberid 1]\2: \"[lindex $quote 0]\""
                    }
                }
            }
        }
    }
}

proc lastmemberquote { nick host hand chan arg } {
    global myprefix
    if { [hasaccess $nick "lastquote"] } {
        set arg [getargs $arg 1]
        if { [llength $arg] < 1 } {
            set db [getdb]
            set quote [mysqlsel $db "select name,quote from members inner join memberquotes on memberid = members.id order by memberquotes.id desc limit 1" -flatlist]
            if { [llength $quote] > 1 } {
                luvmsg $chan "lastquote" "Quote by \2[lindex $quote 0]\2: \"[lindex $quote 1]\""
            } else {
                luvmsg $chan "lastquote" "No quotes in my database."
            }
        } else {
            set db [getdb]
            set member [translateirc [lindex $arg 0] $db ]
            set memberid [mysqlsel $db "select id,name from members where name like '[mysqlescape $member]'" -flatlist]
            if { [llength $memberid] < 1} {
                luvmsg $chan "lastquote" "I can't find any ${myprefix} by that name..."
            } else {
                set quote [mysqlsel $db "select quote from memberquotes where memberid = '[lindex $memberid 0]' order by memberquotes.id desc limit 1" -flatlist]
                if { [llength $quote] < 1 } {
                    luvmsg $chan "lastquote" "$member has no quotes set."
                } else {
                    luvmsg $chan "lastquote" "Quote by \2[lindex $memberid 1]\2: \"[lindex $quote 0]\""
                }
            }
        }
    }
}

proc searchmemberquote { nick host hand chan arg } {
    global myprefix
    if { [hasaccess $nick "quotesearch"] } {
        set arg [getargs $arg 2]
        if { [llength $arg] < 1 } {
            luvnotc $nick "quotesearch" "syntax: [gethelpsyntax $quotesearch]"
        } elseif { [llength $arg] < 2 } {
            set db [getdb]
            set quotes [mysqlsel $db "select name,quote from members inner join memberquotes on memberid = members.id where quote like '%[mysqlescape [lindex $arg 0]]%' order by memberquotes.id desc" -list]

            if { [llength $quotes] > 0 } {
                set count 0
                foreach quote $quotes {
                    if { $count >= 5 } {
                        luvmsg $chan "quotesearch" "And [expr [llength $quotes] - $count] more..."
                        break
                    } else {
                        incr count
                        luvmsg $chan "quotesearch" "Quote by \2[lindex $quote 0]\2: \"[lindex $quote 1]\""
                    }
                }
            } else {
                luvmsg $chan "quotesearch" "No quotes that match the substring \2[lindex $arg 0]\2 could be found."
            }
        } else {
            set db [getdb]
            set member [translateirc [lindex $arg 1] $db ]
            set memberid [mysqlsel $db "select id,name from members where name like '[mysqlescape $member]'" -flatlist]
            if { [llength $memberid] < 1} {
                luvmsg $chan "quotesearch" "I can't find any ${myprefix} by that name..."
            } else {
                set quotes [mysqlsel $db "select quote from memberquotes where memberid = '[lindex $memberid 0]' and quote like '%[mysqlescape [lindex $arg 0]]%' order by memberquotes.id desc" -list]
                if { [llength $quotes] > 0 } {
                    set count 0
                    foreach quote $quotes {
                        if { $count >= 5 } {
                            luvmsg $chan "quotesearch" "And [expr [llength $quotes] - $count] more..."
                            break
                        } else {
                            incr count
                            luvmsg $chan "quotesearch" "Quote by \2$member\2: \"[lindex $quote 0]\""
                        }
                    }
                } else {
                    luvmsg $chan "quotesearch" "No quotes that match the substring \2[lindex $arg 0]\2 could be found for ${myprefix} ${member}."
                }
            }
        }
    }
}

proc memberinfo { nick uhost hand chan arg } {
    global privchan myprefix
    if { [hasaccess $nick "${myprefix}info"] } {
        set arg [getargs $arg 1]
        if { [llength $arg] < 1 } {
            luvnotc $nick "${myprefix}info" "syntax: [gethelpsyntax ${myprefix}info]"
        } else {
            set db [getdb]
            set member [translateirc [lindex $arg 0] $db ]
            set info [mysqlsel $db "select members.name,place,quote,unix_timestamp(birthday),status from members left join memberquotes on memberquotes.memberid = members.id inner join memberalias on memberalias.memberid = members.id where memberalias.name like '[mysqlescape $member]' order by rand() limit 1" -flatlist]

            if { [llength $info] < 1 } {
                luvmsg $chan "${myprefix}info" "I can't find any ${myprefix} by that name..."
            } else {
                set saystring "Name: [lindex $info 0], Birthday: [clock format [lindex $info 3] -format %d.%m.%Y] ([getage [lindex $info 3]] years)"
                if { [lindex $info 4] == 1 } {
                    append saystring ", Status: Trial"
                } else {
                    append saystring ", Status: Member"
                }
                if { [lindex $info 1] != "" } {
                    append saystring ", Location: [lindex $info 1]"
                }

                luvmsg $chan "${myprefix}info" "$saystring"

                if { [lindex $info 2] != "" } {
                    luvmsg $chan "${myprefix}info" "Quote: [lindex $info 2]"
                }
            }
        }
    }
}

proc sqladdlineup {nick uhost hand chan arg} {
    global privchan
    if { [hasaccess $nick "addlineup"] } {
        set arg [getargs $arg]
        if { [llength $arg] < 2 || ![string is integer [lindex $arg 0]] } {
            luvnotc $nick "addlineup" "syntax: [gethelpsyntax addlineup]"
        } else {

            #check that the id for the war exists
            set id [mysqlescape [lindex $arg 0]]
            set db [getdb]
            set query [mysqlsel $db "select id from scores where matchid = '$id'" -flatlist]
            if { [llength $query] == 0 } {
                luvmsg $chan "addlineup" "No CW with that id."
            } else {
                #our id exist, parse the list of irc-nicks and if possible, substitute the "real" nicks.

                #this is the list of players that the user in the channel supplied
                set players [lrange $arg 1 end]

                #number of players
                set count [llength $players]

                #delete the old entries, if they exist. keep spied lineups.
                mysqlexec $db "delete from matchfrags where matchid = '$id' and frags is null"

                #loop through the list of players and substitute the nicks where possible.
                set addedplayers [list]
                foreach scoreid $query {
                    for {set i 0} {$i<$count} {incr i} {
                        set player [string trim [lindex $players $i]]

                        if { $player != "" } {
                            set player [mysqlescape [translateirc $player $db ]]
                            set already [mysqlsel $db "select name from matchfrags where matchid = '$id' and scoreid = '$scoreid' and name collate utf8_bin like '$player'" -flatlist]
                            if { [llength $already] < 1 } {
                                mysqlexec $db "insert into matchfrags (matchid, scoreid, name, frags) values ('$id', '$scoreid', '$player', NULL)"
                                if { [lsearch -exact $addedplayers $player] == -1 } {
                                    lappend addedplayers $player
                                }
                            }
                        }
                    }
                }
                if { [llength $addedplayers] > 0 } { 
                    luvmsg $chan "addlineup" "Added the lineup [join $addedplayers ", "] to CW #$id"
                    foreach player $addedplayers {
                        checkmembernumberofcws $db $player $chan
                    }
                } else {
                    luvmsg $chan "addlineup" "No updates made, is this lineup already set?"
                }
            }
        }
    }
}

proc sqlwarcomments { nick uhost hand chan arg } {
    global pchan privchan mytag
    if { [hasaccess $nick "cwcomments"] } {
        set arg [getargs $arg 1]
        if { [llength $arg] < 1 || ![string is integer [lindex $arg 0]] } { 
            luvnotc $nick "cwcomments" "syntax: [gethelpsyntax cwcomments]"
        } else {
            set id [lindex $arg 0]
            set db [getdb]
            set query [mysqlsel $db "select opponent from matches where id = '$id'" -flatlist]
            if { [llength $query] == 0 } {
                luvmsg $chan "cwcomments" "No CW with that id."
            } else {
                set opponent [lindex $query 0]
                set reportauthor [lindex $query 1]
                set report [lindex $query 2]
                set query [mysqlsel $db "select name,comment from matchcomments where matchid = '$id' order by date" -list]
                if { [llength $query] > 0 } {
                    luvmsg $chan "cwcomments" "The match between $mytag and $opponent (id #$id) has these comments:"
                    foreach comment $query {
                        set msg [lindex $comment 1]
                        set author [lindex $comment 0]
                        luvmsg $chan "cwcomments" "$msg - by $author"
                    }
                } else {
                    luvmsg $chan "cwcomments" "The match between $mytag and $opponent (id #$id) has \2no\2 comments."
                }
            }
        }
    }
}

proc sqladdwarcomment { nick uhost hand chan arg } {
    global pchan privchan
    if { [hasaccess $nick "addcomment"] } {
        set arg [getargs $arg 2]
        if { [llength $arg] < 2 || ![string is integer [lindex $arg 0]] } { 
            luvnotc $nick "addcomment" "syntax: [gethelpsyntax addcomment]"
        } else {
            set id [lindex $arg 0]
            set db [getdb]
            set query [mysqlsel $db "select opponent from matches where id = '$id'" -flatlist]
            if { [llength $query] == 0 } {
                luvmsg $chan "addcomment" "No CW with that id."
            } else {
                set author [translateirc $nick $db ]
                set date [clock seconds]
                set msg [lindex $arg 1]

                mysqlexec $db "insert into matchcomments (matchid, date, name, comment) values ('$id', '$date', '[mysqlescape $author]', '[mysqlescape $msg]')"

                if { $chan == $privchan } {
                    reportcomment $pchan [lindex $query 0] $id $msg $author
                } else {
                    reportcomment $privchan [lindex $query 0] $id $msg $author
                }

                luvmsg $chan "addcomment" "Thanks for the opinion. The comment was added to CW #$id vs [lindex $query 0]"
            }
        }
    }
}

proc sqladdwar {nick uhost hand chan arg} {
    global mytag pchan privchan cwadded_flag
    if { [hasaccess $nick "addcw"] } {
        set arg [getargs $arg 7]
        if {[llength $arg] < 7} {
            luvnotc $nick "addcw" "syntax: [gethelpsyntax addcw]";
        } else {
            set tag [lindex $arg 0]
            set esctag [mysqlescape $tag]

            set db [getdb]

            set tagselect [mysqlsel $db "select id from clans where tag collate utf8_bin like '$esctag'" -flatlist]
            if { [llength $tagselect] == 0 } {
                set tagselect [mysqlsel $db "select tag from clans where tag like '%$esctag%'" -flatlist]
                if { [llength $tagselect] > 0 } {
                    set tags [join $tagselect "\" \""]
                    set tags "\"$tags\""
                    luvmsg $chan "addcw" "No clan with tag $tag found. Did you mean any of $tags?"
                    luvmsg $chan "addcw" "Please correct the tag or add the clan in question to my database."
                } else {
                    luvmsg $chan "addcw" "No clan with tag $tag found. Please add this clan to my database."
                }
            } else {
                #there were a matching tag.

                set date [clock seconds]

                set map1 [mysqlescape [string tolower [lindex $arg 1]]]
                #first map score
                set maps11 [lindex $arg 2]
                set maps12 [lindex $arg 3]

                #second map name in lowercase
                set map2 [mysqlescape [string tolower [lindex $arg 4]]]
                #second map score
                set maps21 [lindex $arg 5]
                set maps22 [lindex $arg 6]

                if { ![string is integer $maps11] || ![string is integer $maps12] || ![string is integer $maps21] || ![string is integer $maps22] } {
                    luvnotc $nick "addcw" "syntax: [gethelpsyntax addcw]"
                } else {
                    #used for the channel reporting.
                    set scorel [expr $maps11 + $maps21]
                    set scoreo [expr $maps12 + $maps22]

                    mysqlexec $db "INSERT INTO matches (date, opponent) VALUES ('$date', '$esctag')"
                    set index [mysqlinsertid $db]

                    mysqlexec $db "INSERT INTO scores (matchid, map, ourscore, oppscore) VALUES ('$index', '$map1', '$maps11', '$maps12'), ('$index', '$map2', '$maps21', '$maps22')"

                    #output to the private channel
                    luvmsg $privchan "addcw" "(id #$index) $mytag vs $tag $scorel-$scoreo added to my database."
                    putlog "Added CW $index vs $tag ($scorel-$scoreo), by $nick"

                    #and the public
                    luvmsg $pchan "cw" "(id #$index) $mytag vs $tag $scorel-$scoreo"

                    checkclannumberofcws $db
                }
            }
        }
    }
}

proc sqldelwar {nick uhost hand chan arg} {
    global privchan

    if { [hasaccess $nick "delcw"] } {
        set arg [getargs $arg 1]
        if { [llength $arg] < 1 || ![string is integer [lindex $arg 0]] } {
            luvnotc $nick "delcw" "syntax: [gethelpsyntax delcw]"
        } else {

            set db [getdb]
            set matches [mysqlsel $db "SELECT opponent FROM matches WHERE id = '[lindex $arg 0]'" -flatlist]

            if { [llength $matches] == 0 } {
                luvmsg $chan "delcw" "No such id in my database."
            } else {
                mysqlexec $db "delete from matches where id = '[lindex $arg 0]'"
                mysqlexec $db "delete from matchfrags where matchid = '[lindex $arg 0]'"
                mysqlexec $db "delete from scores where matchid = '[lindex $arg 0]'"

                luvmsg $chan "delcw" "(id #[lindex $arg 0]) vs [lindex $matches 0] deleted"
            }
        }
    }
}

proc sqllast10wars { nick uhost hand chan arg } {
    global mytag privchan
    if { [hasaccess $nick "last10cws"] } {
        set arg [getargs $arg 2]
        set db [getdb]
        set wars [list]
        if { [llength $arg] > 1 } {
            set cleanmember [translateirc [lindex $arg 0] $db]
            set member [mysqlescape $cleanmember]
            set cleantag [lindex $arg 1]
            set tag [mysqlescape $cleantag]

            set wars [mysqlsel $db "select distinct id, opponent, ourscore, oppscore, date from (select matches.id as id, opponent, sum(ourscore) as ourscore, sum(oppscore) as oppscore, date from matches inner join scores on scores.matchid = matches.id group by matchid) as a inner join matchfrags on matchid = id where matchfrags.name collate utf8_bin like '${member}' and opponent collate utf8_bin like '${tag}' order by date desc limit 10" -list]
            if { [llength $wars] == 0 } {
                luvmsg $chan "last10cws" "No wars found where \2${cleanmember}\2 played against \2${cleantag}\2."
            }
        } elseif { [llength $arg] > 0 } {
            #there are arguments. Assume this argument is the tag of a clan and show the last cw vs this clan.
            set cleanmemberortag [translateirc [lindex $arg 0] $db]
            set memberortag [mysqlescape $cleanmemberortag]
            set cleantag [lindex $arg 0]
            set tag [mysqlescape $cleantag]

            set wars [mysqlsel $db "select distinct id, opponent, ourscore, oppscore, date from (select matches.id as id, opponent, sum(ourscore) as ourscore, sum(oppscore) as oppscore, date from matches inner join scores on scores.matchid = matches.id group by matchid) as a inner join matchfrags on matchid = id where matchfrags.name collate utf8_bin like '${memberortag}' order by date desc limit 10" -list]
            #set wars [mysqlsel $db "SELECT id,opponent,ourscore,oppscore,date FROM matches AS m INNER JOIN (SELECT matchid,sum(ourscore) as ourscore,sum(oppscore) as oppscore FROM scores GROUP BY matchid) AS s on matchid = id where like '%${memberortag}%' ORDER BY date desc limit 10" -list]

            if { [llength $wars] == 0 } {
                set wars [mysqlsel $db "SELECT id,opponent,ourscore,oppscore,date FROM matches AS m INNER JOIN (SELECT matchid,sum(ourscore) as ourscore,sum(oppscore) as oppscore FROM scores GROUP BY matchid) AS s on matchid = id where opponent collate utf8_bin like '$tag' ORDER BY date desc limit 10" -list]
                if { [llength $wars] == 0 } {
                    luvmsg $chan "last10cws" "Can't find any CWs against a clan with the tag \2${cleantag}\2"
                }
            }
        } else {
            set wars [mysqlsel $db "SELECT id,opponent,ourscore,oppscore,date FROM (SELECT id,opponent,date FROM matches ORDER BY date desc LIMIT 10) AS m INNER JOIN (SELECT matchid,sum(ourscore) as ourscore,sum(oppscore) as oppscore FROM scores GROUP BY matchid) AS s WHERE matchid = id ORDER BY date desc" -list]
            if { [llength $wars] == 0 } {
                luvmsg $chan "last10cws" "No wars found."
            }
        }

        if { [llength $wars] > 0 } {
            set ties 0
            set wins 0
            set losses 0
            foreach war $wars {
                luvmsg $chan "last10cws" "(id #[lindex $war 0]) [clock format [lindex $war 4] -format %d.%m.%Y], $mytag vs \2[lindex $war 1]\2 [lindex $war 2]-[lindex $war 3]"

                if {[lindex $war 2] > [lindex $war 3]} {
                    incr wins
                } elseif { [lindex $war 2] < [lindex $war 3]} {
                    incr losses
                } else { incr ties }
            }
            luvmsg $chan "last10cws" "$wins wins, $losses losses, and $ties ties."
        }
    }
}

proc sqlcwinfo {nick host hand chan arg} {
    global mytag privchan
    if { [hasaccess $nick "cwinfo"] } {
        set arg [getargs $arg 1]

        if { [llength $arg] < 1 || ![string is integer [lindex $arg 0]] } { 
            luvnotc $nick "cwinfo" "syntax: [gethelpsyntax cwinfo]"
        } else {

            set db [getdb]
            set info [mysqlsel $db "select matches.opponent, clans.name, matches.date, group_concat(distinct matchfrags.name separator ', ') from matches left join clans on clans.tag collate utf8_bin like matches.opponent left join matchfrags on matchfrags.matchid = matches.id where matches.id = '[lindex $arg 0]' group by matchid" -flatlist]

            if { [llength $info] > 0 } {

                set scores [mysqlsel $db "select ourscore,oppscore,map from scores where matchid = '[lindex $arg 0]'" -list]

                set ctag [lindex $info 0]
                set copponent [lindex $info 1]
                set matchdate [clock format [lindex $info 2] -format "%d.%m.%Y %H:%M"]
                set scorel 0
                set scoreo 0

                foreach score $scores {
                    set scorel [expr $scorel + [lindex $score 0]]
                    set scoreo [expr $scoreo + [lindex $score 1]]
                }

                luvmsg $chan "cwinfo" "(id #[lindex $arg 0]) $mytag vs $ctag ($copponent) $scorel-$scoreo on $matchdate with the lineup: [lindex $info 3]."
                foreach score $scores {
                    luvmsg $chan "cwinfo" "[lindex $score 0]-[lindex $score 1] on [lindex $score 2]."
                }
            } else {
                luvmsg $chan "cwinfo" "No CW with that id..."
            }
        }
    }
}

proc sqllastwars {nick uhost hand chan arg} {
    global mytag privchan
    if { [hasaccess $nick "lastcw"] } {
        set arg [getargs $arg 2]
        set db [getdb]
        set info [list]
        if { [llength $arg] > 1 } {
            set cleanmember [translateirc [lindex $arg 0] $db]
            set member [mysqlescape $cleanmember]
            set cleantag [lindex $arg 1]
            set tag [mysqlescape $cleantag]

            set info [mysqlsel $db "select matches.id, matches.opponent, clans.name, matches.date, group_concat(distinct matchfrags.name separator ', ') from matches left join clans on clans.tag collate utf8_bin like matches.opponent inner join (select matchid from matches inner join matchfrags on matches.id = matchid where name like '${member}' and opponent collate utf8_bin like '${tag}' order by date desc limit 1) as a on matches.id = a.matchid inner join matchfrags on matchfrags.matchid = matches.id group by matches.id" -flatlist]

        } elseif { [llength $arg] > 0 } {
            #there are arguments. Assume this argument is the tag of a clan and show the last cw vs this clan.
            set cleanmember [translateirc [lindex $arg 0] $db]
            set member [mysqlescape $cleanmember]
            set cleantag [lindex $arg 0]
            set tag [mysqlescape $cleantag]

            set info [mysqlsel $db "select matches.id, matches.opponent, clans.name, matches.date, group_concat(distinct matchfrags.name separator ', ') from matches left join clans on clans.tag collate utf8_bin like matches.opponent left join matchfrags on matchid = matches.id where clans.tag collate utf8_bin like '$tag' group by matchid order by date desc limit 1" -flatlist]
            if { [llength $info] == 0 } {
                set info [mysqlsel $db "select matches.id, matches.opponent, clans.name, matches.date, group_concat(distinct matchfrags.name separator ', ') from matches left join clans on clans.tag collate utf8_bin like matches.opponent inner join (select matchid from matches inner join matchfrags on matches.id = matchid where name like '${member}' order by date desc limit 1) as a on matches.id = a.matchid inner join matchfrags on matchfrags.matchid = matches.id group by matches.id" -flatlist]
            }
        } else {
            set info [mysqlsel $db "select matches.id, matches.opponent, clans.name, matches.date, group_concat(distinct matchfrags.name separator ', ') from matches left join clans on clans.tag collate utf8_bin like matches.opponent left join matchfrags on matchfrags.matchid = matches.id group by matches.id order by date desc limit 1" -flatlist]
        }
        if { [llength $info] > 0 } {
            set cid [lindex $info 0]
            set ctag [lindex $info 1]
            set copponent [lindex $info 2]
            set cdate [clock format [lindex $info 3] -format "%d.%m.%Y"]
            set clineup [lindex $info 4]

            set scores [mysqlsel $db "select map,ourscore,oppscore from scores where matchid = '$cid'" -list]

            if { [llength $scores] < 2 } {
                luvmsg $chan "lastcw" "(id #$cid) $mytag vs $cleantag ($copponent) on $cdate"
            } else {
                set lscore 0
                set oscore 0
                set maps [list]

                foreach score $scores {
                    set lscore [expr $lscore + [lindex $score 1]]
                    set oscore [expr $oscore + [lindex $score 2]]
                    lappend maps "[lindex $score 1]-[lindex $score 2] on \2[lindex $score 0]\2"
                }

                set mapstring [join $maps {, }]
                set commaindex [string last {,} $mapstring]
                if { $commaindex > -1 } {
                    set mapstring "[string range $mapstring 0 [expr $commaindex -1]] and[string range $mapstring [expr $commaindex +1] end]"
                }
                luvmsg $chan "lastcw" "(id #$cid) $cdate, $mytag vs \2$ctag\2 $lscore-$oscore with the lineup: ${clineup}. ${mapstring}."
            }
        } elseif {[llength $arg] > 1 } {
            luvmsg $chan "lastcw" "Can't find a match against the clan \2${cleantag}\2 where \2${cleanmember}\2 played."
        } elseif {[llength $arg] > 0 } {
            luvmsg $chan "lastcw" "Can't find a match against a clan with the tag $cleantag"
        } else {
            luvmsg $chan "lastcw" "Can't find any CWs :<"
        }
    }
}

proc fragstats { nick host hand chan arg } {
    global myprefix
    if { [hasaccess $nick "fragstats"] } {
        set arg [getargs $arg 2]
        set db [getdb]

        if { [llength $arg] == 0 } {
            luvnotc $nick "fragstats" "syntax: [gethelpsyntax fragstats]"
        } elseif { [llength $arg] == 1 } {
            set cleanmemberormap [translateirc [lindex $arg 0] $db]
            set memberormap [mysqlescape $cleanmemberormap]

            set frags [mysqlsel $db "select map, avgfrags, name, mapcount from (select map, avg(frags) as avgfrags, count(map) as mapcount, members.name as name from scores inner join matchfrags on scoreid = scores.id inner join memberalias on memberalias.name like matchfrags.name inner join members on memberid = members.id where members.name like '$memberormap' group by map) as a where mapcount > 2 order by avgfrags desc limit 5" -list]
            set titlestr "Highest average frags for ${myprefix} ${cleanmemberormap} for maps played 3 times or more:"

            if { [llength $frags] == 0 } {
                set frags [mysqlsel $db "select name, avgfrags, map, mapcount from (select map, avg(frags) as avgfrags, count(map) as mapcount, members.name as name from scores inner join matchfrags on scoreid = scores.id inner join memberalias on memberalias.name like matchfrags.name inner join members on memberid = members.id where map like '$memberormap' group by members.name) as a order by avgfrags desc limit 5" -list]
                set titlestr "Highest average frags for map ${cleanmemberormap}:"
            }

            if { [llength $frags] != 0 } {
                luvmsg $chan "fragstats" "$titlestr"
                foreach frag $frags {
                    luvmsg $chan "fragstats" "[lindex $frag 0] [format {%.1f} [lindex $frag 1]] frags average (played [lindex $frag 3] times)"
                }
            } else {
                luvmsg $chan "fragstats" "No such ${myprefix} or map found: $cleanmemberormap"
            }
        } else {
            set cleanmember [translateirc [lindex $arg 0] $db]
            set member [mysqlescape $cleanmember]
            set cleanmap [translateirc [lindex $arg 1] $db]
            set map [mysqlescape $cleanmap]

            set frags [mysqlsel $db "select map, avgfrags, name, mapcount, maxfrags from (select map, avg(frags) as avgfrags, count(map) as mapcount, members.name as name, max(frags) as maxfrags from scores inner join matchfrags on scoreid = scores.id inner join memberalias on memberalias.name like matchfrags.name inner join members on memberid = members.id where map like '$map' and members.name like '$member' group by members.name) as a order by avgfrags desc limit 5" -flatlist]

            if { [llength $frags] > 0 } {
                luvmsg $chan "fragstats" "$cleanmember has gotten an average of [format {%.1f} [lindex $frags 1]] and a max of [lindex $frags 4] frags on ${cleanmap} (played [lindex $frags 3] times)"
            } else {
                luvmsg $chan "fragstats" "No stats found for $cleanmember on $cleanmap."
            }
        }
    }
}

proc sqlmapstats { nick host hand chan arg } {
    global mytag privchan myprefix
    if { [hasaccess $nick "mapstats"] } {
        set arg [getargs $arg 2]
        set db [getdb]
        set scores1 [list]
        set scores2 [list]
        set scores [list]
        set scorestext ""

        if { [llength $arg] > 0 } {
            if { [llength $arg] == 1 } {
                set cleanmemberormap [translateirc [lindex $arg 0] $db]
                set memberormap [mysqlescape $cleanmemberormap]
 
                set scores1 [mysqlsel $db "select map, c,w,w/c*100 as wproc,t,t/c*100,l,l/c*100 from (select map,sum(ourscore > oppscore) as w, sum(oppscore=ourscore) as t, sum(ourscore < oppscore) as l, count(1) as c from scores inner join matchfrags on matchfrags.scoreid = scores.id inner join memberalias on memberalias.name collate utf8_bin like matchfrags.name inner join members on members.id = memberalias.memberid where members.name like '${memberormap}' group by map order by map) as m where c > 5 order by wproc desc limit 5" -list]
                set scores2 [mysqlsel $db "select map, c,w,w/c*100,t,t/c*100,l,l/c*100 as lproc from (select map,sum(ourscore > oppscore) as w, sum(oppscore=ourscore) as t, sum(ourscore < oppscore) as l, count(1) as c from scores inner join matchfrags on matchfrags.scoreid = scores.id inner join memberalias on memberalias.name collate utf8_bin like matchfrags.name inner join members on members.id = memberalias.memberid where members.name like '${memberormap}' group by map order by map) as m where c > 5 order by lproc desc limit 5" -list]
                if { [llength $scores1] == 0 } {
                    set scores [mysqlsel $db "select s.map,sum(s.ourscore > s.oppscore), sum(s.oppscore=s.ourscore), sum(s.ourscore < s.oppscore), count(1) from scores as s inner join matches as m on m.id = s.matchid where s.map like '$memberormap' group by map" -flatlist]
                    if { [llength $scores] > 0 && [lindex $scores 4] > 0} {
                        set scorestext "$mytag has played $memberormap"
                    } else {
                        set scorestext "$mytag hasn't played $memberormap."
                    }
                } else {
                    luvmsg $chan "mapstats" "Mapstats for ${myprefix} \2$cleanmemberormap\2:"
                }
            } else {
                set mapname [lindex $arg 0]
                set cleanmemberoropp [translateirc [lindex $arg 1] $db]
                set memberoropp [mysqlescape $cleanmemberoropp]

                set scores [mysqlsel $db "select map,sum(ourscore > oppscore), sum(oppscore=ourscore), sum(ourscore < oppscore), count(1) from scores inner join matchfrags on scores.id = matchfrags.scoreid inner join memberalias on memberalias.name collate utf8_bin like matchfrags.name inner join members on members.id = memberalias.memberid where map like '[mysqlescape $mapname]' and members.name like '%${memberoropp}%' group by map" -flatlist]
                if { [llength $scores] == 0} {
                    set scores [mysqlsel $db "select s.map,sum(s.ourscore > s.oppscore), sum(s.oppscore=s.ourscore), sum(s.ourscore < s.oppscore), count(1) from scores as s inner join matches as m on m.id = s.matchid where s.map like '[mysqlescape $mapname]' and m.opponent collate utf8_bin like '$memberoropp' group by s.map" -flatlist]
                    if { [llength $scores] > 0 && [lindex $scores 4] > 0} {
                        set scorestext "$mytag has played $mapname against $cleanmemberoropp"
                    } else {
                        set scorestext "$mytag hasn't played $mapname against $cleanmemberoropp."
                    }
                } else {
                    set scorestext "$cleanmemberoropp has played $mapname"
                }
            }
        } else {
            set scores1 [mysqlsel $db "select map, c,w,w/c*100 as wproc,t,t/c*100 as tproc,l,l/c*100 from (select map,sum(ourscore > oppscore) as w, sum(oppscore=ourscore) as t, sum(ourscore < oppscore) as l, count(1) as c from scores group by map order by map) as m where c > 5 order by wproc desc, tproc desc limit 5" -list]
            set scores2 [mysqlsel $db "select map, c,w,w/c*100,t,t/c*100 as tproc,l,l/c*100 as lproc from (select map,sum(ourscore > oppscore) as w, sum(oppscore=ourscore) as t, sum(ourscore < oppscore) as l, count(1) as c from scores group by map order by map) as m where c > 5 order by lproc desc, tproc desc limit 5" -list]
        }


        if { [llength $scores] > 0 && [lindex $scores 4] > 0} {
            set wins [lindex $scores 1]
            set ties [lindex $scores 2]
            set losses [lindex $scores 3]
            set count [lindex $scores 4]

            set winproc [format "%.1f" [expr ($wins * 100.0) / $count ]]
            set lossproc [format "%.1f" [expr ($losses * 100.0) / $count]]
            set tieproc [format "%.1f" [expr ($ties * 100.0) / $count ]]

            luvmsg $chan "mapstats" "$scorestext $count times. $wins wins ($winproc%), $ties ties ($tieproc%), and $losses losses ($lossproc%)."

        } elseif { [llength $scores1] > 0 } {
            luvmsg $chan "mapstats" "Best 5:"
            foreach map $scores1 {
                luvmsg $chan "mapstats" "[lindex $map 0]: [lindex $map 2] wins ([format %.1f [lindex $map 3]]%), [lindex $map 4] ties ([format %.1f [lindex $map 5]]%), and [lindex $map 6] losses ([format %.1f [lindex $map 7]]%)"
            }
            luvmsg $chan "mapstats" "Worst 5:"
            foreach map $scores2 {
                luvmsg $chan "mapstats" "[lindex $map 0]: [lindex $map 2] wins ([format %.1f [lindex $map 3]]%), [lindex $map 4] ties ([format %.1f [lindex $map 5]]%), and [lindex $map 6] losses ([format %.1f [lindex $map 7]]%)"
            }
        } else {
            if { [llength $arg] > 0 } {
                if { $scorestext != "" } {
                    luvmsg $chan "mapstats" "$scorestext"
                } else {
                    luvmsg $chan "mapstats" "No mapstats found for the arguments \2[join $arg]\2"
                }
            } else {
                luvmsg $chan "mapstats" "No mapstats found!"
            }
        }
    }
}

proc sqlwarstats {nick uhost hand chan arg} {
    global mytag privchan
    if { [hasaccess $nick "cwstats"] } {
        set arg [split $arg]
        if { [llength $arg] > 0 } {
            cws $nick $uhost $hand $chan [join $arg]
        } else {
            set db [getdb]
            set wins [lindex [mysqlsel $db "select count(*) from (select sum(ourscore) as luv,sum(oppscore) as opp from scores group by matchid) as score where luv > opp" -flatlist] 0]
            set losses [lindex [mysqlsel $db "select count(*) from (select sum(ourscore) as luv,sum(oppscore) as opp from scores group by matchid) as score where luv < opp" -flatlist] 0]
            set ties [lindex [mysqlsel $db "select count(*) from (select sum(ourscore) as luv,sum(oppscore) as opp from scores group by matchid) as score where luv = opp" -flatlist] 0]
            set last100 [mysqlsel $db "select l,o from matches inner join (select matchid,sum(oppscore) as o, sum(ourscore) as l from scores group by matchid) as s on s.matchid = matches.id order by date desc limit 100" -list]

            set count [expr $wins + $losses + $ties]

            set winproc [format "%.1f" [expr ($wins * 100.0) / $count ]]
            set lossproc [format "%.1f" [expr ($losses * 100.0) / $count]]
            set tieproc [format "%.1f" [expr ($ties * 100.0) / $count ]]

            luvmsg $chan "cwstats" "$mytag has played $count CWs. $wins wins ($winproc%), $ties ties ($tieproc%), and $losses losses ($lossproc%)."

            set w 0
            set l 0
            set t 0

            foreach last $last100 {
                if { [lindex $last 0] > [lindex $last 1] } {
                    incr w
                } elseif { [lindex $last 0] < [lindex $last 1] } {
                    incr l
                } else {
                    incr t
                }
            }
            luvmsg $chan "cwstats" "The stats for the last 100 CWs are: $w wins, $t ties, and $l losses."
        }
    }
}

proc cws {nick uhost hand chan arg} {
    global privchan
    if { [hasaccess $nick "cws"] } {
        set arg [getargs $arg 2]

        if {[llength $arg] == 0} {
            sqlwarstats $nick $uhost $hand $chan [join $arg]
        } else {

            set db [getdb]

            set clantag [mysqlescape [lindex $arg 0]]

            set wars [list]
            set member ""
            if { [llength $arg] > 1 } {
                set member [translateirc [lindex $arg 1] $db]
                set wars [mysqlsel $db "select distinct ourscore, oppscore, opponent, d.id from (select sum(scores.ourscore) as ourscore, sum(scores.oppscore) as oppscore, matches.opponent as opponent, matches.id as id from scores inner join matches on matches.id = scores.matchid group by scores.matchid) as d inner join matchfrags on matchfrags.matchid = d.id inner join memberalias on memberalias.name collate utf8_bin like matchfrags.name inner join members on memberalias.memberid = members.id where opponent collate utf8_bin like '$clantag' and members.name collate utf8_bin like '[mysqlescape $member]'" -list]
            } else {
                set wars [mysqlsel $db "select * from (select sum(scores.ourscore), sum(scores.oppscore), matches.opponent from scores inner join matches where matches.id = scores.matchid group by scores.matchid) as d where opponent collate utf8_bin like '$clantag'" -list]
            }
            set matches [llength $wars]

            if { $matches == 0 } {
                if { [llength $arg] > 1 } {
                    luvmsg $chan "cws" "$member hasn't played any CWs against \2[lindex $arg 0]\2."
                } else {
                    luvmsg $chan "cws" "No CWs played against \2[lindex $arg 0]\2."
                }
            } else {
                set losses 0
                set wins 0
                set ties 0

                for { set i 0 } { $i < $matches } { incr i } {
                    set ourscore [lindex [lindex $wars $i] 0]
                    set opscore [lindex [lindex $wars $i] 1]
                    if { $ourscore > $opscore } {
                        incr wins
                    } elseif { $ourscore < $opscore } {
                        incr losses
                    } else { incr ties }
                }

                set cname [join [mysqlsel $db "select name from clans where tag collate utf8_bin like '$clantag' limit 1" -flatlist ]]
                set winproc [format "%.1f" [expr ($wins * 100.0) / $matches ]]
                set lossproc [format "%.1f" [expr ($losses * 100.0) / $matches]]
                set tieproc [format "%.1f" [expr ($ties * 100.0) / $matches ]]

                set ggbg [mysqlsel $db "select count(goodgames.name) - count(badgames.name) from matches left join goodgames on goodgames.matchid = matches.id left join badgames on badgames.matchid = matches.id where opponent collate utf8_bin like '$clantag' group by matches.id" -list]

                set ggs 0
                set bgs 0

                foreach game $ggbg {
                    if { [lindex $game 0] > 0 } {
                        incr ggs
                    } elseif { [lindex $game 0] < 0 } {
                        incr bgs
                    }
                }

                set ggbgratio [getggbgratio [lindex $arg 0]]


                if { [llength $arg] > 1 } {
                    luvmsg $chan "cws" "$member has played $matches CWs played against $cname ([lindex $arg 0])"
                    luvmsg $chan "cws" "$wins wins ($winproc%), $ties ties ($tieproc%), and $losses losses ($lossproc%). $ggs GGs, $bgs BGs and a GG/BG ratio of $ggbgratio"
                } else {
                    luvmsg $chan "cws" "$matches CWs played against $cname ([lindex $arg 0])"
                    luvmsg $chan "cws" "$wins wins ($winproc%), $ties ties ($tieproc%), and $losses losses ($lossproc%). $ggs GGs, $bgs BGs and a GG/BG ratio of $ggbgratio"
                }
            }
        }
    }
}

proc addserver { nick uhost hand chan arg } {
    global privchan
    if { [hasaccess $nick "addserver"] } {
        set arg [getargs $arg 2]
        if { [llength $arg] < 2 || ![regexp "^\[0-9a-zA-Z.-\]+:\[0-9\]+$" [lindex $arg 0]] || ![regexp "^(clan|pub)$" [lindex $arg 1]] } {
            luvnotc $nick "addserver" "syntax: [gethelpsyntax addserver]"
        } else {
            set db [getdb]

            set already [mysqlsel $db "select id from servers where address like '[mysqlescape [lindex $arg 0]]'" -flatlist]
            if { [llength $already] > 0 } {
                luvmsg $chan "addserver" "Server [lindex $arg 0] is already in my database."
            } else {
                switch -- [lindex $arg 1] {
                    "pub" {
                        mysqlexec $db "insert into servers (address, type, available) values ('[mysqlescape [lindex $arg 0]]', 0, 1)"
                        luvmsg $chan "addserver" "Added the public server [lindex $arg 0] to my database."
                    }
                    "clan" {
                        mysqlexec $db "insert into servers (address, type, available) values ('[mysqlescape [lindex $arg 0]]', 1, 1)"
                        luvmsg $chan "addserver" "Added the clan server [lindex $arg 0] to my database."
                    }
                    default {
                        luvnotc $nick "addserver" "syntax: [gethelpsyntax addserver]"
                    }
                }
            }
        }
    }
}

