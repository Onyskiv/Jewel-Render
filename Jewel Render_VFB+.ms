/*  
[INFO] 

NAME = Shamballa Jewels
VERSION = 1.0.4
AUTHOR = MastaMan
DEV = 
HELP = help\jwrender.html

[1.0.0]

* First release =

[1.0.1]

* Changed UI


[1.0.2]

* Small bug fixes

[1.0.3]

+ Added: UVW XForm for Jewels

[1.0.4]

+ Added: Ability to add custom reflection objects. Just link it to dummy!

[ABOUT]

This script automate rendering Shamballa Jewels

TIPS:
	Scene (ground, light, cameras),  Jewels and Bracelet (strings, dummies) must be in separate files!
	Scene must be named: [Type]_[Category]_[Size] ex.: B_SBFB_XXL
	Push modifier must be added manually with amount setting to String.
	Dummy  must be named: 1-13, A,B, Lock.
	Jewels must be named: [Name]_[Part] ex.: 7SOSY_C			
	String must be named: String_[Color] ex.: String_12
	For stop render press and hold Esc
	Link objects to dummy, if you want display it in reflections

[SCRIPT]
*/	


try(closeRolloutFloater rJewelRender) catch()
try(destroyDialog _rAddObjects) catch()
global _rAddObjects
global rJewelRender = newRolloutFloater "Shamballa Jewels" 300 900
global _rStep1
global _rStep0


global jewelArray = #()
global bracletArray = #()

global iniFile = @""

fn getScriptInfo s releaseInfo: "" =
(		
	if(releaseInfo != "") do
	(
		r = getINISetting s releaseInfo
		return r
	)
	
	v = getINISetting s "INFO" "VERSION"
	a = getINISetting s "INFO" "AUTHOR"
	n = getINISetting s "INFO" "NAME"
	o = getINISetting s "ABOUT"
	c = getINISetting s "INFO" "DEV"
	h = getINISetting s "INFO" "HELP"
	
	r = for i in (getINISetting s) where i != "ABOUT" and i != "SCRIPT" and i != "COPY" collect i
	
	return #(n, a, v, o, r, c, h)
)

fn parseToLine m = 
(
	if(m.count == 0) do return ""
	
	l = ""				
	for i in m do l += i + "\n"
	return l
)


rollout _rAbout "About" 
(
	label lblName "" 
	label lblVer "" 
	
	label lblAuthor "" height: 30
	label lblCopy ""  height: 30
	button btnHelp "Help" enabled: false
	
	fn getHelp run: false =
	(
		s = getThisScriptFilename()
		i = getScriptInfo s
		szHelp = (getFilenamePath s) + i[7]
		if(doesFileExist szHelp) do btnHelp.enabled = true
			
		if(run) do ShellLaunch szHelp ""
	)
	
	on btnHelp pressed do getHelp run: true
		
	on _rAbout open do
	(		
		i = getScriptInfo (getThisScriptFilename())
			
		lblName.caption = i[1]
		lblAuthor.caption = i[2]
		lblVer.caption = i[3]
		lblCopy.caption = i[6]
		
		getHelp()
	)
)

