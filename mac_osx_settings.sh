#!/bin/zsh

  ##############################################################################################
 ########  Basic Settings Setup for Mac                                                ########
##############################################################################################
#
# Description - Basic Settings Setup for Mac OSX to quickly provide a good platform for my development
# Note - This is currently optimized for ZSH on MAC OSX
# Dependencies - ZSH (or possibly Bash)
# Status - Work in Progess

# Run with ./Forge/temp_installers/mac_osx_settings.sh

# TODO: This is a fully independent installer... but I think I want to move it into Spry
# TODO: This is a great example of what I want the the ScripTease shell to produce!


##############################################################################################
####  Format Functions
##############################################################################################
# Because we all love pretty outputs

# Standard colors
SUCCESS='\033[0;32m'    # Green
WARNING='\033[0;33m'    # Yellow
ERROR='\033[0;31m'      # Red
INFO='\033[01;34m'      # Blue
UNIQUE='\033[00;35m'    # Light Purple
CASUAL='\033[02;37m'    # Grey
DEBUG1='\033[00;36m'    # Light Blue
DEBUG2='\033[02;36m'    # Teal
RESET='\033[0m'         # Back to Default

info() {
    # Colors a single sentance in Blue
    echo -e "${INFO}${1}${RESET}"
}

success() {
    # Formats and colors [SUCCCES] and colors a single sentance.
    echo -e "[${SUCCESS}SUCCESS${RESET}] ${CASUAL}${1}${RESET}"

}

warning() {
    # Formats and colors [WARNING] and colors a single sentance.
    echo -e "[${WARNING}WARNING${RESET}] ${CASUAL}${1}${RESET}"
}

error() {
    # Formats and colors [ERROR] and colors a single sentance.
    echo -e "[${ERROR}ERROR${RESET}] ${CASUAL}${1}${RESET}"  # Extra spacing is intentional 
}

prompt() {
    # Formats and colors asking the user for information
    echo -e "${DEBUG1}USER INPUT${RESET}: ${CASUAL}Please type your ${DEBUG1}${1}${RESET} ${CASUAL}and press${RESET} ${WARNING}[ENTER]${RESET}"
}

casual() {
    # Colors a single sentance in Grey
    echo -e "${CASUAL}${1}${RESET}"
}

debug1() {
    # Formats and colors
    echo -e "${DEBUG1}${1}${RESET}: ${CASUAL}${2}${RESET}"
}

##############################################################################################
####  Helper Functions
##############################################################################################
# Because we all love pretty outputs

function installation_failure() {
    error "Unable to complete the installation\n"
    exit 1
}


##############################################################################################
####  Settings Functions
##############################################################################################
# The core of what this shell script is trying to accomplish

function grant_basic_permissions() {

    info "Granting basic permissions"

    # Open the security Preferences
    # Is it necesssary to all the terminal to make these changes?
    open "x-apple.systempreferences:com.apple.preference.security"
    read -p "Press [ENTER] to continue"
}

function set_sleep_timers() {
    # Set the sleep times

    info "Setting the sleep timers"

    sudo systemsetup -setcomputersleep 90
    sudo systemsetup -setdisplaysseleep 90
    sudo systemsetup -setharddisksleep 90
}

function set_display_scale() {
    
    # Currently there is no command to change the display scale
    # You'll have to do this manually
    echo "Work in progress"
}

function set_finder_defaults() {

    info "Setting the finder defaults"

    # https://pawelgrzybek.com/change-macos-user-preferences-via-command-line/
    # Change default to show hiden files in Fider
    defaults write com.apple.finder AppleShowAllFiles -string YES
    # Verify with defaults read com.apple.finder AppleShowAllFileso

}

# Check all defaults domains
# defaults domains | tr ',' '\n'
# To read all defaults for a setting
# defaults read [NAME]
# EXAMPLE: defaults read com.apple.dock

