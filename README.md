# dws is for Dumb Work Space

[Drop the patter I ain't got all day](#impatient)

As a programmer, I am a fickle beast. On the one hand, I love what Git and its
ecosystem provide in terms of coding safety, reproducibility and
collaboration. On the other hand, I have a few recurring use cases that I have
been solving using Git, but it's been awkward.

1. It's 4:57pm, my parental duties are closing in, and I'm nose-deep debugging
   a weiiiird race condition. I almost see it, but now I also hear *hey
   Parent, what's for dinner?* So I have to dump my brain context somewhere
   and make sure an overnight electrical bogey will not kill my precious work
   so far. Thus, I must create a throwaway branch, commit my work
   there, push that branch to Github. So I go to the shell, create that
   branch, what do I name it? Find a name, type `git commit`, the cursor
   flashes at the top of the editor... what was it I had already tried, what
   was it I wanted to try next? I forgot everything. I type in `figure out the
   stupid RC when you baz the foobar`, save, exit, git push. I go start my
   evening shift with a chip on my shoulder.
1. It's 2:16pm, I tweaked some code experimentally to make it work on my
   machine on a small data subset. Now I would move this code over to the big
   compute rig to try against a larger data set. What must I do? oh, create an
   ad hoc experiment branch, commit my mod on there, push that branch... then
   fetch and check out that branch on the big rig. Three commands later I ssh
   over the big rig, then fetch and oops! I cannot check out my ad hoc branch,
   because my repository copy on the big rig is dirty. I git stash these
   quickly, check out, now -- how do I run this bigger data experiment again?
   If I make some mod during my experimentation on the big rig and want to
   take my work back to my previous machine, I have to do more commit and
   pushing and pulling. And clean up the ad hoc branches and temporary commits.
1. I often write small routines and scripts and snippets that serve an instant
   purpose, but end up not fitting in the larger project I'm participating to.
   A few weeks pass, and somebody comes to me asking for that snippet I had
   shown them. Ok, so have I still got that somewhere? Maybe on machine X? No
   no, it was machine Y. Doh! I deleted the file from Y. Maybe if I look at
   the branches of the Git repository... Oh on machine Z I had a serendipitous
   clone of the repo I took and it has that ad hoc branch where the snippet
   lived. It only took me 37 minutes to find it.
   
I wish this sort of code storage for myself, and code sharing with myself,
could be done with less fussing, with less boilerplate. This is the problem
`dws` sets out to solve.

## <a name="impatient"></a>For the impatient

Have a Bash shell with basic UNIX tools (think GNU Coreutils, `sed` and `awk`)
and Git.

1. Download the [dws script](https://raw.githubusercontent.com/hamelin/dws/main/dws)
   and put it somewhere in your `PATH`.

1. Make yourself a private repository on Github. Call it `my-dumb-work-space`.
   Copy its clone URL.

1. In your shell, `cd` to a directory you would like to save to your dumb work
   space (there has to be files in it -- why would you sync an empty
   directory?). Type `dws`.
   - As this is the first time you use it, you will have to input how you
     would like to call your machine (for the sake of the example, call it
     `host1`), clone your private repository (did you
     copy its URL like I told you?) and generally set yourself up.
   - Once setup is done, your directory will have been added to your dumb work
     space, and synchronized over with the Github repository.

1. `ssh` or otherwise connect to another machine where you have such a
   simiarly decked-out shell. Install the `dws` script there too. Now type:
   ```
   dws clone host1/<the name of the directory you saved> my-clone
   ```
   As this is a distinct machine, `dws` will have you go through the setup
   routine again: for the sake of example again, name this second machine
   `hostB`. When all is said and done, you have a full recursive copy of your
   original directory in new directory `my-clone`.

1. `cd my-clone; dws`
   - You are now synchronizing this same directory on `hostB` to the same
     `my-dumb-work-space` repository.

1. Look at your `my-dumb-work-space` on Github: you should see two
   directories in the repository, respectively named `hostA` and `hostB`.
   Under `hostA`, you have your original directory; under `hostB`, you have
   `my-clone`.

So there you have it: a catch-all Git repository, managed with minimum fuss
and boilerplate, that distinguishes between origins of the directories you
save in it. This is a *dumb* workspace: it's up to you to merge your stuff
together. But it makes it easy to quickly save small bits of code you're not
sure whether to throw away, and to move code around without thinking too hard
about it.

## Installation

Trivial: there is no installation per se. `dws` is a Bash script that
deliberately composes only basic UNIX utilities (using them so as to avoid
anything that goes beyond the POSIX standard) and Git. The file
[dws](https://raw.githubusercontent.com/hamelin/dws/main/dws) can thus be
simply dropped in any directory made part of one's `PATH` environment
variable. It can be owned by the root user (in the case of a system-wide
deployment) if you must, or any other for that matter, as long as it's made
readable and executable to users that would run it.

## Usage

`dws` leans on a bare Git repository that you can access from any machine you
would work on. This central repository is called the *parentship*. It will act
as a data storage and exchange hub between these machines. When `dws` is first
run on any such machine, this repository is cloned there.

### <a name="init"></a>Initialization

The first time you issue any `dws` command (except for online help), `dws`
proceeds with an interactive three-step initialization process. 

1. Figure out a directory where to put the metadata.
1. Clone your parentship repository from a URL or path (in the case of 
   a NFS-stored parentship) and prepare it with the user metadata necessary
   for committing. Remark that you have to use neither a true name or e-mail
   address -- it's just that Git insists on attaching such information to
   commits, so we have to have *something*.
1. <a name="machine"></a>Assign a name to identify this machine. `dws`
   leverages the `hostname` command as a suggestion, but you can use any name
   that could be used as a machine's hostname. The only rule is that this name
   be unique amongst the machine names already recorded in the parentship
   repository.

`dws` tries to both respect your home directory management preferences, and to
avoid putting its metadata in a directory that already exists. Thus, if you
interrupt the process during the initialization after `dws` has created the
metadata directory, when you run it next, it will fail to detect this
half-baked directory, and propose you with an alternative. You can type the
name of the directory you used the first time, and brush off `dws`'s
protesting the directory already exists. You are, after all, the *boss*:
do assert yourself.

In addition, if you interrupt the process during the initialization, `dws`
will attempt to be smart and to avoid repeating initialization steps it has
already performed. Should it fail to do so, you can always reset this by
deleting the metadata directory you agreed to let it create.

### Online help

Invoke `dws -h` to get an index of the subcommands `dws` supports. For all
these subcommands, you can also invoke `dws <subcommand> -h` to get terse
contextual help.

### Synchronizing a space

From any machine where you work on code (or any set of files), one typical
thing to do is to *send* this work over to the parentship. This synchronizes
the remote store with your work on this machine. For this, simply invoke

```
dws sync
```

This copies the current directory **recursively** to the parentship, under a
directory named with the [machine identifier you chose](#machine) at the
[initialization](#init) step. The `sync` subcommand is implied if you leave it
off, so you can type instead

```
dws
```

Directories thus synchronized with the parentship are deemed *spaces*.
Any space must have a **unique** name for the current machine.  Thus, if your
space's name has been used previously, `dws` will work interactively with
you to choose a unique name. You can also provide a name of your choice at the
command line:

```
dws sync the-name-i-choose
dws -- the-name-i-choose     # Alternative
```

This name only has to be mentioned once; you can omit it as you keep invoking
`dws sync` to further synchronize your work. Remark that you can specify
another name at a later time: from then on, `dws sync` will use that new name.

Under the hood, any effective synchronization results in a commit added to the
parentship repository. This commit is appended to the `main` branch of the
local parentship copy, which is then pushed to the remote repository. `dws`
handles the grunt work of first pulling the `main` branch to permit a
fast-forward push, so you don't have to worry about any of this.

A default commit message is generated for you everytime you `sync`. You can
however control the commit message with the `-m` and `-e` options. The former
should be followed by the message you want to use; the latter opens the editor
as does any invokation of `git-commit`. With using these two options, the
files in your space don't even have to be different from the mothership's:
an empty commit will be added with your message.

```
dws sync -m 'Now I have done this, finishing fixing it tomorrow'
dws sync -e
```

If both options are used, the message associated with option `-m` is opened up
in the editor.

**An important exception** to the synchronization of space content is that
anything under directories named `.git` is omitted. This is a Git behavior: it
seems to avoid caring for files that it may confuse with its own metadata. To
force the synchronization of files under a `.git` directory (say, to save a
snapshot of a directory before committing the tree as a complicated sequence
of patches), one must duplicate it to another name (using a command such as
`cp -R .git ,git`), and remove or rename these files later. This restriction
may be addressed in a later version.

### Listing files on the parentship

After you have synchronized a few spaces with the parentship, you may want to
get some situational awareness as to what's actually in there. For that, use
the `list` subcommand (alias `ls`):

```
dws list
dws ls
```

By default, you get a big dump of all files from all spaces synchronized
across all machines you've used `dws` on (with this particular parentship).
You can filter that list using pipelines to fetch what you need. For instance,
to get a list limited to spaces named `fft` (across all machines),

```
dws ls | awk -F/ '$2 == "fft"'
```

To list all spaces synced from every machine:

```
dws ls | awk -F/ '{print $1, $2}' | sort | uniq
```

The `list` subcommand can also take a regular expression as parameter, which
abbreviates commands of the type `dws ls | grep ...`. These regular expressions
are made to match from the start of each path stored on the parentship,
effectively prepending `^` to the expression.  For instance, to see all files
saved for machine `bigrig`:

```
dws ls bigrig/
```

Coming back to the first example: list all files under spaces named `fft`,
across all machines:

```
dws ls .\*/fft
```

Yes, you have to escape the regular expression metacharacters, all because
Bourne shell programming sucks. 🤷 Use `awk` or `grep` if you can't be
bothered.  Another thing that can annoy users is that `dws ls` is careful to
pull the latest commits from the parentship everytime it runs. If you are sure
enough you don't need such an update and want to cut down on the latency, use
option `-n` to skip the refresh against the remote repository:

```
dws ls -n
```

### Cloning a space

While synchronizing against the parentship is useful to simply store spaces,
it gains its full power when used to share code with oneself across machines
(or even on a single machine). To do this, run

```
dws clone <machine>/<space>
```

This would copy that space into an eponymous subdirectory. The only
restriction `dws clone` poses is that there exist no subdirectory named
`<space>` to the current directory. One can thus specify a target directory to
put the space contents in:

```
dir clone <machine>/<space> copy/the/files/here/please
```

Remark that the directory created by `dws clone` is not itself a space: it has
no associated directory on the mothership. It is merely a clone of a space!
To make it a space, `cd` into it and use `dws sync`.

### Forgetting a space

The sort of files we want to store and share with the Dumb Work Space often
have a limited purpose. When this purpose is done, we would want to take them
out of our faces. Any space can be removed from the parentship's tree and
index using command

```
dws forget
```

while the shell's current directory corresponds to that space. Since `dws
forget` involves a commit, the options `-m` and `-e` work as with `dws sync`.

```
dws forget -m 'Experiment #233876 aborted. I hope Ricky gets out of the ICU soon.'
```

You cannot use `dws` to forget spaces that belong to other machines. You can
manage the parentship's local copy to your heart's content and push
modifications you make to it. However, if you break the work assumptions on
which `dws` rely, hijinks may ensue.

### Bits and bobs

Some other `dws` subcommands are useful for scripting with `dws` metadata or
the local contents of the parentship.

- `dws here` prints the [machine identifier](#machine) on standard output.
- `dws ship` prints the real path to the parentship's local copy on standard
  output.
- For a file in the current space, `dws path` prints the real path of its
  last sync in the parentship's local copy.

The latter command can be useful to track changes following a `sync`:

```
diff -y subdir/my-file $(dws path subdir/my-file)
```
