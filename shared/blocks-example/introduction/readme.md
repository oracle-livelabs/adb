# README

This content simply shows an example using blocks and tasks. 

## Need to know to use blocks and tasks
Here's the basics for using blocks and tasks. Refer to [Using Blocks](https://oracle-livelabs.github.io/common/building-blocks/how-to-author-with-blocks/workshop/index.html) for more details. Also, check out [Lauran's slides and word document](https://oracle.sharepoint.com/:x:/r/teams/AutonomousDatabasePMHome/Shared%20Documents/adb/workshops/2025-04-ADB-Workshops.xlsx?d=w17ff3eb03d414a73a87ba718aabaaf2d&csf=1&web=1&e=xpJXQh)


### What is a block and task
* A block is a complete lab
* A task is a step in a lab

### How to use them
* Your manifest.json will need to refer to the blocks and tasks (see the include section of the manifest.json)
    - You simply refer to the block for a lab. The manifest.json's include will also need to include any tasks within that block.
    - You embed a task in your markdown
* Add a variable.json - which is used to customize settings in a block or task
