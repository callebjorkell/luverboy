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


### VOTE SYSTEM

bind pub -|- !voteduration voteduration
bind pub -|- !addvote addvote
bind pub -|- !delvote delvote
bind pub -|- !closevote delvote
bind pub -|- !denyvote denyvote
bind pub -|- !votes listvotes
bind pub -|- !lastvote lastvote
bind pub -|- !votecomments votecomments
bind pub -|- !votesearch votesearch
bind pub -|- !vote pubdovote

registerhelp "addvote" "This command adds a vote to the voting system." \
            "!addvote <daysopen> <subject>" \
            "!addvote 2 \"Nisse is great\"" 3 "pub" "vote"
registerhelp "votes" "This command lists all open votes. If an id is specified that vote is shown, even if it is closed." \
            "!votes \[voteid\]" \
            "!votes" 3 "pub" "vote"
registerhelp "vote" "This casts your vote on the given ope n vote. This command can be sent as a private message. NOTE: You need ops in the private channel to be allowed to vote." \
            "!vote <voteid> <yes/no/dunno> \[comment\]" \
            "/msg $botnick !vote 4 yes This is a hell of a good player!" 3 "priv" "vote"
registerhelp "votecomments" "This shows the comments on a given vote." \
            "!votecomments <voteid>" \
            "!votecomments 12" 3 "pub" "vote"
registerhelp "votesearch" "This command searches all votes for a keyword, and prints them (at most 5). You can use * to match any string, and ? to match any character." \
            "!votesearch <searchstring>" \
            "!votesearch pono*trial" 3 "pub" "vote"
registerhelp "lastvote" "This shows the result and id of the last completed vote" \
            "!lastvote" \
            "!lastvote" 3 "pub" "vote"
registerhelp "closevote" "Closes the vote with the given id. NOTE: You must be the creator of the vote to close it. Synonymous with delvote." \
            "!closevote <voteid>" \
            "!closevote 1" 3 "pub" "vote"
registerhelp "delvote" "Synonymous with closevote. See help for closevote for more information." \
            "!delvote <vote>" \
            "!delvote 1" 3 "pub" "vote"
registerhelp "denyvote" "Denies a given ${myprefix} the right to vote on the given vote." \
            "!denyvote <voteid> <name/nick>" \
            "!denyvote 3 Poopy" 3 "pub" "vote"
registerhelp "voteduration" "Changes the duration of the specified vote. In the example below 2 days and 10 hours will be added to vote 19." \
            "!voteduration <voteid> <+-days>d \[hours\]h" \
            "!voteduration 19 +2d 10h" 3 "pub" "vote"


bind time - "20 * * * *" checkvotes
bind time - "00 * * * *" checkvotes
bind time - "40 * * * *" checkvotes


proc lastvote { nick host hand chan arg } {
    if { [hasaccess $nick "lastvote"] } {
        set db [getdb]
        set vote [mysqlsel $db "select subject,sum(vote like 'Yes'),sum(vote like 'No'), sum(vote like 'Dunno'), votes.id from votes left join votees on votes.id = voteid where date < [clock seconds] and printed = 1 group by votes.id order by date desc limit 1" -flatlist]
        if { [llength $vote] > 0 } {
            luvmsg $chan "lastvote" "(id #[lindex $vote 4]) \2[lindex $vote 0]\2 (Yes: [lindex $vote 1], No: [lindex $vote 2], Dunno: [lindex $vote 3])"
        } else {
            luvmsg $chan "lastvote" "I couldn't find any completed votes :<"
        }
    }
}


