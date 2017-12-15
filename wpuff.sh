#!/bin/bash
#
# WPuff (｡◕‿◕｡)
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

# path to install your WPs
installpath=~/Sites

# path to plugins.txt
plugins=~/.wpuff/default-plugins.txt

# local url login
# --> Change to fit your server URL model (eg: http://$project.loc)
url="http://localhost/$project/"

# Include a config file
source config.sh

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
green='\x1B[0;32m'
cyan='\x1B[1;36m'
blue='\x1B[0;34m'
grey='\x1B[1;30m'
red='\x1B[0;31m'
bold='\033[1m'
normal='\033[0m'

# Jump a line
function line {
  echo " "
}

# wpuff has something to say
function bot {
  line
  echo "${blue}${bold}(｡◕‿◕｡)${normal}  $1"
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
line
echo "${blue}–––––––––––––––––––––––––––––––––––––––––––––"
line
bot "${blue}${bold}Bonjour ! Je suis WPuff.${normal}"
echo "         Je vais installer WordPress pour votre site : ${cyan}$title${normal}"

# CHECK :  Directory doesn't exist
# go to wordpress installs folder
# --> Change : to wherever you want
cd $installpath

# check if provided folder name already exists
if [ -d $project ]; then
	bot "${red}Le dossier ${cyan}$project ${red}existe déjà${normal}."
	if [ "$(ls ./$project)" ]; then
	  bot "${red}Le dossier ${cyan}$project ${red}n'est pas vide${normal}."
	  echo "         Par sécurité, je ne vais pas plus loin pour ne rien écraser."
	  line
	  # quit script
	  exit 1
	fi
else
	# create directory
	bot "Je crée le dossier : ${cyan}$project${normal}"
	mkdir $project
fi
cd $project

# Download WP
bot "Je télécharge WordPress..."
wp core download --locale=fr_FR --force

# check version
bot "J'ai récupéré cette version :"
wp core version

# create base configuration
bot "Je lance la configuration :"
wp core config --dbname=$project --dbprefix="${project:0:4}_" --dbuser=root --dbpass=mypass --skip-check --extra-php <<PHP
define( 'WP_DEBUG', false );
define( 'WP_POST_REVISIONS', 5 );
define( 'DISABLE_WP_CRON', false );
define( 'DISALLOW_FILE_EDIT', true );
PHP

# Create database
bot "Je crée la base de données :"
wp db create

# Generate random password
#passgen=`head -c 10 /dev/random | base64`
#password=${passgen:0:10}
password=120BXgeuRAT

# launch install
bot "et j'installe !"
wp core install --url=$url --title="$title" --admin_user=$admin --admin_email=$email --admin_password=$password --skip-email

# Plugins install
if [[ "$plugins" -ne "$no" ]]; then
bot "J'installe les plugins listés dans le fichier : ${plugins}"
while read -r line || [ -n "$line" ];
do
    bot "plugin install $line"
    wp plugin install $line --activate
done < $plugins
fi

# Download from private git repository
#bot "Je télécharge le thème WP0 theme :"
#cd wp-content/themes/
#git clone git@bitbucket.org:maximebj/wordpress-zero-theme.git
#wp theme activate wordpress-zero-theme

# Scaffold a new starter theme
bot "Je crée un nouveau thème de base"
wp scaffold _s $project --activate --theme_name="$title" --author=$admin --author_uri="http://www.fugu.fr"

# Create standard pages
bot "Je crée les pages habituelles (Accueil, blog, contact...)"
wp post create --post_type=page --post_title='Accueil' --post_status=publish
wp post create --post_type=page --post_title='À propos' --post_status=publish
wp post create --post_type=page --post_title='Contact' --post_status=publish
wp post create --post_type=page --post_title='Mentions Légales' --post_status=publish
if [[ "$blog" -eq "$yes" ]]; then
wp post create --post_type=page --post_title='Blog' --post_status=publish
fi

# Create fake posts
if [[ "$blog" -eq "$yes" ]]; then
bot "Je crée quelques faux articles"
curl http://loripsum.net/api/5 | wp post generate --post_content --count=5
fi

# Change Homepage
bot "Je change la page d'accueil"
wp option update show_on_front page
wp option update page_on_front 3
if [[ "$blog" -eq "$yes" ]]; then
wp option update page_for_posts 7
fi

# Menu stuff
bot "Je crée le menu principal, assigne les pages, et je lie l'emplacement du thème : "
wp menu create "Menu Principal"
wp menu item add-post menu-principal 3
wp menu item add-post menu-principal 4
wp menu item add-post menu-principal 5
if [[ "$blog" -eq "$yes" ]]; then
wp menu item add-post menu-principal 7
fi
wp menu location assign menu-principal primary

# Misc cleanup
bot "Je supprime Hello Dolly, les thèmes de base et les articles exemples"
wp post delete 1 --force # Article exemple - no trash. Comment is also deleted
wp post delete 2 --force # page exemple
wp plugin delete akismet
wp plugin delete hello
wp theme delete twentythirteen
wp theme delete twentyfourteen
wp option update blogdescription ''


# Permalinks to /%postname%/
bot "J'active la structure des permaliens"
wp rewrite structure "/%postname%/" --hard
wp rewrite flush --hard

# cat and tag base update
wp option update timezone_string Europe/Paris
#wp option update category_base theme
#wp option update tag_base sujet

# Git project
# REQUIRED : download Git at http://git-scm.com/downloads
#bot "Je Git le projet :"
#cd ../..
#git init    # git project
#git add -A  # Add all untracked files
#git commit -m "Initial commit"   # Commit changes

# Open the stuff
bot "Je lance le navigateur, l'éditeur et le finder."

# Open in browser
open "${url}wp-admin"
open $url

# Open in Sublime text
# REQUIRED : activate subl alias at https://www.sublimetext.com/docs/3/osx_command_line.html
#cd wp-content/themes
#subl $1

# Open in Coda
# REQUIRED : activate coda-cli
#cd wp-content/themes
#coda .
subl $installpath"/"$project

# Open in finder
#cd $1
open .

# Copy password in clipboard
echo $password | pbcopy

# That's all ! Install summary
bot "${green}L'installation est terminée !${normal}"
line
echo "URL du site:   $url"
echo "Login admin :  $admin"
echo "Password :  ${cyan}${bold} $password ${normal}${normal}"
line
echo "${grey}(N'oubliez pas le mot de passe ! Je l'ai copié dans le presse-papier)${normal}"

line
bot "${blue}à Bientôt !"
line
line
echo "${blue}–––––––––––––––––––––––––––––––––––––––––––––${normal}"
line
line
