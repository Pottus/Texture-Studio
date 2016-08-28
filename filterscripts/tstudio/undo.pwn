#define         MAX_UNDO_BUFFER         10000

#define         UNDO_TYPE_UNUSED        0
#define         UNDO_TYPE_CREATED       1
#define         UNDO_TYPE_EDIT          2
#define         UNDO_TYPE_DELETED       3

#define         UNDO_GROUP_NONE         0

// Object information ENUM
enum OBJECTUNDOINFO
{
	uoGroup,                                     // Object group
	uoModel,                                     // Object Model
	Float:uoX,                                   // Position Z
	Float:uoY,                                   // Position Z
	Float:uoZ,                                   // Position Z
	Float:uoRX,                                  // Rotation Z
	Float:uoRY,                                  // Rotation Z
	Float:uoRZ,                                  // Rotation Z
    Float:uoDD,                                  // Draw distance
	uoTexIndex[MAX_MATERIALS],                   // Texture index ref
	uoColorIndex[MAX_MATERIALS],                 // Material List
	uousetext,              					// Use text
	uoFontFace,    								// Font face reference
	uoFontSize,    								// Font size reference
	uoFontBold,    								// Font bold
	uoFontColor,   								// Font color
	uoBackColor,   								// Font back color
	uoAlignment,   								// Font alignment
	uoTextFontSize, 							 // Font text size
	uoObjectText[MAX_TEXT_LENGTH],              // Font text
	uoNote[64],                                 // Note
	uoAttachedVehicle,                           // Vehicle object is attached to
	uoIndex,                                    // Store indexid object
	uoType,                                     // Type of undo
	uoGroupTask,                                 // Group
}

static UndoBuffer[MAX_UNDO_BUFFER][OBJECTUNDOINFO];
static CurrBufferIndex;

SaveUndoInfo(index, type, group=0)
{
   	UndoBuffer[CurrBufferIndex][uoGroup] = ObjectData[index][oGroup];
   	UndoBuffer[CurrBufferIndex][uoModel] = ObjectData[index][oModel];
   	UndoBuffer[CurrBufferIndex][uoX] = ObjectData[index][oX];
   	UndoBuffer[CurrBufferIndex][uoY] = ObjectData[index][oY];
   	UndoBuffer[CurrBufferIndex][uoZ] = ObjectData[index][oZ];
   	UndoBuffer[CurrBufferIndex][uoRX] = ObjectData[index][oRX];
   	UndoBuffer[CurrBufferIndex][uoRY] = ObjectData[index][oRY];
   	UndoBuffer[CurrBufferIndex][uoRZ] = ObjectData[index][oRZ];
   	UndoBuffer[CurrBufferIndex][uoDD] = ObjectData[index][oDD];
	UndoBuffer[CurrBufferIndex][uousetext] = ObjectData[index][ousetext];
   	UndoBuffer[CurrBufferIndex][uoFontFace] = ObjectData[index][oFontFace];
   	UndoBuffer[CurrBufferIndex][uoFontSize] = ObjectData[index][oFontSize];
   	UndoBuffer[CurrBufferIndex][uoFontBold] = ObjectData[index][oFontBold];
   	UndoBuffer[CurrBufferIndex][uoFontColor] = ObjectData[index][oFontColor];
   	UndoBuffer[CurrBufferIndex][uoBackColor] = ObjectData[index][oBackColor];
   	UndoBuffer[CurrBufferIndex][uoAlignment] = ObjectData[index][oAlignment];
   	UndoBuffer[CurrBufferIndex][uoTextFontSize] = ObjectData[index][oTextFontSize];
	UndoBuffer[CurrBufferIndex][uoAttachedVehicle] = ObjectData[index][oAttachedVehicle];
   	UndoBuffer[CurrBufferIndex][uoGroupTask] = group;

	for(new i = 0; i < MAX_MATERIALS; i++)
	{
		UndoBuffer[CurrBufferIndex][uoTexIndex][i] = ObjectData[index][oTexIndex][i];
		UndoBuffer[CurrBufferIndex][uoColorIndex][i] = ObjectData[index][oColorIndex][i];
	}

	format(UndoBuffer[CurrBufferIndex][uoNote], 64, "%s", ObjectData[index][oNote]);
	format(UndoBuffer[CurrBufferIndex][uoObjectText], MAX_TEXT_LENGTH, "%s", ObjectData[index][oObjectText]);
	
	UndoBuffer[CurrBufferIndex][uoIndex] = index;
	UndoBuffer[CurrBufferIndex][uoType] = type;
	
	if(++CurrBufferIndex == MAX_UNDO_BUFFER) CurrBufferIndex = 0;
}