function set_dock_size() {
    # Set dock size

    info "Setting the size of the dock"

    # It’s possible to go all the way down to 1, which is essentially unusable without magnification. Around 60` appears to be the default size on most Macs, and 16 is the smallest setting accessible outside of Terminal.
    defaults write com.apple.dock tilesize -integer 40

    # Refresh the dock
    killall Dock
}

# Cool but unnecessary trick
# Add a blank spacer to the Dock's persistant apps
# defaults write com.apple.dock persistent-apps -array-add '{"tile-type"="spacer-tile";}'; killall Dock

# Show only active - I don't care much for this one
# defaults write com.apple.dock static-only -bool true; killall Dock

# 

function dock_factory_reset() {
    # Reset the dock
    # TODO: Needs an are you sure function!

    defaults delete com.apple.dock
    killall Dock
}

function dock_delete_all_persistent_apps() {
    # Deletes all persistant apps
    defaults delete com.apple.dock persistent-apps
    killall Dock
}

function dock_show_persistent_app_names() {

    info "\"Persistent\" Dock app names"
    defaults read com.apple.dock persistent-apps | grep "\"_CFURLString\"" | grep -o "[%0-9a-zA-Z]*.app"
    echo ""
}

function dock_show_app_names() {

    info "All current Dock app names"
    defaults read com.apple.dock | grep "\"_CFURLString\"" | grep -o "[%0-9a-zA-Z]*.app"
    echo ""
}

# List of built in Mac commands
# https://ss64.com/osx/

function dock_delete_default_persistent_apps() {


    info "Removing default apps from the \"Persistent\" portion of the Dock"

    # Apps to remove
    array=()    
    array+="Books"
    array+="Calendar"
    array+="Contacts"
    array+="FaceTime"
    array+="Keynote"
    array+="Launchpad"
    array+="Mail"
    array+="Maps"
    array+="Messages"
    array+="Music"
    array+="News"
    array+="Notes"
    array+="Numbers"
    array+="Pages"
    array+="Photos"
    array+="Podcasts"
    array+="Reminders"
    array+="Safari"
    array+="Siri"
    array+="Terminal"
    array+="TV"


    # How to Remove something from the dock 

    # 1 - Get all the persistant apps in the dock
    # defaults read com.apple.dock persistent-apps | grep "\"_CFURLString\"" | grep -o "[%0-9a-zA-Z]*.app"

    # 2 - Get the dock position number of a persistant app in the dock (offset by -1)
    # # EXAMPLE: ...Delete persistent-apps:[DOCK POSITION NUMBER]...
    # defaults read com.apple.dock persistent-apps | grep "\"_CFURLString\"" | awk '/App%20Store.app/ {print (NR - 1) }'

    # Get the dock position number of a persistant app in the dock
    # # EXAMPLE: ...a wk '/[APP NAME].app/ ...
    # defaults read com.apple.dock persistent-apps | grep "\"_CFURLString\"" | awk '/Safari.app/ {print NR}'

    # 3 - Use the Dock Location position number from the previous command to delete it from the persistant aps, then sleep a few seconds... just in case
    # EXAMPLE: ... Delete persistent-apps:[DOCK POSITION NUMBER] ...
    # sudo -u $USER /usr/libexec/PlistBuddy -c "Delete persistent-apps:3" ~/Library/Preferences/com.apple.dock.plist; sleep 3; killall Dock

    for item in $array; do
        
        # Gets a dock location for each item
        dock_location=$(defaults read com.apple.dock persistent-apps | grep "\"_CFURLString\"" | awk "/${item}.app/ {print (NR - 1) }")

        # Check to see if there is a number
        # Note: This is a zsh-ism, so it's not cross-shell portable, but the pattern <-> matches any string having any number of digits and only digits.
        if [[ ${dock_location} = <-> ]]; then
            # Unfortunately this command doesn't really give us anything
            result=$(sudo -u $USER /usr/libexec/PlistBuddy -c "Delete persistent-apps:${dock_location}" ~/Library/Preferences/com.apple.dock.plist)
            # sleep 1
            killall Dock
        else
            warning "\"$item\" was previously removed from the Persistent dock apps"

            # if [[ ${result} =~ "successfully installed"  ]]; then
            #     ((counter_installed=counter_installed+1))
            #     success "\"$item\" installed ($total_seconds secs)"
            # else
            #     ((counter_failures=counter_failures+1))
            #     error "Unknown issues: ${result}"
            #     installation_failure
            # fi
        fi
    done

    echo ""
}


