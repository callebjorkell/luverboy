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

exit "EDIT THE CONFIG!"

### General config.

#quakenet authentication. set auth to 0 if your bot doesn't have an authentification username, or 1 if you want the bot to auth.
set auth 0
set authuser "Username"
set authpass "Password"


#These settings all correspond to clan information:
# mypage   - This is the link to the clans homepage.
# mytag    - The own clan tag to display in messages (for example cwspy output)
# clanname - The clan's full name
# myprefix - The name of a member of the clan (in the case of love messengers, a member is a "luver").
#            It can also be set to something boring like "member" :)
set mypage "http://luvers.nrgizer.com"
set mytag "LM//"
set clanname "Love Messengers"
set myprefix "luver"


#The regexp for finding the name of a player in the clan (NEEDS TO INCLUDE THE CAPTURE GROUPS FOR THE NAMES!!)
#It is very important that this regexp is set correctly. If it is not, cwspy will not work. The example below
#will find all tags that start with LM// and possibly ends with <3 while capturing the name that would be in
#between these two elements.
set mytagregexp "LM//(.{1,}?)(?: <3)?"


#irc channels both a private channel and a public channel is needed. The private channel should be a channel that only
#members of the clan has access to. A password protected channel is recomended.
set pchan "#lovemessengers"
set privchan "#privpriv"


#SQL config. Should be pretty self-explanatory.
set dbhost "localhost"
set dbuser ""
set dbpass ""
set dbname ""


#Nicks to ignore when highlighting.
set ignorenicks [list "L" "Q"]


#cwspy stuff:
# cwwatchrounds  - the number of rounds that are watched before it is decided what team is "our" team in a CW.
# cwchecktime    - the time in seconds between active CW queries. If this is set to, for example, 5, the server
#                  that hosts a clanmatch will be pinged every 5 seconds for stats. If this is set too high, the
#                  bot might miss the last round if the server is killed too fast. I've deemed 2 to be a good number here.
# maxtimeouts    - number of timeouts before the cwspy decides that the server was rebooted (a map ended) prevents
#                  false mapscore suggestions caused by UDP packet timeouts or packet loss. 3 should be enough.
# cwspymapexpire - the amount of seconds before a played map expires in the CWSPY system. Default = 1h. if a map
#                  score has been in the cwspyqueue longer than this, it will be deleted on the next check.
set cwwatchrounds 4
set cwchecktime 2
set maxtimeouts 3
set cwspymapexpire 3600


#max number of reminders any one luver can have activated. (all reminders are kept in memory only)
set maxremind 5


#the array of responses that the bot responds to an op with. (just for fun)
set opanswers [list "Affirmative, sir." "Yes my man!" "I do agree." "Yes, and remember to luuv." "Sure thing." "Yeah." "You are correct." "Yep." "Sure!" "Whatever you say!"]


#cache aliases for 20 minutes to lessen the sql burden.
set aliascachetime 1200


#maximum number of seconds a server can be down before it is deleted from the database. This is useful as waiting for downed servers can take up alot of time.
#This way a server is automatically deleted when it is no longer up.
#2592000 seconds = 30 days.
set maxserverdowntime 2592000


#the max number of quotes to keep in mind. Any member can save a quote for another member with !addquote if it is 
#input exactly as this person said it and if the bot still remembers the quote. By default the last 200 lines of
#irc chat is kept in memory, increase this if you want to be able to add older quotes. This will increase memory usage.
set maxquotes 200


#password hash salt. Can be set to anything, just used to increase password complexity, and make bruteforce of the hashes harder.
#Note that this won't affect anyone else, but if you check the passwords from somewhere else (like from a homepage) be sure
#to include the same hash there :)
set hashsalt "R44nDomSaLLT"


#the number of lines that the bot forwards to the private channel from any given person.
#note that this counter is reset every half hour.
set privspamlines 3


#these are the multipliers and the step by which the ggbg ratio is weighted. The ggbgmultiplier
#is applied to a match played today, and after this it is stepped down towards 1.0 with ggbgstep
#each day. You probably won't have to change this.
set ggbgmultiplier 2
set ggbgstep 0.002


#Flood protection. Set the flood limit to 0 if you don't want flood protection.
#  floodlimit - the maximum number of commands a single user can trigger, per floodtime
#  floodtime  - The timeperiod to check flood for.
#  bantime    - The ban time in seconds if the floodlimit is exceeded.
set floodlimit 4
set floodtime 25
set bantime 120


### YOU PROBABLY DO NOT NEED TO CHANGE THE STUFF BELOW!
set QSTAT ${username}/bin/qstat
set SED_BIN "/usr/bin/sed"
set cwsearchregexp "^cw|^\[\[:digit:\]\](on|o|vs|v)\[\[:digit:\]\]|^m(a|ä)(tch|ts|tsh|tz|tzi|zi|z)"

