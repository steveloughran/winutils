param(
	$credentialFilePath = "c:\hadoop\singlenodecreds.xml",
	$hadoopHome = "$env:HADOOP_HOME",
	$shellCmd = "`"$env:HADOOP_HOME\bin\hadoop.cmd`""
)

function Start-HadoopShell($message, $credentials)
{
	if($credentials)
	{
		Start-Process cmd.exe -ArgumentList @("/k pushd `"$hadoopHome`" && $shellCmd && title Hadoop Admin Command Line") -Credential $creds
	}
	else
	{
		Start-Process cmd.exe -ArgumentList @("/k pushd `"$hadoopHome`" && $shellCmd && title Hadoop Command Line && echo: && echo $message")
	}
}

if (Test-Path ($credentialFilePath))
{
	$import = Import-Clixml -Path $credentialFilePath
	$username = $import.Username
	try
	{
		$securePassword = $import.Password | ConvertTo-SecureString -ErrorAction Stop
	}
	catch
	{
		$message = "WARNING: Unable to decrypt credentials file for hadoop service user. The same user account used to install hadoop must be used to start the hadoop command shell. Hadoop admin commands will not be available."
	}
	if($securePassword)
	{
		$creds = New-Object System.Management.Automation.PSCredential $username, $securePassword
		Start-HadoopShell -credentials $creds
	}
	else
	{
		Start-HadoopShell -message $message
	}
}
else
{
	Start-HadoopShell -message "WARNING: Credentials file for hadoop service user not found at $credentialFilePath. Hadoop admin commands will not be available."
}