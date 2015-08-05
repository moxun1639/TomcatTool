getJavaProcessInfo()
{
	javaProcessInfo := {}
	queryResult:=ComObjGet("winmgmts:").ExecQuery("Select CommandLine,Handle from Win32_Process where name ='java.exe'")
	for process in queryResult
	{
		javaPid := process.Handle
		javaCommandLine := process.CommandLine
		StringGetPos, basePos, javaCommandLine, -Dcatalina.base=
		StringGetPos, homePos, javaCommandLine, -Dcatalina.home=
		StringMid, workDir, javaCommandLine, basePos + 17, homePos - basePos - 17
		tomcatFolderName := getTomcatFolderName(workDir)
		javaProcessInfo.Insert(tomcatFolderName, javaPid)
	}		
	return javaProcessInfo
}
