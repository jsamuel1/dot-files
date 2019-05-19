#!/usr/bin/env python3
import click
import subprocess
import glob
import os
import tempfile
from pathlib import Path


@click.command()
@click.option('--dryrun/--no-dryrun', default=True,
              help='Show what would happen, but don\'t change anything')
@click.option('--sync/--no-sync', default=False, help='fetch from git')
def install(dryrun, sync):
    click.echo('dryrun: %s   sync: %s' % (dryrun, sync))
    if sync:
        gitsync()
    files = [f for f in glob.glob('*')
             if f not in ['README.md', 'Makefile', 'install.py', 'requirements.txt']
             and os.path.isfile(f)]
    configfiles = [f for f in glob.glob('config/**', recursive=True) if os.path.isfile(f)]
    binfiles = [f for f in glob.glob('bin/*') if os.path.isfile(f)]
    linkfiles(files, dryrun)
    linkfiles(configfiles, dryrun)
    linkfiles(binfiles, dryrun)


def linkfiles(files, dryrun):
    homedir=str(Path.home())
    thisdir=str(Path.cwd())
    for f in files:
        dotf = os.path.join(homedir, '.'+f)
        status = getsymlinkstatus(f, dotf)
        targ = os.path.join(thisdir, f)
        print (targ + '->'+ dotf + ' :' + status)
        if dryrun == False:
            symlink(targ, dotf)


def getsymlinkstatus(target, link_name):
    if not os.path.exists(link_name):
        return 'new'
    elif os.path.samefile(target, link_name):
        return 'same'
    elif os.path.islink(link_name):
        return 'replace link'
    elif os.path.isfile(link_name):
        return 'replace file'
    elif os.path.isdir(link_name):
        return 'ERROR: directory'
    return 'unknown'


def symlink(target, link_name, overwrite=True):
    '''
    Create a symbolic link named link_name pointing to target.
    If link_name exists then FileExistsError is raised, unless overwrite=True.
    When trying to overwrite a directory, IsADirectoryError is raised.
    '''

    if not overwrite:
        os.symlink(target, linkname)
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
    subprocess.run(['git','pull'])


if __name__ == '__main__':
    install()
