This is an adventure platformer game developed with the Godot engine.

How to Run the game (Windows):
1. Download the .exe file
3. Run the exefile

How to Run the game (Mac)
1. Download the .dmg file
2. Try to run the game by double clicking on GAMEPROJECT1
3. On your Mac, choose Apple menu > System Settings, then click Privacy & Security in the sidebar. (You may need to scroll down.)
4. Open Privacy & Security settings for me
5. Go to Security, then click Open.
6. Click Open Anyway. This button is available for about an hour after you try to open the app.
7. Enter your login password, then click OK.

How to Run in Godot:
1. Download or clone the repository
2. Open Godot Engine
3. Import > find project
4. Open project.godot

How to Build an executable:
1. Check that export templates are downloaded. Editor > Manage Export Template
2. Project > Export
Add preset for your operating system
3. Set export path
4. Click export project
5. Run the file

------------------------------------------------------------------------------------------
  Testing Method: Manual
  
  Tested movements: Used WASD or arrows to move and space to jump
  
  Tested Abilities: Shift to dash and hold jump to glide for a short time
  
  Tested Enemy hurtbox: Walking into the enemy hurtbox hurt the player
  
  Tested Health UI and mechanic: Decreased when the player was hurt
  
  Tested Death Screen: Appeared when Heath UI dropped to 0
  
  Tested Enemy movement: Moved around the enemy and watched it move
  
  Tested Killzone at the bottom of the map: Walked off and saw the Death Screen
  
  Tested Boss and its minions: In the main menu, you can select “Test Boss” which brings you to an area where you can fight the bell boss, which, compared to other enemies, appears with a different sprite, size, takes no knockback, has 
  different attacks and two phases, and has a bigger health pool
  
  Tested Shop: Walking to the NPC brings up a prompt for the player to spend coins and buy items.  The player can not buy infinite items, coins are deducted when the player buys an item, and the player can not buy anything if they don't 
  have enough coins.
  
  Tested healing potion: If the player is damaged, the player can press X to use the potion to heal a heart.  Nothing will happen when the potion is used when there is none, and when the player is at max health.
  
  Tested level transition: When the player walks into the designated space, it teleports the player to the designated scene.
  
  Tested knockback for players and enemies: If the player attacks an enemy, the hit knocks the enemy back.  When an enemy hits the player, it knocks them back.
  
  Tested more maps: The player can walk on the different maps that the transition brings them to
------------------------------------------------------------------------------------------

Follow this project board to know the latest status of the project: https://github.com/orgs/cis3296s26/projects/36  
UML
<img width="1681" height="1984" alt="Untitled Diagram drawio (5)" src="https://github.com/user-attachments/assets/a2024144-ce7c-48de-8996-50c962a699fb" />

