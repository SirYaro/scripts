#! /bin/bash
#
# mp3links.sh - mp3 linker script by eur0dance
# Version 1.2.1
#
# -------------------------------------------------------------------------
# This is a script by eur0dance to create links to MP3 releases according
# to genres, artist names and groups that made those release.
# This script is based on Jehsom's mp3 linker script called mp3links.cron
# and the following header was left the same as it was in the original script.
# -------------------------------------------------------------------------
# Jehsom's mp3 linker script - Indexes mp3 releases.
# Copyright (C) 2000 jehsom@usa.net
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
# -------------------------------------------------------------------------

# You must have mp3info 0.8.2 or greater, by Cedrec Tefft to link genres.
# If you don't have it, get it from my zipscript package, or from:
#   http://www.ibiblio.org/mp3info
# Note: you don't need gmp3info, only the mp3info.

# CHANGES:
# 1.1 - Script would make links in /glftpd/bin if any of the *_DIR settings
#       were commented out. This means /glftpd/bin would be deleted. So if
#       you're running a pre-1.1 version and you don't want one type of the
#       links, please upgrade asap! (Jehsom)
# 1.1.1 Fixed a couple misc quoting bugs (Jehsom)
# 1.2 - Doesn't remove the contents of the link dirs anymore, it removes
#       all the dead links and adds only the new links. This way the new
#       release will have a correct date which is useful when you want
#       to sort by date and see only the new release. (eur0dance)
# 1.2.1 - A little fix for some crontabs which don't find mp3info binary
#         through the path variable. (eur0dance)

# Put the full path to mp3info here if it's not in your $PATH.
mp3info=`which mp3info 2>/dev/null`  

# Wildcard expressions that match the names of all your release dirs.
# Edit these according to the way your site is set.
RLS_DIRS="
/home/yaro/Muzyka/All/*
/home/yaro/Muzyka/All2/*
/home/yaro/Muzyka/All3/*
"

# Where do you want the link trees to go? Set to "" or comment out to disable.
# Note: These dirs need to exist if you intend to use them.
ALPHA_DIR="/home/yaro/Muzyka/Sorted/by.artist"
GENRE_DIR="/home/yaro/Muzyka/Sorted/by.genre"
GROUP_DIR=""

#####################################################
############## You can ignore the rest ##############
#####################################################

function get_mp3info_path () {
        if [ -n $mp3info ]; then
                if [ -f /usr/local/bin/mp3info ]; then
                        mp3info="/usr/local/bin/mp3info"
                else
                        if [ -f /usr/bin/mp3info ]; then
                                mp3info="/usr/bin/mp3info"
                        else
                                if [ -f /usr/bin/mp3info ]; then
                                        mp3info="/bin/mp3info"
                                else
                                        if [ -f /glftpd/bin/mp3info ]; then
                                                mp3info="/glftpd/bin/mp3info"
                                        else
                                                if [ -f /jail/glftpd/bin/mp3info ]; then
                                                        mp3info="/jail/glftpd/bin/mp3info"
                                                fi
                                        fi
                                fi
                        fi
                fi
        fi
}

function link_alpha () {
    cd "$1" || return 1
    rlsdir="$PWD"
    base="$(basename "$PWD")"
    sortable="${base#(}"

    case $sortable in
        *NUKED*)
            return 0
            ;;
        [vV][aA][-_.]*|[vV]arious[-_.]*|[vV][_.][aA][.-_]*)
            letter="Various"
            ;;
        *)
            letter=$(echo ${base%${base#?}} | tr '[:lower:]' '[:upper:]')
            ;;
    esac

    [ -d "$ALPHA_DIR/$letter" ] || mkdir "$ALPHA_DIR/$letter"

    oIFS="$IFS" IFS="/" relpath=
    set -- $rlsdir
    for seg in $ALPHA_DIR; do
        case $relpath$seg in
             "$1") shift ;;
            *) relpath=../$relpath ;;
        esac
    done
    relpath="../$relpath$*" IFS="$oIFS"
    IFS="$oIFS"

    # A condition added by eur0dance
    if [ ! -e "$ALPHA_DIR/$letter/$base" ]; then
    	ln -s "$relpath/" "$ALPHA_DIR/$letter/$base"
    fi
    cd -
}

function link_genre () {
    cd "$1" || return 1
    rlsdir="$PWD"
    base="$(basename "$PWD")"

    case $base in *NUKED*) return 0 ;; esac

    mp3="$(echo *.[mM][pP]3 */*.[mM][pP]3 | cut -f1 -d ' ')"
    [ -f "$mp3" ] || return 1
    genre=$($mp3info -p "%g" $mp3 | tr -d '[:punct:]' | tr ' ' '_')
    [ -z "$genre" ] && genre="Unknown"

    [ -d "$GENRE_DIR/$genre" ] || mkdir "$GENRE_DIR/$genre"
    
    oIFS="$IFS" IFS="/" relpath=
    set -- $rlsdir
    for seg in $GENRE_DIR; do
        case $relpath$seg in
             "$1") shift ;;
            *) relpath=../$relpath ;;
        esac 
    done     
    relpath="../$relpath$*" IFS="$oIFS"
    IFS="$oIFS"

    # A condition added by eur0dance
    if [ ! -e "$GENRE_DIR/$genre/$base" ]; then
    	ln -s "$relpath/" "$GENRE_DIR/$genre/$base"
    fi
    cd -
}

