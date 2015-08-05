;version 2.2
;author moxun moxun1639@163.com
;date 2015-7-28
SetTitleMatchMode, 2
#NoTrayIcon
#SingleInstance, force
#ErrorStdOut

appName = TomcatTool V2.2
tomcatNameList = 
tomcatPathList = 

tomcatCounts=0
SetWorkingDir, %A_ScriptDir%

;读取配置文件
IniRead, activeHotKey, tomcat.ini, config, activeHotKey, !c
IniRead, selectAllEnable, tomcat.ini, config, selectAllEnable, false
IniRead, doubleClickStartEnable, tomcat.ini, config, doubleClickStartEnable, false
IniRead, resetTitle, tomcat.ini,  config, resetTitle, false
IniRead, detectJavaProcessWhenStart, tomcat.ini,  config, detectJavaProcessWhenStart, true
IniRead, detectJavaProcessPeriod, tomcat.ini, config, detectJavaProcessPeriod, 1000
IniRead, tomcatInfos, tomcat.ini, tomcats

if activeHotKey <> null
	Hotkey, %activeHotKey%, showToolView

gui, Font, c00FF00 S16

detectJavaProcessSwitchXpos = 20
detectJavaProcessSwitchChecked=
if detectJavaProcessWhenStart = true
	detectJavaProcessSwitchChecked = Checked
if selectAllEnable = true
	detectJavaProcessSwitchXpos=110
toDetect = detectJavaProcessWhenStart

Gui, -MaximizeBox -MinimizeBox ;ToolWindow
Gui, Add, Checkbox, X%detectJavaProcessSwitchXpos% %detectJavaProcessSwitchChecked% vToDetect gSwitchDetectJavaProcess, 检测状态
Gui, Add, Button, X390 Y6 w100 gStartTomcat Default , 启动
Gui, Add, Button, X495 Y6 w100 gGuiEscape, 后台

if selectAllEnable = true
	Gui, Add, Button, X20 Y4 gSelectAllTomcats , 全选

Gui, Font, c0000FF
Gui, Add, ListView, X0 Y52 W600 H296 Grid Multi BackgroundC0DCC0 AltSubmit gTomcatListView, 服务名|状态|路径	;-Hdr 
Loop, Parse, tomcatInfos, `n
{
	StringSplit, tomcatInfo, A_LoopField, =
	tomcatNameList%A_Index% := tomcatInfo1
	tomcatPathList%A_Index% := tomcatInfo2
	LV_Add("", tomcatInfo1, "   -   ", tomcatInfo2)
	++tomcatCounts
}
LV_ModifyCol()
Gui, Font, c405871 underline s12 w60
Gui, Add, Link, X6 Y356 W450 vStatus
Gui, Add, Link, X510 Y356 W40, <a href="%A_WorkingDir%/tomcat.ini">配置</a>
Gui, Add, Text, cBlue X560 Y356 gReloadAPP, 重启
;Gui +Resize

Menu, MyContextMenu, Add, 启动服务, ContextStartService
;Menu, MyContextMenu, Add, 删除服务, ContextDeleteService
;Menu, MyContextMenu, Add, 打开服务路径, ContextOpenServicePath
Menu, MyContextMenu, Add
Menu, MyContextMenu, Add, 打开工具路径, OpenTooPath
Menu, MyContextMenu, Add, 退出, ExitApp

if detectJavaProcessWhenStart = true
{
	SetTimer, detectJavaProcess, %detectJavaProcessPeriod%
	LV_ModifyCol(2, 90)
	Goto, detectJavaProcessWithoutWinActive
}
else
	LV_ModifyCol(2, 0)
GoSub, showToolView
return

SelectAllTomcats:
	LV_Modify(0, "Select")
	return

TomcatListView:
if (A_GuiEvent = "Normal" or A_GuiEvent = "DoubleClick")
{
	LV_GetText(tomcatPath, A_EventInfo, 3)
	GuiControl, Text, Status, 打开 <a href="%tomcatPath%">%tomcatPath%</a>

	if (A_GuiEvent = "DoubleClick")
		if doubleClickStartEnable = true
			Gosub, StartTomcat
}
return

OpenTooPath:
	Run, %A_WorkingDir%
	return

StartTomcat:
	RowNumber = 0
	Loop
	{
		RowNumber := LV_GetNext(RowNumber)
		if not RowNumber
			break
		;LV_GetText(tomcatPath, RowNumber, 2)
		tomcatPath := tomcatPathList%RowNumber%
		launchTomcat(tomcatPath)
	}
	if toDetect
		Gosub, detectJavaProcessWithoutWinActive
	return


GuiContextMenu:
if %A_EventInfo%
	Menu, MyContextMenu, Show, %A_GuiX%, %A_GuiY%

return

ContextStartService:
	GoSub StartTomcat
	return
ContextDeleteService:	
	Loop % LV_GetCount()
	{
		RowNumber := LV_GetNext(RowNumber)
		if not RowNumber
			break
		LV_Delete(RowNumber)
	}
	return
ContextOpenServicePath:
	return
ReloadAPP:
	Reload
	return
GuiEscape:
	Gui, Hide
	return

GuiClose:
	Gui, show, Minimize
	return
ExitApp:
	ExitApp
showToolView:
	Gui, show, W600 H380 Center, %appName%
	return

F1::
	MsgBox , , 关于, TomcatTool`n`nAuthor:`tmoxun`nE-mail:`tmoxun1639@163.com
	return