proc votecomments { nick host hand chan arg } {
    if { [hasaccess $nick "votecomments"] } {
        set arg [getargs $arg 1]
        if { [llength $arg] > 0 && [string is integer [lindex $arg 0]] } {
            set db [getdb]
            set comments [mysqlsel $db "select vote,comment from votees where comment not like '' and voteid = '[lindex $arg 0]' order by vote" -list]
            if { [llength $comments] > 0 } {
                set vote [mysqlsel $db "select subject,sum(vote like 'Yes'),sum(vote like 'No'), sum(vote like 'Dunno'), votes.id from votes left join votees on votes.id = voteid where votes.id = '[lindex $arg 0]' group by votes.id" -flatlist]
                luvmsg $chan "votecomments" "Comments for the vote (id #[lindex $vote 4]) \2[lindex $vote 0]\2 (Yes: [lindex $vote 1], No: [lindex $vote 2], Dunno: [lindex $vote 3])"
                foreach comment $comments {
                    luvmsg $chan "votecomments" "\2[lindex $comment 0]\2 - [lindex $comment 1]"
                }
            } else {
                luvmsg $chan "votecomments" "This vote has no comments..."
            }
        } else {
            luvnotc $nick "votecomments" "syntax: [gethelpsyntax votecomments]"
        }
    }
}


proc listvotes { nick host hand chan arg } {
    global privchan
    
    if { [hasaccess $nick "votes"] } {
        set db [getdb]
        set arg [getargs $arg 1]
        if { [llength $arg] > 0 } {
            set v [mysqlsel $db "select subject,date,sum(vote like 'Yes'),sum(vote like 'No'), sum(vote like 'Dunno'), votes.id, sum(comment not like '') from votes left join votees on votes.id = voteid where voteid = '[lindex $arg 0]' group by votes.id limit 1" -flatlist]
            if { [llength $v] > 0 } {
                set yes [lindex $v 2]
                set no [lindex $v 3]
                set dunno [lindex $v 4]
                set comments [lindex $v 6]

                if { $yes == "" } {
                    set yes 0
                }
                if { $no == "" } {
                    set no 0
                }
                if { $dunno == "" } {
                    set dunno 0
                }
                if { $comments == "" } {
                    set comments "0 comments"
                } elseif { $comments == 1 } {
                    set comments "1 comment"
                } else {
                    set comments "$comments comments"
                }
                set votedate [clock format [lindex $v 1] -format "%d.%m.%Y %H:%M"]
                set endstring "ends on"
                if { [lindex $v 1] < [clock seconds] } {
                    set endstring "ended on"
                }
                luvmsg $chan "votes" "(id #[lindex $v 5]) \2[lindex $v 0]\2 $endstring $votedate - $comments - Yes: $yes, No: $no, Dunno: $dunno"
            } else {
                luvmsg $chan "votes" "No vote with that id..."
            } 
        } else {
            set votes [mysqlsel $db "select subject,date,sum(vote like 'Yes'),sum(vote like 'No'), sum(vote like 'Dunno'), votes.id, sum(comment not like '') from votes left join votees on votes.id = voteid where date > [clock seconds] group by votes.id order by votes.date" -list]
            if { [llength $votes] > 0 } {
                luvmsg $chan "votes" "Open votes:"
                foreach v $votes {
                    set yes [lindex $v 2]
                    set no [lindex $v 3]
                    set dunno [lindex $v 4]
                    set comments [lindex $v 6]

                    if { $yes == "" } {
                        set yes 0
                    }
                    if { $no == "" } {
                        set no 0
                    }
                    if { $dunno == "" } {
                        set dunno 0
                    }
                    if { $comments == "" } {
                        set comments "0 comments"
                    } elseif { $comments == 1 } {
                        set comments "1 comment"
                    } else {
                        set comments "$comments comments"
                    }
                    set votedate [clock format [lindex $v 1] -format "%d.%m.%Y %H:%M"]
                    luvmsg $chan "votes" "(id #[lindex $v 5]) \2[lindex $v 0]\2 ends on $votedate - $comments - Yes: $yes, No: $no, Dunno: $dunno"
                }
            } else {
                luvmsg $chan "votes" "No open votes..."
            }
        }
    }
}

