serverAddress="keombre.carek.eu/gpjp"

function sendRequest() {
    #Needed to build token and is not installed by default:
    {
        sudo apt-get install net-tools -y
    } &> /dev/null
    
    myToken=$( echo $( sudo dmidecode -t 4 | grep ID | sed 's/.*ID://;s/ //g' ) | sha256sum | awk '{print $1}' )

    echo "Enter name for this PC:"
    read name
    
    #Replace all spaces by %20
    name="${name//' '/%20}"

    echo "Name is: $name"
    
    request=$serverAddress"/api.php?token="$myToken"&name="$name
    
    echo "My token is: $myToken"
    echo "Sending request: $request"
}

sendRequest
