<#
.SYNOPSIS  
    Base classes for working with 1C  
.DESCRIPTION
    Classes 
.PARAMETER 
	Not implemented
.NOTES  
    Name: 			base1cClasses.ps1
    Author: 		Evgeny Alpeyev
    DateCreated: 	01.05.2023        
.EXAMPLE  
    using module ./base1cClasses.ps1
     
Description
------------
 
#>

enum ibOperations {
	DisconnectUsers
	DumpIB
	EnableUsersConnect
	RestoreIB
	DumpCfgToFile
	DumpCfgToFiles
	LoadCfgFromFile
	LoadCfgFromFiles
}

class CmdLineParams {

    [string] $clpCFG = 'CONFIG '
    [string] $clpENT = 'ENTERPRISE '
    [string] $clpOut = '/OUT'
    [string] $clpUsrPass = '/P'
    [string] $clpUsrName = '/N'
    [string] $clpServerBase  = '/S'
    [string] $clpFileBase    = '/F'
	[string] $clpDump = '/DumpIB ' 
    [string] $clpRestore = '/RestoreIB '
    [string] $clpDumpCfg = '/DumpCfg '
    [string] $clpLoadCfg = '/LoadCfg '
    [string] $clpAddInList = '/AddInList '
	[string] $clpUpdateCfg = '/UpdateDBCfg '
	[string] $clpDumpCfgFiles = '/DumpConfigToFiles '
    [string] $clpLoadCfgFiles = '/LoadConfigFromFiles '
    [string] $clpAcceptCode  = '/UC"КодРазрешения" '
    [string] $clpDisStartupMsg  = '/DisableStartupMessages '
    [string] $clpStopUsrRun  = '/C"ЗавершитьРаботуПользователей" '
    [string] $clpEnableUsrRun = '/C"РазрешитьРаботуПользователей" '
	
}

class OneCOperate {

    [string]$vendor = "1С-Софт"
    [string]$arch = "*x86-64*"
    [string]$platformPath
    [string]$space = " "
	[string]$User = "Администратор"
	[string]$Pass
	[string]$connString
	[string]$logFile = "output.txt"
	[string]$dtPath
	[string]$extFile
	[CmdLineParams]$cmdparam = [CmdLineParams]::new()
	
    OneCOperate(){
        
        $plLists = @(Get-WmiObject -Class Win32_Product|where {($_.vendor -like $this.vendor) -and $_.Comments -notlike $this.arch})
        $this.platformPath = $($plLists|Sort InstallDate|Select -Last 1|foreach{$_.InstallLocation}) + 'bin\1cv8.exe'
        
    }

    [void] DumpIB(){
	
        $shellCmd = [shellCommand]::new()
        #disconnect users
        $cmdargs = $this.getArgsString([ibOperations]::DisconnectUsers)
		$shellCmd.cmdexec($this.platformPath,$cmdargs)
		#dump ib
        $cmdargs = $this.getArgsString([ibOperations]::DumpIB)
		$shellCmd.cmdexec($this.platformPath,$cmdargs)
		#enable usesrs connect
        $cmdargs = $this.getArgsString([ibOperations]::EnableUsersConnect)
		$shellCmd.cmdexec($this.platformPath,$cmdargs)

    }

    [void] RestoreIB(){
        
		$shellCmd = [shellCommand]::new()
        #disconnect users
        $cmdargs = $this.getArgsString([ibOperations]::DisconnectUsers)
		$shellCmd.cmdexec($this.platformPath,$cmdargs)
		#restore ib
        $cmdargs = $this.getArgsString([ibOperations]::RestoreIB)
		$shellCmd.cmdexec($this.platformPath,$cmdargs)
		#enable usesrs connect
        $cmdargs = $this.getArgsString([ibOperations]::EnableUsersConnect)
		$shellCmd.cmdexec($this.platformPath,$cmdargs)

    }
    
	[void] DumpCfgToFiles(){
		$shellCmd = [shellCommand]::new()
		#dump cfg to files 
        $cmdargs = $this.getArgsString([ibOperations]::DumpCfgToFiles)
		$shellCmd.cmdexec($this.platformPath,$cmdargs)
    }
	
	[void] DumpCfgToFile(){
		$shellCmd = [shellCommand]::new()
		#dump cfg to files 
        $cmdargs = $this.getArgsString([ibOperations]::DumpCfgToFile)
		$shellCmd.cmdexec($this.platformPath,$cmdargs)
    }
	[void] LoadCfgFromFile(){
		$shellCmd = [shellCommand]::new()
		#dump cfg to files 
        $cmdargs = $this.getArgsString([ibOperations]::LoadCfgFromFile)
		$shellCmd.cmdexec($this.platformPath,$cmdargs)
    }	
    [string] LoadCfgFromFiles([string]$UpdateDB){
		$shellCmd = [shellCommand]::new()
		#restore cfg from files 
        $cmdargs = $this.getArgsString([ibOperations]::LoadCfgFromFiles)
		if ($UpdateDB -eq "update"){
			$cmdargs = $cmdargs + $this.space + $this.cmdparam.clpUpdateCfg
		}		
		$output = $shellCmd.cmdexec($this.platformPath,$cmdargs)
		return $output
    }