proc votesearch { nick host hand chan arg } {
    global privchan

    if { [hasaccess $nick "votesearch"] } {
        set arg [getargs $arg 1]
        if { [llength $arg] > 0 } {
            set searchstr [lindex $arg 0]
            set mysqlsearchstr [string map {* % ? _} [mysqlescape [string map {% \\% _ \\_} $searchstr]]]
            set db [getdb]

            set votes [mysqlsel $db "select subject,date,sum(vote like 'Yes'),sum(vote like 'No'), sum(vote like 'Dunno'), votes.id from votes left join votees on votes.id = voteid where subject like '%${mysqlsearchstr}%' group by votes.id order by votes.date desc" -list]

            if { [llength $votes] > 0 } {

                luvmsg $chan "votesearch" "\2$searchstr\2 matches:"
                set count 0
                foreach vote $votes {
                    incr count
                    if { $count > 5 } {
                        break;
                    }
                    set votedate [clock format [lindex $vote 1] -format "%d.%m.%Y %H:%M"]
                    if { [lindex $vote 1] > [clock seconds] } {
                        luvmsg $chan "votesearch" "(id #[lindex $vote 5]) \2[lindex $vote 0]\2 ends on $votedate - Yes: [lindex $vote 2], No: [lindex $vote 3], Dunno: [lindex $vote 4]"
                    } else {
                        luvmsg $chan "votesearch" "(id #[lindex $vote 5]) \2[lindex $vote 0]\2 ended on $votedate - Yes: [lindex $vote 2], No: [lindex $vote 3], Dunno: [lindex $vote 4]"
                    }
                }

                if { [llength $votes] > 5 } {
                    luvmsg $chan "votesearch" "... and \2[expr [llength $votes] - 5]\2 more votes."
                }

            } else {
                luvmsg $chan "votesearch" "There are no votes matching \2$searchstr\2."
            }
        } else {
            luvnotc $nick "votesearch" "syntax: [gethelpsyntax votesearch]"
        }
    }
}

proc delvote { nick host hand chan arg } {
    global privchan

    if { [hasaccess $nick "closevote"] } {
        set arg [getargs $arg 1]
        if { [llength $arg] < 1 || ![string is integer [lindex $arg 0]] } {
            luvnotc $nick "closevote" "syntax: [gethelpsyntax delvote]"
        } else {
            set db [getdb]
            set membername [mysqlescape [translateirc $nick $db]]

            set vote [mysqlsel $db "select subject,owner,sum(vote like 'Yes'),sum(vote like 'No'), sum(vote like 'Dunno') from votes left join votees on votes.id = voteid where votes.id = '[lindex $arg 0]' group by votes.id" -flatlist]
            if { [llength $vote] < 1 } {
                luvmsg $chan "closevote" "No vote with that id..."
            } else {
                if { [string match $membername [lindex $vote 1]] || ([validuser $hand] && [matchattr $hand "m"]) } {
                    mysqlexec $db "update votes set date = [clock seconds], printed = 1 where id = '[lindex $arg 0]'"
                    luvmsg $chan "closevote" "The vote \2[lindex $vote 0]\2 was closed... The votes were Yes: [lindex $vote 2], No: [lindex $vote 3], Dunno: [lindex $vote 4]"
                } else {
                    luvmsg $chan "closevote" "You are not the owner of this vote..."
                }
            }
        }
    }
}

