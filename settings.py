#!/usr/bin/env python3
import argparse
import subprocess
import os
import tempfile
from pathlib import Path


def install():
    parser = argparse.ArgumentParser(
        description='setup dotfiles in home directory based on git repo')
    parser.add_argument('--dryrun', action='store_true', default=False)
    parser.add_argument('--no-dryrun', action='store_false', dest='dryrun')
    parser.add_argument('--sync', action='store_true')
    args = parser.parse_args()

    print(f'dryrun: {args.dryrun}   sync: {args.sync}')

    if args.sync:
        gitsync()
    files = [f for f in Path('./dots').glob('*')  # Only one level for ~/.blah
             if str(f) not in [
                '.gitignore',
                'Makefile',
                'README.md',
             ]
             and os.path.isfile(f)]
    configfiles = [f for f in Path('.').glob('config/**/*') if os.path.isfile(f)]
    localfiles = [f for f in Path('.').glob('local/**/*') if os.path.isfile(f)]
    sheldonfiles = [f for f in Path('.').glob('sheldon/**/*') if os.path.isfile(f)]
    zshfiles = [f for f in Path('.').glob('zsh/**/*') if os.path.isfile(f)]
    linkfiles(files, args.dryrun, "dots")
    linkfiles(configfiles, args.dryrun, ".")
    linkfiles(localfiles, args.dryrun, ".")
    linkfiles(sheldonfiles, args.dryrun, ".")
    linkfiles(zshfiles, args.dryrun, ".")


def linkfiles(files, dryrun, relativepath):
    homedir = Path.home()
    thisdir = Path.cwd()
    for file_name in files:
        dotf = os.path.join(homedir, '.'+str(file_name.relative_to(relativepath)))
        status = getsymlinkstatus(file_name, dotf)
        targ = os.path.join(thisdir, file_name)
        print(targ + '->'+ dotf + ' :' + status)
        if not dryrun:
            symlink(targ, dotf)


def getsymlinkstatus(target, link_name):
    if not os.path.exists(link_name):
        return 'new'
    if os.path.samefile(target, link_name):
        return 'same'
    if os.path.islink(link_name):
        return 'replace link'
    if os.path.isfile(link_name):
        return 'replace file'
    if os.path.isdir(link_name):
        return 'ERROR: directory'
    return 'unknown'


def symlink(target, link_name, overwrite=True):
    '''
    Create a symbolic link named link_name pointing to target.
    If link_name exists then FileExistsError is raised, unless overwrite=True.
    When trying to overwrite a directory, IsADirectoryError is raised.
    '''

    if not overwrite:
        os.symlink(target, link_name)
        return

    # os.replace() may fail if files are on different filesystems
    link_dir = os.path.dirname(link_name)
    if not os.path.exists(link_dir):
        try:
            os.makedirs(link_dir)
        except FileExistsError:
            pass

    # Create link to target with temporary filename
    while True:
        temp_link_name = tempfile.mktemp(dir=link_dir)

        # os.* functions mimic as closely as possible system functions
        # The POSIX symlink() returns EEXIST if link_name already exists
        # https://pubs.opengroup.org/onlinepubs/9699919799/functions/symlink.html
        try:
            os.symlink(target, temp_link_name)
            break
        except FileExistsError:
            pass

    # Replace link_name with temp_link_name
    try:
        # Pre-empt os.replace on a directory with a nicer message
        if os.path.isdir(link_name):
            raise IsADirectoryError(f"Cannot symlink over existing directory: '{link_name}'")
        os.replace(temp_link_name, link_name)
    except:
        if os.path.islink(temp_link_name):
            os.remove(temp_link_name)
        raise


def gitsync():
    subprocess.run(['git', 'pull'])


if __name__ == '__main__':
    install()
