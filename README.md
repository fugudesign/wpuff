# WPuff

WPuff is a Bash script to build your Wordpress application with a simple command line.

```
wpuff [project-slug] [options]
```

## Options

Option | Short |  Description
------ | ----- |  -----------
--title | -t | The Wordpress instance site name (Default: [project-name])
--domain | -d | The custom domain name for the website (Default: http://localhost/[project-name]/)
--plugins | -p | The path to a txt file with plugins list (one per line) (Default: ./default-plugins.txt)
--blog | n/a | Just add the flag activate the Wordpress blog features

## Install

Clone the repository in your home directory and enter inside.

```
cd ~
git clone git@github.com:fugudesign/wpuff.git .wpuff
cd .wpuff
``` 

Create your custom config and edit it with your favorite editor
```
cp config.sample.sh config.sh
open -e config.sh
```

Add the script as a command.
```
sudo chmod +x wpuff.sh
ln -s ~/.wpuff/wpuff.sh /usr/local/bin
```

Now, just create your first site.
```
wpuff my-first-test
```

## Setup

You need to customize the script configuration.
```
cd ~/.wpuff
open -e config.sh
```

You can customize the default plugins.
```
cd ~/.wpuff
open -e default-plugins.txt
```

## Example

Full options website creation.
```
wpuff my-website --domain="my-website.loc" --titlte="My Puffed Website" --plugins="~/my-plugins.txt"
```

## Requirements

- Bash
- Terminal