function link_group () {
    cd "$1" || return 1
    rlsdir="$PWD"
    base="$(basename "$PWD")"

    case $base in
        *NUKED*)
            return 0
            ;;
        *)
            group=$(echo "${base##*-}" | tr '[:lower:]' '[:upper:]')
            ;;
    esac

    # In case the foler name was formatted improperly
    [ ${#group} -gt 15 ] && return 0

    group=${group#_}

    [ -d "$GROUP_DIR/$group" ] || mkdir "$GROUP_DIR/$group"

    oIFS="$IFS" IFS="/" relpath=
    set -- $rlsdir
    for seg in $GROUP_DIR; do
        case $relpath$seg in
             "$1") shift ;;
            *) relpath=../$relpath ;;
        esac
    done
    relpath="../$relpath$*" IFS="$oIFS"
    IFS="$oIFS"
    
    # A condition added by eur0dance
    if [ ! -e "$GROUP_DIR/$group/$base" ]; then
    	ln -s "$relpath/" "$GROUP_DIR/$group/$base"
    fi
    cd -
}

# Added by eur0dance
function check_dead_links () {
    curpos=`pwd`
    cd "$1" || return 1
    for i in *; do
         cd "$i" || continue
         for dir in *; do
                if [ -L "$dir" ]; then        
                        cd "$dir" >/dev/null 2>&1
                        res=$?
                        if [ $res -eq 0 ]; then
                                cd ..
                        else
                                rm -f -- "$dir"
                        fi
                fi
         done
         cd ..
    done
    cd $curpos                     
}

#### Main program body ****

allow_null_glob_expansion=1
shopt -s nullglob 2>/dev/null

# Added by eur0dance
get_mp3info_path

{ [ -n "$mp3info" ] && $mp3info 2>/dev/null | grep "Cedric Tefft" > /dev/null; } || {
    echo "Your mp3info binary is missing or incorrect. Exiting." 1>&2
    exit 0
}

for i in ALPHA GENRE GROUP; do
    if eval [ -d "\"\$${i}_DIR\"" -a -x "\"\$${i}_DIR\"" ]; then
        eval cd \"\$${i}_DIR\"
        eval ${i}_DIR="$PWD"
    else
        eval [ -n \"\$${i}_DIR\" ] &&
            echo "Your ${i}_DIR is invalid. Skipping $i links." 1>&2
        eval ${i}_DIR=""
    fi
done

{ [ -z "$ALPHA_DIR" ] && [ -z "$GENRE_DIR" ] && [ -z "$GROUP_DIR" ]; } &&
    exit 1

# Added by eur0dance
check_dead_links "$ALPHA_DIR"
check_dead_links "$GENRE_DIR"
check_dead_links "$GROUP_DIR"

for i in $RLS_DIRS; do
	[ -d "$i" -a -x "$i" ] || continue
    [ -n "$ALPHA_DIR" ] && link_alpha "$i"
    [ -n "$GENRE_DIR" ] && link_genre "$i"
	[ -n "$GROUP_DIR" ] && link_group "$i"
done

exit 0
