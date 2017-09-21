serverAdress="keombre.carek.eu/gpjp"
name="To be filled"

function sendRequest() {
#Needed to build token and is not installed by default:
{
sudo apt-get install net-tools -y
} &> /dev/null

myToken=$(echo $(sudo dmidecode -t 4 | grep ID | sed 's/.*ID://;s/ //g') \
       $(ifconfig | grep eth1 | awk '{print $NF}' | sed 's/://g') | sha256sum |
  awk '{print $1}')

#Replace all spaces by %20
name="${name//' '/%20}"

request=$serverAdress"/api.php?token="$myToken"&name="$name

echo "My token is: $myToken"
echo "Sending request: $request"
}

sendRequest
