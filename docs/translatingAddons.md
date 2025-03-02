# Translating NVA Add-ons

This document provides guidance about translating add-ons registered to be translated using the [NVDA's centralized translation system](https://github.com/nvaccess/addon-datastore/blob/master/docs/submitters/submissionGuide.md#RegisteringAnAdd-onInTheTranslationSystem).

Add-ons maintainers can request for their add-ons to be registered on that system, or they may choose other procedures to get their add-ons translated.

## Before translating add-ons

### Join the translation mailing list

Translators should subscribe to the [NVDA translations mailing list hosted at Groups.IO](https://groups.io/g/nvda-translations).

It is an English low traffic list devoted to the discussion of translation.

### Install recommended software

* [SVN](https://tortoisesvn.net/downloads.html)
* [Poedit](https://poedit.net/download)

### Checkout the repository

1. Create a new folder to host the translations repository, for example, presing `control+shift+n`.
1. Open the context menu (for example, presing the `applications` key, `shift+f10`, or the `right mouse button`).
3 From the SVN submenu, choose checkout and, in the corresponding edit box, paste the following URL:

```
https://subversion.assembla.com/svn/screenReaderTranslations
```

## Translating

Generally, new messages to be translated will be available once a week.

1. Open the context menú on the translations folder.
1. From the SVN submenu, select `SVN update` to get the latest changes.
1. Open `langCode/addons/`addonName` folder, and use Poedit to translate the `nvda.po` file to translate messages corresponding to the add-on interface.
1. Open `website/addons`, and use Poedit to translate `addonName.langCode.po`, to translate add-ons documentation
