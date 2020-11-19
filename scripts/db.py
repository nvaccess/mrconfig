#!/usr/bin/env python3
import argparse
import sys
import json


class DB(dict):

    def __init__(self, fname='settings', autoSave=False, *args, **kwargs):
        super(DB, self).__init__(*args, **kwargs)
        # If settings file is corrupt or doesnt exist,
        # make sure we end up with an empty dict.
        self.fname = fname
        self.autoSave = autoSave
        try:
            f = open(fname, 'r')
        except IOError:
            pass
        else:
            try:
                self.update(json.load(f))
            except ValueError:
                raise
            finally:
                f.close()

    def __getitem__(self, key):
        try:
            return super(DB, self).__getitem__(key)
        except:
            return 0

    def __delitem__(self, key):
        super(DB, self).__delitem__(key)
        if self.autoSave:
            self.save()

    def __setitem__(self, key, value):
        super(DB, self).__setitem__(key, value)
        if self.autoSave:
            self.save()

    def save(self):
        ## prune keys that have no content.
        rkeys = []
        for key in self.keys():
            if not self[key]:
                rkeys.append(key)
        for key in rkeys:
            del self[key]

        ## write out the remaining keys to file.
        f = open(self.fname, 'w')
        json.dump(self, f, indent=2, ensure_ascii=False, sort_keys=True)
        f.close()

##############
if __name__ == "__main__" and len(sys.argv) >= 1:
    help_welcome = 'Json db interface.'
    help_file = 'Use the given file as the database.'
    help_set = 'Insert or update key/value.'
    help_set_default = ("If the given key doesn't exist,"
                        " insert it with the given value as default.")
    help_get = ('Return value stored for this key, if not found 0 will be returned.'
                ' Note that if the key is not found, or the stored value is actually 0,'
                ' the same output will be produced.')
    help_delete = 'If this key is available in the database, remove it and its value.'
    parser = argparse.ArgumentParser(description=help_welcome)
    parser.add_argument('-f', '--file', metavar='FILE_NAME', default='settings', help=help_file)
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument('-s', '--set', nargs=2, metavar=('KEY', 'VALUE'), help=help_set)
    group.add_argument('--set_default', nargs=2, metavar=('KEY', 'VALUE'), help=help_set_default)
    group.add_argument('-g', '--get', metavar='KEY', help=help_get)
    group.add_argument('-d', '--delete', metavar='KEY', help=help_delete)
    cmdArgs = parser.parse_args()

    db = DB(cmdArgs.file, autoSave=True)
    if cmdArgs.get:
        print(db[cmdArgs.get])
    elif cmdArgs.set:
        k, v = cmdArgs.set
        if v == '-':  # user is giving us the data on stdin
            db[k] = sys.stdin.readlines()
        else:
            db[k] = v
    elif cmdArgs.set_default:
        k, v = cmdArgs.set_default
        if v == '-':  # user is giving us the data on stdin
            tmpv = sys.stdin.readlines()
        else:
            tmpv = v
        if k not in db:
            db[k] = tmpv
    elif cmdArgs.delete:
        try:
            del db[cmdArgs.delete]
        except KeyError:
            pass
