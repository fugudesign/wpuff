# WPuff

WPuff is a Bash script to build your Wordpress application with a simple command line.

```
wpuff [project-slug] [options]
```

## Options

```
--title,    -t     The Wordpress instance site name.
--domain,   -d    The custom domain name for the website (default: http://localhost/project-slug/).
--plugins,  -p   The path to a txt file with plugins list (one per line).
```

##Install

Clone the repository in your home directory.

```
cd ~
git clone git@github.com:fugudesign/wpuff.git
```

Rename the wpuff source directory.
```
mv wpuff .wpuff
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

You can customize the script configuration.
```
cd ~/.wpuff
open -e config.sh
```

You can customize the default plugins.
```
cd ~/.wpuff
open -e settings.sh
```

## Example

Full options website creation.
```
wpuff my-website --domain="my-website.loc" --titlte="My Puffed Website" --plugins="~/my-plugins.txt"
```

## Requirements

- Bash
- Terminal