fn addObjects type: #jewels = 
(
	try(destroyDialog _rAddObjects) catch()
	global szType = type
	global _rAddObjects
	
	rollout _rAddObjects ""
	(		
		MultiListBox lbxAddObjects "" height: 23
		button btnAddObjects "Add" width: 85 across: 2
		button btnClose "Close" width: 85
		
		fn collectItems old: #() empt: false =
		(
			t = old
			c = lbxAddObjects.selection as array
			t2 = for i in c collect lbxAddObjects.items[i]
				
			join t t2
			t = makeUniqueArray t			
			if(empt == true and t[1] != "") do t = join #("") t
			sort t
			return t
		)
		
		on _rAddObjects open do
		(
			objectsArray = #()
			case szType of
			(
				#jewels: 
				(
					_rAddObjects.title = "Jewels"
					objectsArray = jewelArray
				)				
				#dummy: 
				(
					_rAddObjects.title = "Dummy"
					objectsArray = bracletArray
				)
				#bracelet:
				(
					_rAddObjects.title = "Bracelet"
					objectsArray = bracletArray
				)
			)
								
			items = for i in objectsArray where not isGroupMember i and superClassOf i != Shape  collect i.name
			sort items	
			lbxAddObjects.items = items
				
			p = rJewelRender.pos
					
			setDialogPos _rAddObjects [p[1] + 320, p[2] + 25]
		)
		
		on btnClose pressed do try(destroyDialog _rAddObjects) catch()
		
		on btnAddObjects pressed do
		(
			case szType of
			(
				#jewels: 
				(
					t = _rStep1.lbxJewels.items
										
					_rStep1.lbxJewels.items = collectItems old:t
				)
				#dummy:
				(
					t = _rStep1.lbxDummy.items
										
					_rStep1.lbxDummy.items = collectItems old:t empt: true
				)
				#bracelet:
				(
					t = _rStep1.lbxBracelet.items
										
					_rStep1.lbxBracelet.items = collectItems old:t
				)
			)
		)
	)
	
	createDialog _rAddObjects 200 350 modal: true
)

rollout _rStep0  "Path"
(
	group "Studio Path"
	(
		edittext edtStudio "" height:25 readOnly:true 
		button btnStudio "Browse"
	)
	group "Jewels Path"
	(
		edittext edtJewelScene "" height:25 readOnly:true 
		button btnJewelScene "Browse"
	)
	group "Bracelet Path"
	(
		edittext edtBraceletlScene "" height:25 readOnly:true 
		button btnBraceletScene "Browse"
	)
	
	fn disableUI d btn: true =
	(
		for i in _rStep0.controls do i.enabled = d
		for i in _rStep1.controls do i.enabled = d
		_rStep0.btnStudio.enabled = true
		_rStep0.btnJewelScene.enabled = btn
		_rStep0.btnBraceletScene.enabled = btn
	)
	
	on _rStep0 open do
	(
		disableUI false btn: false
	)
	
	on btnStudio pressed do
	(
		f = getOpenFileName caption: "Select Studio" types: "3Ds Max(*.max)|*.max"
		
		if(f != undefined) do
		(						
			resetMaxFile #noPrompt 
			
			loadMaxFile  f useFileUnits: true quiet: true

			edtStudio.text = f

			disableUI false
		)
	)
	
	on btnJewelScene pressed do
	(
		if(maxFileName.count == 0) do return messageBox "Please open studo first please!" title: "Warning!"
		f = getOpenFileName caption: "Select Jewels Scene" types: "3Ds Max(*.max)|*.max"
			
		if(f != undefined) do
		(						
			clearSelection()
			/*  ADD: Save in temp */
						
			mergeMaxFile f #select quiet: true
			jewelArray = selection as array
			hide selection
			
			edtJewelScene.text = f					
		)
	)
	
	on btnBraceletScene pressed do
	(
		if(maxFileName.count == 0) do return messageBox "Please open studo first please!" title: "Warning!"
		f = getOpenFileName caption: "Select Bracelet Scene" types: "3Ds Max(*.max)|*.max"
		
		if(jewelArray.count == 0) do return messageBox "Please add Jewels first!" title: "Warning!"
		
		if(f != undefined) do
		(						
			clearSelection()
		
			mergeMaxFile f #select quiet: true
			bracletArray = selection as array
			hide selection
			
			iniFile = @"c:\temp\jw\"
			makeDir iniFile
			
			saveMaxFile (iniFile + "tmp.max") quiet:true
			
			iniFile += (getFileNameFile f) + ".ini"
			deleteFile iniFile
			
			--getList type: #jewel
			--getList type: #dummy
			--getList type: #bracelet
			
			edtBraceletlScene.text = f
				
			disableUI true
		)
	)
)	