switchDetectJavaProcess:
Gui, Submit, NoHide
if toDetect
{
	IniWrite, true, tomcat.ini, config, detectJavaProcessWhenStart
	SetTimer, detectJavaProcess, %detectJavaProcessPeriod%
	Gosub, detectJavaProcessWithoutWinActive
	LV_ModifyCol(2, 84)
}
else
{
	LV_ModifyCol(2, 0)
	IniWrite, false, tomcat.ini, config, detectJavaProcessWhenStart
	SetTimer, detectJavaProcess, Off
}
return

detectJavaProcess:
	WinWaitActive, ahk_exe %A_ScriptName%
detectJavaProcessWithoutWinActive:
	javaProcessInfo := getJavaProcessInfo()
	loop, %tomcatCounts%
	{
		LV_GetText(tomcatPath, A_Index, 3)
		tomcatFolderName := getTomcatFolderName(tomcatPath)
		tomcatPid := javaProcessInfo[tomcatFolderName]
		if tomcatPid
			LV_Modify(A_Index, "col" 2, "运行中")
		else
			LV_Modify(A_Index, "col" 2, "未启动")
	}
return

launchTomcat(tomcatPath)
{
	IfExist, %tomcatPath%/bin/catalina.bat
	{
		RunWait, %tomcatPath%/bin/catalina.bat start, %tomcatPath%, hide
		if resetTitle = true
		{
			loop, 3
			{
				javaProcessInfo := getJavaProcessInfo()
				tomcatFolderName := getTomcatFolderName(tomcatPath)
				tomcatPid := javaProcessInfo[tomcatFolderName]
				if tomcatPid
				{
					;WinHide, ahk_pid %tomcatPid%
					tomcatName := tomcatNameList%RowNumber%
					;msgbox, %tomcatName% %tomcatPid%
					WinSetTitle, ahk_pid %tomcatPid%, , %tomcatName% - (%tomcatPath%)
					;WinMove, ahk_pid %tomcatPid%, , 24+12*RowNumber, 68+32*RowNumber
					;WinShow, ahk_pid %tomcatPid%
					break
				}
				sleep 333
			}
		}
	}
}

getTomcatFolderName(tomcatPath)
{
	StringReplace, tomcatPath, tomcatPath, `", , A
	SplitPath, tomcatPath, tomcatFolderName
	return tomcatFolderName
}

#Include JavaProcessInfo.ahk
#Include QuickLaunchReg.ahk