UndoLastAction(lastgroup=0)
{
	if(CurrBufferIndex == 0)
	{
		if(UndoBuffer[MAX_UNDO_BUFFER-1][uoType] == UNDO_TYPE_UNUSED) return 0;
		else CurrBufferIndex = MAX_UNDO_BUFFER;
	}
	
	CurrBufferIndex--;

	// Group deletion is complete
	if(lastgroup > 0 && UndoBuffer[CurrBufferIndex][uoGroupTask] != lastgroup)
	{
		CurrBufferIndex++;
		return 1;
	}
	else
	{
		switch(UndoBuffer[CurrBufferIndex][uoType])
		{
			case UNDO_TYPE_CREATED:
			{
				DeleteDynamicObject(UndoBuffer[CurrBufferIndex][uoIndex]);
				// Grouped event keep undoing
				ClearUndoInfo(CurrBufferIndex);
	            if(UndoBuffer[CurrBufferIndex][uoGroupTask] > 0) UndoLastAction(UndoBuffer[CurrBufferIndex][uoGroupTask]);
				return 1;
			}
			case UNDO_TYPE_EDIT, UNDO_TYPE_DELETED:
			{
				new index = UndoBuffer[CurrBufferIndex][uoIndex];

			   	ObjectData[index][oGroup] = UndoBuffer[CurrBufferIndex][uoGroup];
			   	ObjectData[index][oModel] = UndoBuffer[CurrBufferIndex][uoModel];
			   	ObjectData[index][oX] = UndoBuffer[CurrBufferIndex][uoX];
			   	ObjectData[index][oY] = UndoBuffer[CurrBufferIndex][uoY];
			   	ObjectData[index][oZ] = UndoBuffer[CurrBufferIndex][uoZ];
			   	ObjectData[index][oRX] = UndoBuffer[CurrBufferIndex][uoRX];
			   	ObjectData[index][oRY] = UndoBuffer[CurrBufferIndex][uoRY];
			   	ObjectData[index][oRZ] = UndoBuffer[CurrBufferIndex][uoRZ];
			   	ObjectData[index][oDD] = UndoBuffer[CurrBufferIndex][uoDD];
				ObjectData[index][ousetext] = UndoBuffer[CurrBufferIndex][uousetext];
			   	ObjectData[index][oFontFace] = UndoBuffer[CurrBufferIndex][uoFontFace];
			   	ObjectData[index][oFontSize] = UndoBuffer[CurrBufferIndex][uoFontSize];
			   	ObjectData[index][oFontBold] = UndoBuffer[CurrBufferIndex][uoFontBold];
			   	ObjectData[index][oFontColor] = UndoBuffer[CurrBufferIndex][uoFontColor];
			   	ObjectData[index][oBackColor] = UndoBuffer[CurrBufferIndex][uoBackColor];
			   	ObjectData[index][oAlignment] = UndoBuffer[CurrBufferIndex][uoAlignment];
			   	ObjectData[index][oTextFontSize] = UndoBuffer[CurrBufferIndex][uoTextFontSize];
			   	ObjectData[index][oAttachedVehicle] = UndoBuffer[CurrBufferIndex][uoAttachedVehicle];
			   	format(ObjectData[index][oNote], 64, "%s", UndoBuffer[CurrBufferIndex][uoNote]);

				for(new i = 0; i < MAX_MATERIALS; i++)
				{
					ObjectData[index][oTexIndex][i] = UndoBuffer[CurrBufferIndex][uoTexIndex][i];
					ObjectData[index][oColorIndex][i] = UndoBuffer[CurrBufferIndex][uoColorIndex][i];
				}
				format(ObjectData[index][oObjectText], MAX_TEXT_LENGTH, "%s", UndoBuffer[CurrBufferIndex][uoObjectText]);

				// Rebuild object
			    if(UndoBuffer[CurrBufferIndex][uoType] == UNDO_TYPE_DELETED)
				{
					Iter_Add(Objects, index);
					sqlite_InsertObject(index);
				}
				else DestroyDynamicObject(ObjectData[index][oID]);
				
				// Re-create object
				ObjectData[index][oID] = CreateDynamicObject(ObjectData[index][oModel], ObjectData[index][oX], ObjectData[index][oY], ObjectData[index][oZ], ObjectData[index][oRX], ObjectData[index][oRY], ObjectData[index][oRZ], MapSetting[mVirtualWorld], MapSetting[mInterior], -1, 300.0);

				Streamer_SetFloatData(STREAMER_TYPE_OBJECT, ObjectData[index][oID], E_STREAMER_DRAW_DISTANCE, 300.0);

				// Update the streamer
				foreach(new i : Player)
				{
				    if(IsPlayerInRangeOfPoint(i, 300.0, ObjectData[index][oX], ObjectData[index][oY], ObjectData[index][oZ])) Streamer_Update(i);
				}

				// Update the materials
				UpdateMaterial(index);

				// Update object text
				UpdateObjectText(index);

			   	if(ObjectData[index][oAttachedVehicle] > -1) UpdateAttachedVehicleObject(ObjectData[index][oAttachedVehicle], index, VEHICLE_REATTACH_UPDATE);

	            UpdateObject3DText(index);

	            // Save all data
	            sqlite_UpdateObjectPos(index);
				sqlite_SaveMaterialIndex(index);
				sqlite_SaveColorIndex(index);
				sqlite_SaveAllObjectText(index);

				// Grouped event keep undoing
				ClearUndoInfo(CurrBufferIndex);
	            if(UndoBuffer[CurrBufferIndex][uoGroupTask] > 0) UndoLastAction(UndoBuffer[CurrBufferIndex][uoGroupTask]);
				return 1;
			}
		}
	}
	return 0;
}