rollout _rStep1  "Settings"
(
	group "Objects Lists"
	(				
		listBox lbxJewels "Jewels List:" height: 9
		button btnAddJewels "Add" width: 90 across: 2
		button btnDelJewels "Del" width: 90
		
		
		progressBar pbSeparate1 "" height: 4
		MultiListBox lbxDummy "Dummy List:" height: 9
		button btnAddDummy "Add" width: 90 across: 2
		button btnDelDummy "Del" width: 90		
		button btnBindDummy "Bind" width: 90 across: 2 offset: [0, 10]
		button btnUnbindDummy "Unbind" width: 90 offset: [0, 10]
		
		
		progressBar pbSeparate2 "" height: 4
		listBox lbxBracelet "Bracelet:" height: 6
		button btnAddBracelet "Add" width: 90 across: 2		
		button btnDelBracelet "Del" width: 90
	)
	
	group "Jewels UVW XForm"
	(
		spinner spnUOffsetMin "U Offset:" range: [-9999, 9999, -1] type: #float fieldWidth: 40 across: 2 align: #left
		spinner spnUOffsetMax "to " range: [-9999, 9999, 1] type: #float fieldWidth: 40 align: #left offset: [-30, 0]
		
		spinner spnVOffsetMin "V Offset:" range: [-9999, 9999, -1] type: #float fieldWidth: 40 across: 2 align: #left
		spinner spnVOffsetMax "to " range: [-9999, 9999, 1] type: #float fieldWidth: 40 align: #left offset: [-30, 0]
	)
	
	
	
	fn disableUI d btn: true =
	(
		for i in _rStep1.controls do i.enabled = d
		--_rStep1.btnStudio.enabled = true
		--_rStep1.btnJewelScene.enabled = btn
		--_rStep1.btnBraceletScene.enabled = btn
	)
	
	fn getJewels = getINISetting iniFile "BIND"
	
	fn getBind i =
	(
		return filterString (getINISetting iniFile "BIND" i) "|"
	)
	
	fn getBracelet =
	(
		return getINISetting iniFile "BRACELET"		
	)
	
	fn getDummies =
	(
		j = getJewels()
		d = #()
		for i in j do join d (getBind i)
		
		d = makeUniqueArray d
		
		return d
	)

	fn checkAdded =
	(
		i1 = lbxDummy.items.count
		i2 = lbxJewels.items.count
		
		if(i1 == 0 or i2 == 0) do
		(
			messageBox "Please add objects!" title: "Warning!"
			return false
		)
		return true
	)
	
	fn deleteItems o items: #() =
	(
		d = for i in items where i != 0 collect o[i]
		
		r = for i in o where (i != undefined and findItem d i == 0) or i == "" collect i
		
		return r
	)
	
	fn getList type: #jewel =
	(
		case type of
		(
			#jewel:
			(
				i = getJewels()
				lbxJewels.items = i
			)
			#dummy:
			(
				j = getJewels()
				
				d = #()
				for i in j do join d (getBind i)
				
				d = makeUniqueArray d
				n = #("")
				join n d
				
				lbxDummy.items = n
			)
		)
	)
	
	on _rStep1 open do
	(
		disableUI false btn: false
	)
		
	on btnAddJewels pressed do
	(
		addObjects()
	)
	
	on btnAddBracelet pressed do
	(									
		addObjects type: #bracelet
		s = lbxBracelet.selection
		
		i = lbxBracelet.items	
		
		for b in i do
		(
			setINISetting iniFile "BRACELET" b "true"
		)		
	)
	
	on btnAddDummy pressed do
	(
		addObjects type: #dummy
	)
	
	on btnDelBracelet pressed do
	(
		o = lbxBracelet.items
		i = lbxBracelet.selection
		
		if(i == 0) do return false
		
		lbxBracelet.items = deleteItems o items: #(i)
		
		delIniSetting iniFile "BRACELET" o[i]
	)
	
	on btnDelJewels pressed do
	(
		o = lbxJewels.items
		i = lbxJewels.selection
		
		if(i == 0) do return false
		
		lbxJewels.items = deleteItems o items: #(i)
		
		delIniSetting iniFile "BIND" o[i]
	)
	
	on btnDelDummy pressed do
	(
		o = lbxDummy.items
		i = lbxDummy.selection as array
			
		lbxDummy.items = deleteItems o items: i
		
		k = getJewels()
		
		for v in k do
		(
			vv = getINISetting iniFile "BIND" v
			
			aa = #()
			aa = filterString vv "|"	
			
			for s in i where s != 0 do
			(
				d = o[s]
				
				del = findItem aa d
				if(del != 0) do deleteItem aa del
				
				print aa
			)
			
			s = ""
			for ss in aa do s += ss + "|"
			
			setINISetting iniFile "BIND" v s
		)
		
		try(lbxDummy.selection = 1) catch()
		
	)
	
	on lbxJewels selected x do
	(
		try(lbxDummy.selection = 1) catch()
		
		j = lbxJewels.selected 
		
		d = getIniSetting iniFile "BIND" j
		d = filterString d "|"
		
		c = lbxDummy.items.count
		s = for i in 1 to c where findItem d lbxDummy.items[i] != 0 collect i
		if(s.count == 0) do s = #(1)
		try(lbxDummy.selection = s)catch()
	)
	
	on btnBindDummy pressed do
	(
		if(not checkAdded()) do return false
		j = lbxJewels.selected 
		
		c = lbxDummy.selection as array
		
		
		if(c.count == 0) do return messageBox "Please add dummy!" title: "Warning!"
		if(c.count == 1 and lbxDummy.items[c[1]] == "") do return false
			
		t = ""
		m = ""
		for i in c where c != 1 do 
		(
			t += lbxDummy.items[i] + "|"
			m += lbxDummy.items[i] + "\n"
		)
				
		setIniSetting iniFile "BIND" j t
		
		
		messageBox ("Bind " + j + " to: \n\n" + m) title: "Binded!"
	)
	
	on btnUnbindDummy pressed do
	(
		j = lbxJewels.selected 
		if(j == undefined or j == "") do return false
		
		q = queryBox ("Do you really want to unbind " + j + " ?") title: "Warning!"
		if(q == true) do setIniSetting iniFile "BIND" j ""
		try(lbxDummy.selection = #(1)) catch()
	)
)

rollout _rStep2  "Render"
(
	global saveRender = ""
	global _RENDER = false
	
	group "Render Size"
	(
		listBox lbxResoluton "Resolutions List:" height: 3
		spinner spnResolutionX "" range:[1, 9999999, 1920] type: #integer align: #right  across: 2
		spinner spnResolutionY "x" range:[1, 9999999, 1200] type: #integer align: #left  offset: [4, 0]
		button btnAddResolution "Add" width: 90 across: 2
		button btnDelResolution "Del" width: 90
	)
	
	group "Save Renders To:"
	(
		edittext edtSaveRender "" height:25 readOnly:true 
		button btnSaveRender "Browse"
	)
	
	group "Debug Mode"
	(
		checkbutton btnDebug "Debug"
	)
	
	button btnRender "Render" height: 35 width: 260
	
	fn SetAsMatte b enable: true =
	(
		for o in b do
		(
			try(setUserProp o "VRay_Matte_Enable" enable)catch()
			try(setUserProp o "VRay_Matte_Alpha" (if(enable) then -1.0 else 1.0))catch()
			try(setUserProp o "VRay_Matte_Shadows" false)catch()
			try(setUserProp o "VRay_Matte_ShadowAlpha" false)catch()
		)
	)
	
	fn disableReflection b enable: true =
	(
		for o in b do
		(
			try(o.secondaryVisibility = enable)catch()	
		)
	)
	
	fn addUVWXform s =
	(	
		for i in s where superClassOf i == geometryClass do
		(
			x = i.modifiers[#uvw_xform]
			if(x == undefined) do 
			(
				x = uvw_xform()
				addModifier i x
			)
			
			iMin = _rStep1.spnUOffsetMin.value
			iMax = _rStep1.spnUOffsetMax.value
			x.U_Offset = random  iMin iMax
			
			
			iMin = _rStep1.spnVOffsetMin.value
			iMax = _rStep1.spnVOffsetMax.value
			x.V_Offset = random  iMin iMax	
		)
	)	

	fn getObjects n = 
	(
		o = #()
		for i in n do
		(
			t = getNodeByName i ignoreCase: false all: false			
			if(t != undefined) do append o t
		)
		
		return o
	)
	
	fn setResolution r =
	(
		s = filterString r "x"
		return [s[1] as integer, s[2] as integer]
	)
	
	fn parseName n =
	(
		n = getFilenameFile n
		s = #()
		s = filterString n "_"
				
		if(s[1] == undefined) do s[1] = ""
		if(s[2] == undefined) do s[2] = ""
								
		return s 	
	)
	
	
	fn renderName type:"" part:"" persp:"" category: "" size: "" stringColor:"" obj: "" componentPos: "" res: "" =
	(
		n = "Bad name for part " + obj + ". Please use type: _S,_C,_L,_A or _B in end of name!"
		case part of
		(
			"S": n = type + "-" + part + "-" + category + "-" + size + "-" + stringColor + "-" + persp + "-" + res
			"C": n = type + "-" + part + "-" + category + "-" + size + "-" + obj + "-" + componentPos + "-" + persp + "-" + res	
			"L": n = type + "-" + part + "-" + category + "-" + size + "-" + obj + "-" + persp + "-" + res
			"A": n = type + "-" + part + "-" + category + "-" + size + "-" + obj + "-" + persp + "-" + res
			"B": n = type + "-" + part + "-" + category + "-" + size + "-" + obj + "-" + persp + "-" + res
		)
		
		return n
	)
	
	fn enablePushMod o enable: true =
	(
		for s in o do
		(
			pushModifer = s.modifiers[#Push] 
			if(pushModifer != undefined) do pushModifer.enabled = enable
		)
	)
	
	fn getByHead s = 
	(
		if(isGroupHead s) do return s.children
		return s
	)
	
	on _rStep2 open do
	(
		i = #("488x305", "744x465", "1920x1200")
		lbxResoluton.items = i
	)
	
	on btnAddResolution pressed do
	(
		i = lbxResoluton.items
		
		append i (spnResolutionX.value as string + "x" + spnResolutionY.value as string)
		
		lbxResoluton.items = i
	)
	
	on btnDelResolution pressed do
	(
		i = lbxResoluton.items
		
		s = lbxResoluton.selection
		
		if(s != 0) do deleteItem i s
		
		lbxResoluton.items = i
	)
	
	on btnSaveRender pressed do
	(
		f = getSavePath initialDir:saveRender
		
		if(f != undefined) do 
		(
			saveRender = f + @"\"
			edtSaveRender.text = saveRender
		)
	)
	
	on btnRender pressed do
	(
		vr = renderers.current
		-- Clear Previous frame
		vr.system_previousRender = 5
		-- Set Render Mask for none
		vr.imageSampler_renderMask_type = 0
				
		clearListener()
		_RENDER = true
		
		Cams = cameras as array
		
		j = _rStep1.getJewels()
		JewelsHeads = getObjects j
		
		b = _rStep1.getBracelet()
		BraceletsHeads = getObjects b
		
		Dummies = _rStep1.getDummies()
		
		tmp = parseName (_rStep0.edtBraceletlScene.text)
		
		-- For file name
		Type = tmp[1]
		Category = tmp[2]
		Size = tmp[3]		
		
		if(Cams.count == 0) do return messageBox "Scene has no cameras!" title: "Warning!"
		if(saveRender.count < 2) do return messageBox "Please choose path for save renders!" title: "Warning!"
		if(JewelsHeads.count == 0) do return messageBox "Jewels and Dummies not binded!" title: "Warning!"
		if(iniFile.count < 2) do messageBox "Please browse Bracelet file!" title: "Warning!"
		if(BraceletsHeads.count == 0) do return messageBox "Please add bracelet!" title: "Warning!"
		if(Type == undefined or Category == undefined or Size == undefined) do return messageBox "Bracelet scene name wrong! Should be:\n[Type]_[Category]_[Size]" title: "Warning!"
				
		disableSceneRedraw()
		-- Render bracelet in 3 views
			
		-- Render Bracelets First!
		Bracelets = #()
				
		Resolutions = lbxResoluton.items
		
		-- Resolutions
		for Resolution in Resolutions do
		(
			-- Cameras
			for Cam in Cams where classOf Cam != TargetObject do
			(
				-- Bracelets
				for BraceletsHead in BraceletsHeads do
				(
					bracelet = getByHead BraceletsHead
					
					unhide bracelet
					select bracelet
															
					-- Enable Push Modifier
					enablePushMod bracelet
									
					n =  renderName type:Type part:"S" persp:Cam.name category: Category size: Size stringColor: ((parseName BraceletsHead.name)[2]) obj: "" componentPos: "" res: Resolution
					if(btnDebug.checked == true) do 
					(
						print (parseName BraceletsHead.name)[2]
						print "----------------"
						print "Bracelet: " + n
						print "Objects:"
						print bracelet
						print "----------------"
					)
					
					n = saveRender + n + ".png"
					
					if(btnDebug.checked == false) do 
					(
						viewport.setCamera Cam
											
						r = (setResolution Resolution)
						renderWidth = r[1]
						renderHeight = r[2]
																												
						max quick render
						
						try(VFBPlus2.SaveImage n)catch(return messageBox "Please install VFB+")
						
						if (keyboard.escPressed) do 
						(
							_RENDER = false
							return enableSceneRedraw()
						)
					)
										
					hide bracelet
					-- Disable Push Modifier
					enablePushMod bracelet enable: false
					
					if(_RENDER == false) do exit
				)
				
				if(_RENDER == false) do exit
			)
			
			if(_RENDER == false) do exit
		)
			
		-- Bracelet						
		bracelet = getByHead BraceletsHeads[1]
		unhide	bracelet
		-- Set Matte
		SetAsMatte bracelet enable: true
		-- Disable Reflection
		disableReflection bracelet enable: false
		-- Disable Push
		enablePushMod bracelet enable: false
		
			-- Resolutions
			for Resolution in Resolutions do
			(	
				-- Cameras 
				for Cam in Cams where classOf Cam != TargetObject do
				(
					-- Jewels
					for JewelsHead in JewelsHeads do
					(
						jewel = getByHead JewelsHead
						
						unhide jewel
						select jewel
					
						-- Get Binded Dummies
						d = _rStep1.getBind JewelsHead.name
						Dummies = getObjects d
						
						-- Set Position And Render
						for Dummie in Dummies do
						(
							-- Set Position And Rotation
							jewel.rotation = Dummie.rotation
							jewel.pos = Dummie.pos
														
							addUVWXform jewel
							
							-- Parts of string, which should be reflected
							dc = Dummie.children
							SetAsMatte (Dummie.children) enable: true
							unhide Dummie.children
							
							n =  renderName type:Type part: ((parseName JewelsHead.name)[2]) persp:Cam.name category: Category size: Size obj: ((parseName JewelsHead.name)[1]) componentPos: Dummie.name res: Resolution
							if(btnDebug.checked == true) do 
							(
								print (parseName JewelsHead.name)[1]
								print "----------------"
								print "Jewel: " + n
								print "Objects:"
								print jewel
								print "Pos: " + Dummie.name
								print "Linked to Dummy:" 
								print dc
								print "----------------"
							)
							
							n = saveRender + n + ".png"
							
							if(btnDebug.checked == false) do 
							(
								viewport.setCamera Cam
											
								r = (setResolution Resolution)
								renderWidth = r[1]
								renderHeight = r[2]
																				
								max quick render
								
								try(VFBPlus2.SaveImage n)catch(return messageBox "Please install VFB+")
								
								if (keyboard.escPressed) do 
								(
									enableSceneRedraw()
									return messageBox "Render caneled!" title: "Warning!"
								)
							)
							
							hide Dummie.children
							
							if(_RENDER == false) do exit
						)
												
						hide jewel	
						
						if(_RENDER == false) do exit						
					)
					
					if(_RENDER == false) do exit
				)

				if(_RENDER == false) do exit				
			)
		
			
			
		hide bracelet
				
		if(btnDebug.checked == true) do actionMan.executeAction 0 "40472"
		
		enableSceneRedraw()
		
		messageBox "Render Done!" title: "Success!"
		shellLaunch saveRender ""
	)
	
)

addRollout _rStep0 rJewelRender rolledUp:false
addRollout _rStep1 rJewelRender rolledUp:true
addRollout _rStep2 rJewelRender rolledUp:true 
addRollout _rAbout rJewelRender rolledUp:true 
