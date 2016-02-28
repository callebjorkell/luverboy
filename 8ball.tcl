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

bind pub -|- !8ball ballanswer

registerhelp "8ball" "Gives an 'Magic 8-ball' answer to a question" \
            "!8ball <question>" \
            "!8ball \"Is soppis gay?\"" 1 "pub" "general"

set ballanswers [list "As I see it, yes" "It is certain" "It is decidedly so" "Most likely" "Outlook good" "Signs point to yes" "Without a doubt" "Yes" "Yes - definitely" "You may rely on it" "Reply hazy, try again" "Ask again later" "Better not tell you now" "Cannot predict now" "Concentrate and ask again" "Don't count on it" "My reply is no" "My sources say no" "Outlook not so good" "Very doubtful"]

proc ballanswer { nick host hand chan arg } {
    global ballanswers
    if { [hasaccess $nick "8ball"] } {
        set arg [getargs $arg 1]
        if { [llength $arg] < 1 } {
            luvnotc $nick "8ball" "syntax: [gethelpsyntax 8ball]"
        } else {
            set id [ expr { int(rand()*[llength $ballanswers]) } ]
            luvmsg $chan "8ball" "[lindex $arg 0] - \2[lindex $ballanswers $id]\2"
        }
    }
}
