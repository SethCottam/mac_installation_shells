#!/bin/zsh

  ##############################################################################################
 ########  Basic Setup for Mac                                                         ########
##############################################################################################
#
# Description - Basic Setup for Mac OSX to quickly provide a good platform for my development
# Note - This is currently optimized for ZSH on MAC OSX
# Dependencies - ZSH (or possibly Bash)
# Status - Work in Progess

# WARNING: Moved a copy of this 

# Instructions
# Run with ./Forge/temp_installers/osx_install_functions.sh

# TODO: This is a fully independent installer... but I think I want to move it into Spry
# TODO: This is a great example of what I want the the ScripTease shell to produce!

# TODO: Need to set .zshrc theme from robbyrussel to sethcottam.
#   - Is there a way to pass a varaible to do this? Or alter the PS1= to circumvent the regular theme
#       - Example: PS1='${SSH_CONNECTION+"%{$fg_bold[green]%}%n@%m:"}%{$fg_bold[green]%}Location: %~%{$reset_color%}$(git_prompt_info) 
#   - Might need to include a theme builder, theme template, or theme git pull

# TODO: need to add something to `touch .hushlogin`
#   - This silences the "Last login: Wed Jul  8 00:48:13 on ttys014" terminal login messages

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
####  Setup Functions
##############################################################################################
# The core of what this shell script is trying to accomplish

# alias x="source ~/Forge/temp_installers/osx_install_functions.sh; echo 'reloaded osx_install_functions'; create_directory_structure;"

function _install_full() {
    # Full Installation

    info "\nBasic OSX installtions and setup\n"

    # TODO: This probably should be it's own shell script
    # TODO: Should probably be encapsulated with some runtime totals!

    # Directory creation
    _create_directory_structure

    # Basic Setup
    _enable_zsh
    _enable_ohmyzsh

    # Setup program management
    _install_brew
    _install_brew_cask

    # Install specific programs and applications
    _install_brew_formulae
    _install_brew_cask_formulae

    # Dock updates
    # adjust_dock_settings
    # remove_from_dock
    # add_to_dock

    info "Final Messages"
    success "Finished basic OSX installations and setup has been completed."
    echo ""
}


function _installation_failure() {
    error "Unable to complete the installation\n"
    exit 1
}

function _enable_zsh() {
    # Switches the shell to ZSH

    info "Enabling ZSH"

    if [[ $SHELL = "/bin/zsh"  ]]; then
        warning "ZSH was previously enabled"
    elif [[ $SHELL = "/bin/bash" ]]; then
	# TODO: This is sloppy and needs to be rebuilt
        warning "Bash is not currently a compatible shell"
        warning "Switching shell default to ZSH"
        warning "Please exit and reopen the the terminal"
        chsh -s /bin/zsh
        _installation_failure
    else
        error "Our script is unfamiliar with the shell \"${SHELL}\""
        _installation_failure
    fi

    echo ""
}

function _enable_ohmyzsh() {
    # Switches the shell to ZSH

    info "Enabling Oh My ZSH"

    installer_location="$HOME/Downloads/temp_intaller.sh"

    installer=$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh > $installer_location)
    chmod +x $installer_location
    result=$(/bin/zsh $installer_location 2>&1)

    if [[ ${result} =~ "brew" ]]; then
        success "Oh My ZSH installed"
    elif [[ ${result} =~ "You already have Oh My Zsh installed"  ]]; then
        warning "Oh My ZSH was previously installed"
    elif [[ ${result} =~ "ZSH folder already exists"  ]]; then
        warning "Oh My ZSH was previously installed"
    else
        error "Unknown issues: ${result}"
        _installation_failure
    fi 

    echo ""

    # Cleanup and/or Garbage collection (because sourced files retain vairables in the shell)
    rm $installer_location
    unset installer_location
}

