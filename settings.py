#!/usr/bin/env python3
import argparse
import subprocess
import os
import tempfile
from pathlib import Path


def install():
    parser = argparse.ArgumentParser(
        description='setup dot files in home directory based on git repo')
    parser.add_argument('--dryrun', action='store_true', default=False)
    parser.add_argument('--no-dryrun', action='store_false', dest='dryrun')
    parser.add_argument('--sync', action='store_true')
    parser.add_argument('--verbose', action='store_true')
    args = parser.parse_args()
    args.files_processed = 0
    args.files_changed = 0

    print(f'dryrun: {args.dryrun} sync: {args.sync} verbose: {args.verbose} ')

    if args.sync:
        git_sync()
    files = [f for f in Path('./dots').glob('*')  # Only one level for ~/.blah
             if str(f) not in [
        '.gitignore',
        'Makefile',
        'README.md',
    ]
        and os.path.isfile(f)]
    config_files = [f for f in Path('.').glob(
        'config/**/*') if os.path.isfile(f)]
    local_files = [f for f in Path('.').glob('local/**/*') if os.path.isfile(f)]
    sheldon_files = [f for f in Path('.').glob(
        'sheldon/**/*') if os.path.isfile(f)]
    zsh_files = [f for f in Path('.').glob('zsh/**/*') if os.path.isfile(f)]
    link_files(files, args, "dots")
    link_files(config_files, args, ".")
    link_files(local_files, args, ".")
    link_files(sheldon_files, args, ".")
    link_files(zsh_files, args, ".")

    print(
        f'finished.  Processed: {args.files_processed} Changed: {args.files_changed}')


def link_files(files, args, relative_path):
    home_dir = Path.home()
    this_dir = Path.cwd()
    for file_name in files:
        dot_file = os.path.join(
            home_dir, '.'+str(file_name.relative_to(relative_path)))
        status = get_symlink_status(file_name, dot_file)
        args.files_processed += 1
        if status == 'same':
           continue 
        args.files_changed += 1
        target = os.path.join(this_dir, file_name)
        if args.verbose or status != 'same':
            print(target + '->' + dot_file + ' :' + status)
        if not args.dryrun:
            symlink(target, dot_file, args)


def get_symlink_status(target, link_name):
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


def symlink(target, link_name, args, overwrite=True):
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
        temp_link_name = link_name + tempfile.gettempprefix()

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
        # Preempt os.replace on a directory with a nicer message
        if os.path.isdir(link_name):
            raise IsADirectoryError(
                f"Cannot symlink over existing directory: '{link_name}'")
        os.replace(temp_link_name, link_name)
    except IsADirectoryError:
        if os.path.islink(temp_link_name):
            os.remove(temp_link_name)
        raise


def git_sync():
    subprocess.run(['git', 'pull'])


if __name__ == '__main__':
    install()
