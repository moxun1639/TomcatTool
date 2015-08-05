^F12::
	MsgBox , , 提示, 【确定】添加右键及资源管理器快捷启动`n【Ctrl+Shift+F12】删除快捷启动
	RegWrite, REG_SZ, HKEY_CLASSES_ROOT, Directory\Background\shell\TomcatTool, ,打开 TomcatTool
	RegWrite, REG_SZ, HKEY_CLASSES_ROOT, Directory\Background\shell\TomcatTool, Icon, %A_ScriptFullPath%
	RegWrite, REG_SZ, HKEY_CLASSES_ROOT, Directory\Background\shell\TomcatTool\command, ,%A_ScriptFullPath%
	
	RegWrite, REG_SZ, HKEY_CURRENT_USER, Software\Classes\CLSID\{20150720-0903-0B08-1639-2F9C3D093F69}, LocalizedString, TomcatTool
	RegWrite, REG_SZ, HKEY_CURRENT_USER, Software\Classes\CLSID\{20150720-0903-0B08-1639-2F9C3D093F69}, InfoTip, 双击运行
	RegWrite, REG_SZ, HKEY_CURRENT_USER, Software\Classes\CLSID\{20150720-0903-0B08-1639-2F9C3D093F69}\DefaultIcon, , %A_ScriptFullPath%
	RegWrite, REG_SZ, HKEY_CURRENT_USER, Software\Classes\CLSID\{20150720-0903-0B08-1639-2F9C3D093F69}\Shell\Open\Command, , %A_ScriptFullPath%
	RegWrite, REG_SZ, HKEY_CURRENT_USER, Software\Classes\CLSID\{20150720-0903-0B08-1639-2F9C3D093F69}, System.ItemAuthors, 双击运行TomcatTool
	RegWrite, REG_SZ, HKEY_CURRENT_USER, Software\Classes\CLSID\{20150720-0903-0B08-1639-2F9C3D093F69}, TileInfo, prop:System.ItemAuthors
	RegWrite, REG_SZ, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{20150720-0903-0B08-1639-2F9C3D093F69}
	return

^+F12::
	MsgBox , , 提示, 【确定】删除右键及资源管理器快捷启动`n【Ctrl+F12】添加快捷启动
	RegDelete, HKEY_CLASSES_ROOT, Directory\Background\shell\TomcatTool
	RegDelete, HKEY_CURRENT_USER, Software\Classes\CLSID\{20150720-0903-0B08-1639-2F9C3D093F69}
	RegDelete, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{20150720-0903-0B08-1639-2F9C3D093F69}
	return
