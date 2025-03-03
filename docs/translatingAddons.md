# Translating NVA Add-ons

This document provides guidance about translating add-ons registered to be translated using the [NVDA's centralized translation system](https://github.com/nvaccess/addon-datastore/blob/master/docs/submitters/submissionGuide.md#RegisteringAnAdd-onInTheTranslationSystem).

Add-ons maintainers can request for their add-ons to be registered on that system, or they may choose other procedures to get their add-ons translated.

## Before translating

### Join the translations mailing list

Translators should subscribe to the [NVDA translations mailing list hosted at Groups.IO](https://groups.io/g/nvda-translations).

It is an English low traffic list devoted to the discussion of translation.

If you aren't a member of the translation team, request an invitation on the translation mailing list.

Once you receive your [assembla(http://www.assembla.com) invitation, you can proceed by creating a username/password so that you can use the svn server. Once you are logged in, you need to accept the invitation to the screenReaderTranslations team. After that, you don't need to come back to the website.

### Install recommended software

- [SVN](https://tortoisesvn.net/downloads.html)
- [Poedit](https://poedit.net/download)

### Checkout the repository

1. Create a new folder to host the translations repository, for example, pressing `control+shift+n`.
1. Open the context menu (for example, pressing the `applications` key, `shift+f10`, or the `right mouse button`).
1. From the SVN submenu, choose checkout and, in the corresponding edit box, paste the following URL:

```
https://subversion.assembla.com/svn/screenReaderTranslations
```

Wait until, in the SVN dialog, you receive a message confirming that the process is complete. 

## Translating

### The Add-on Settings

Each language folder in the translations repository contains a file named "settings". This is a text file containing a list of add-ons and the translation settings value for the add-on (1 means yes, 0 means no). For example, a typical entry for an add-on looks like:

```
instantTranslate: "1"
```

This means that a translator decided to translate Instant Translate add-on. Another example is:

```
VocalizerDriver: "0"
```

This means that the translator is not interested in translating Vocalizer speech synthesizer add-on at this time.

So if you are interested in translating a particular add-on to your language, open `yourLangCode/settings` and change the value for the add-on to 1. If you do not want to translate the add-on at this time, set add-on value to 0. Then commit your settings.

# ## Add-on file location


Two different files can be available to translate for each add-on:

#### File for interface messages

If you set add-on translation value to 1, the next time you receive interface file updates, you'll receive the add-on file in the following location:

```
yourLangCode/addons/addonName/nvda.po
```

Where `yourLangCode` is your language and `addonName` is the name of the add-on.

Generally, new interface messages to be translated will be available once a week.

#### File for documentation

This file will be available in the following location:

```
website/addons/addonName.yourLangCode.po

```

Translate the documentation and commit changes.



### Translation process

1. Open the context menu on the translations folder.
1. From the SVN submenu, select `SVN update` to get the latest changes.
1. Open `langCode/addons/`addonName` folder, and use Poedit to translate the `nvda.po` file to translate messages corresponding to the add-on interface.
1. Open `website/addons`, and use Poedit to translate `addonName.langCode.po`, to translate add-ons documentation
1. Open the context menu on the translated file, and select the `SVN commit` command to submit your changes to the server.