function _install_brew() {
    # Installs Homebrew if it's not already installed
    info "Attempting to install HomeBrew"

    result=$(brew -h 2>&1)
    if [[ ${result} =~ "command not found" ]]; then
        # This is covers a similiar request behind the scenes
        echo -e "${DEBUG1}USER INPUT${RESET}: ${CASUAL}Press${RESET} ${WARNING}[ENTER]${RESET} ${CASUAL}to continue ot any other key to abort${RESET}"
        # TODO: Attempt to install brew
        #   - This keeps crapping out because it asks for some confirmation mid-stream.
        # result=$(/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)")
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
        # echo 'eval "$(opt/homebrew/bin/brew shellenv)"' >> $HOME/.zprofile  # New step from the new hombrew installation
        # eval "$(/opt/homebrew/bin/brew shellenv)"  # New step from the new hombrew installation
        # TODO: `Error: Unknown command: shellenv" ``
        success "Homebrew has been installed"
    elif [[ ${result} =~ "brew search"  ]]; then
        warning "HomeBrew was previously installed"
    elif [[ ${result} =~ "cannot load such file" ]]; then
        error "There is an unrecoverable error: $result"
        warning "Attempting to reinstall HomeBrew"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
        # Need to check the installation
    else
        error "Unknown issues: ${result}"
        _installation_failure
    fi

    warning "May need to add \"eval $(/opt/homebrew/bin/brew shellenv\" to .zshrc file)"

    echo ""
}

function _install_brew_external() {
    # Installs HomeBrew to Tap into other repositories of formulae if not previously tapped
    # TODO: Built this out
    error "This has not been build out yet"

    # Need a list of things to tap

    echo ""
}

function _install_brew_cask() {
    # Installs HomeBrew Cask if it's not already installed
    info "Attemting to install HomeBrew Cask"

    result=$(brew info --cask 2>&1)
    if [[ ${result} =~ "Error: invalid option: --cask" ]]; then
        result=$(brew tap homebrew/cask 2>&1)
        # TODO: Build out the an installation check!!!!
        echo $result
        warning "TODO: Build out the an installation check!!!!"
        success "Homebrew Cask has been installed"
    elif [[ ${result} =~ "kegs"  ]]; then  # TODO: this needs to be fixed
        warning "HomeBrew Cask was previously installed"
    else
        error "Unknown issues: ${result}"
        _installation_failure
    fi

    echo ""
}

function _install_brew_formulae() {
    # Installs brew formulae (greek form of formulas. Used by HomeBrew)
    info "Attempting to install HomeBrew formulae. This may take awhile."
    section_start_time=$(perl -MTime::HiRes=time -e 'printf "%.3f\n", time')

    # Counters for stats
    counter_installed=0
    counter_preexisting=0
    counter_failures=0

    # TODO: Need to move this into a variable    
    # homebrew
    array=()
    array+="aws-elasticbeanstalk"
    array+="jq"
    array+="awscli"  # Amazon Web Services CLI
    array+="derailed/k9s/k9s"  # Kubernetes CLI tool
    array+="memcached"  # Caching system
    # array+="bash-completion"  # Oh, heck yes!  ... Might have unintended consequences when trying to `brew install node`
    array+="kafkacat"  # For working with Kafka, required by @kafy
    array+="mongodb"  # Maybe, Mongo Database
    array+="kubernetes-cli"  # Maybe, need to check
    array+="kubernetes-helm"
    array+="kubetail"  # TODO: Needs `brew tap johanhaleby/kubetail` ??? brew tap johanhaleby/kubetail && brew install kubetail
    array+="k9s"
    array+="switchaudio-osx"  # For OSX sound management from CLI
    array+="openssl"
    array+="telnet"  # Great tool, used by the memcached flush function
    array+="git-flow"  # Extention for GIT
    array+="wget"  # Good linux tool for getting stuff via web
    array+="go"  # Nice to have, Go Lang
    array+="grafana"  # Nice to have, For running Grafana locally
    array+="helm"
    array+="pyenv"  # Python environment manager for handling multiple environments
    array+="pyenv-virtualenv"  # For setting up the pyenv virtual environm
    array+="htop" # Tool for checking processes
    array+="python"  # Python for the win
    array+="mysql"  # Python for the win

    for item in $array; do
        # Do an actual logic check first
        # NOTE: using -w to match a whole word. This means we miss formulae with longer install names than installed names (ex: "derailed/k9s/k9s" becomes "k9s") but will not count a missing package that shares part of it's name with an installed package (ex: "minikube" vs "kube").
        result=$(brew list | grep -w "$item")
        if [[ ${result} == "$item"  ]]; then
            ((counter_preexisting=counter_preexisting+1))
            warning "\"$item\" was previously installed"
        else
            # Attempt to install and track how long it takes
            # TODO: This is inefficient! On average it takes between 3-5 seconds to attempt the install
            #   Need to check to see if it's in a list. If not, then we need to install it
            #   This will save minutes in the install process, and make updating reasonable
            # OSX doesn't have the date +%%N command for milliseconds
            start_time=$(perl -MTime::HiRes=time -e 'printf "%.3f\n", time')
            result=$(brew install $item 2>&1)
            end_time=$(perl -MTime::HiRes=time -e 'printf "%.3f\n", time')
            total_seconds=$(printf "%0.3f" $(($end_time - $start_time)) )

            if [[ ${result} =~ "Pouring"  ]]; then
                ((counter_installed=counter_installed+1))
                success "\"$item\" installed ($total_seconds secs)"
            elif [[ ${result} =~ "already installed" ]]; then
                # This should be a redundant check, but sometimes the install name is different from the local name
                ((counter_preexisting=counter_preexisting+1))
                warning "\"$item\" was previously installed under a slightly different name ($total_seconds secs)"
            elif [[ ${result} =~ "built in "  ]]; then
                ((counter_installed=counter_installed+1))
                success "\"$item\" installed ($total_seconds secs)"
            elif [[ ${result} =~ "No available formula with the name" ]]; then
                ((counter_failures=counter_failures+1))
                error "No formula named \"$item\" ($total_seconds secs)"
            else
                ((counter_failures=counter_failures+1))
                error "Unknown issues: ${result}"
                error "Skipping \"$item\""
                # _installation_failure 
            fi
        fi
    done

    # Stats
    # TODO: Cleanup this format. It's ugly
    echo ""
    warning "Installed: $counter_installed"
    warning "Pre-existing: $counter_preexisting"
    warning "Failures: $counter_failures"
    echo ""

    section_stop_time=$(perl -MTime::HiRes=time -e 'printf "%.3f\n", time')
    section_total_seconds=$(printf "%0.2f" $(($(($section_stop_time - $section_start_time)) / 60)) )
    warning "Total Brew runtime: $section_total_seconds minutes"
    echo ""

    # Cleanup and/or Garbage collection (because sourced files retain vairables in the shell)
    unset counter_installed counter_preexisting counter_failures start_time end_time total_second section_start_time section_stop_time
}

