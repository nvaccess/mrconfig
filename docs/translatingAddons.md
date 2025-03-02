# Translating NVA Add-ons

This document provides guidance about translating add-ons registered to be translated using the [NVDA's centralized translation system](https://github.com/nvaccess/addon-datastore/blob/master/docs/submitters/submissionGuide.md#RegisteringAnAdd-onInTheTranslationSystem).

Add-ons maintainers can request for their add-ons to be registered on that system, or they may choose other procedures to get their add-ons translated.

## Before translating add-ons

### Join the translation mailing list

Translators should subscribe to the [NVDA translations mailing list hosted at Groups.IO](https://groups.io/g/nvda-translations).

It is an English low traffic list devoted to the discussion of translation.

### Install recommended software

- [SVN](https://tortoisesvn.net/downloads.html)
- [Poedit](https://poedit.net/download)

### Checkout the repository

1. Create a new folder to host the translations repository, for example, presing `control+shift+n`.
1. Open the context menu (for example, presing the `applications` key, `shift+f10`, or the `right mouse button`).
1. From the SVN submenu, choose checkout and, in the corresponding edit box, paste the following URL:

```
https://subversion.assembla.com/svn/screenReaderTranslations
```

## Translating

### The Add-on Settings

Each language folder in the translations repository contains a file named "settings". This is a text file containing a list of add-ons and the translation settings value for the add-on (1 means yes, 0 means no). For example, a typical entry for an add-on looks like:
instantTranslate: "1"
This means that a translator decided to translate Instant Translate add-on. Another example is:
VocalizerDriver: "0"
This means that the translator is not interested in translating Vocalizer speech synthesizer add-on at this time.

So if you are interested in translating a particular add-on to your language, open yourlangcode/Settings and change the value for the add-on to 1. If you do not want to translate the add-on at this time, set add-on value to 0. Then commit your settings.

# ## Add-on file location

If you set add-on translation value to 1, the next time you receive interface file updates, you'll receive the add-on file in the following location:
yourlang/Add-ons/addonname/nvda.po
Where yourlang is your language and addonname is the name of the add-on.

Generally, new messages to be translated will be available once a week.

### Translation process

1. Open the context menú on the translations folder.
1. From the SVN submenu, select `SVN update` to get the latest changes.
1. Open `langCode/addons/`addonName` folder, and use Poedit to translate the `nvda.po` file to translate messages corresponding to the add-on interface.
1. Open `website/addons`, and use Poedit to translate `addonName.langCode.po`, to translate add-ons documentation
