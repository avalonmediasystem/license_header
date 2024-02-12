# LicenseHeader

Utility for updating license headers across the various components of the Avalon Media System project. This
tool is designed to be integrated into the development process to automate license management across several
standard formats such as CSS, Ruby, and Java.

## Installation

Add this line to your application's Gemfile:

    gem 'license_header'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install license_header

## Usage
To see all of the options run:
```
bundle exec license_header
```
Identify the directories that have the source files that you want to apply license headers to then run the audit action.  For a typical rails app this might look like:
```
bundle exec license_header -a app/ db/ lib/ script/ spec/
```
When you're ready to add/update headers run the update action:
```
bundle exec license_header -u app/ db/ lib/ script/ spec/
```