ClearAllUndoInfo()
{
	CurrBufferIndex = 0;

	for(new i = 0; i < MAX_UNDO_BUFFER; i++) ClearUndoInfo(i);
	return 1;
}

ClearUndoInfo(index)
{
   	UndoBuffer[index][uoGroup] = 0;
   	UndoBuffer[index][uoModel] = 0;
   	UndoBuffer[index][uoX] = 0.0;
   	UndoBuffer[index][uoY] = 0.0;
   	UndoBuffer[index][uoZ] = 0.0;
   	UndoBuffer[index][uoRX] = 0.0;
   	UndoBuffer[index][uoRY] = 0.0;
   	UndoBuffer[index][uoRZ] = 0.0;
   	UndoBuffer[index][uoDD] = 300.0;
	UndoBuffer[index][uousetext] = 0;
   	UndoBuffer[index][uoFontFace] = 0;
   	UndoBuffer[index][uoFontSize] = 0;
   	UndoBuffer[index][uoFontBold] = 0;
   	UndoBuffer[index][uoFontColor] = 0;
   	UndoBuffer[index][uoBackColor] = 0;
   	UndoBuffer[index][uoAlignment] = 0;
   	UndoBuffer[index][uoTextFontSize] = 20;
   	
	for(new i = 0; i < MAX_MATERIALS; i++)
	{
		UndoBuffer[index][uoTexIndex][i] = 0;
		UndoBuffer[index][uoColorIndex][i] = 0;
	}

	format(UndoBuffer[index][uoObjectText], MAX_TEXT_LENGTH, "None");
	UndoBuffer[index][uoNote][0] = EOS;

	UndoBuffer[index][uoIndex] = 0;
	UndoBuffer[index][uoType] = UNDO_TYPE_UNUSED;
	return 1;
}

YCMD:undo(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Undo last action.");
		return 1;
	}

    MapOpenCheck();
    NoEditingMode(playerid);
	if(UndoLastAction()) SendClientMessage(playerid, STEALTH_GREEN, "Last action has been undone.");
	else SendClientMessage(playerid, STEALTH_YELLOW, "No actions to undo.");
	return 1;
}