	[string] getArgsString([string]$operation){
	    
		$extName = ""
		
		if($this.connString.split("\").count -eq 2){
			$connType =  $this.cmdparam.clpServerBase
		}else {
			$connType = $this.cmdparam.clpFileBase
		}
		
		if(![string]::IsNullOrEmpty($this.extFile)){
		  	$extName = $this.space + '-Extension "' + $this.extFile + '"' + $this.space
		}
		
		$paramString = switch($operation)
				{
					DisconnectUsers{
	        			$this.cmdparam.clpENT + $connType + '"' + $this.connString + '"' + $this.space + $this.cmdparam.clpDisStartupMsg + $this.cmdparam.clpUsrName + '"' + $this.User  + '"' + $this.space + $this.cmdparam.clpUsrPass + '"' + $this.Pass + '"' + $this.space + $this.cmdparam.clpStopUsrRun
					}
					DumpIB{
        				$this.cmdparam.clpCFG + $connType + '"' + $this.connString + '"' + $this.space + $this.cmdparam.clpDisStartupMsg + $this.cmdparam.clpUsrName + '"' + $this.User + '"' + $this.space + $this.cmdparam.clpUsrPass + '"' + $this.Pass + '"' + $this.space + $this.cmdparam.clpAcceptCode + $this.cmdparam.clpDump + $this.dtPath + $this.space + $this.cmdparam.clpOut + $this.space + $this.logFile
					}
					EnableUsersConnect{
						$this.cmdparam.clpENT + $connType + '"' + $this.connString + '"' + $this.space + $this.cmdparam.clpDisStartupMsg + $this.cmdparam.clpUsrName + '"' + $this.User + '"' + $this.space + $this.cmdparam.clpUsrPass + '"' + $this.Pass + '"' + $this.space + $this.cmdparam.clpEnableUsrRun + $this.cmdparam.clpAcceptCode
					}
					RestoreIB{
        				$this.cmdparam.clpCFG + $connType + '"' + $this.connString + '"' + $this.space + $this.cmdparam.clpDisStartupMsg + $this.cmdparam.clpUsrName + '"' + $this.User + '"' + $this.space + $this.cmdparam.clpUsrPass + '"' + $this.Pass + '"' + $this.space + $this.cmdparam.clpAcceptCode + $this.cmdparam.clpRestore + '"' + $this.dtPath + '"' + $extName + $this.cmdparam.clpOut + $this.space + $this.logFile					
					}
					SaveFiles{
					
					}
					DumpCfgToFile{
        				$this.cmdparam.clpCFG + $connType + '"' + $this.connString + '"' + $this.space + $this.cmdparam.clpDisStartupMsg + $this.cmdparam.clpUsrName + '"' + $this.User + '"' + $this.space + $this.cmdparam.clpUsrPass + '"' + $this.Pass + '"' + $this.space + $this.cmdparam.clpAcceptCode + $this.cmdparam.clpDumpCfg + '"' + $this.dtPath + '"' + $extName + $this.cmdparam.clpOut + $this.space + $this.logFile					
					}
					DumpCfgToFiles{
        				$this.cmdparam.clpCFG + $connType + '"' + $this.connString + '"' + $this.space + $this.cmdparam.clpDisStartupMsg + $this.cmdparam.clpUsrName + '"' + $this.User + '"' + $this.space + $this.cmdparam.clpUsrPass + '"' + $this.Pass + '"' + $this.space + $this.cmdparam.clpAcceptCode + $this.cmdparam.clpDumpCfgFiles + '"' + $this.dtPath + '"' + $extName + $this.cmdparam.clpOut + $this.space + $this.logFile					
					}
					LoadCfgFromFile{
        				$this.cmdparam.clpCFG + $connType + '"' + $this.connString + '"' + $this.space + $this.cmdparam.clpDisStartupMsg + $this.cmdparam.clpUsrName + '"' + $this.User + '"' + $this.space + $this.cmdparam.clpUsrPass + '"' + $this.Pass + '"' + $this.space + $this.cmdparam.clpAcceptCode + $this.cmdparam.clpLoadCfg + '"' + $this.dtPath + '"' + $extName + $this.cmdparam.clpOut + $this.space + $this.logFile										
					}
					LoadCfgFromFiles{
        				$this.cmdparam.clpCFG + $connType + '"' + $this.connString + '"' + $this.space + $this.cmdparam.clpDisStartupMsg + $this.cmdparam.clpUsrName + '"' + $this.User + '"' + $this.space + $this.cmdparam.clpUsrPass + '"' + $this.Pass + '"' + $this.space + $this.cmdparam.clpAcceptCode + $this.cmdparam.clpLoadCfgFiles + '"' + $this.dtPath + '"' + $extName + $this.cmdparam.clpOut + $this.space + $this.logFile					

					}
				}

		return $paramString		
	}

}

class shellCommand {

     [string] cmdexec([string]$binPath,[string]$sarg)
	 {
      	$output = "exit without start"
		$process = New-Object System.Diagnostics.Process
        $process.StartInfo.FileName = $binPath
        $process.StartInfo.Arguments = $sarg
        $process.StartInfo.UseShellExecute = $false
        $process.StartInfo.RedirectStandardOutput = $true
		
        if ($process.Start()) {
               $output = $process.StandardOutput.ReadToEnd() -replace"\r\n$",""
#               if ($output){ 
#                 $output -split "`r`n"
#                }
#            	elseif ($output.Contains("`n") ) {
#                 $output -split "`n"
#				 return $output
#                }
         }
		 #else {
         #   $output = "Error of start process"
         #}
        $process.WaitForExit()
		return $output
		
    }
	
	
}