function _install_brew_cask_formulae() {
    # Installs brew cask formulae (greek form of formulas. Used by HomeBrew)
    info "Attempting to install HomeBrew Cask formulae. This may take awhile."
    section_start_time=$(perl -MTime::HiRes=time -e 'printf "%.3f\n", time')

    # Counters for stats
    counter_installed=0
    counter_preexisting=0
    counter_failures=0

    array=()
    array+="sublime-text"  # My favorite IDE
    array+="insomnia"  # Great CURL interface, espescially for Rest APIs
    array+="minikube"  # Probably don't need
    array+="spotify"  # My favoite music player
    array+="slack"  # Great IM tool
    array+="evernote"
    array+="moom"  # OSX window management tool
    array+="iterm2"  # Superior to OSX's default "terminal"
    array+="docker"  # Container platform
    array+="jetbrains-toolbox"  # The toolbox for Jetbrains IDEs
    array+="alfred"  # GUI search tool that's better than the builtin
    array+="dropbox"  # Great tool for filesharing and backups
    array+="sourcetree"  # Tool for visualizing GIT
    array+="brave-browser"  # More secure web browser
    array+="discord"  # Instant messager and communication tool
    array+="tableplus"  # Database GUI
    array+="stats"  # Taskbar tool for displaying computer usage stats
    array+="raspberry-pi-images"  # Taskbar tool for displaying computer usage stats
    array+="atom"
    array+="firefox"
    array+="microsoft-teams"
    array+="caffeine"
    array+="visual-studio-code"


    # Questionable
    array+="google-chrome"  # Security Concerns

    # Needs manual installation
    # array+="signal"  # Secure SMS/MMS/IM tool
    # array+="tutanota"  # Security Concerns    


    for item in $array; do
        # Do an actual logic check first
        # NOTE: using -w to match a whole word. This means we miss formulae with longer install names than installed names (ex: "derailed/k9s/k9s" becomes "k9s") but will not count a missing package that shares part of it's name with an installed package (ex: "minikube" vs "kube").
        result=$(brew list --cask | grep -w "$item")
        if [[ ${result} == "$item"  ]]; then
            ((counter_preexisting=counter_preexisting+1))
            warning "\"$item\" was previously installed"
        else
            # Attempt to install and track how long it takes
            # TODO: This is inefficient! On average it takes between 3-5 seconds to attempt the install
            #   Need to check to see if it's in a list. If not, then we need to install it
            #   This will save minutes in the install process, and make updating reasonable
            # OSX doesn't have the date +%%N command for milliseconds
            start_time=$(perl -MTime::HiRes=time -e 'printf "%.3f\n", time')
            result=$(brew install --cask $item 2>&1)
            end_time=$(perl -MTime::HiRes=time -e 'printf "%.3f\n", time')
            total_seconds=$(printf "%0.3f" $(($end_time - $start_time)) )
            
            if [[ ${result} =~ "successfully installed"  ]]; then
                ((counter_installed=counter_installed+1))
                success "\"$item\" installed ($total_seconds secs)"
            elif [[ ${result} =~ "built in "  ]]; then
                ((counter_installed=counter_installed+1))
                success "\"$item\" installed ($total_seconds secs)"
            elif [[ ${result} =~ "already installed" ]]; then
                # This should be a redundant check, but sometimes the install name is different from the local name
                ((counter_preexisting=counter_preexisting+1))
                warning "\"$item\" was previously installed under a slightly different name($total_seconds secs)"
            elif [[ ${result} =~ "No Cask with this name exists" ]]; then
                ((counter_failures=counter_failures+1))
                error "No formula named \"$item\" ($total_seconds secs)"
            else
                ((counter_failures=counter_failures+1))
                error "Unknown issues: ${result}"
                _installation_failure
            fi
        fi
    done

    # Stats
    # TODO: Cleanup this format. It's ugly
    echo ""
    warning "Installed: $counter_installed"
    warning "Pre-existing: $counter_preexisting"
    warning "Failures: $counter_failures"
    echo ""

    section_stop_time=$(perl -MTime::HiRes=time -e 'printf "%.3f\n", time')
    section_total_seconds=$(printf "%0.2f" $(($(($section_stop_time - $section_start_time)) / 60)) )
    warning "Total Brew Cask runtime: $section_total_seconds minutes"
    echo ""

    # Cleanup and/or Garbage collection (because sourced files retain vairables in the shell)
    unset counter_installed counter_preexisting counter_failures start_time end_time total_seconds section_start_time section_stop_time
}