proc voteduration { nick host hand chan arg } {
    global privchan

    if { [hasaccess $nick "voteduration"] } {
        set arg [getargs $arg 3]
        if { [llength $arg] < 2 || ![string is integer [lindex $arg 0]] || ![regexp -- {^(-|\+)[0-9]+d} [lindex $arg 1] match] || ([llength $arg] > 2 && ![regexp -- {[0-9]+h} [lindex $arg 2] match])} {
            luvnotc $nick "voteduration" "syntax: [gethelpsyntax voteduration]"
        } else {
            set db [getdb]
            set membername [mysqlescape [translateirc $nick $db]]

            set vote [mysqlsel $db "select subject,owner,date from votes where id = '[lindex $arg 0]'" -flatlist]
            if { [llength $vote] < 1 } {
                luvmsg $chan "voteduration" "No vote with that id..."
            } elseif { [lindex $vote 2] < [clock seconds] } {
                luvmsg $chan "voteduration" "The vote \2[lindex $vote 0]\" has already been closed."
            } else {
                if { [string match $membername [lindex $vote 1]] } {
                    set direction 1
                    if { [string index [lindex $arg 1] 0] == "-" } {
                        set direction "-1"
                    }

                    set days [string trim [lindex $arg 1] "d-+"]
                    set hours 0
                    if { [llength $arg] > 2} {
                        set hours [string trim [lindex $arg 2] "h"]
                    }

                    if { ![string is integer $days] || ![string is integer $hours] } {
                        luvmsg $chan "voteduration" "Invalid time change syntax. Please correct the syntax into the format +-\2days\2d \2hours\2h."
                    } else {
                        set change [expr (($days * 60 * 60 * 24) + ($hours * 60 * 60)) * $direction]
                        set date [expr [lindex $vote 2] + $change]
                        mysqlexec $db "update votes set date = '$date' where id = '[lindex $arg 0]'"
                        luvmsg $chan "voteduration" "The vote \2[lindex $vote 0]\2 was changed to end at [clock format $date -format {%d.%m.%Y %H:%M}]"
                    }
                } else {
                    luvmsg $chan "voteduration" "You are not the owner of this vote..."
                }
            }
        }
    }
}

proc denyvote { nick host hand chan arg } {
    global privchan myprefix

    if { [hasaccess $nick "denyvote"] } {
        set arg [getargs $arg 2]
        if { [llength $arg] < 2 || ![string is integer [lindex $arg 0]] } {
            luvnotc $nick "denyvote" "syntax: [gethelpsyntax denyvote]"
        } else {
            set db [getdb]
            set membername [mysqlescape [translateirc $nick $db]]

            set vote [mysqlsel $db "select subject,owner from votes where id = '[lindex $arg 0]'" -flatlist]
            if { [llength $vote] < 1 } {
                luvmsg $chan "denyvote" "No vote with that id..."
            } else {
                if { [string match $membername [lindex $vote 1]] } {
                    set denieduser_name [translateirc [lindex $arg 1] $db]
                    set denieduser [mysqlsel $db "select id from members where name like '[mysqlescape $denieduser_name]'" -flatlist]
                    if { [llength $denieduser] > 0 } {
                        set already [mysqlsel $db "select denied from votees where voteid = '[lindex $arg 0]'and memberid = '[lindex $denieduser 0]'" -flatlist]
                        if { [llength $already] < 1} {
                            mysqlexec $db "insert into votees (memberid, voteid, denied, vote) values ('[lindex $denieduser 0]', '[lindex $arg 0]', '1', '')"
                            luvmsg $chan "denyvote" "$denieduser_name was denied the right to vote on \2[lindex $vote 0]\2 (id #[lindex $arg 0])..."
                        } else {
                            if { [lindex $already 0] == 0 } {
                                luvmsg $chan "denyvote" "$denieduser_name has already voted on \2[lindex $vote 0]\2 (id #[lindex $arg 0])..."
                            } else {
                                luvmsg $chan "denyvote" "$denieduser_name is already denied the right to vote on \2[lindex $vote 0]\2 (id #[lindex $arg 0])..."
                            }
                        }
                    } else {
                        luvmsg $chan "denyvote" "I don't know who that ${myprefix} is :<..."
                    }
                } else {
                    luvmsg $chan "denyvote" "You are not the owner of this vote..."
                }
            }
        }
    }
}

proc addvote { nick host hand chan arg } {
    global privchan
    
    if { [hasaccess $nick "addvote"] } {
        set arg [getargs $arg 2]
        if { [llength $arg] < 2 || ![string is integer [lindex $arg 0]] } {
            luvnotc $nick "addvote" "syntax: [gethelpsyntax addvote]"
        } else {
            set db [getdb]
            set membername [mysqlescape [translateirc $nick $db]]
            set subject [mysqlescape [lindex $arg 1]]
            set duedate [expr [lindex $arg 0] * 24 * 60 * 60 + [clock seconds]]

            mysqlexec $db "insert into votes (subject, owner, date) values ('$subject', '$membername', '$duedate')"
            set index [mysqlinsertid $db]
            luvmsg $chan "addvote" "Vote added to the voting system with id $index."
        }
    }
}

