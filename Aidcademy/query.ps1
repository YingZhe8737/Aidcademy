$conn = New-Object System.Data.SqlClient.SqlConnection("Data Source=(LocalDB)\MSSQLLocalDB;AttachDbFilename=d:\desktop\WAPP-Member\Aidcademy\Aidcademy\App_Data\AidcademyDB.mdf;Integrated Security=True")
$conn.Open()
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE'"
$reader = $cmd.ExecuteReader()
while ($reader.Read()) { Write-Host $reader[0] }
$conn.Close()
