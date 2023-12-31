#!/usr/bin/env python3

from asyncio import sleep
import os
import iterm2

"""
This script was created with the "basic" environment which does
not support adding dependencies with pip.
"""

async def main(connection):
    app = await iterm2.async_get_app(connection)

    def mwInitPath() -> str:
        """
        return the path to the mwinit command
        """
        # mwinit's full path
        from shutil import which
        filePath = which("mwinit", path='/usr/local/bin:' + os.environ["PATH"])
        if filePath is None:
            print("mwinit not found")
            return ""
        return filePath


    async def createIterm2DynamicProfile():
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
    
        # if mwinit doesn't exist, don't create the profile
        mwInit = mwInitPath()
        if mwInit == "":
            return

        with open(dynamicProfilePath, "w") as f:
            f.write(
                json.dumps(
                    profileDataMwinit(mwInit),
                    sort_keys=True,
                    indent=4
                )
            )

    async def updateDefaultTriggers(connection):
        """
        update the default triggers in iterm2
        """
        profile = await iterm2.Profile.async_get_default(connection)

        await create_trigger_if_missing(profile, "Run the following command before retrying: mwinit")


    async def create_trigger_if_missing(profile: iterm2.Profile, regex : str):
        triggers = profile.triggers
        if triggers is not None:
            for encTrigger in triggers:
                trigger = iterm2.decode_trigger(encTrigger)
                if trigger.regex == regex:
                    return

        newTrigger = iterm2.RPCTrigger(regex, "launch_mwinit()", False, True)
        encTrigger = [ newTrigger.encode ]

        await profile.async_set_triggers(encTrigger)
        

    def profileDataMwinit(mwInit):
        return {
            "Profiles": [
                {
                    "Name": "mwinit",
                    "Close Sessions On End": 1,
                    "Columns": 50,
                    "Command": mwInit,
                    "Custom Command": "Custom Shell",
                    "Custom Window Title": "Authenticate with Amazon",
                    "Use Custom Window Title": True,
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
                    "HotKey Key Code": 0,  # A scan code on mac
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
                    # Other settings
                    "Screen": -2,
                    "Show Status Bar": False,
                    "Sync Title": False,
                    "Title Components": 1,
                    "Minimum Contrast": 0.30,

                }
            ]
        }

    @iterm2.RPC
    async def launch_mwinit():
        connection = app.connection

        # if mwinit doesn't exist, don't run
        mwInit = mwInitPath()
        if mwInit == "":
            print("mwinit not found.  Not launching")
            alert = iterm2.Alert(
                title="mwinit not found",
                message="mwinit was not found.  Please install mwinit and try again.",
                icon=iterm2.Alert.Icon.WARNING,
            )
            await alert.async_run(connection)
            return

        for i in [1, 2, 3]:
            profiles = await iterm2.Profile.async_get(connection)
            for profile in profiles:
                if profile.name == "mwinit":
                    mwinitProfile = profile.local_write_only_copy
                    profileName = profile.name
                    break
            if mwinitProfile is not None:
                break
             
            if i == 1:
                print("mwinit profile not found.  Creating")
                await createIterm2DynamicProfile()
            else:  # i > 1:  
                print("mwinit profile not found. Sleeping")
            await sleep(1)

        if mwinitProfile is None:
            print("Ouch.  Using default profile")
            mwinitProfile = await iterm2.Profile.async_get_default(connection)
            mwinitProfile = mwinitProfile.local_write_only_copy
            mwinitProfile.set_name("mwinit")
            mwinitProfile.set_command(mwInitPath())
            mwinitProfile.set_use_custom_command("Custom Shell")
            mwinitProfile.set_use_custom_window_title(True)
            mwinitProfile.set_custom_window_title("Authenticate with Amazon")

        await iterm2.Window.async_create(connection=connection,
                                        profile=profileName,
                                        profile_customizations=mwinitProfile)

    # main
    await createIterm2DynamicProfile()
    await updateDefaultTriggers(connection)
    await launch_mwinit.async_register(connection)


iterm2.run_forever(main)
