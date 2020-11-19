# encoding: utf-8
import plumbum
from plumbum.cmd import git
from plumbum import local

class Repo():
    """Returns a repo object."""
    def __init__(self,gitrpath):
        """Creates a repo object to the given git repo path."""
        p = local.path(gitrpath)
        if not p.exists():
            raise(ValueError("%s doesn't seem to be a git repository." % gitrpath))
        self.gitRepoPath = p
        self.git = git['--git-dir='+p._path]

    def getRevList(self, branch):
        lst = self.git['rev-list', '--reverse', branch]().split()
        # Insert a 0th item to avoid adding 1 to indecees to get nvda snapshot number.
        lst.insert(0, '')
        return lst

    def getHashChangesSince(self, rhash, branch, file):
        revrange = "%s..%s" %(rhash, branch)
        return self.git['log', '--first-parent', '--reverse', '--format=%H', revrange, '--', file]().split()

    def getDiffBetween(self, rhash1, rhash2, file):
        revrange = "%s..%s" %(rhash1, rhash2)
        return self.git['diff', revrange, '--', file]()

    def getFileAt(self, rhash, file):
        return self.git['show', "%s:%s" %(rhash, file)]()

    def getLogAt(self, rhash):
        return self.git['log', '-n', '1', rhash]()

