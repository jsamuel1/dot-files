#!/usr/bin/env python3

from asyncio import sleep
import os
import iterm2
import iterm2.profile
import iterm2.rpc

"""
This script was created with the "basic" environment which does
not support adding dependencies with pip.
"""


def mwInitPath() -> str:
    """
    return the path to the mwinit command
    """
    # mwinit's full path
    from shutil import which
    filePath = which("mwinit", path='/usr/local/bin:' + os.environ["PATH"])
    if filePath is None:
        print("mwinit not found")
        return "/usr/bin/env true"
    return filePath


def createIterm2DynamicProfile():
    """
    create a JSON file in the Dynamic Profile folder of iterm2
    """

    import json
    import os

    dynamicProfileFolder = os.path.expanduser(
        "~/Library/Application Support/iTerm2/DynamicProfiles"
    )
    if not os.path.exists(dynamicProfileFolder):
        os.makedirs(dynamicProfileFolder)

    dynamicProfilePath = os.path.join(dynamicProfileFolder, "mwinit.json")
    # if os.path.exists(dynamicProfilePath):
    #    return

    with open(dynamicProfilePath, "w") as f:
        f.write(
            json.dumps(
                {
                    "Profiles": [
                        {
                            "Name": "mwinit",
                            "Close Sessions On End": 1,
                            "Columns": 50,
                            "Command": mwInitPath(),
                            "Custom Command": "Custom Shell",
                            "Custom Window Title": "Authenticate with Amazon",
                            "Disable Window Resizing": True,
                            "Window Type": 0,
                            "Prevent Opening in a Tab": True,
                            "Shortcut": "A",  # Profile switch shortcut
                            # unique Guid generated for mwinit
                            "Guid": "DADE84FA-07F2-498C-A5D5-99C4E20706B9",
                            "Has Hotkey": True,
                            "HotKey Activated By Modifier": False,
                            "HotKey Alternate Shortcuts": [],
                            "HotKey Characters Ignoring Modifiers": "A",
                            "HotKey Characters": "a",
                            "HotKey Key Code": 0,  # A scancode on mac
                            "HotKey Modifier Activation": 0,
                            "HotKey Modifier Flags": 1179648,
                            "HotKey Window Animates": True,
                            "HotKey Window AutoHides": True,
                            "HotKey Window Dock Click Action": 0,
                            "HotKey Window Floats": True,
                            "HotKey Window Reopens On Activation": False,
                            "Prompt Before Closing 2": False,
                            "Rows": 10,
                            # Transparency settings
                            "Initial Use Transparency": True,
                            "Only The Default BG Color Uses Transparency": False,
                            "Transparency": 0.25,
                            "Blur": True,
                            "Blur Radius": 6.3,
                        }
                    ]
                },
                sort_keys=True,
                indent=4
            )
        )


async def main(connection):
    # app = await iterm2.async_get_app(connection)
    # window = app.current_terminal_window
    mwinitProfile = None
    profileName = "Default"

    createIterm2DynamicProfile()

    for i in [1, 2, 3]:
        profiles = await iterm2.Profile.async_get(connection)
        for profile in profiles:
            if profile.name == "mwinit":
                mwinitProfile = profile.local_write_only_copy
                profileName = profile.name
                break
        if mwinitProfile is not None:
            break
        print("mwinit profile not found. Sleeping")
        await sleep(1)

    if mwinitProfile is None:
        print("Ouch.  Using default profile")
        mwinitProfile = await iterm2.Profile.async_get_default(connection)
        mwinitProfile = mwinitProfile.local_write_only_copy
        mwinitProfile.set_name("mwinit")
        mwinitProfile.set_command(mwInitPath())
        mwinitProfile.set_custom_command("Yes")

    await iterm2.Window.async_create(connection=connection,
                                     profile=profileName,
                                     profile_customizations=mwinitProfile)


iterm2.run_until_complete(main)