proc pubdovote { nick host hand chan arg } {
    dovote $nick $host $hand $arg
}

proc dovote { nick host hand arg } {
    global pchan privchan
    set arg [getargs $arg 3]
    if { [hasaccess $nick "vote"] } {
        if { [llength $arg] > 1 && [string is integer [lindex $arg 0]] } {
            set db [getdb]

            set membername [mysqlescape [translateirc $nick $db]]
            set member [mysqlsel $db "select id,status from members where name like '$membername'" -flatlist]
            if { [llength $member] < 1 } {
                luvmsg $nick "vote" "Do I know you?"
            } elseif { [lindex $member 1] != 0 } {
                luvmsg $nick "vote" "Trials are not allowed to vote :<"
            } else {
                set voted [mysqlsel $db "select id,denied,vote from votees where voteid = '[lindex $arg 0]' and memberid = '[lindex $member 0]'" -flatlist]
                if { [llength $voted] > 0 && [lindex $voted 1] == 1 } {
                    luvmsg $nick "vote" "You are not allowed to vote on this vote."
                } else {
                    set votestring ""
                    switch -regexp -- [lindex $arg 1] {
                        ^\[Yy\](\[eE\]\[Ss\])?\$      { set votestring "Yes" }
                        ^\[Nn\]\[Oo\]?\$         { set votestring "No" }
                        ^\[Dd\](\[Uu\]\[Nn\]\[Nn\]\[oO\])?\$    { set votestring "Dunno" }
                    }
                    if { $votestring != "" } {
                        set vote [mysqlsel $db "select subject,date,id from votes where id = '[lindex $arg 0]'" -flatlist]
                        if { [llength $vote] < 1 } {
                            luvmsg $nick "vote" "I can't find a vote with that id..."
                        } else {
                            if { [lindex $vote 1] < [clock seconds] } {
                                luvmsg $nick "vote" "You cannot vote on this anymore, since the vote has been closed already."
                            } else {
                                set comment ""
                                set printstring ""
                                if { [llength $arg] > 2 } {
                                    set comment [lindex $arg 2]
                                }
                                if { [llength $voted] > 0 } {
                                    # already voted, just change the vote.
                                    if { [string match [lindex $voted 2] $votestring] } {
                                        luvmsg $nick "vote" "You already voted $votestring on this vote. Keeping it as it is."
                                        set printstring ""
                                    } else {
                                        mysqlexec $db "update votees set vote = '$votestring', comment = '$comment' where memberid = '[lindex $member 0]' and voteid = '[lindex $arg 0]'"
                                        luvmsg $nick "vote" "I changed your vote to $votestring"
                                        set printstring "A \2[lindex $voted 2]\2 vote was changed to a \2$votestring\2 vote"
                                    }
                                } else {
                                    mysqlexec $db "insert into votees (memberid, voteid, vote, comment) values ('[lindex $member 0]', '[lindex $arg 0]', '$votestring', '$comment')"
                                    luvmsg $nick "vote" "I registered your vote... ($votestring)"
                                    set printstring "The vote was \2$votestring\2"
                                }

                                if { $printstring != "" } {
                                    set status [mysqlsel $db "select sum(vote like 'Yes'), sum(vote like 'No'), sum(vote like 'Dunno') from votees where voteid = '[lindex $vote 2]'" -flatlist]

                                    set votedate [clock format [lindex $vote 1] -format "%d.%m.%Y %H:%M"]
                                    luvmsg $privchan "vote" "\2updated!\2 (id #[lindex $vote 2]) \2[lindex $vote 0]\2 ends on $votedate - Yes: [lindex $status 0], No: [lindex $status 1], Dunno: [lindex $status 2]"
                                    if { $comment == "" } {
                                        luvmsg $privchan "vote" "${printstring}."
                                    } else {
                                        luvmsg $privchan "vote" "$printstring with the comment: $comment"
                                    }
                                }
                            }
                        }
                    } else {
                        luvmsg $nick "vote" "syntax: [gethelpsyntax vote]"
                    }
                }
            }
        } else {
            luvmsg $nick "vote" "syntax: [gethelpsyntax vote]"
        }
    }
}

