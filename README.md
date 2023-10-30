# Pico Explorer for Onion

Pico Explorer is an project for Onion that replicates the functionality of Splore, the official PICO-8 store, directly on the Onion user interface. After an initial refresh, it will display in your game list the content of Splore with the same categories as the official one. So it allows to discover and download the last games from Pico8 universe. 
Pico Explorer use the default Onion emulator to run PICO8 games (Retroarch + Fake-08 core).

https://github.com/schmurtzm/Onion-Pico-Explorer/assets/7110113/13129b72-0efc-4435-9fde-50a0382f07bd


## Prerequisites

To use Pico Explorer, you need the following:

- A Miyoo Mini Plus (with WiFi capability).
- Onion firmware version 4.2.0 or superior.
- Extract the contents of this archive on the root of your SD card.

## How to Use

Follow these steps to set up and use Pico Explorer:

1. Extract the contents of [this archive](https://github.com/schmurtzm/Onion-Pico-Explorer/releases) on the root of your SD card.
2. Go into your PICO game list -> Pico Explorer.
3. Select the option to refresh Pico Explorer.

The initial sync may take around one minute, depending on your WiFi speed and the number of PICO games you already have installed. Subsequent syncs will be faster, taking approximately 25 seconds, as there will be fewer files to download.

After synchronization, all the Pico Explorer subfolders should be populated, including Featured, Jam, New, and Work in Progress. Each game is named with its Lexaloffle's forum official game name (which may be different from the filename itself). Games within each section are ordered similarly to Splore, using a prefix like 001, 002, and so on. Previous results from Pico Explorer are kept in each folder without numbering, making it easy to find them later.

- The search section allows you to easily find your favorite games in Splore, even though the refresh may take a while.
- Once you find a game you like in Pico Explorer, press the 'Y' button to display the GLO (Game List Options) menu and select "Copy this game to root list" to add it to your personal main game list.




 ## Release Notes
```
/*  Release Notes (yyyy/mm/dd):                                                             */
/*  v1.0 - 2023/10/30 :                                                                     */
/*    - Initial release                                                                     */
```


## About the Project

Pico Explorer was a fun project to create, as it involved many concepts to tinker with MainUI:

- Automated generation of the MainUI game database.
- Virtual subfolders: MainUI usually limits use to a single subfolder, but here we have two layers of subfolders by manipulating the MainUI PICO game database.
- Adding images to folders: This serves as a workaround to the MainUI limitation, allowing nice pictures on each Pico Explorer category.
- GLO script: In Onion, you can easily add your own scripts. In this project, a new GLO script is created to allow copying a game from Pico Explorer to your main game list.

Pico Explorer provides a good base for experimenting with various ideas for game lists.

Please note that not all games from Splore are compatible with Fake-08, the PICO-8 emulator used in Onion. To achieve perfect compatibility, it would require the real PICO-8 software on Onion, which is another story entirely.

------------------------------------------------


 ## Thanks
You like this project ? You want to improve this project ? 

Do not hesitate, **Participate**, there are many ways :
- If you don't know bash language you can test releases , and post some issues, some tips and tricks for daily use.
- If you're a coder or a graphist you can fork, edit and publish your modifications with Pull Request on github :)<br/>
- Join my Patreon community and be a part of supporting the development of my various projects!  [![Participate to my Patreon][Patreon-shield]][patreon]
  
- Or you can buy me a coffee to keep me awake during night coding sessions :dizzy_face: !
   <a href="https://www.buymeacoffee.com/schmurtz"><img src="https://www.buymeacoffee.com/assets/img/guidelines/download-assets-sm-2.svg" alt="Buy me a coffee" width="100"/></a>
<br/><br/>

Your contributions make a huge difference in keeping these projects alive !


<br/><br/>

[buymeacoffee-shield]: https://www.buymeacoffee.com/assets/img/guidelines/download-assets-sm-2.svg
[buymeacoffee]: https://www.buymeacoffee.com/schmurtz
[Patreon-shield]:https://img.shields.io/badge/Patreon-F96854?style=for-the-badge&logo=patreon&logoColor=white
[patreon]: https://www.patreon.com/schmurtz

 ===========================================================================
 
