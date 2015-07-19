# `Texture-Studio`


# *Commands:*



## Maps:

/loadmap - Load a map

/newmap - Create a new map

/importmap - Import CreateObject() or CreateDynamicObject() raw code

/export - Export a map to code



## Objects:

/cobject <objectid> - Create an object

/dobject - Delete your selected object

/robject - Resets an objects text and materials

/osearch - Search for a object

/sel <objectid> - Select a object id index

/csel - Use the mouse to select an object

/lsel - Graphical object selection

/flymode - Enter flymode

/ogoto - Goto your selected object (must be in flymode)

/pivot - Set a pivot position to rotate objects around

/togpivot - Turn on/off pivot rotation

/oprop - Object property editor



## Movement:

/editobject - Edit object mode

/ox - /oy - /oz - Standard movement commands

/rx - ry - /rz - Standard rotation commands

/dox - /doy - /doz - Delta move map

/drx - /dry - /drz - Rotate map around map center



## Textures/Text/Indexes/Theme:

/mtextures - Show a list of textures in a list

/ttextures - Show a list of textures in (Theme)

/stexture - Texture editor

/mtset <index> <textureref> - Set a material

/mtsetall <index> <textureref> - Set a material to ALL objects of the same modelid

/mtcolor <index> <Hex Color ARGB> - Sets a material color

/mtcolorall <index> <Hex Color ARGB> - Sets a material color to ALL objects of the same modelid

/copy - Copy object properties to buffer from currently selected object

/paste - Paste object properties from buffer to currently selected object

/clear - Clear object properties from buffer

/text - Open the object text editor

/sindex - Set text on a object will show material IDs

/rindex - Removes material indexes shown on an object

/loadtheme - Load a texture theme

/savetheme - Saves a texture theme

/deletetheme - Delete a texture theme

/tsearch - Find a texture by part of name



## Groups/Prefabs:

/setgroup - Sets a group id for a group objects

/selectgroup - Select a group of objects to edit

/gsel - Open up click select to add/remove objects from your group

/gadd - Add an object to your group useful for objects that cannot be clicked on

/grem - Remove a specific object from your group

/gclear - Clear your group selection

/gclone - Clone your group selection

/gdelete - Delete all objects in your group

/editgroup - Start editing a group

/gox - /goy - /goz - Stardard group movement commands

/gox - /goy - /goz - Stardard group rotation commands

/gaexport - Exports a group of objects to a attached object FS (Not yet completed)

/gprefab - Export a group of objects to a loadable prefab file

/prefabsetz - Set the load offset of a prefab file

/prefab <LoadName"> - Load a prefab file, /prefab will show all prefabs



## Bind Editor:

/bindeditor - Open the bind editor you can enter a series of commands to execute

/runbind <index> - Runs a bind



## GTA Objects:

/gtaobjects - Shows 3D Text of all GTA objects the indexes can be used for deleting objects

/remobject <index> - Remove a GTA object specify the index

/swapbuilding <index> - Remove a GTA and swap with an editable object



## Vehicles:

/avmodcar - Mod a car it will teleport the vehicle to the correct mod garage if modable

/avsetspawn - Set the spawn position of a vehicle

/avnewcar - Create a new car

/avdeletecar - Delete an unwanted car

/avcarcolor - Set vehicle car color

/avpaint - Set a vehicles paintjob

/avattach - Attach currently selected object to currently selected vehicle

/avdetach - Detach currently selected object from vehicle

/avsel - Select a vehicle to edit

/avexport - Export a car to filterscript

/avexportall - Export all cars to filterscript

/avox - /avoy - /avoz - Standard vehicle object movement commands

/avrx - /avry - /avrz - Standard vehicle object rotation commands

/avmirror - Mirror an object attached to a vehicle

(Special note: using /editobject on an attached object will edit the object on the vehicle)



## Other:

/echo - Will echo back any text sent this is useful for autohotkey so that you can create

displayed output for your keybinds





# *Key Combos:*



## /csel:

Holding 'H' while clicking an object will copy properites to buffer

Holding 'Walk Key' while clicking an object will paste properties from buffer



## /editgroup:

Hold 'Walk Key' to set the group rotation pivot you can only do this once per edit



## GUI:

When in fly mode to open the GUI press 'Jump Key' otherwise it can be opened by pressing 'N' Key



## Texture Viewer:

In Fly mode instead of pressing Y/H to scroll through textures hold enter/exit vehicle and press ANALOG Left ---- ANALOG Right

Pressing sprint will add textures to your theme in fly mode press sprint+aim to add textures to theme in walk mode

Walk key will apply the selected texture to your object