proc checkvotes { min hour day month year } {
    global privchan

    set now [clock seconds]

    set db [getdb]
    #print expired votes that haven't been printed yet.
    set expired [mysqlsel $db "select votes.id,subject,sum(vote like 'Yes'),sum(vote like 'No'), sum(vote like 'Dunno') from votes left join votees on votes.id = voteid where date <= $now and printed = 0 group by votes.id" -list]
    foreach e $expired {
        mysqlexec $db "update votes set printed = 1 where id = '[lindex $e 0]'"
        set yes [lindex $e 2]
        set no [lindex $e 3]
        set dunno [lindex $e 4]

        set winner "Yes"
        if { $no > $yes } {
            set winner "No"
        } elseif { $no == $yes } {
            set winner "Dunno"
        }
        luvmsg $privchan "vote" "\2Vote closed!\2 The vote on \2[lindex $e 1]\2 is now closed. Results - Yes: $yes, No: $no, Dunno: $dunno"
        luvmsg $privchan "vote" "In conclusion, the winner is the \2$winner\2 side!"
    }
    
    #check if there are votes that will expire soon

    #fetch open votes.
    set votes [mysqlsel $db "select subject,date,sum(vote like 'Yes'),sum(vote like 'No'), sum(vote like 'Dunno'),votes.id from votes left join votees on votes.id = voteid where date > $now group by votes.id" -list]
    foreach v $votes {
        #iterations are the number of 20 minute blocks until the vote expires.
        set minutestoexpire [expr int(floor(( [lindex $v 1] - $now ) / 60))]
        set iterations [expr int(floor($minutestoexpire / 20))]
        if { $iterations < 3 || $iterations == 8 || $iterations == 24 } {
            set notvotednicks [list]
            set notvoted [mysqlsel $db "select members.id,members.name,ircnicks.nick from members inner join ircnicks on members.id = ircnicks.memberid where members.id not in (select memberid from votees where voteid = '[lindex $v 5]') and status = 0 order by members.id" -list]
            set lastadded -1
            for {set i 0} {$i < [llength $notvoted]} {incr i} {
                set memberid [lindex [lindex $notvoted $i] 0]
                if { $lastadded != $memberid } {
                    set nick [lindex [lindex $notvoted $i] 2]
                    if { [onchan $nick $privchan] } {
                        lappend notvotednicks $nick
                        set lastadded $memberid
                    } else {
                        if { $i == [expr [llength $notvoted] - 1] || $memberid != [lindex [lindex $notvoted [expr $i + 1]] 0] } {
                            #We don't have any more names in the list (or no more nicks for this memberid)
                            lappend notvotednicks [lindex [lindex $notvoted $i] 1]
                            set lastadded $memberid
                        }
                    }
                }
            }
            set timeleft ""
            if { $minutestoexpire >= 60 } {
                set timeleft "[expr int(floor($minutestoexpire / 60))]h [expr int($minutestoexpire % 60)]min"
            } else {
                set timeleft "$minutestoexpire"
                append timeleft "min"
            }
            #set votedate [clock format [lindex $v 1] -format "%d.%m.%Y %H:%M"]
            luvmsg $privchan "vote" "\2soon closing\2 (id #[lindex $v 5]) \2[lindex $v 0]\2 ends in $timeleft - Yes: [lindex $v 2], No: [lindex $v 3], Dunno: [lindex $v 4]"
            luvmsg $privchan "vote" "These have not yet voted: [join $notvotednicks {, }]"
        }
    }
}
