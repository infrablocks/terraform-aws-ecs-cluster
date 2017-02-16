Terraform AWS ECS Cluster
=========================

Describe it here.

Technologies Used
-----------------

The repository makes use of:

### Languages and Scripting

* [Ruby 2.3](http://ruby-doc.org/core-2.3.1/): Used for build and scripting

### Libraries, Frameworks and Platforms

### Persistence

### Building and Packaging

* [Rake](http://docs.seattlerb.org/rake/): Simple build tool
* [RubyGems](https://rubygems.org): Packaging tool and standard for Ruby
* [Bundler](http://bundler.io): Dependency manager and isolator for Ruby

### Testing

### Environment Automation

* [Docker](https://www.docker.com/): Containerisation platform
* [git-crypt](https://www.agwa.name/projects/git-crypt/): Encryption for files and folders in git repositories


Obtaining the Repository
------------------------

After you have been added as a contributor, execute the following to clone the repository:

```
git clone git@github.com:tobyclemson/base-project-template.git
```

Development Machine Requirements
--------------------------------

In order for the build to run correctly, a few tools will need to be installed on your
development machine:

* Ruby (2.3.1)
* Bundler
* git
* git-crypt
* gnupg
* direnv

### Mac OS X Setup

Installing the required tools is best managed by [homebrew](http://brew.sh) and
[homebrew-cask](http://caskroom.io).

To install homebrew:

```
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

To install homebrew-cask:

```
brew tap caskroom/cask
```

Then, to install the required tools:

```
# ruby
brew install rbenv
brew install ruby-build
echo 'eval "$(rbenv init - bash)"' >> ~/.bash_profile
echo 'eval "$(rbenv init - zsh)"' >> ~/.zshrc
eval "$(rbenv init -)"
rbenv install 2.3.1
rbenv rehash
rbenv local 2.3.1
gem install bundler

# docker
brew cask install docker
# at this point start the docker app and give it permission to start up

# git, git-crypt, gnupg
brew install git
brew install git-crypt
brew install gnupg

# direnv
brew install direnv
echo "$(direnv hook bash)" >> ~/.bash_profile
echo "$(direnv hook zsh)" >> ~/.zshrc
eval "$(direnv hook $SHELL)"

direnv allow <repository-directory>
```