function _create_directory_structure() {
    # Creates the standard directories
    info "Attempting to create new Directories."

    # List of all the directories that need to be created in a new OSX setup
    array=()
    array+="$HOME/Development"
    array+="$HOME/Development/sandbox"
    array+="$HOME/Development/3rd_party"
    array+="$HOME/Backups"
    array+="$HOME/Backups/exports"

    for directory in $array; do
        result=$(mkdir $directory 2>&1)
        if [[ -z $result ]]; then
            # A successful mkdir returns an empty result
            success "\"$directory\" has been created"
        elif [[ ${result} =~ "exists"  ]]; then
            # Example: "mkdir: testy: File exists"  # Which is strange since it's not a file...
            warning "\"$directory\" was previously created"
        else
            error "Unknown issues: ${result}"
            _installation_failure
        fi
    done

    echo ""

    # Cleanup and/or Garbage collection
    unset array directory result
}

function _enable_sublime_cli() {
    # Enables sublime commands to be run on command line

    # requires sudo?
    ln -s "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" /usr/local/bin/sublime
}



# install ${@:2}

# install_brew_cask_formulae

function install() {
    # Example parent function

    if [ -d "$1" ]; then
        # cdto=`cd "$1"; pwd`
        args="${@:1}"  # Start with the 1st command since this starts from the script
    fi

    # echo -e "args ${args}"

    # If the string is not empty
    if [[ -n ${1} ]]; then
        local full_function="_install_${1}"
        if [[ "$(whence ${full_function})" = "${full_function}" ]]; then
            success "Running ${0} ${1}"
            # Call the family_arg1 then pass all args >= arg position 2
            $full_function ${@:1}
        else
            error "install does not support \"${1}\" as an argument"
            _install_help
        fi
    else
        # TODO: should probably defeault to install_help
        # _install_full
        _install_help
    fi
}

function _install_help() {
    # Just reroutes to the examples
    info "Install help"
    _install_examples
}


function _install_examples() {
    # List of usage examples
    casual "Example: ~/Forge/temp_installers/osx_install_functions.sh [Command goes here]"
    debug1 "help" "Brings up help"
    debug1 "full" "Full installation"
}

# Start the script with or without arguments
if [ -n "$1" ]; then
    install ${@:1}
else
    install
fi