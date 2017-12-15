#!/bin/bash
#
# WPuff
# Automatize your WordPress installation
#
# By @fugudesign (v.lalanne@fugu.fr)
#
# *** Recommended for Lazy people like me ***
#
# How to launch WPuff ?
# bash wpuff.sh sitename "My WP Blog"
# $1 = folder name & database name
# $2 = Site title



# VARS
# Project slug
project=$1

# admin email
email="admin@domain.tld"

# admin login
admin="admin"

# default admin pass
password="admin"

# default author url for generated theme
authorUrl="http://domaine.tld"

# path to install your WPs
installpath=~/sites

# path to plugins.txt
plugins=~/.wpuff/default-plugins.txt

# local url login
# --> Change to fit your server URL model (eg: http://$project.loc)
url="http://localhost/$project/"

# Include a config file
source ~/.wpuff/config.sh


#  ===============
#  = Fancy Stuff =
#  ===============
# not mandatory at all

yes=1;
no=0;

# Stop on error
set -e

# colorize and formatting command line
# You need iTerm and activate 256 color mode in order to work : http://kevin.colyar.net/wp-content/uploads/2011/01/Preferences.jpg
green='\033[0;32m'
cyan='\033[1;36m'
blue='\033[0;34m'
grey='\033[1;30m'
red='\033[0;31m'
white='\033[1;37m'
bold='\033[1m'
normal='\033[0m'

# Jump a line
function line {
  echo -e " "
}

# wpuff has something to say
function bot {
  line
  echo -e "${white}${bold}•  •  •  $1${normal}"
}

# Success msg
function success {
    echo -e "${green}${bold}Success:${normal} $1"
}

# Error msg
function error {
    echo -e "${red}${bold}Error:${normal} $1"
}



# SCRIPT OTPS
myopts() {
	while getopts ":bd:p:t:" optname
	do
	  case "$optname" in

	    "p") pluginsfile=$OPTARG ;;

	    "t") title=$OPTARG ;;

	    "d") domain=$OPTARG ;;

	    "b") blog=1 ;;

	    "?") bot "Unknown option $OPTARG" ;;
	    ":") bot "No argument value for option $OPTARG" ;;
	    *) bot "Unknown error while processing options" ;; # Should not occur

	  esac
	done
}

myopts "${@:2}"

# define title
if [ ! -z "$title" ]; then
    title=$title
else
    title=$project
fi

# define domain
if [ ! -z "$domain" ]; then
    url="http://$domain/"
fi

#define if blog is active
if [ -z "$blog" ]; then
    blog=0
fi

#define plugins file path

if [ -f ${pluginsfile} ]; then
	plugins=$pluginsfile
fi


#  ==============================
#  = The show is about to begin =
#  ==============================

# Welcome !
line
echo -e "${white}
      ##
      ##
 ##   ## #######  ###  ##  ####### #######
 ## # ##       ## ###  ##
 #######  ######  ###  ##  ####### #######
 ### ###  ###     ###  ##  ##      ##
 ##   ##  ###      #####   ##      ##
${normal} ---------------
 by fugudesign
"
line
bot "Wordpress installation for ${cyan}$title${normal}."

# CHECK :  Directory doesn't exist
# go to wordpress installs folder
cd $installpath

# check if provided folder name already exists
if [ -d $project ]; then
	error "Directory ${cyan}$project ${normal}already exists."
	if [ "$(ls ./$project)" ]; then
	  error "Directory ${cyan}$project ${normal}is not empty."
	  line
	  # quit script
	  exit 1
	fi
else
	# create directory
	bot "Create directory..."
	mkdir $project
	success "$installpath/$project created."
fi
cd $project

# Download WP
bot "Download WordPress..."
wp core download --locale=fr_FR --force

# check version
bot "Check the version..."
success "$(wp core version) récupérée."

# create base configuration
bot "Configure Wordpress..."
wp core config --dbname=$project --dbprefix="${project:0:4}_" --dbuser=root --dbpass=mypass --skip-check --extra-php <<PHP
define( 'WP_DEBUG', false );
define( 'WP_POST_REVISIONS', 5 );
define( 'DISABLE_WP_CRON', false );
define( 'DISALLOW_FILE_EDIT', true );
PHP

# Create database
bot "Create the database..."
wp db create

# launch install
bot "Install Wordpress..."
wp core install --url=$url --title="$title" --admin_user=$admin --admin_email=$email --admin_password=$password --skip-email

# Plugins install
if [[ "$plugins" -ne "$no" ]]; then
bot "Install plugins..."
echo -e "Plugin file: ${plugins}"
while read -r line || [ -n "$line" ];
do
    bot "plugin install $line"
    wp plugin install $line --activate
done < $plugins
fi

# Scaffold a new starter theme
bot "Create new base theme..."
wp scaffold _s $project --activate --theme_name="$title" --author=$admin --author_uri=$authorUrl

# Create standard pages
bot "Create default basic pages (Home, blog, contact...)"
wp post create --post_type=page --post_title='Accueil' --post_status=publish
wp post create --post_type=page --post_title='À propos' --post_status=publish
wp post create --post_type=page --post_title='Contact' --post_status=publish
wp post create --post_type=page --post_title='Mentions Légales' --post_status=publish
if [[ "$blog" -eq "$yes" ]]; then
wp post create --post_type=page --post_title='Blog' --post_status=publish
fi

# Change Homepage
bot "Change the homepage..."
wp option update show_on_front page
wp option update page_on_front 3
if [[ "$blog" -eq "$yes" ]]; then
wp option update page_for_posts 7
fi

# cat and tag base update
bot "Setup options..."
wp option update timezone_string "Europe/Paris"

# Menu stuff
bot "Setup the main menu..."
wp menu create "Menu Principal"
wp menu item add-post menu-principal 3
wp menu item add-post menu-principal 4
wp menu item add-post menu-principal 5
if [[ "$blog" -eq "$yes" ]]; then
wp menu item add-post menu-principal 7
fi
wp menu location assign menu-principal menu-1

# Misc cleanup
bot "Clean contents and extensions..."
wp post delete 1 --force # Article exemple - no trash. Comment is also deleted
wp post delete 2 --force # page exemple
wp plugin delete akismet
wp plugin delete hello
wp theme delete twentythirteen
wp theme delete twentyfourteen
wp option update blogdescription ''

# Create fake posts
if [[ "$blog" -eq "$yes" ]]; then
bot "Generate some fake blog posts..."
curl http://loripsum.net/api/5 | wp post generate --post_content --count=5
fi

# Permalinks to /%postname%/
bot "Activate the permalink structure..."
wp rewrite structure "/%postname%/" --hard
wp rewrite flush --hard


# Open in browser
bot "Open browser pages..."
open "${url}wp-admin/"
open "$url"

# Open in Sublime text
# REQUIRED : activate subl alias at https://www.sublimetext.com/docs/3/osx_command_line.html
bot "Open project in SublimeText..."
subl .

# Open in finder
bot "Open the directory window..."
open .

# Copy password in clipboard
echo $password | pbcopy

# That's all ! Install summary
bot "${green}${bold}Install done.${normal}"
line
echo -e "URL:   $url"
echo -e "Admin login:  $admin"
echo -e "Admin pass:  ${cyan}${bold} $password ${normal}${normal}"
line
echo -e "${grey}(Don't forget the password. It was copied in the clipboard!)${normal}"

line
bot "${normal}Generated with ${white}WPuff.${normal}"
line