function dock_add_persistent_apps() {

    info "Adding apps to the \"Persistent\" portion of the Dock"

    # Apps to add to the Persistent portion of the Dock
    # Note: These will be added in the order they appear so arrange them appropiately
    array=()
    array+="iTerm"
    array+="Spotify"
    array+="Sublime Text"
    array+="Brave Browser"
    array+="Discord"
    array+="Slack"
    array+="Sourcetree"
    array+="Activity Monitor"  # Can't seem to get this one to work!!!
    array+="Evernote"
    array+="Google Chrome"
    array+="Insomnia"
    array+="Signal"
    array+="Tutanota"


    # Add items to the dock
    # EXAMPLE: .../Applications/[Applicaiton Name].app... 
    # defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/spotify.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"; killall Dock

    for item in $array; do

        item_check=${item/ /%20}
        echo "item_check = ${item_check}"

        dock_location=$(defaults read com.apple.dock persistent-apps | grep "\"_CFURLString\"" | awk "/${item}.app/ {print (NR - 1) }")
        echo "item dock_location = ${dock_location}"


        # Gets a dock location for each item
        # Note: This check requires spaces to be replaced with %20
        # TODO: Replace spaces with %20
        dock_location=$(defaults read com.apple.dock persistent-apps | grep "\"_CFURLString\"" | awk "/${item_check}.app/ {print (NR - 1) }")
        echo "item_check dock_location = ${dock_location}"

        # Add it if it's not already inthe dock
        # Note: This is a zsh-ism, so it's not cross-shell portable, but the pattern <-> matches any string having any number of digits and only digits.
        if [[ ${dock_location} = <-> ]]; then
            warning "\"$item\" was previously added"
        else
        
            # Gets a dock location for each item
            result=$(defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/${item}.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>" 2>&1)

            if [[ ${result} =~ "successfully installed"  ]]; then
                error "Unknown issues with \"$item\": ${result}"
            else
                success "\"$item\" added"
            fi
        fi

        echo ""

    done

    killall Dock
    echo ""
}

function set_mac_defaults () {

    info "Setting the \"Defaults\" settings for the Mac"

    local new_screenshots_location="~/Screenshots"

    if [[ -d "$new_screenshots_location" ]}; then
        mkdir ${HOME}/Screenshots
        # if [ -d "$new_screenshots_location" ]; then
        #     error " There was a problem creating \"$new_screenshots_location\""
        # else
        #     succes "YAY"
        # fi
        success "Created \"$new_screenshots_location\""
        defaults write com.apple.screencapture ${new_screenshots_location}
    else
        warning "\"$new_screenshots_location\" was previously created"
        defaults write com.apple.screencapture ${new_screenshots_location}
    fi

    if [[ $(defaults read com.apple.screencapture) = ${new_screenshots_location} ]]; then
        succss "Screenshot location set to ${new_screenshots_location}"
    fi




    # mkdir $HOME/Screenshots

    # local old_screenshots_location=$(defaults read com.apple.screencapture location)

    # defaults write com.apple.screencapture ${new_screenshots_location}

    # if [[ "$(defaults read com.apple.screencapture location)" = "${full_function}" ]]; then
    #     warning "\"$item\" was previously added"
    # else
}

function set_default_screenshot_locaton() {

}


# dock_show_persistent_app_names
# dock_show_app_names
# dock_delete_default_persistent_apps
# dock_add_persistent_apps
# set_dock_size
# set_finder_defaults
# set_sleep_timers
set_mac_defaults

# grant_basic_permissions  # TODO: Should only run once after everything is installed